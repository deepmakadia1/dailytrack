import 'package:dailytrack/core/notifications/notification_ids.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/planned_reminder.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/reminders/plan_reminders.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:flutter_test/flutter_test.dart';

/// planReminders and reminder ids (T063, research R10, FR-038, FR-039).
/// 2026-10-19 is a Monday; "now" defaults to Wednesday 21 at 06:00.
void main() {
  const daily = HabitSchedule(type: ScheduleType.daily, target: 1);

  Habit habit({
    HabitSchedule schedule = daily,
    List<ReminderTime> times = const [ReminderTime(7, 0)],
    bool onlyIfNotDone = true,
    String start = '2026-10-01',
  }) => Habit(
    id: 'h1',
    name: 'Read',
    iconKey: 'menu_book',
    colorHex: '#2B7ACA',
    kind: HabitKind.yesNo,
    schedule: schedule,
    reminderTimes: times,
    remindOnlyIfNotDone: onlyIfNotDone,
    startDate: LocalDate.fromKey(start),
    isArchived: false,
    sortOrder: 0,
    freezesAvailable: 0,
    celebratedMilestones: const {},
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  List<PlannedReminder> plan(
    Habit h, {
    DateTime? now,
    bool doneToday = false,
    bool weekTargetMet = false,
    int firstDayOfWeek = 1,
  }) => planReminders(
    h,
    now: now ?? DateTime(2026, 10, 21, 6),
    doneToday: doneToday,
    weekTargetMet: weekTargetMet,
    firstDayOfWeek: firstDayOfWeek,
  );

  group('daily habit, reminder at 07:00', () {
    test('at 06:00, not done → today 07:00, repeating daily', () {
      final p = plan(habit()).single;
      expect(p.firstAt, DateTime(2026, 10, 21, 7));
      expect(p.repeat, ReminderRepeat.daily);
      expect(p.id, reminderIdFor('h1', 0, 0));
    });

    test('at 08:00 → tomorrow 07:00', () {
      final p = plan(habit(), now: DateTime(2026, 10, 21, 8)).single;
      expect(p.firstAt, DateTime(2026, 10, 22, 7));
    });

    test('exactly at 07:00 → tomorrow (the time has come)', () {
      final p = plan(habit(), now: DateTime(2026, 10, 21, 7)).single;
      expect(p.firstAt, DateTime(2026, 10, 22, 7));
    });

    test('at the end of the month and year the first fire rolls over', () {
      expect(
        plan(habit(), now: DateTime(2026, 10, 31, 9)).single.firstAt,
        DateTime(2026, 11, 1, 7),
      );
      expect(
        plan(habit(), now: DateTime(2026, 12, 31, 23, 59)).single.firstAt,
        DateTime(2027, 1, 1, 7),
      );
    });
  });

  group('HAB-02 criterion "Remind only if not done suppresses the '
      'notification when today\'s entry already meets the target"', () {
    test('done today, flag on → first fire tomorrow 07:00', () {
      final p = plan(habit(), doneToday: true).single;
      expect(p.firstAt, DateTime(2026, 10, 22, 7));
    });

    test('done today, flag off → today 07:00 (US4-4)', () {
      final p = plan(habit(onlyIfNotDone: false), doneToday: true).single;
      expect(p.firstAt, DateTime(2026, 10, 21, 7));
    });

    test("unchecking today brings back today's later reminder (US4-3)", () {
      final h = habit(times: const [ReminderTime(7, 0), ReminderTime(21, 0)]);
      final noon = DateTime(2026, 10, 21, 12);
      final done = plan(h, now: noon, doneToday: true);
      final undone = plan(h, now: noon);
      expect(done[1].firstAt, DateTime(2026, 10, 22, 21));
      expect(undone[1].firstAt, DateTime(2026, 10, 21, 21));
      expect(undone[0].firstAt, DateTime(2026, 10, 22, 7), reason: 'past');
    });
  });

  group('specific days (Mon/Thu)', () {
    final monThu = habit(
      schedule: const HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {4, 1},
      ),
      times: const [ReminderTime(21, 30), ReminderTime(7, 0)],
    );

    test('one weekly notification per time per weekday, on the next '
        'matching day', () {
      final p = plan(monThu);
      expect(p, hasLength(4));
      expect({for (final r in p) r.repeat}, {ReminderRepeat.weekly});
      // Times are sorted: index 0 = 07:00, index 1 = 21:30.
      expect(
        [for (final r in p) (r.id, r.firstAt)],
        [
          (reminderIdFor('h1', 0, 1), DateTime(2026, 10, 26, 7)),
          (reminderIdFor('h1', 0, 4), DateTime(2026, 10, 22, 7)),
          (reminderIdFor('h1', 1, 1), DateTime(2026, 10, 26, 21, 30)),
          (reminderIdFor('h1', 1, 4), DateTime(2026, 10, 22, 21, 30)),
        ],
      );
      for (final r in p) {
        expect(r.firstAt.weekday, anyOf(DateTime.monday, DateTime.thursday));
      }
    });

    test('done on a Monday skips to next Monday', () {
      final monday = DateTime(2026, 10, 19, 6);
      final p = plan(monThu, now: monday, doneToday: true);
      expect(p[0].firstAt, DateTime(2026, 10, 26, 7));
      final notDone = plan(monThu, now: monday);
      expect(notDone[0].firstAt, DateTime(2026, 10, 19, 7));
    });
  });

  group('times per week', () {
    final threeTimes = habit(
      schedule: const HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 1,
        timesPerWeek: 3,
      ),
    );

    test('not met → daily from today', () {
      final p = plan(threeTimes).single;
      expect(
        (p.firstAt, p.repeat),
        (DateTime(2026, 10, 21, 7), ReminderRepeat.daily),
      );
    });

    test('week target met → the first day of next week (Monday start)', () {
      expect(
        plan(threeTimes, weekTargetMet: true).single.firstAt,
        DateTime(2026, 10, 26, 7),
      );
    });

    test('week target met → the first day of next week (Sunday start)', () {
      expect(
        plan(threeTimes, weekTargetMet: true, firstDayOfWeek: 7).single.firstAt,
        DateTime(2026, 10, 25, 7),
      );
    });

    test('met but the flag is off → today', () {
      final h = threeTimes.copyWith(remindOnlyIfNotDone: false);
      expect(
        plan(h, weekTargetMet: true).single.firstAt,
        DateTime(2026, 10, 21, 7),
      );
    });
  });

  test('a future start date → first fire on or after it', () {
    expect(
      plan(habit(start: '2026-10-30')).single.firstAt,
      DateTime(2026, 10, 30, 7),
    );
    final mondays = habit(
      start: '2026-10-30',
      schedule: const HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {1},
      ),
    );
    expect(plan(mondays).single.firstAt, DateTime(2026, 11, 2, 7));
  });

  test('no reminders → nothing planned', () {
    expect(plan(habit(times: const [])), isEmpty);
  });

  group('ids', () {
    test('stable: same input, same ids', () {
      expect(plan(habit())[0].id, plan(habit())[0].id);
      expect(reminderIdFor('h1', 2, 7), stableNotificationId('habit:h1:2:7'));
    });

    test('reminderIdsFor lists 24 distinct ids covering every plan', () {
      final ids = reminderIdsFor('h1');
      expect(ids, hasLength(24));
      expect(ids.toSet(), hasLength(24));
      final allDays = habit(
        schedule: const HabitSchedule(
          type: ScheduleType.specificWeekdays,
          target: 1,
          weekdays: {1, 2, 3, 4, 5, 6},
        ),
        times: const [
          ReminderTime(6, 0),
          ReminderTime(7, 0),
          ReminderTime(8, 0),
        ],
      );
      for (final p in [...plan(allDays), ...plan(habit())]) {
        expect(ids, contains(p.id));
      }
      expect(reminderIdsFor('h2').toSet().intersection(ids.toSet()), isEmpty);
    });
  });
}
