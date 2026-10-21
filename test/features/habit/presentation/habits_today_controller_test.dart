import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// HabitsTodayController (T052, contracts/screens.md HAB-01, research R7,
/// R14). Today is Wednesday 2026-10-21; weeks start on Monday unless set.
void main() {
  late HabitFakes f;
  late ProviderContainer c;

  LocalDate d(String key) => LocalDate.fromKey(key);

  ProviderContainer container({int firstDayOfWeek = 1}) {
    f.world.firstDayOfWeek = firstDayOfWeek;
    final container = ProviderContainer(
      overrides: [
        ...f.overrides,
        clockProvider.overrideWithValue(f.clock),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            initial: AppSettings(firstDayOfWeek: firstDayOfWeek),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 10)));
    c = container();
  });

  Future<HabitsTodayData> data([ProviderContainer? on]) async {
    final cc = (on ?? c)..listen(habitsTodayControllerProvider, (_, _) {});
    // Settings first, then the controller's streams.
    await cc.read(appSettingsProvider.future);
    await pumpEventQueue();
    return cc.read(habitsTodayControllerProvider).data.requireValue;
  }

  HabitsTodayController controller([ProviderContainer? on]) =>
      (on ?? c).read(habitsTodayControllerProvider.notifier);

  group('week cells', () {
    test('Monday start: Mon 19 … Sun 25, today selected', () async {
      final s = await data();
      expect(
        [for (final w in s.week) w.date.key],
        [
          '2026-10-19',
          '2026-10-20',
          '2026-10-21',
          '2026-10-22',
          '2026-10-23',
          '2026-10-24',
          '2026-10-25',
        ],
      );
      expect(s.selected, d('2026-10-21'));
      expect(s.week[2].isToday, isTrue);
      expect(
        [for (final w in s.week) w.isFuture],
        [false, false, false, true, true, true, true],
      );
    });

    test('Sunday start: Sun 18 … Sat 24', () async {
      c = container(firstDayOfWeek: 7);
      final s = await data();
      expect(s.week.first.date, d('2026-10-18'));
      expect(s.week.last.date, d('2026-10-24'));
    });

    test('the previous-week page: selectable = today … 7 days back', () async {
      await data();
      controller().pageWeek(-1);
      final s = c.read(habitsTodayControllerProvider).data.requireValue;
      expect(s.weekOffset, -1);
      expect(s.week.first.date, d('2026-10-12'));
      // 9 and 8 days back are not selectable; 7 back (Wed 14) is.
      expect(
        [for (final w in s.week) w.selectable],
        [false, false, true, true, true, true, true],
      );
      controller().pageWeek(-5);
      expect(
        c.read(habitsTodayControllerProvider).data.requireValue.weekOffset,
        -1,
        reason: 'one page back only',
      );
    });

    test('ratios are done / scheduled per day', () async {
      final a = f.addHabit('A').id;
      f
        ..addHabit('B')
        ..setDay(a, '2026-10-19')
        ..setDay(a, '2026-10-20');
      final b = f.world.habits.values.last.id;
      f.setDay(b, '2026-10-20');
      final s = await data();
      expect(
        [for (final w in s.week.take(3)) (w.done, w.scheduled)],
        [(1, 2), (2, 2), (0, 2)],
      );
      expect(s.week[1].ratio, 1);
      expect(s.week[3].scheduled, 0, reason: 'future days count nothing');
    });
  });

  group('selection', () {
    test('selectDay accepts today … 7 days back only', () async {
      await data();
      controller()
        ..selectDay(d('2026-10-22'))
        ..selectDay(d('2026-10-13'));
      expect(
        c.read(habitsTodayControllerProvider).data.requireValue.selected,
        d('2026-10-21'),
      );
      controller().selectDay(d('2026-10-14'));
      expect(
        c.read(habitsTodayControllerProvider).data.requireValue.selected,
        d('2026-10-14'),
      );
    });

    test('a day rollover resets the selection to the new today', () async {
      f.addHabit('A');
      await data();
      controller().selectDay(d('2026-10-19'));
      f.clock.value = DateTime(2026, 10, 22, 7);
      controller().checkDayRollover();
      await pumpEventQueue();
      final s = c.read(habitsTodayControllerProvider).data.requireValue;
      expect((s.today, s.selected), (d('2026-10-22'), d('2026-10-22')));
    });
  });

  group('scheduled vs "Not scheduled today"', () {
    test('specific days and a future start date', () async {
      f
        ..addHabit(
          'Tue',
          schedule: const HabitSchedule(
            type: ScheduleType.specificWeekdays,
            target: 1,
            weekdays: {2},
          ),
        )
        ..addHabit('Daily')
        ..addHabit('Later', start: '2026-10-25');
      final s = await data();
      expect([for (final h in s.scheduled) h.habit.name], ['Daily']);
      expect([for (final h in s.notScheduled) h.habit.name], ['Tue', 'Later']);
      controller().selectDay(d('2026-10-20'));
      final tue = c.read(habitsTodayControllerProvider).data.requireValue;
      expect([for (final h in tue.scheduled) h.habit.name], ['Tue', 'Daily']);
    });

    test('times per week: listed until the target is met before that day, '
        'and on its done days', () async {
      final id = f
          .addHabit(
            '2x',
            schedule: const HabitSchedule(
              type: ScheduleType.timesPerWeek,
              target: 1,
              timesPerWeek: 2,
            ),
          )
          .id;
      f
        ..setDay(id, '2026-10-19')
        ..setDay(id, '2026-10-20');
      var s = await data();
      expect(s.scheduled, isEmpty, reason: 'met on Mon and Tue');
      expect(
        s.notScheduled.single.schedule,
        const TimesPerWeekText(2, left: 0),
      );
      controller().selectDay(d('2026-10-20'));
      s = c.read(habitsTodayControllerProvider).data.requireValue;
      expect(s.scheduled.single.isDone, isTrue, reason: 'its done day');
      controller().selectDay(d('2026-10-19'));
      s = c.read(habitsTodayControllerProvider).data.requireValue;
      expect(s.scheduled, hasLength(1), reason: 'not yet met before Mon');
    });
  });

  group('cards and header', () {
    test('progress, status, value, streak from the engine', () async {
      final a = f.addHabit('A').id;
      final b = f
          .addHabit(
            'B',
            kind: HabitKind.count,
            schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
          )
          .id;
      f
        ..doneRange(a, '2026-10-18', '2026-10-21')
        ..setDay(b, '2026-10-21', value: 3);
      final s = await data();
      expect((s.doneCount, s.scheduledCount), (1, 2));
      final ca = s.scheduled.firstWhere((x) => x.id == a);
      final cb = s.scheduled.firstWhere((x) => x.id == b);
      expect(
        (ca.isDone, ca.currentStreak, ca.unit),
        (true, 4, StreakUnit.days),
      );
      expect((cb.isDone, cb.value, cb.target), (false, 3, 8));
      expect(s.allDoneToday, isFalse);
    });

    test(
      'allDoneToday only for today with at least one scheduled habit',
      () async {
        final a = f.addHabit('A').id;
        var s = await data();
        expect(s.allDoneToday, isFalse);
        f.setDay(a, '2026-10-21');
        await pumpEventQueue();
        s = c.read(habitsTodayControllerProvider).data.requireValue;
        expect(s.allDoneToday, isTrue);
        f.setDay(a, '2026-10-20');
        await pumpEventQueue();
        controller().selectDay(d('2026-10-20'));
        s = c.read(habitsTodayControllerProvider).data.requireValue;
        expect(s.allDoneToday, isFalse, reason: 'not today');
        expect(s.doneCount, 1);
      },
    );

    test('canSkipToday: today, scheduled, not done, not frozen', () async {
      final a = f.addHabit('A').id;
      final b = f.addHabit('B').id;
      f.setDay(b, '2026-10-21');
      var s = await data();
      expect(s.scheduled.firstWhere((x) => x.id == a).canSkipToday, isTrue);
      expect(s.scheduled.firstWhere((x) => x.id == b).canSkipToday, isFalse);
      controller().selectDay(d('2026-10-20'));
      s = c.read(habitsTodayControllerProvider).data.requireValue;
      expect(s.scheduled.firstWhere((x) => x.id == a).canSkipToday, isFalse);
    });
  });

  group('writes', () {
    test('toggle writes the selected day and reconciles this week', () async {
      final a = f.addHabit('A').id;
      await data();
      controller().selectDay(d('2026-10-19'));
      final r = await controller().toggle(a);
      expect(r, isNotNull);
      expect(f.entry(a, '2026-10-19')?.value, 1);
      expect(f.scheduler.calls, ['reconcile:$a']);
    });

    test('skipToday freezes today; undo puts it back', () async {
      final a = f.addHabit('A', freezes: 1).id;
      await data();
      controller().selectDay(d('2026-10-20'));
      final r = (await controller().skipToday(a))!;
      expect(f.entry(a, '2026-10-21')?.isFreeze, isTrue, reason: 'today');
      await controller().undo(r.before);
      expect(f.entry(a, '2026-10-21'), isNull);
      expect(f.world.habits[a]!.freezesAvailable, 1);
    });

    test('a failed write returns null', () async {
      final a = f.addHabit('A').id;
      await data();
      f.world.failNextWrite = true;
      expect(await controller().toggle(a), isNull);
    });

    test('archive cancels reminders; undoArchive reconciles', () async {
      final a = f.addHabit('A').id;
      await data();
      expect(await controller().archive(a), isTrue);
      await controller().undoArchive(a);
      expect(f.scheduler.calls, ['cancel:$a', 'reconcile:$a']);
      f.world.failNextWrite = true;
      expect(await controller().archive(a), isFalse);
    });
  });

  group('history window (research R7)', () {
    test('watches 400 days back; a run reaching the window start loads the '
        'full history', () async {
      final id = f.addHabit('Old', start: '2025-01-01').id;
      f.doneRange(id, '2025-01-01', '2026-10-20');
      final s = await data();
      await pumpEventQueue();
      final card = c
          .read(habitsTodayControllerProvider)
          .data
          .requireValue
          .scheduled
          .single;
      // 2025-01-01 … 2026-10-20 is 658 days, more than the 400-day window.
      expect(card.currentStreak, 658);
      expect(s.scheduled, hasLength(1));
    });

    test('a run broken inside the window needs no full history', () async {
      final id = f.addHabit('Old', start: '2025-01-01').id;
      f
        ..doneRange(id, '2025-01-01', '2026-10-09')
        ..doneRange(id, '2026-10-11', '2026-10-20');
      await data();
      await pumpEventQueue();
      expect(
        c
            .read(habitsTodayControllerProvider)
            .data
            .requireValue
            .scheduled
            .single
            .currentStreak,
        10,
      );
    });
  });

  test('a stream error becomes the error state; retry reloads', () async {
    f
      ..addHabit('A')
      ..world.failWatch = Exception('boom');
    c.listen(habitsTodayControllerProvider, (_, _) {});
    await c.read(appSettingsProvider.future);
    await pumpEventQueue();
    expect(c.read(habitsTodayControllerProvider).data.hasError, isTrue);
    f.world.failWatch = null;
    controller().retry();
    await pumpEventQueue();
    expect(c.read(habitsTodayControllerProvider).data.hasValue, isTrue);
  });

  test('reorder mode and reorder', () async {
    final a = f.addHabit('A').id;
    final b = f.addHabit('B').id;
    await data();
    controller().setReorderMode(on: true);
    expect(
      c.read(habitsTodayControllerProvider).data.requireValue.reorderMode,
      isTrue,
    );
    await controller().reorder([b, a]);
    await pumpEventQueue();
    final s = c.read(habitsTodayControllerProvider).data.requireValue;
    expect([for (final h in s.habits) h.id], [b, a]);
  });
}
