import 'dart:math';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// `watchBreakdown` (feature 003 research R11): expense totals by category,
/// account and payment mode, built from the same predicate as the ledger,
/// so every total equals the EXP-01 summary strip.
void main() {
  late ExpenseDb x;
  late String cash;
  late String sbi;
  late String food;
  late String travel;
  late String salary;

  setUp(() async {
    x = await ExpenseDb.open();
    cash = await x.account('Cash');
    sbi = await x.account('SBI', type: AccountType.bank);
    food = await x.category('Food');
    travel = await x.category('Travel');
    salary = await x.category('Salary', type: CategoryType.income);
  });

  TxnQuery month(int m) => TxnQuery(period: MonthPeriod(DateTime(2026, m)));

  test('groups October expenses by category, account and payment mode; '
      'income, transfers and deleted rows are excluded', () async {
    await x.add(account: cash, category: food, amount: 20000);
    await x.add(
      account: sbi,
      category: food,
      amount: 5000,
      mode: PaymentMode.upi,
      at: DateTime(2026, 10, 3, 9),
    );
    await x.add(
      account: sbi,
      category: travel,
      amount: 70000,
      mode: PaymentMode.card,
      at: DateTime(2026, 10, 31, 23, 59),
    );
    await x.add(
      account: cash,
      category: salary,
      amount: 9900000,
      type: TxnType.income,
    );
    await x.add(
      account: cash,
      toAccount: sbi,
      amount: 100000,
      type: TxnType.transfer,
    );
    final deleted = await x.add(account: cash, category: food, amount: 123);
    await x.transactions.softDelete(deleted.id);
    // Another month.
    await x.add(
      account: cash,
      category: food,
      amount: 777,
      at: DateTime(2026, 11),
    );

    final b = await x.transactions.watchBreakdown(month(10)).first;
    expect(b.byCategory, {food: 25000, travel: 70000});
    expect(b.byAccount, {cash: 20000, sbi: 75000});
    expect(b.byPaymentMode, {
      PaymentMode.cash: 20000,
      PaymentMode.upi: 5000,
      PaymentMode.card: 70000,
    });
    expect(b.totalExpenseMinor, 95000);
  });

  test(
    'every grouping sums to the ledger expense for each period kind',
    () async {
      final rnd = Random(3);
      const modes = PaymentMode.values;
      for (var i = 0; i < 120; i++) {
        final type = TxnType.values[i % 3];
        await x.add(
          account: i.isEven ? cash : sbi,
          toAccount: type == TxnType.transfer ? (i.isEven ? sbi : cash) : null,
          category: switch (type) {
            TxnType.expense => i % 4 == 0 ? food : travel,
            TxnType.income => salary,
            TxnType.transfer => null,
          },
          type: type,
          mode: modes[i % modes.length],
          amount: 1 + rnd.nextInt(90000),
          at: DateTime(2026, 9).add(Duration(hours: rnd.nextInt(24 * 90))),
        );
      }
      final now = DateTime(2026, 10, 14);
      final periods = <Period>[
        SingleDayPeriod(now),
        WeekPeriod(now, firstDayOfWeek: 1),
        MonthPeriod(now),
        YearPeriod(now),
        CustomPeriod(DateTime(2026, 9, 10), DateTime(2026, 11, 2)),
      ];
      for (final p in periods) {
        final q = TxnQuery(period: p);
        final ledger = await x.transactions.watchLedger(q).first;
        final b = await x.transactions.watchBreakdown(q).first;
        int sum(Iterable<int> v) => v.fold(0, (s, e) => s + e);
        expect(b.totalExpenseMinor, ledger.expenseMinor, reason: '$p');
        expect(sum(b.byCategory.values), ledger.expenseMinor, reason: '$p');
        expect(sum(b.byAccount.values), ledger.expenseMinor, reason: '$p');
        expect(sum(b.byPaymentMode.values), ledger.expenseMinor, reason: '$p');
      }
    },
  );

  test('re-emits after an insert', () async {
    final values = <int>[];
    final sub = x.transactions
        .watchBreakdown(month(10))
        .listen((b) => values.add(b.totalExpenseMinor));
    addTearDown(sub.cancel);
    await pumpEventQueue();
    await x.add(account: cash, category: food, amount: 4500);
    await pumpEventQueue();
    expect(values, [0, 4500]);
  });

  test(
    'a year breakdown at 10,000 rows emits first in < 500 ms',
    tags: ['perf'],
    () async {
      final rnd = Random(7);
      await x.db.batch((b) {
        for (var i = 0; i < 10000; i++) {
          b.insert(
            x.db.transactions,
            TransactionsCompanion.insert(
              id: 'perf-$i',
              type: TxnType.expense,
              amountMinor: 1 + rnd.nextInt(500000),
              accountId: i.isEven ? cash : sbi,
              categoryId: Value(i % 3 == 0 ? food : travel),
              paymentMode: PaymentMode.values[i % 5],
              occurredAt: DateTime(2026)
                  .add(Duration(minutes: rnd.nextInt(365 * 24 * 60)))
                  .toUtc()
                  .millisecondsSinceEpoch,
              createdAt: i,
              updatedAt: i,
            ),
          );
        }
      });
      final sw = Stopwatch()..start();
      final b = await x.transactions
          .watchBreakdown(TxnQuery(period: YearPeriod(DateTime(2026))))
          .first;
      sw.stop();
      expect(b.byCategory.keys, unorderedEquals([food, travel]));
      expect(sw.elapsedMilliseconds, lessThan(500));
    },
  );
}
