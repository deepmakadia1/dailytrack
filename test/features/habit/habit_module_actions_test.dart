import 'package:dailytrack/core/module/app_action.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/notifications/notification_service.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/habit/habit_module.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import 'fakes.dart';

/// HabitModule.handleAction and contributeGlance (feature 008 T104, T127,
/// T018; research R17, R19, R20; clarification Q3). Today is Wednesday
/// 2026-10-21 at 09:00.
void main() {
  late HabitFakes f;
  late FakeNotificationService service;
  late ProviderContainer c;
  const module = HabitModule();

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 9)));
    service = FakeNotificationService();
    c = ProviderContainer(
      overrides: [
        ...f.overrides,
        clockProvider.overrideWithValue(f.clock),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        notificationServiceProvider.overrideWithValue(service),
      ],
    );
    addTearDown(c.dispose);
  });

  Future<bool> act(
    String name,
    Map<String, String> params, {
    AppActionSource source = AppActionSource.notification,
  }) => module.handleAction(
    AppAction(source: source, name: name, params: params),
    c.read,
  );

  String count() => f
      .addHabit(
        'Read',
        kind: HabitKind.count,
        unit: 'pages',
        schedule: const HabitSchedule(type: ScheduleType.daily, target: 20),
      )
      .id;

  int? valueOn(String id, String key) =>
      f.world.entries[id]?[LocalDate.fromKey(key)]?.value;

  group('habit.markDone (FR-038)', () {
    test('sets the resolved day to its target with SetValue; a second tap '
        'keeps it done', () async {
      final id = f.addHabit('Meditate').id;
      final params = {'habit': id, 'at': '08:00', 'wd': '0'};
      expect(await act(HabitActions.markDone, params), isTrue);
      expect(await act(HabitActions.markDone, params), isTrue);
      expect(valueOn(id, '2026-10-21'), 1);
      expect(f.entries.applied, hasLength(1));
      expect(f.entries.applied.single.op, isA<SetValue>());
    });

    test('before the reminder time it marks the previous day', () async {
      f.clock.value = DateTime(2026, 10, 22, 0, 30);
      final id = f.addHabit('Meditate').id;
      await act(HabitActions.markDone, {'habit': id, 'at': '21:00', 'wd': '0'});
      expect(valueOn(id, '2026-10-21'), 1);
      expect(valueOn(id, '2026-10-22'), isNull);
    });

    test('an archived or deleted habit: handled, nothing written', () async {
      final archived = f.addHabit('Old', archived: true).id;
      expect(
        await act(HabitActions.markDone, {
          'habit': archived,
          'at': '08:00',
          'wd': '0',
        }),
        isTrue,
      );
      expect(
        await act(HabitActions.markDone, {
          'habit': 'gone',
          'at': '08:00',
          'wd': '0',
        }),
        isTrue,
      );
      expect(f.entries.applied, isEmpty);
    });

    test('a count habit: nothing written', () async {
      final id = count();
      await act(HabitActions.markDone, {'habit': id, 'at': '08:00', 'wd': '0'});
      expect(f.entries.applied, isEmpty);
    });
  });

  group('habit.snooze (FR-039)', () {
    test('a one-shot an hour from now with the same text, buttons, and '
        'payload', () async {
      service.exactAllowed = false;
      final id = f.addHabit('Meditate').id;
      final params = {'habit': id, 'at': '08:00', 'wd': '0'};
      expect(await act(HabitActions.snooze, params), isTrue);
      final s = service.scheduled[snoozeIdFor(id)]!;
      expect(s.firstAt, DateTime(2026, 10, 21, 10));
      expect(s.repeat, isNull);
      expect(s.exact, isFalse);
      expect(s.notification.title, 'Meditate');
      expect(s.notification.channel, NotificationChannelId.habitReminders);
      expect(s.notification.payload, '/habits?habit=$id&at=08:00&wd=0');
      expect(
        [for (final a in s.notification.actions) a.id],
        [HabitActions.markDone, HabitActions.snooze],
      );
    });

    test(
      'exact when exact alarms are allowed; snoozing again replaces it',
      () async {
        final id = f.addHabit('Meditate').id;
        final params = {'habit': id, 'at': '08:00', 'wd': '0'};
        await act(HabitActions.snooze, params);
        f.clock.advance(const Duration(minutes: 30));
        await act(HabitActions.snooze, params);
        expect(service.scheduled, hasLength(1));
        final s = service.scheduled[snoozeIdFor(id)]!;
        expect(s.exact, isTrue);
        expect(s.firstAt, DateTime(2026, 10, 21, 10, 30));
      },
    );

    test('an archived habit is not snoozed', () async {
      final id = f.addHabit('Old', archived: true).id;
      await act(HabitActions.snooze, {'habit': id, 'at': '08:00', 'wd': '0'});
      expect(service.scheduled, isEmpty);
    });
  });

  group('habit.widgetCheck (FR-045, Q3)', () {
    Map<String, String> today(String id) => {'habit': id, 'day': '2026-10-21'};

    test('a yes/no habit that is not done becomes done', () async {
      final id = f.addHabit('Meditate').id;
      expect(
        await act(
          HabitActions.widgetCheck,
          today(id),
          source: AppActionSource.widget,
        ),
        isTrue,
      );
      expect(valueOn(id, '2026-10-21'), 1);
    });

    test('a done yes/no habit stays done (no undo from the widget)', () async {
      final id = f.addHabit('Meditate').id;
      f.setDay(id, '2026-10-21');
      await act(HabitActions.widgetCheck, today(id));
      expect(f.entries.applied, isEmpty);
      expect(valueOn(id, '2026-10-21'), 1);
    });

    test('a count habit gets +1', () async {
      final id = count();
      f.setDay(id, '2026-10-21', value: 12);
      await act(HabitActions.widgetCheck, today(id));
      expect(f.entries.applied.single.op, isA<Increment>());
      expect(valueOn(id, '2026-10-21'), 13);
    });

    test('a stale widget (another day) changes nothing', () async {
      final id = f.addHabit('Meditate').id;
      await act(HabitActions.widgetCheck, {'habit': id, 'day': '2026-10-20'});
      expect(f.entries.applied, isEmpty);
    });
  });

  test('other actions are not handled', () async {
    expect(await act('expense.something', const {}), isFalse);
    expect(await act(HabitActions.markDone, const {}), isFalse);
  });

  test("T018 contributeGlance: the day's listed habits in order, at most 4, "
      'with done counts', () async {
    final ids = [
      for (final n in ['A', 'B', 'C', 'D', 'E']) f.addHabit(n).id,
    ];
    f
      ..setDay(ids[0], '2026-10-21')
      ..setDay(ids[4], '2026-10-21');
    final weekdays = f.addHabit(
      'Mondays',
      schedule: const HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {1},
      ),
    );
    f.addHabit('Archived', archived: true);
    final b = GlanceBuilder(DateTime(2026, 10, 21));
    await module.contributeGlance(b, c.read, f.clock.now());
    final habits = b.build().habits!;
    expect((habits.scheduled, habits.done), (5, 2));
    expect([for (final h in habits.items) h.name], ['A', 'B', 'C', 'D']);
    expect(habits.items.first.done, isTrue);
    expect(habits.items.any((h) => h.id == weekdays.id), isFalse);

    // Tomorrow (precomputed for the widget after midnight): nothing done.
    final next = GlanceBuilder(DateTime(2026, 10, 22));
    await module.contributeGlance(next, c.read, DateTime(2026, 10, 22));
    expect(next.build().habits!.done, 0);
  });
}
