import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';

// Budget math (research R5). Pure functions over whole paise; every
// comparison is integer arithmetic, so there is no rounding at any step
// (Constitution III). Months are local calendar months keyed `yyyy-MM`.

final RegExp _monthKey = RegExp(r'^(\d{4})-(\d{2})$');

/// The local month of [local], e.g. `2026-10`.
String monthKeyOf(DateTime local) =>
    '${local.year.toString().padLeft(4, '0')}-'
    '${local.month.toString().padLeft(2, '0')}';

/// Local midnight on the 1st of [monthKey]. Throws [FormatException].
DateTime monthStartLocal(String monthKey) {
  final m = _monthKey.firstMatch(monthKey);
  final month = m == null ? 0 : int.parse(m.group(2)!);
  if (m == null || month < 1 || month > 12) {
    throw FormatException('Invalid month key', monthKey);
  }
  return DateTime(int.parse(m.group(1)!), month);
}

/// The month [months] after (or before, when negative) [monthKey].
String shiftMonthKey(String monthKey, int months) {
  final start = monthStartLocal(monthKey);
  return monthKeyOf(DateTime(start.year, start.month + months));
}

/// `[start, end)` of [monthKey] in UTC ms, from local midnights, so the
/// boundaries follow the device time zone (spec edge case "Month
/// boundaries").
({int startUtcMs, int endUtcMsExclusive}) monthRangeUtc(String monthKey) {
  final start = monthStartLocal(monthKey);
  return (
    startUtcMs: start.toUtc().millisecondsSinceEpoch,
    endUtcMsExclusive: DateTime(
      start.year,
      start.month + 1,
    ).toUtc().millisecondsSinceEpoch,
  );
}

int daysInMonth(String monthKey) {
  final start = monthStartLocal(monthKey);
  return DateTime(start.year, start.month + 1, 0).day;
}

/// Whether [threshold] is reached. Exactly 80% or 100% counts.
bool reaches(
  BudgetThreshold threshold, {
  required int spentMinor,
  required int limitMinor,
}) => switch (threshold) {
  BudgetThreshold.p80 => spentMinor * 100 >= limitMinor * 80,
  BudgetThreshold.p100 => spentMinor >= limitMinor,
};

/// Under 80%, 80–100% (both included), or over 100% (US1 s3).
BudgetLevel levelFor({required int spentMinor, required int limitMinor}) {
  if (spentMinor > limitMinor) return BudgetLevel.over;
  if (reaches(
    BudgetThreshold.p80,
    spentMinor: spentMinor,
    limitMinor: limitMinor,
  )) {
    return BudgetLevel.warning;
  }
  return BudgetLevel.under;
}

/// Whole percent used, rounded down; may exceed 100.
int percentOf({required int spentMinor, required int limitMinor}) =>
    spentMinor * 100 ~/ limitMinor;

MonthPhase monthPhase(String monthKey, DateTime nowLocal) {
  final c = monthKey.compareTo(monthKeyOf(nowLocal));
  return c < 0
      ? MonthPhase.past
      : c == 0
      ? MonthPhase.current
      : MonthPhase.future;
}

/// Days from today to the last day of the month, both included, for the
/// current month; every day of a future month; null for a past month.
int? daysLeftInclusive(String monthKey, DateTime nowLocal) =>
    switch (monthPhase(monthKey, nowLocal)) {
      MonthPhase.past => null,
      MonthPhase.current => daysInMonth(monthKey) - nowLocal.day + 1,
      MonthPhase.future => daysInMonth(monthKey),
    };

/// remaining ÷ days, rounded down to whole paise; null when nothing is
/// left (FR-009) or there are no days (past month).
int? perDayLeft({required int remainingMinor, required int? daysLeft}) =>
    remainingMinor > 0 && daysLeft != null && daysLeft > 0
    ? remainingMinor ~/ daysLeft
    : null;

BudgetStatus buildBudgetStatus({
  required Budget budget,
  required int spentMinor,
  required DateTime nowLocal,
  Category? category,
  bool categoryHidden = false,
}) {
  final limit = budget.limitMinor;
  final remaining = limit - spentMinor;
  final days = daysLeftInclusive(budget.monthKey, nowLocal);
  return BudgetStatus(
    budget: budget,
    category: category,
    categoryHidden: categoryHidden,
    spentMinor: spentMinor,
    remainingMinor: remaining,
    percent: percentOf(spentMinor: spentMinor, limitMinor: limit),
    level: levelFor(spentMinor: spentMinor, limitMinor: limit),
    monthPhase: monthPhase(budget.monthKey, nowLocal),
    daysLeft: days,
    perDayLeftMinor: perDayLeft(remainingMinor: remaining, daysLeft: days),
  );
}
