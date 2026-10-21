import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_template.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Short localized weekday name, 1 = Monday … 7 = Sunday.
/// 2024-01-01 was a Monday.
String weekdayShort(AppLocalizations l10n, int weekday) =>
    DateFormat.E(l10n.localeName).format(DateTime(2024, 1, weekday));

/// One-letter-ish narrow weekday name for the week strip.
String weekdayNarrow(AppLocalizations l10n, int weekday) =>
    DateFormat.EEEEE(l10n.localeName).format(DateTime(2024, 1, weekday));

/// Full weekday name, for semantics.
String weekdayLong(AppLocalizations l10n, int weekday) =>
    DateFormat.EEEE(l10n.localeName).format(DateTime(2024, 1, weekday));

/// "Daily", "Mon, Wed, Fri", "3× per week · 1 left" (spec US1-6).
String scheduleLabel(AppLocalizations l10n, ScheduleTextData data) =>
    switch (data) {
      DailyText() => l10n.habit_scheduleDaily,
      WeekdaysText(:final weekdays) => [
        for (final d in weekdays) weekdayShort(l10n, d),
      ].join(', '),
      TimesPerWeekText(:final times, :final left) =>
        left == 0
            ? l10n.habit_scheduleTimesPerWeekMet(times)
            : l10n.habit_scheduleTimesPerWeek(times, left),
    };

/// "5 days" or "3 weeks".
String streakLength(AppLocalizations l10n, int count, StreakUnit unit) =>
    switch (unit) {
      StreakUnit.days => l10n.habit_streakDays(count),
      StreakUnit.weeks => l10n.habit_streakWeeks(count),
    };

/// A template's localized name.
String templateName(AppLocalizations l10n, HabitTemplate t) =>
    l10nByKey(l10n, t.nameKey) ?? t.id;

/// A template's localized unit, if it has one.
String? templateUnit(AppLocalizations l10n, HabitTemplate t) =>
    switch (t.unitKey) {
      null => null,
      final key => l10nByKey(l10n, key),
    };

IconData habitIcon(Habit habit) => AppIcons.byKey(habit.iconKey);

Color habitColor(Habit habit) => AppColors.fromHex(habit.colorHex);
