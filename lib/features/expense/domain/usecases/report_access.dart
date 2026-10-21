import 'package:dailytrack/core/utils/period.dart';

/// EXP-11 tabs, in display order.
enum ReportTab { overview, categories, trends, accounts }

/// Whether [tab] for [period] needs the `advancedReports` unlock
/// (clarification Q1, FR-039). Free: Overview and Categories for the
/// current or previous local month, or a week that overlaps either of them.
/// Everything else (Trends, Accounts, Year, Custom, older or future months
/// and weeks) is advanced. Pure Dart.
bool requiresAdvanced(ReportTab tab, Period period, DateTime now) {
  if (tab == ReportTab.trends || tab == ReportTab.accounts) return true;
  final current = MonthPeriod(now.toLocal());
  final previous = current.previous();
  return switch (period) {
    MonthPeriod() => period != current && period != previous,
    WeekPeriod() =>
      !(period.startLocal.isBefore(current.endLocalExclusive) &&
          period.endLocalExclusive.isAfter(previous.startLocal)),
    // Day is not offered in EXP-11; Year and Custom are always advanced.
    SingleDayPeriod() || YearPeriod() || CustomPeriod() => true,
  };
}
