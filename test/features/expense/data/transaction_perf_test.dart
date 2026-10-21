@Tags(['perf'])
library;

import 'dart:math';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_budget_repository.dart';
import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/check_budget_alerts.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';
import 'expense_db_fixture.dart';

/// SC-004 proxy at 10,000 rows (research R15): an in-memory database on the
/// test machine, not a device. Device numbers are recorded in T117.
void main() {
  test('save < 100 ms, month page + ledger < 300 ms, year ledger < 300 ms '
      'with 10,000 transactions', () async {
    final (:x, :cash, :food) = await _seed10k();

    final saves = <int>[];
    for (var i = 0; i < 20; i++) {
      final sw = Stopwatch()..start();
      await x.transactions.create(
        TransactionDraft(
          type: TxnType.expense,
          amountMinor: 1010,
          accountId: cash,
          categoryId: food,
          paymentMode: PaymentMode.cash,
          occurredAt: DateTime.now().toUtc(),
        ),
      );
      saves.add(sw.elapsedMilliseconds);
    }
    saves.sort();
    expect(saves[saves.length ~/ 2], lessThan(100), reason: 'median save');

    final month = TxnQuery(period: MonthPeriod(DateTime(2026, 10)));
    final sw = Stopwatch()..start();
    final page = await x.transactions.watchPage(month, limit: 50).first;
    await x.transactions.watchLedger(month).first;
    expect(
      sw.elapsedMilliseconds,
      lessThan(300),
      reason: 'month first content',
    );
    expect(page, hasLength(50));

    sw.reset();
    final year = await x.transactions
        .watchLedger(TxnQuery(period: YearPeriod(DateTime(2026))))
        .first;
    expect(sw.elapsedMilliseconds, lessThan(300), reason: 'year ledger');
    expect(year.dayTotals.length, greaterThan(300));
  });

  // --- 003-budgets-recurring-reports (T103, SC-004, quickstart §6) ---
  test(
    'save + budget check < 100 ms; EXP-08 overview, year breakdown and '
    'the Trends ledger pair each < 500 ms with 10,000 transactions',
    () async {
      final (:x, :cash, :food) = await _seed10k();
      x.clock.value = DateTime(2026, 10, 14, 10);
      final settings = SettingsRepositoryImpl(
        x.db,
        knownModuleIds: const ['expense'],
      );
      final budgets = DriftBudgetRepository(x.db, x.clock, settings);
      await budgets.create(
        BudgetDraft(
          monthKey: '2026-10',
          categoryId: food,
          limitMinor: 99999999900,
          rollover: true,
        ),
      );
      await budgets.create(
        const BudgetDraft(
          monthKey: '2026-10',
          limitMinor: 99999999900,
          rollover: true,
        ),
      );
      final checker = BudgetAlertChecker(
        budgets,
        FakeBudgetAlertNotifier(),
        FakeNotificationGate(),
        x.clock,
      );

      final saves = <int>[];
      for (var i = 0; i < 20; i++) {
        final sw = Stopwatch()..start();
        final t = await x.transactions.create(
          TransactionDraft(
            type: TxnType.expense,
            amountMinor: 1010,
            accountId: cash,
            categoryId: food,
            paymentMode: PaymentMode.cash,
            occurredAt: DateTime(2026, 10, 14, 9).toUtc(),
          ),
        );
        await checker.check(
          occurredAtUtcMs: t.occurredAt.millisecondsSinceEpoch,
          categoryId: t.categoryId,
          type: t.type,
        );
        saves.add(sw.elapsedMilliseconds);
      }
      saves.sort();
      expect(
        saves[saves.length ~/ 2],
        lessThan(100),
        reason: 'median save + check',
      );

      var sw = Stopwatch()..start();
      final overview = await budgets.watchOverview('2026-10').first;
      expect(
        sw.elapsedMilliseconds,
        lessThan(500),
        reason: 'EXP-08 first emit',
      );
      expect(overview.categories, hasLength(1));

      sw = Stopwatch()..start();
      await x.transactions
          .watchBreakdown(TxnQuery(period: YearPeriod(DateTime(2026))))
          .first;
      expect(sw.elapsedMilliseconds, lessThan(500), reason: 'year breakdown');

      sw = Stopwatch()..start();
      await Future.wait([
        x.transactions
            .watchLedger(TxnQuery(period: YearPeriod(DateTime(2026))))
            .first,
        x.transactions
            .watchLedger(TxnQuery(period: YearPeriod(DateTime(2025))))
            .first,
      ]);
      expect(sw.elapsedMilliseconds, lessThan(500), reason: 'Trends, year');
    },
  );
}

/// A real in-memory database with 10,000 transactions of all three types
/// spread over 2026 (Cash/SBI, Food/Salary).
Future<({ExpenseDb x, String cash, String food})> _seed10k() async {
  final x = await ExpenseDb.open();
  final cash = await x.account('Cash');
  final sbi = await x.account('SBI');
  final food = await x.category('Food');
  final salary = await x.category('Salary', type: CategoryType.income);

  final rnd = Random(7);
  final start = DateTime(2026);
  await x.db.batch((b) {
    for (var i = 0; i < 10000; i++) {
      final type = TxnType.values[i % 3];
      final at = start.add(Duration(minutes: rnd.nextInt(365 * 24 * 60)));
      b.insert(
        x.db.transactions,
        TransactionsCompanion.insert(
          id: 'perf-$i',
          type: type,
          amountMinor: 1 + rnd.nextInt(500000),
          accountId: cash,
          toAccountId: Value(type == TxnType.transfer ? sbi : null),
          categoryId: Value(switch (type) {
            TxnType.expense => food,
            TxnType.income => salary,
            TxnType.transfer => null,
          }),
          paymentMode: PaymentMode.upi,
          note: Value(i.isEven ? 'chai' : null),
          occurredAt: at.toUtc().millisecondsSinceEpoch,
          createdAt: i,
          updatedAt: i,
        ),
      );
    }
  });
  return (x: x, cash: cash, food: food);
}
