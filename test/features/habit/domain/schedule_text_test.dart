import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/templates.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// scheduleText (T050) and the templates (T055, research R16).
void main() {
  group('scheduleText', () {
    test('daily → Daily', () {
      expect(
        scheduleText(const HabitSchedule(type: ScheduleType.daily, target: 1)),
        const DailyText(),
      );
    });

    test('Mon/Wed/Fri in week order for Monday and Sunday starts', () {
      const s = HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {5, 1, 3},
      );
      expect(scheduleText(s), const WeekdaysText([1, 3, 5]));
      const withSunday = HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {7, 1, 6},
      );
      expect(scheduleText(withSunday), const WeekdaysText([1, 6, 7]));
      expect(
        scheduleText(withSunday, firstDayOfWeek: 7),
        const WeekdaysText([7, 1, 6]),
      );
      expect(
        scheduleText(withSunday, firstDayOfWeek: 6),
        const WeekdaysText([6, 7, 1]),
      );
    });

    test('all 7 weekdays → Daily', () {
      const s = HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {1, 2, 3, 4, 5, 6, 7},
      );
      expect(scheduleText(s), const DailyText());
    });

    test('3× per week with 2 done → 1 left; never below 0', () {
      const s = HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 1,
        timesPerWeek: 3,
      );
      expect(
        scheduleText(s, doneThisWeek: 2),
        const TimesPerWeekText(3, left: 1),
      );
      expect(scheduleText(s), const TimesPerWeekText(3, left: 3));
      expect(
        scheduleText(s, doneThisWeek: 5),
        const TimesPerWeekText(3, left: 0),
      );
    });

    test('equality', () {
      expect(const WeekdaysText([1, 3]), isNot(const WeekdaysText([1, 4])));
      expect(const WeekdaysText([1]), isNot(const WeekdaysText([1, 2])));
      expect(
        const TimesPerWeekText(3, left: 1).hashCode,
        const TimesPerWeekText(3, left: 1).hashCode,
      );
      expect(const DailyText().hashCode, const DailyText().hashCode);
    });
  });

  group('templates (FR-022)', () {
    test('six daily templates in the spec order', () {
      expect(
        [for (final t in habitTemplates) t.id],
        ['drinkWater', 'read', 'walk', 'meditate', 'wakeUpEarly', 'study'],
      );
    });

    test('Read is a count habit of 20 pages (spec US1)', () {
      final read = habitTemplateById('read')!;
      expect(
        (read.kind, read.target, read.unitKey),
        (HabitKind.count, 20, 'habit_unit_pages'),
      );
      expect(habitTemplateById('wakeUpEarly')!.kind, HabitKind.yesNo);
      expect(habitTemplateById('nope'), isNull);
      expect(habitTemplateById(null), isNull);
    });

    test('icons, colors, and strings come from the shared sets', () {
      final palette = {for (final c in AppColors.palette) AppColors.toHex(c)};
      for (final code in ['en', 'hi', 'gu']) {
        final l10n = lookupAppLocalizations(Locale(code));
        for (final t in habitTemplates) {
          expect(AppIcons.isKnown(t.iconKey), isTrue, reason: t.iconKey);
          expect(palette, contains(t.colorHex), reason: t.id);
          expect(l10nByKey(l10n, t.nameKey), isNotNull, reason: t.nameKey);
          if (t.unitKey case final u?) {
            expect(l10nByKey(l10n, u), isNotNull, reason: u);
          }
        }
      }
    });
  });
}
