import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/usecases/validate_habit.dart';
import 'package:flutter_test/flutter_test.dart';

/// validateHabit and normalizeHabitDraft (T049, data-model §5.1, FR-025).
void main() {
  HabitDraft draft({
    String name = 'Read',
    HabitKind kind = HabitKind.yesNo,
    HabitSchedule schedule = const HabitSchedule(
      type: ScheduleType.daily,
      target: 1,
    ),
    String? unit,
    List<ReminderTime> reminders = const [],
  }) => HabitDraft(
    name: name,
    iconKey: 'menu_book',
    colorHex: '#2B7ACA',
    kind: kind,
    schedule: schedule,
    startDate: const LocalDate(2026, 10, 21),
    unit: unit,
    reminderTimes: reminders,
  );

  HabitSchedule countSchedule(int target) =>
      HabitSchedule(type: ScheduleType.daily, target: target);

  test('a valid draft has no errors', () {
    expect(validateHabit(draft()), isEmpty);
    expect(
      validateHabit(
        draft(
          kind: HabitKind.count,
          schedule: countSchedule(20),
          unit: 'pages',
        ),
      ),
      isEmpty,
    );
  });

  group('name', () {
    test('trimmed empty → nameRequired', () {
      expect(validateHabit(draft(name: '')), [HabitFieldError.nameRequired]);
      expect(validateHabit(draft(name: '   ')), [HabitFieldError.nameRequired]);
    });

    test('over 40 after trimming → nameTooLong', () {
      expect(validateHabit(draft(name: 'x' * 40)), isEmpty);
      expect(validateHabit(draft(name: '  ${'x' * 40}  ')), isEmpty);
      expect(validateHabit(draft(name: 'x' * 41)), [
        HabitFieldError.nameTooLong,
      ]);
    });
  });

  group('target', () {
    test('yes/no target is forced to 1', () {
      final d = draft(schedule: countSchedule(7));
      expect(validateHabit(d), isEmpty);
      expect(normalizeHabitDraft(d).schedule.target, 1);
    });

    test('count target must be 1–9,999', () {
      for (final t in [1, 20, 9999]) {
        expect(
          validateHabit(
            draft(kind: HabitKind.count, schedule: countSchedule(t)),
          ),
          isEmpty,
          reason: '$t',
        );
      }
      for (final t in [0, -1, 10000]) {
        expect(
          validateHabit(
            draft(kind: HabitKind.count, schedule: countSchedule(t)),
          ),
          [HabitFieldError.targetOutOfRange],
          reason: '$t',
        );
      }
    });
  });

  group('unit', () {
    test('at most 20 characters for count habits', () {
      final count = draft(kind: HabitKind.count, schedule: countSchedule(5));
      expect(validateHabit(count.copyWith(unit: 'u' * 20)), isEmpty);
      expect(validateHabit(count.copyWith(unit: 'u' * 21)), [
        HabitFieldError.unitTooLong,
      ]);
    });

    test('yes/no habits drop the unit; a blank unit is none', () {
      expect(normalizeHabitDraft(draft(unit: 'u' * 30)).unit, isNull);
      expect(validateHabit(draft(unit: 'u' * 30)), isEmpty);
      final count = draft(kind: HabitKind.count, schedule: countSchedule(5));
      expect(normalizeHabitDraft(count.copyWith(unit: '   ')).unit, isNull);
      expect(normalizeHabitDraft(count.copyWith(unit: ' km ')).unit, 'km');
    });
  });

  group('schedule', () {
    test('HAB-02 criterion "Specific days requires at least one weekday"', () {
      const none = HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
      );
      expect(validateHabit(draft(schedule: none)), [
        HabitFieldError.weekdayRequired,
      ]);
      expect(
        validateHabit(draft(schedule: none.copyWith(weekdays: {1, 3, 5}))),
        isEmpty,
      );
      expect(validateHabit(draft(schedule: none.copyWith(weekdays: {0}))), [
        HabitFieldError.weekdayRequired,
      ]);
    });

    test('times per week must be 1–6', () {
      HabitSchedule times(int? n) => HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 1,
        timesPerWeek: n,
      );
      for (final n in [1, 3, 6]) {
        expect(validateHabit(draft(schedule: times(n))), isEmpty, reason: '$n');
      }
      for (final n in [null, 0, 7]) {
        expect(validateHabit(draft(schedule: times(n))), [
          HabitFieldError.timesOutOfRange,
        ], reason: '$n');
      }
    });
  });

  group('reminders', () {
    test('up to 3', () {
      const three = [
        ReminderTime(7, 0),
        ReminderTime(12, 0),
        ReminderTime(21, 0),
      ];
      expect(validateHabit(draft(reminders: three)), isEmpty);
      expect(
        validateHabit(draft(reminders: [...three, const ReminderTime(22, 0)])),
        [HabitFieldError.tooManyReminders],
      );
    });

    test('no duplicates', () {
      expect(
        validateHabit(
          draft(reminders: const [ReminderTime(7, 0), ReminderTime(7, 0)]),
        ),
        [HabitFieldError.duplicateReminder],
      );
    });
  });

  test('editing with a different kind → kindLocked', () {
    final existing = Habit(
      id: 'h',
      name: 'Read',
      iconKey: 'menu_book',
      colorHex: '#2B7ACA',
      kind: HabitKind.yesNo,
      schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
      reminderTimes: const [],
      remindOnlyIfNotDone: true,
      startDate: const LocalDate(2026, 10, 1),
      isArchived: false,
      sortOrder: 0,
      freezesAvailable: 0,
      celebratedMilestones: const {},
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    expect(validateHabit(draft(), existing: existing), isEmpty);
    expect(
      validateHabit(
        draft(kind: HabitKind.count, schedule: countSchedule(5)),
        existing: existing,
      ),
      [HabitFieldError.kindLocked],
    );
  });

  test('several errors come back in form order', () {
    expect(
      validateHabit(
        draft(
          name: '',
          kind: HabitKind.count,
          schedule: const HabitSchedule(
            type: ScheduleType.specificWeekdays,
            target: 0,
          ),
          unit: 'u' * 21,
        ),
      ),
      [
        HabitFieldError.nameRequired,
        HabitFieldError.targetOutOfRange,
        HabitFieldError.unitTooLong,
        HabitFieldError.weekdayRequired,
      ],
    );
  });
}
