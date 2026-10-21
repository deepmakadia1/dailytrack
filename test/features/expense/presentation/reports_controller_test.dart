import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/report_access.dart';
import 'package:dailytrack/features/expense/presentation/controllers/reports_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../fakes.dart';

/// EXP-11 controller (T084, T096) over fake repositories and a fake gate.
/// "Now" is 14 Oct 2026 10:00.
void main() {
  late ExpenseFakes f;
  late FakeFeatureGate gate;
  late ProviderContainer c;

  /// Expenses, income and a transfer across September and October.
  ExpenseFakes seeded() {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi', type: AccountType.bank)
      ..addTransaction(
        amount: 500000,
        category: 'rent',
        at: DateTime(2026, 10, 5, 9),
      )
      ..addTransaction(
        amount: 25000,
        category: 'food',
        at: DateTime(2026, 10, 13, 13),
      )
      ..addTransaction(
        amount: 12000,
        category: 'food',
        account: 'sbi',
        mode: PaymentMode.card,
        at: DateTime(2026, 10, 14, 8),
      )
      ..addTransaction(
        amount: 9000000,
        category: 'income_salary',
        type: TxnType.income,
        at: DateTime(2026, 10, 1, 10),
      )
      ..addTransaction(
        amount: 100000,
        type: TxnType.transfer,
        toAccount: 'sbi',
        at: DateTime(2026, 10, 2),
      )
      ..addTransaction(
        amount: 30000,
        category: 'food',
        at: DateTime(2026, 9, 20, 9),
      )
      ..addTransaction(
        amount: 700,
        category: 'fuel',
        at: DateTime(2025, 12, 31, 23),
      );
    return f;
  }

  setUp(() {
    f = seeded();
    gate = FakeFeatureGate();
    c = ProviderContainer(
      overrides: [...f.overrides, featureGateProvider.overrideWithValue(gate)],
    );
    addTearDown(c.dispose);
    c.listen(reportsControllerProvider, (_, _) {});
  });

  Future<ReportsState> settle() async {
    for (var i = 0; i < 5; i++) {
      await pumpEventQueue();
    }
    final state = c.read(reportsControllerProvider);
    return state;
  }

  ReportsController ctrl() => c.read(reportsControllerProvider.notifier);

  test(
    'defaults to the current month and the Overview tab, unlocked rules',
    () async {
      final s = await settle();
      expect(s.period, MonthPeriod(DateTime(2026, 10)));
      expect(s.tab, ReportTab.overview);
      expect(s.locked, isFalse);
      expect(s.data.value!.hasTransactions, isTrue);
    },
  );

  group('EXP-11 criterion "Chart totals match the EXP-01 summary strip for the '
      'same period"', () {
    final now = DateTime(2026, 10, 14);
    final periods = <Period>[
      MonthPeriod(now),
      WeekPeriod(now, firstDayOfWeek: 1),
      YearPeriod(now),
      CustomPeriod(DateTime(2026, 9, 15), DateTime(2026, 10, 14)),
    ];
    for (final p in periods) {
      test('${p.runtimeType}', () async {
        gate.set(FeatureKey.advancedReports, unlocked: true);
        await settle();
        ctrl().setPeriod(p);
        final s = await settle();
        final ledger = await f.transactions
            .watchLedger(TxnQuery(period: p))
            .first;
        final vm = s.data.value!;
        expect(vm.overview.incomeMinor, ledger.incomeMinor);
        expect(vm.overview.expenseMinor, ledger.expenseMinor);
        expect(vm.overview.netMinor, ledger.netMinor);
        expect(vm.donut.totalMinor, ledger.expenseMinor);
        int sum(Iterable<int> v) => v.fold(0, (a, b) => a + b);
        expect(
          sum(vm.donut.slices.map((s) => s.amountMinor)),
          ledger.expenseMinor,
        );
        expect(
          sum(vm.bars.byAccount.map((b) => b.amountMinor)),
          ledger.expenseMinor,
        );
        expect(
          sum(vm.bars.byPaymentMode.map((b) => b.amountMinor)),
          ledger.expenseMinor,
        );

        ctrl().setTab(ReportTab.trends);
        final t = await settle();
        expect(t.data.value!.trend!.currentTotalMinor, ledger.expenseMinor);
        expect(
          sum(t.data.value!.trend!.current.map((x) => x.yMinor)),
          ledger.expenseMinor,
        );
      });
    }
  });

  test('transfers are excluded from every figure (US4 s6)', () async {
    final s = await settle();
    expect(s.data.value!.overview.expenseMinor, 537000);
    expect(s.data.value!.overview.incomeMinor, 9000000);
  });

  test(
    'selectSlice lists that category, newest first; again clears it',
    () async {
      await settle();
      ctrl().selectSlice('food');
      var s = await settle();
      expect(s.selectedKey, 'food');
      expect(s.selected.map((v) => v.transaction.amountMinor), [12000, 25000]);
      ctrl().selectSlice('food');
      s = await settle();
      expect(s.selectedKey, isNull);
      expect(s.selected, isEmpty);
    },
  );

  test('refresh reloads, and data follows new transactions', () async {
    await settle();
    f.addTransaction(
      amount: 1000,
      category: 'food',
      at: DateTime(2026, 10, 14, 9),
    );
    var s = await settle();
    expect(s.data.value!.overview.expenseMinor, 538000);
    await ctrl().refresh();
    s = await settle();
    expect(s.data.value!.overview.expenseMinor, 538000);
  });

  group('locked (FR-039, FR-040)', () {
    test(
      'Trends and Accounts are locked without the unlock and load no data',
      () async {
        await settle();
        ctrl().setTab(ReportTab.trends);
        var s = await settle();
        expect(s.locked, isTrue);
        expect(s.data.isLoading, isTrue);
        ctrl().setTab(ReportTab.accounts);
        s = await settle();
        expect(s.locked, isTrue);
      },
    );

    test(
      'an older month is locked on every tab; the previous month is free',
      () async {
        await settle();
        ctrl().setPeriod(MonthPeriod(DateTime(2026, 9)));
        expect((await settle()).locked, isFalse);
        ctrl().setPeriod(MonthPeriod(DateTime(2026, 8)));
        expect((await settle()).locked, isTrue);
        ctrl().setPeriod(YearPeriod(DateTime(2026)));
        expect((await settle()).locked, isTrue);
      },
    );

    test(
      'the gate flipping unlocks and relocks without leaving (US5 s8)',
      () async {
        await settle();
        ctrl().setTab(ReportTab.trends);
        expect((await settle()).locked, isTrue);
        gate.set(FeatureKey.advancedReports, unlocked: true);
        var s = await settle();
        expect(s.locked, isFalse);
        expect(s.data.value!.trend, isNotNull);
        gate.set(FeatureKey.advancedReports, unlocked: false);
        s = await settle();
        expect(s.locked, isTrue);
        expect(
          s.isTabLocked(ReportTab.overview, DateTime(2026, 10, 14)),
          isFalse,
        );
      },
    );
  });

  test(
    'an empty period has no transactions; a load error is reported',
    () async {
      await settle();
      ctrl().setPeriod(MonthPeriod(DateTime(2026, 11)));
      gate.set(FeatureKey.advancedReports, unlocked: true);
      var s = await settle();
      expect(s.data.value!.hasTransactions, isFalse);
      f.world.failWatch = StateError('db');
      ctrl().retry();
      s = await settle();
      expect(s.data.hasError, isTrue);
    },
  );
}
