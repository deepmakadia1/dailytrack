import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/habit/data/reminders/local_habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// LocalHabitReminderScheduler (T064, research R10, R11, FR-038–FR-043).
/// "Now" is Wednesday 2026-10-21 at 06:00; 2026-10-19 is a Monday.
void main() {
  late HabitFakes f;
  late FakeNotificationService service;
  late FakeSettingsRepository settings;
  late LocalHabitReminderScheduler scheduler;

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 6)));
    service = FakeNotificationService();
    settings = FakeSettingsRepository();
    scheduler = LocalHabitReminderScheduler(
      service: service,
      habits: f.habits,
      entries: f.entries,
      settings: settings,
      clock: f.clock,
      l10n: () => lookupAppLocalizations(const Locale('en')),
    );
  });

  String withReminders(
    List<ReminderTime> times, {
    HabitSchedule schedule = const HabitSchedule(
      type: ScheduleType.daily,
      target: 1,
    ),
    String name = 'Read',
  }) => f.addHabit(name, reminders: times, schedule: schedule).id;

  test('reconcile cancels all 24 ids, then schedules the plan', () async {
    final id = withReminders(const [ReminderTime(7, 0), ReminderTime(21, 0)]);
    await scheduler.reconcile(id);
    expect(service.cancelled, reminderIdsFor(id));
    expect(service.scheduled.keys, {
      reminderIdFor(id, 0, 0),
      reminderIdFor(id, 1, 0),
    });
  });

  test('SC-005: saving 3 times leaves no duplicates', () async {
    final id = withReminders(const [ReminderTime(7, 0)]);
    for (var i = 0; i < 3; i++) {
      await scheduler.reconcile(id);
    }
    expect(service.scheduled, hasLength(1));
  });

  test('a removed reminder slot is cancelled (US4-2)', () async {
    final id = withReminders(const [ReminderTime(7, 0), ReminderTime(21, 0)]);
    await scheduler.reconcile(id);
    final h = (await f.habits.byId(id))!;
    f.world.habits[id] = h.copyWith(reminderTimes: const [ReminderTime(7, 0)]);
    await scheduler.reconcile(id);
    expect(service.scheduled.keys, {reminderIdFor(id, 0, 0)});
    expect(service.cancelled, contains(reminderIdFor(id, 1, 0)));
  });

  test('HAB-02 criterion "Reminders fire at the set local time": the first '
      'fire keeps the wall-clock time; repeat follows the schedule', () async {
    final daily = withReminders(const [ReminderTime(7, 30)]);
    final mwf = withReminders(
      const [ReminderTime(21, 0)],
      schedule: const HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {1, 3, 5},
      ),
    );
    await scheduler.reconcileAll();
    final d = service.scheduled[reminderIdFor(daily, 0, 0)]!;
    expect((d.firstAt.hour, d.firstAt.minute), (7, 30));
    expect(d.firstAt, DateTime(2026, 10, 21, 7, 30));
    expect(d.repeat, RepeatInterval.daily);
    final wed = service.scheduled[reminderIdFor(mwf, 0, 3)]!;
    expect(wed.firstAt, DateTime(2026, 10, 21, 21));
    expect(wed.repeat, RepeatInterval.weekly);
    expect(service.scheduled[reminderIdFor(mwf, 0, 1)]!.firstAt.weekday, 1);
  });

  test('HAB-02 criterion "Remind only if not done suppresses the '
      'notification when today\'s entry already meets the target"', () async {
    final id = withReminders(const [ReminderTime(21, 0)]);
    f.setDay(id, '2026-10-21');
    await scheduler.reconcile(id);
    expect(
      service.scheduled[reminderIdFor(id, 0, 0)]!.firstAt,
      DateTime(2026, 10, 22, 21),
    );
    // Unchecking today brings tonight's reminder back (US4-3).
    f.setDay(id, '2026-10-21', value: 0);
    await scheduler.reconcile(id);
    expect(
      service.scheduled[reminderIdFor(id, 0, 0)]!.firstAt,
      DateTime(2026, 10, 21, 21),
    );
  });

  test(
    'a met "times per week" target moves the first fire to next week',
    () async {
      final id = withReminders(
        const [ReminderTime(7, 0)],
        schedule: const HabitSchedule(
          type: ScheduleType.timesPerWeek,
          target: 1,
          timesPerWeek: 2,
        ),
      );
      f
        ..setDay(id, '2026-10-19')
        ..setDay(id, '2026-10-20');
      await scheduler.reconcile(id);
      expect(
        service.scheduled[reminderIdFor(id, 0, 0)]!.firstAt,
        DateTime(2026, 10, 26, 7),
      );
    },
  );

  test('a count habit is done only at its target', () async {
    final id = f
        .addHabit(
          'Water',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
          reminders: const [ReminderTime(21, 0)],
        )
        .id;
    f.setDay(id, '2026-10-21', value: 5);
    await scheduler.reconcile(id);
    expect(
      service.scheduled[reminderIdFor(id, 0, 0)]!.firstAt.day,
      21,
      reason: 'not done yet, so tonight still reminds',
    );
  });

  test('exact follows canScheduleExact', () async {
    final id = withReminders(const [ReminderTime(7, 0)]);
    await scheduler.reconcile(id);
    expect(service.scheduled.values.single.exact, isTrue);
    expect(await scheduler.exactAlarmsAllowed(), isTrue);
    service.exactAllowed = false;
    await scheduler.reconcile(id);
    expect(service.scheduled.values.single.exact, isFalse);
    expect(await scheduler.exactAlarmsAllowed(), isFalse);
  });

  group('nothing is scheduled', () {
    test('when the notifications switch is off', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(notificationsEnabled: false),
      );
      scheduler = LocalHabitReminderScheduler(
        service: service,
        habits: f.habits,
        entries: f.entries,
        settings: settings,
        clock: f.clock,
        l10n: () => lookupAppLocalizations(const Locale('en')),
      );
      final id = withReminders(const [ReminderTime(7, 0)]);
      await scheduler.reconcile(id);
      expect(service.scheduled, isEmpty);
      expect(service.cancelled, reminderIdsFor(id), reason: 'stops old ones');
    });

    test('when "Habit reminders" is off', () async {
      final id = withReminders(const [ReminderTime(7, 0)]);
      await scheduler.reconcile(id);
      await settings.setHabitRemindersEnabled(enabled: false);
      await scheduler.reconcileAll();
      expect(service.scheduled, isEmpty);
    });

    test('when the OS blocks notifications', () async {
      service.allowed = false;
      final id = withReminders(const [ReminderTime(7, 0)]);
      await scheduler.reconcile(id);
      expect(service.scheduled, isEmpty);
    });

    test(
      'when the time zone cannot be read; existing ones are left alone',
      () async {
        final id = withReminders(const [ReminderTime(7, 0)]);
        await scheduler.reconcile(id);
        final before = {...service.scheduled};
        service
          ..zoneResolvable = false
          ..cancelled.clear();
        await scheduler.reconcile(id);
        await scheduler.reconcileAll();
        expect(service.cancelled, isEmpty);
        expect(service.scheduled, before);
      },
    );

    test('for an archived or unknown habit (its ids are cancelled)', () async {
      final id = withReminders(const [ReminderTime(7, 0)]);
      await scheduler.reconcile(id);
      await f.habits.archive(id);
      await scheduler.reconcile(id);
      expect(service.scheduled, isEmpty);
      await scheduler.reconcile('nope');
      expect(service.cancelled, containsAll(reminderIdsFor('nope')));
    });
  });

  test('reconcileAll covers every active habit only', () async {
    final a = withReminders(const [ReminderTime(7, 0)], name: 'A');
    final b = withReminders(const [ReminderTime(8, 0)], name: 'B');
    final archived = f.addHabit(
      'C',
      reminders: const [ReminderTime(9, 0)],
      archived: true,
    );
    await scheduler.reconcileAll();
    expect(service.scheduled.keys, {
      reminderIdFor(a, 0, 0),
      reminderIdFor(b, 0, 0),
    });
    expect(
      service.scheduled.keys,
      isNot(contains(reminderIdFor(archived.id, 0, 0))),
    );
  });

  test('cancel and cancelAll cancel every id', () async {
    final a = withReminders(const [ReminderTime(7, 0)], name: 'A');
    final archived = f.addHabit('B', archived: true);
    await scheduler.reconcileAll();
    await scheduler.cancel(a);
    expect(service.scheduled, isEmpty);
    service.cancelled.clear();
    await scheduler.cancelAll();
    expect(service.cancelled, [
      ...reminderIdsFor(a),
      ...reminderIdsFor(archived.id),
    ]);
  });

  test(
    'FR-043: text holds only the name and encouragement; payload /habits',
    () async {
      final id = withReminders(const [ReminderTime(7, 0)], name: 'Drink water');
      f.setDay(id, '2026-10-20', note: 'secret note');
      await scheduler.reconcile(id);
      final n = service.scheduled.values.single.notification;
      expect(n.title, 'Drink water');
      expect(n.body, "Time for Drink water. You've got this.");
      expect(n.body, isNot(contains('secret')));
      expect(n.payload, '/habits');
      expect(n.channel, NotificationChannelId.habitReminders);
    },
  );
}
