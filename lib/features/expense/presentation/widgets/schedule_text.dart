import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:intl/intl.dart';

/// The English ordinal category of [day] (`st`, `nd`, `rd`, `th`), the
/// select key of `expense_everyMonthOn`; hi and gu ignore it.
String ordinalSuffix(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) return 'th';
  return switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
}

/// A schedule in words ("Every month on 5th"), from ARB with placeholders
/// (FR-046). Used by EXP-02's Repeat section and EXP-10 rows.
String scheduleText(AppLocalizations l10n, ScheduleDescription d) {
  final locale = l10n.localeName;
  return switch (d.frequency) {
    Frequency.daily => l10n.expense_everyDay,
    // 1 Jan 2024 was a Monday, so day [weekday] has that weekday.
    Frequency.weekly => l10n.expense_everyWeekOn(
      DateFormat.EEEE(locale).format(DateTime(2024, 1, d.weekday)),
    ),
    Frequency.monthly => l10n.expense_everyMonthOn(d.day, ordinalSuffix(d.day)),
    // A leap year, so 29 Feb can be named.
    Frequency.yearly => l10n.expense_everyYearOn(
      DateFormat('d MMM', locale).format(DateTime(2024, d.month, d.day)),
    ),
  };
}

/// A frequency chip label.
String frequencyLabel(AppLocalizations l10n, Frequency f) => switch (f) {
  Frequency.daily => l10n.expense_freqDaily,
  Frequency.weekly => l10n.expense_freqWeekly,
  Frequency.monthly => l10n.expense_freqMonthly,
  Frequency.yearly => l10n.expense_freqYearly,
};
