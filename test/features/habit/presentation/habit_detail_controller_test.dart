import 'dart:typed_data';

import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/share/image_sharer.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_detail_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/mutable_clock.dart';
import '../fakes.dart';

/// HabitDetailController (T078, contracts/screens.md HAB-03, research R9,
/// R13). Today is Wednesday 2026-10-21.
void main() {
  late HabitFakes f;
  late FakeFeatureGate gate;
  late FakeImageSharer sharer;

  LocalDate d(String key) => LocalDate.fromKey(key);

  setUp(() {
    f = HabitFakes(MutableClock(DateTime(2026, 10, 21, 10)));
    gate = FakeFeatureGate();
    sharer = FakeImageSharer();
  });

  ProviderContainer container({
    bool debugTools = false,
    bool debugUnlockAll = false,
  }) {
    final c = ProviderContainer(
      overrides: [
        ...f.overrides,
        clockProvider.overrideWithValue(f.clock),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            initial: AppSettings(debugUnlockAll: debugUnlockAll),
          ),
        ),
        featureGateProvider.overrideWithValue(gate),
        debugToolsAvailableProvider.overrideWithValue(debugTools),
        imageSharerProvider.overrideWithValue(sharer),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  Future<HabitDetailData> data(ProviderContainer c, String id) async {
    c.listen(habitDetailControllerProvider(id), (_, _) {});
    await c.read(appSettingsProvider.future);
    await pumpEventQueue();
    return c.read(habitDetailControllerProvider(id)).data.requireValue;
  }

  test('the view model is built once per history change', () async {
    final id = f.addHabit('Read').id;
    final c = container();
    HabitDetailController.viewModelBuilds = 0;
    await data(c, id);
    expect(HabitDetailController.viewModelBuilds, 1);
    // A gate change or a habit-only change does not rebuild it.
    gate.set(FeatureKey.advancedReports, unlocked: true);
    await pumpEventQueue();
    expect(HabitDetailController.viewModelBuilds, 1);
    expect(
      c
          .read(habitDetailControllerProvider(id))
          .data
          .requireValue
          .advancedReportsUnlocked,
      isTrue,
    );
    // An entry change does.
    f.setDay(id, '2026-10-20');
    await pumpEventQueue();
    expect(HabitDetailController.viewModelBuilds, 2);
  });

  test('freezeableDays: missed days 1–3 back only', () async {
    final id = f.addHabit('Read', freezes: 1).id;
    f
      ..setDay(id, '2026-10-19')
      ..setDay(id, '2026-10-16');
    final s = await data(container(), id);
    // 20 and 18 missed (1 and 3 back); 19 done; 21 is today; 17 is 4 back.
    expect(s.freezeableDays, [d('2026-10-20'), d('2026-10-18')]);
  });

  test('freezeableDays for specific days skips unscheduled days', () async {
    final id = f
        .addHabit(
          'Gym',
          schedule: const HabitSchedule(
            type: ScheduleType.specificWeekdays,
            target: 1,
            weekdays: {1, 3, 5},
          ),
        )
        .id;
    final s = await data(container(), id);
    expect(s.freezeableDays, [d('2026-10-19')], reason: 'Mon only');
  });

  test(
    'useFreeze writes UseFreeze(allowToday: false); undo restores',
    () async {
      final id = f.addHabit('Read', freezes: 1).id;
      final c = container();
      await data(c, id);
      final ctl = c.read(habitDetailControllerProvider(id).notifier);
      final r = (await ctl.useFreeze(d('2026-10-20')))!;
      final op = f.entries.applied.last.op;
      expect(
        op,
        isA<UseFreeze>().having((o) => o.allowToday, 'allowToday', false),
      );
      expect(f.entry(id, '2026-10-20')?.isFreeze, isTrue);
      expect(f.world.habits[id]!.freezesAvailable, 0);
      await ctl.undo(r.before);
      expect(f.entry(id, '2026-10-20'), isNull);
      expect(f.world.habits[id]!.freezesAvailable, 1);
      // Today is refused from the freeze card.
      expect(await ctl.useFreeze(d('2026-10-21')), isNull);
    },
  );

  group('addDebugFreeze (FR-037)', () {
    test('only with dev tools and the switch on', () async {
      final id = f.addHabit('Read').id;
      var c = container(debugTools: true, debugUnlockAll: true);
      var s = await data(c, id);
      expect(s.showDebugFreezeButton, isTrue);
      final ctl = c.read(habitDetailControllerProvider(id).notifier);
      expect(await ctl.addDebugFreeze(), 1);
      expect(await ctl.addDebugFreeze(), 2);
      expect(await ctl.addDebugFreeze(), 2, reason: 'cap 2');

      c = container(debugTools: true);
      s = await data(c, id);
      expect(s.showDebugFreezeButton, isFalse);
      expect(
        await c
            .read(habitDetailControllerProvider(id).notifier)
            .addDebugFreeze(),
        isNull,
      );

      c = container(debugUnlockAll: true);
      s = await data(c, id);
      expect(s.showDebugFreezeButton, isFalse, reason: 'prod build');
    });
  });

  test('editDay: yes/no toggle, count value, and the note', () async {
    final yes = f.addHabit('Read').id;
    final count = f
        .addHabit(
          'Water',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
        )
        .id;
    final c = container();
    await data(c, yes);
    await data(c, count);
    final cy = c.read(habitDetailControllerProvider(yes).notifier);
    final cc = c.read(habitDetailControllerProvider(count).notifier);
    await cy.editDay(d('2026-10-15'), done: true);
    expect(f.entry(yes, '2026-10-15')?.value, 1);
    await cy.editDay(
      d('2026-10-15'),
      done: false,
      note: 'Sick',
      noteChanged: true,
    );
    final e = f.entry(yes, '2026-10-15')!;
    expect((e.value, e.note), (0, 'Sick'));
    await cc.editDay(d('2026-10-14'), value: 9);
    expect(f.entry(count, '2026-10-14')?.value, 9);
    await cc.editDay(d('2026-10-14'), noteChanged: true);
    expect(f.entry(count, '2026-10-14')?.note, isNull);
    expect(
      await cc.editDay(d('2026-10-22'), value: 1),
      isNull,
      reason: 'future',
    );
  });

  test('the gate stream toggles advancedReportsUnlocked', () async {
    final id = f.addHabit('Read').id;
    final c = container();
    expect((await data(c, id)).advancedReportsUnlocked, isFalse);
    gate.set(FeatureKey.advancedReports, unlocked: true);
    await pumpEventQueue();
    expect(
      c
          .read(habitDetailControllerProvider(id))
          .data
          .requireValue
          .advancedReportsUnlocked,
      isTrue,
    );
  });

  test('shareHeatmap hands the PNG to the sharer as heatmap.png', () async {
    final id = f.addHabit('Read').id;
    final c = container();
    await data(c, id);
    final ok = await c
        .read(habitDetailControllerProvider(id).notifier)
        .shareHeatmap(Uint8List.fromList([1, 2, 3]));
    expect(ok, isTrue);
    expect(sharer.shared.single.fileName, 'heatmap.png');
  });

  test('a deleted or archived habit reports notFound', () async {
    final id = f.addHabit('Read').id;
    final c = container();
    await data(c, id);
    await f.habits.archive(id);
    await pumpEventQueue();
    expect(c.read(habitDetailControllerProvider(id)).notFound, isTrue);
  });

  test('summary and notes newest first', () async {
    final id = f.addHabit('Read').id;
    f
      ..doneRange(id, '2026-10-18', '2026-10-20')
      ..setDay(id, '2026-10-10', note: 'old', value: 0)
      ..setDay(id, '2026-10-19', note: 'new');
    final s = await data(container(), id);
    expect(s.summary.current, 3);
    expect([for (final n in s.notes) n.note], ['new', 'old']);
  });
}
