import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-11 view-model builders (T083, T093, research R12): pure, whole
/// paise, ready to draw.
void main() {
  Category cat(String id, {int order = 0}) => Category(
    id: id,
    name: id,
    type: CategoryType.expense,
    iconKey: 'category',
    colorHex: '#0F766E',
    isDefault: false,
    isHidden: false,
    sortOrder: order,
  );

  Account acct(String id) => Account(
    id: id,
    name: id,
    type: AccountType.cash,
    openingBalanceMinor: 0,
    iconKey: 'wallet',
    colorHex: '#0F766E',
    isArchived: false,
    sortOrder: 0,
  );

  final october = MonthPeriod(DateTime(2026, 10));
  final now = DateTime(2026, 10, 14, 10);

  group('buildOverview', () {
    ExpenseBreakdown breakdown(Map<String, int> byCategory) => ExpenseBreakdown(
      byCategory: byCategory,
      totalExpenseMinor: byCategory.values.fold(0, (s, v) => s + v),
    );

    test('net, savings rate (half up), and the top 3 with shares', () {
      final vm = buildOverview(
        ledger: const PeriodLedger(incomeMinor: 3000000, expenseMinor: 1240000),
        breakdown: breakdown({
          'food': 500000,
          'rent': 600000,
          'fuel': 100000,
          'fun': 40000,
        }),
        period: october,
        now: now,
        categories: {
          for (final id in ['food', 'rent', 'fuel', 'fun']) id: cat(id),
        },
      );
      expect(vm.incomeMinor, 3000000);
      expect(vm.expenseMinor, 1240000);
      expect(vm.netMinor, 1760000);
      expect(vm.savingsRatePercent, 59, reason: '58.67% rounds half up');
      expect(vm.top.map((t) => (t.categoryId, t.amountMinor, t.sharePercent)), [
        ('rent', 600000, 48),
        ('food', 500000, 40),
        ('fuel', 100000, 8),
      ]);
      expect(vm.top.first.category?.id, 'rent');
    });

    test(
      'savings rate is "—" (null) when income is 0, and may be negative',
      () {
        final none = buildOverview(
          ledger: const PeriodLedger(expenseMinor: 100),
          breakdown: breakdown({'food': 100}),
          period: october,
          now: now,
          categories: const {},
        );
        expect(none.savingsRatePercent, isNull);
        final negative = buildOverview(
          ledger: const PeriodLedger(incomeMinor: 1000, expenseMinor: 1500),
          breakdown: breakdown({'food': 1500}),
          period: october,
          now: now,
          categories: const {},
        );
        expect(negative.savingsRatePercent, -50);
      },
    );

    test('average daily spend: elapsed days of the current period, all days '
        'of a past one, null for a future one', () {
      PeriodLedger ledger(int e) => PeriodLedger(expenseMinor: e);
      final current = buildOverview(
        ledger: ledger(140000),
        breakdown: breakdown({'food': 140000}),
        period: october,
        now: now,
        categories: const {},
      );
      expect(current.avgDailySpendMinor, 10000, reason: '₹1,400 over 14 days');
      final past = buildOverview(
        ledger: ledger(300000),
        breakdown: breakdown({'food': 300000}),
        period: MonthPeriod(DateTime(2026, 9)),
        now: now,
        categories: const {},
      );
      expect(past.avgDailySpendMinor, 10000, reason: '30 days');
      final future = buildOverview(
        ledger: ledger(0),
        breakdown: breakdown(const {}),
        period: MonthPeriod(DateTime(2026, 11)),
        now: now,
        categories: const {},
      );
      expect(future.avgDailySpendMinor, isNull);
      expect(future.top, isEmpty);
    });
  });

  group('buildDonut', () {
    test('sorted descending; percents sum to 100 within rounding', () {
      final vm = buildDonut(
        breakdown: const ExpenseBreakdown(
          byCategory: {'a': 100, 'b': 300, 'c': 200},
          totalExpenseMinor: 600,
        ),
        categories: {
          for (final id in ['a', 'b', 'c']) id: cat(id),
        },
      );
      expect(vm.totalMinor, 600);
      expect(vm.slices.map((s) => s.key), ['b', 'c', 'a']);
      expect(vm.slices.map((s) => s.percent), [50, 33, 17]);
      final sum = vm.slices.fold(0, (s, x) => s + x.percent);
      expect(sum, inInclusiveRange(99, 101));
    });

    test('more than 8 slices: those under 2% merge into "Other", which '
        'carries its members', () {
      final by = <String, int>{
        for (var i = 0; i < 8; i++) 'big$i': 1200,
        'tiny1': 10,
        'tiny2': 20,
      };
      final vm = buildDonut(
        breakdown: ExpenseBreakdown(
          byCategory: by,
          totalExpenseMinor: by.values.fold(0, (s, v) => s + v),
        ),
        categories: {for (final id in by.keys) id: cat(id)},
      );
      expect(vm.slices, hasLength(9));
      final other = vm.slices.last;
      expect(other.isOther, isTrue);
      expect(other.memberIds, unorderedEquals(['tiny1', 'tiny2']));
      expect(other.amountMinor, 30);
      expect(other.key, donutOtherKey);
    });

    test('8 or fewer slices never merge, even tiny ones', () {
      final vm = buildDonut(
        breakdown: const ExpenseBreakdown(
          byCategory: {'a': 10000, 'b': 1},
          totalExpenseMinor: 10001,
        ),
        categories: {'a': cat('a'), 'b': cat('b')},
      );
      expect(vm.slices.map((s) => s.key), ['a', 'b']);
      expect(vm.slices.any((s) => s.isOther), isFalse);
    });

    test('an empty breakdown gives no slices', () {
      final vm = buildDonut(
        breakdown: const ExpenseBreakdown(),
        categories: const {},
      );
      expect(vm.slices, isEmpty);
      expect(vm.totalMinor, 0);
    });
  });

  group('buildTrend', () {
    PeriodLedger days(Map<DateTime, int> expense) => PeriodLedger(
      expenseMinor: expense.values.fold(0, (s, v) => s + v),
      dayTotals: {
        for (final MapEntry(:key, :value) in expense.entries)
          DateKeys.fromLocal(key): DayTotal(expenseMinor: value),
      },
    );

    test(
      'month: one point per day, the previous month aligned by day index',
      () {
        final vm = buildTrend(
          current: days({DateTime(2026, 10): 500, DateTime(2026, 10, 31): 700}),
          previous: days({DateTime(2026, 9): 100, DateTime(2026, 9, 30): 900}),
          period: october,
          previousPeriod: october.previous(),
        );
        expect(vm.granularity, TrendGranularity.day);
        expect(vm.current, hasLength(31));
        expect(vm.previous, hasLength(30));
        expect(vm.current.first.yMinor, 500);
        expect(vm.current.last.yMinor, 700);
        expect(vm.previous.first.yMinor, 100);
        expect(vm.previous.last, const TrendPoint(x: 29, yMinor: 900));
        expect(vm.currentTotalMinor, 1200);
        expect(vm.previousTotalMinor, 1000);
        expect(vm.maxYMinor, 1000, reason: 'nice ceiling of 900');
      },
    );

    test('week and custom are daily; custom compares the preceding range of '
        'the same length', () {
      final week = WeekPeriod(DateTime(2026, 10, 14), firstDayOfWeek: 1);
      final w = buildTrend(
        current: days({DateTime(2026, 10, 12): 300}),
        previous: days({DateTime(2026, 10, 5): 100}),
        period: week,
        previousPeriod: week.previous(),
      );
      expect(w.current, hasLength(7));
      expect(w.current.first.yMinor, 300);
      expect(w.previous.first.yMinor, 100);

      final custom = CustomPeriod(DateTime(2026, 10), DateTime(2026, 10, 10));
      final prev = previousForTrend(custom);
      expect(prev.startLocal, DateTime(2026, 9, 21));
      expect(prev.endLocalExclusive, DateTime(2026, 10));
    });

    test('year: 12 monthly points summed from the day totals', () {
      final year = YearPeriod(DateTime(2026));
      final vm = buildTrend(
        current: days({
          DateTime(2026, 1, 3): 100,
          DateTime(2026, 1, 20): 200,
          DateTime(2026, 12, 31): 50,
        }),
        previous: days({DateTime(2025, 2): 400}),
        period: year,
        previousPeriod: year.previous(),
      );
      expect(vm.granularity, TrendGranularity.month);
      expect(vm.current, hasLength(12));
      expect(vm.current.first.yMinor, 300);
      expect(vm.current.last.yMinor, 50);
      expect(vm.previous[1].yMinor, 400);
      expect(vm.maxYMinor, 500);
    });

    test('nice ceilings', () {
      expect(
        [
          for (final v in [0, 1, 7, 10, 11, 199, 250, 999, 1001]) niceCeil(v),
        ],
        [1, 1, 10, 10, 20, 200, 500, 1000, 2000],
      );
    });
  });

  test('buildBars: by account and by payment mode, sorted, summing to the '
      'total', () {
    final vm = buildBars(
      breakdown: const ExpenseBreakdown(
        byAccount: {'cash': 200, 'sbi': 700},
        byPaymentMode: {PaymentMode.upi: 600, PaymentMode.cash: 300},
        totalExpenseMinor: 900,
      ),
      accounts: {'cash': acct('cash'), 'sbi': acct('sbi')},
    );
    expect(vm.byAccount.map((b) => (b.account?.id, b.amountMinor)), [
      ('sbi', 700),
      ('cash', 200),
    ]);
    expect(vm.byPaymentMode.map((b) => (b.mode, b.amountMinor)), [
      (PaymentMode.upi, 600),
      (PaymentMode.cash, 300),
    ]);
    int sum(List<BarItem> items) => items.fold(0, (s, b) => s + b.amountMinor);
    expect(sum(vm.byAccount), 900);
    expect(sum(vm.byPaymentMode), 900);
    expect(vm.maxYMinor, 1000);
  });
}
