import 'dart:async';

import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/features/habit/data/dev/habit_sample_seeder.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_db_fixture.dart';

/// Dev-only sample habits added with "Seed 10,000 transactions" (feature
/// 012 contracts/dev-seed.md), over a real in-memory database. Today is
/// Wednesday 2026-10-21.
void main() {
  late HabitDb t;
  late BackupCoordinator coordinator;
  late HabitSampleSeeder seeder;

  setUp(() async {
    t = await HabitDb.open();
    coordinator = BackupCoordinator(t.db, t.clock);
    seeder = HabitSampleSeeder(t.db, t.clock, coordinator);
  });

  test('adds five habits covering every kind and schedule type, started a '
      'year ago, with check-ins only on due days before today', () async {
    final result = await seeder.seed();
    expect((result as DevActionDone).count, 5);

    final habits = await t.habits.activeHabits();
    expect(habits, hasLength(5));
    expect({for (final h in habits) h.kind}, HabitKind.values.toSet());
    expect({
      for (final h in habits) h.schedule.type,
    }, ScheduleType.values.toSet());
    final start = t.today.addDays(-HabitSampleSeeder.historyDays);
    for (final h in habits) {
      expect(h.startDate, start, reason: h.name);
      expect(h.reminderTimes, isEmpty, reason: h.name);
    }

    final entries = await t.db.select(t.db.habitEntries).get();
    expect(entries.length, greaterThan(1000));
    final today = t.today.key;
    expect(entries.where((e) => e.dateKey.compareTo(today) >= 0), isEmpty);
    expect(entries.where((e) => e.dateKey.compareTo(start.key) < 0), isEmpty);
    for (final h in habits) {
      final mine = [
        for (final e in entries)
          if (e.habitId == h.id) e,
      ];
      expect(mine, isNotEmpty, reason: h.name);
      for (final e in mine) {
        expect(e.value, inInclusiveRange(1, h.schedule.target));
      }
    }
    final walk = habits.singleWhere((h) => h.name == 'Walk');
    final walkDays = {
      for (final e in entries)
        if (e.habitId == walk.id) DateTime.parse(e.dateKey).weekday,
    };
    expect(walkDays, {1, 3, 5});
  });

  test('a second run adds no duplicate habits', () async {
    await seeder.seed();
    final second = await seeder.seed();
    expect((second as DevActionDone).count, 0);
    expect(await t.habits.activeHabits(), hasLength(5));
  });

  test('while a backup or restore holds the lease, it returns busy and adds '
      'nothing', () async {
    final gate = Completer<void>();
    final backup = coordinator.run(() => gate.future);
    expect(await seeder.seed(), isA<DevActionBusy>());
    expect(await t.habits.activeHabits(), isEmpty);
    gate.complete();
    await backup;
  });
}
