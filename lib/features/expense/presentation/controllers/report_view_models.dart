import 'dart:math' as math;

import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_view_models.freezed.dart';

// EXP-11 view models (research R12): plain, ready-to-draw data built in
// pure Dart from the ledger and the breakdown, so chart widgets only map
// them to fl_chart and do no arithmetic, sorting or grouping. Money stays
// in whole paise; percents are whole numbers rounded half up.

/// `n / d` rounded half up (d > 0), for whole-number percents.
int _roundHalfUp(int n, int d) {
  final q = (2 * n + d) / (2 * d);
  return q.floor();
}

int _percent(int part, int whole) =>
    whole == 0 ? 0 : _roundHalfUp(part * 100, whole);

/// The smallest 1, 2, 5 × 10ⁿ at or above [v] (at least 1): a chart axis
/// maximum.
int niceCeil(int v) {
  if (v <= 1) return 1;
  var p = 1;
  while (p * 10 < v) {
    p *= 10;
  }
  for (final f in [1, 2, 5, 10]) {
    if (f * p >= v) return f * p;
  }
  return 10 * p;
}

@freezed
abstract class TopCategory with _$TopCategory {
  const factory({
    required String categoryId,
    required int amountMinor,

    /// Share of the period's expense.
    required int sharePercent,
    Category? category,
  }) = _TopCategory;
}

/// EXP-11 Overview (US4 s2).
@freezed
abstract class OverviewVm with _$OverviewVm {
  const factory({
    required int incomeMinor,
    required int expenseMinor,
    required int netMinor,

    /// net ÷ income; null ("—") when income is 0.
    int? savingsRatePercent,

    /// expense ÷ days so far (current period) or all days (past); null for
    /// a period that has not started.
    int? avgDailySpendMinor,
    @Default(<TopCategory>[]) List<TopCategory> top,
  }) = _OverviewVm;
}

OverviewVm buildOverview({
  required PeriodLedger ledger,
  required ExpenseBreakdown breakdown,
  required Period period,
  required DateTime now,
  required Map<String, Category> categories,
}) {
  final income = ledger.incomeMinor;
  final expense = ledger.expenseMinor;
  final net = income - expense;
  final today = DateTime(now.year, now.month, now.day);
  final int? days;
  if (period.startLocal.isAfter(today)) {
    days = null;
  } else {
    final end = period.endLocalExclusive.isAfter(today)
        ? DateTime(today.year, today.month, today.day + 1)
        : period.endLocalExclusive;
    days = _dayCount(period.startLocal, end);
  }
  final sorted = breakdown.byCategory.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return OverviewVm(
    incomeMinor: income,
    expenseMinor: expense,
    netMinor: net,
    savingsRatePercent: income == 0 ? null : _roundHalfUp(net * 100, income),
    avgDailySpendMinor: days == null || days == 0 ? null : expense ~/ days,
    top: [
      for (final e in sorted.take(3))
        TopCategory(
          categoryId: e.key,
          category: categories[e.key],
          amountMinor: e.value,
          sharePercent: _percent(e.value, breakdown.totalExpenseMinor),
        ),
    ],
  );
}

/// Calendar days in `[start, end)` of local midnights (DST-safe).
int _dayCount(DateTime start, DateTime end) => DateTime.utc(
  end.year,
  end.month,
  end.day,
).difference(DateTime.utc(start.year, start.month, start.day)).inDays;

/// The [DonutSlice.key] of the merged "Other" slice.
const String donutOtherKey = '_other';

@freezed
abstract class DonutSlice with _$DonutSlice {
  const factory({
    /// The category id, or [donutOtherKey].
    required String key,
    required int amountMinor,
    required int percent,
    Category? category,

    /// Categories merged into "Other"; empty for a single category.
    @Default(<String>[]) List<String> memberIds,
  }) = _DonutSlice;

  const new _();

  bool get isOther => key == donutOtherKey;

  /// Category ids whose transactions this slice lists when selected.
  List<String> get categoryIds => isOther ? memberIds : [key];
}

/// EXP-11 Categories (US4 s3).
@freezed
abstract class DonutVm with _$DonutVm {
  const factory({
    required int totalMinor,
    @Default(<DonutSlice>[]) List<DonutSlice> slices,
  }) = _DonutVm;
}

