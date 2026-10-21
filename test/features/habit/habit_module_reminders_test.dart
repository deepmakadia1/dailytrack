import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/data/reminders/local_habit_reminder_scheduler.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/habit/habit_module.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'fakes.dart';

/// HabitModule reminder hooks and reconcile triggers (T066, FR-040, US4-3,
/// US4-5, US4-6). Today is Wednesday 2026-10-21 at 06:00.
void main() {
  late HabitFakes f;
  late FakeNotificationService service;

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 6)));
    service = FakeNotificationService();
  });

  ProviderContainer container({bool realScheduler = false}) {
    final settings = FakeSettingsRepository();
    final c = ProviderContainer(
      overrides: [
        habitRepositoryProvider.overrideWithValue(f.habits),
        habitEntryRepositoryProvider.overrideWithValue(f.entries),
        clockProvider.overrideWithValue(f.clock),
        settingsRepositoryProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(service),
        if (realScheduler)
          habitReminderSchedulerProvider.overrideWith(
            (ref) => LocalHabitReminderScheduler(
              service: service,
              habits: f.habits,
              entries: f.entries,
              settings: settings,
              clock: f.clock,
              l10n: () => lookupAppLocalizations(const Locale('en')),
            ),
          )
        else
          habitReminderSchedulerProvider.overrideWithValue(f.scheduler),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('module hooks', () {
    test(
      'onEnable and onAppOpen refresh the zone, then reconcile all',
      () async {
        final c = container();
        await const HabitModule().onEnable(c.read);
        await const HabitModule().onAppOpen(c.read);
        expect(service.refreshTimeZoneCalls, 2);
        expect(f.scheduler.calls, ['reconcileAll', 'reconcileAll']);
      },
    );

    test('onDisable cancels every habit reminder (data kept)', () async {
      final c = container();
      f.addHabit('Read');
      await const HabitModule().onDisable(c.read);
      expect(f.scheduler.calls, ['cancelAll']);
      expect(f.world.habits, hasLength(1));
    });

    test('US4-6: on app start every active habit is (re)scheduled', () async {
      final c = container(realScheduler: true);
      final a = f.addHabit('A', reminders: const [ReminderTime(7, 0)]).id;
      final b = f.addHabit('B', reminders: const [ReminderTime(20, 0)]).id;
      await const HabitModule().onAppOpen(c.read);
      expect(service.scheduled.keys, {
        reminderIdFor(a, 0, 0),
        reminderIdFor(b, 0, 0),
      });
    });

    test('hooks never throw when the scheduler fails', () async {
      final c = ProviderContainer(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
      );
      addTearDown(c.dispose);
      await const HabitModule().onAppOpen(c.read);
      await const HabitModule().onDisable(c.read);
    });
  });

  group('day writes', () {
    test('US4-3: a check-in today reconciles that habit', () async {
      final c = container();
      final id = f.addHabit('Read').id;
      await c
          .read(habitDayWriterProvider)
          .write(id, LocalDate.fromKey('2026-10-21'), const Toggle());
      expect(f.scheduler.calls, ['reconcile:$id']);
    });

    test(
      'US4-3: checking in suppresses tonight; unchecking brings it back',
      () async {
        final c = container(realScheduler: true);
        final id = f
            .addHabit('Read', reminders: const [ReminderTime(21, 0)])
            .id;
        final writer = c.read(habitDayWriterProvider);
        final today = LocalDate.fromKey('2026-10-21');
        final rid = reminderIdFor(id, 0, 0);

        await writer.write(id, today, const Toggle());
        expect(service.scheduled[rid]!.firstAt, DateTime(2026, 10, 22, 21));
        await writer.write(id, today, const Toggle());
        expect(service.scheduled[rid]!.firstAt, DateTime(2026, 10, 21, 21));
      },
    );
  });
}