/// Slices under 2% merge into "Other" only when there are more than 8.
DonutVm buildDonut({
  required ExpenseBreakdown breakdown,
  required Map<String, Category> categories,
}) {
  final total = breakdown.totalExpenseMinor;
  final sorted = breakdown.byCategory.entries.where((e) => e.value > 0).toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.compareTo(b.key);
    });
  final small = sorted.length > 8
      ? [
          for (final e in sorted)
            if (e.value * 100 < total * 2) e,
        ]
      : const <MapEntry<String, int>>[];
  final kept = [
    for (final e in sorted)
      if (!small.contains(e)) e,
  ];
  final otherAmount = small.fold(0, (s, e) => s + e.value);
  return DonutVm(
    totalMinor: total,
    slices: [
      for (final e in kept)
        DonutSlice(
          key: e.key,
          category: categories[e.key],
          amountMinor: e.value,
          percent: _percent(e.value, total),
        ),
      if (small.isNotEmpty)
        DonutSlice(
          key: donutOtherKey,
          amountMinor: otherAmount,
          percent: _percent(otherAmount, total),
          memberIds: [for (final e in small) e.key],
        ),
    ],
  );
}

enum TrendGranularity { day, month }

@freezed
abstract class TrendPoint with _$TrendPoint {
  /// [x] is the day (or month) index from the period's start.
  const factory({required int x, required int yMinor}) = _TrendPoint;
}

/// EXP-11 Trends (US5 s3): the period and the previous one of the same
/// length, aligned by index.
@freezed
abstract class TrendVm with _$TrendVm {
  const factory({
    required TrendGranularity granularity,
    required List<TrendPoint> current,
    required List<TrendPoint> previous,
    required int maxYMinor,
    required int currentTotalMinor,
    required int previousTotalMinor,

    /// Local start of the current period, for axis labels.
    required DateTime startLocal,
  }) = _TrendVm;
}

/// The comparison period for Trends: the previous week, month or year, or
/// for a custom range the preceding range of the same number of days.
Period previousForTrend(Period period) => switch (period) {
  CustomPeriod() => CustomPeriod(
    DateTime(
      period.startLocal.year,
      period.startLocal.month,
      period.startLocal.day -
          _dayCount(period.startLocal, period.endLocalExclusive),
    ),
    DateTime(
      period.startLocal.year,
      period.startLocal.month,
      period.startLocal.day - 1,
    ),
  ),
  _ => period.previous()!,
};

List<TrendPoint> _points(PeriodLedger ledger, Period period) {
  if (period is YearPeriod) {
    final sums = List<int>.filled(12, 0);
    for (final MapEntry(:key, :value) in ledger.dayTotals.entries) {
      final d = DateKeys.parse(key);
      if (d.year == period.startLocal.year) {
        sums[d.month - 1] += value.expenseMinor;
      }
    }
    return [for (var m = 0; m < 12; m++) TrendPoint(x: m, yMinor: sums[m])];
  }
  final n = _dayCount(period.startLocal, period.endLocalExclusive);
  final s = period.startLocal;
  return [
    for (var i = 0; i < n; i++)
      TrendPoint(
        x: i,
        yMinor:
            ledger
                .dayTotals[DateKeys.fromLocal(
                  DateTime(s.year, s.month, s.day + i),
                )]
                ?.expenseMinor ??
            0,
      ),
  ];
}

TrendVm buildTrend({
  required PeriodLedger current,
  required PeriodLedger previous,
  required Period period,
  required Period previousPeriod,
}) {
  final now = _points(current, period);
  final before = _points(previous, previousPeriod);
  final peak = [...now, ...before].fold(0, (m, p) => math.max(m, p.yMinor));
  return TrendVm(
    granularity: period is YearPeriod
        ? TrendGranularity.month
        : TrendGranularity.day,
    current: now,
    previous: before,
    maxYMinor: niceCeil(peak),
    currentTotalMinor: current.expenseMinor,
    previousTotalMinor: previous.expenseMinor,
    startLocal: period.startLocal,
  );
}

@freezed
abstract class BarItem with _$BarItem {
  /// One bar: an account (by account) or a payment mode (by mode).
  const factory({
    required int amountMinor,
    Account? account,
    String? accountId,
    PaymentMode? mode,
  }) = _BarItem;
}

/// EXP-11 Accounts (US5 s4).
@freezed
abstract class BarsVm with _$BarsVm {
  const factory({
    required List<BarItem> byAccount,
    required List<BarItem> byPaymentMode,
    required int maxYMinor,
  }) = _BarsVm;
}

BarsVm buildBars({
  required ExpenseBreakdown breakdown,
  required Map<String, Account> accounts,
}) {
  final byAccount = breakdown.byAccount.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final byMode = breakdown.byPaymentMode.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final peak = [
    ...breakdown.byAccount.values,
    ...breakdown.byPaymentMode.values,
  ].fold(0, math.max);
  return BarsVm(
    byAccount: [
      for (final e in byAccount)
        BarItem(
          accountId: e.key,
          account: accounts[e.key],
          amountMinor: e.value,
        ),
    ],
    byPaymentMode: [
      for (final e in byMode) BarItem(mode: e.key, amountMinor: e.value),
    ],
    maxYMinor: niceCeil(peak),
  );
}
