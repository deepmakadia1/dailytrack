import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/mappers/habit_mapper.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import 'habit_db_fixture.dart';

/// DriftHabitRepository on a real in-memory database (T037, data-model.md
/// §6–§7, research R3, R9). Today is Wednesday 2026-10-21.
void main() {
  late HabitDb t;

  setUp(() async => t = await HabitDb.open());

  const mwf = HabitSchedule(
    type: ScheduleType.specificWeekdays,
    target: 1,
    weekdays: {1, 3, 5},
  );
  const daily = HabitSchedule(type: ScheduleType.daily, target: 1);

  HabitDraft draftOf(Habit h, {HabitSchedule? schedule, String? start}) =>
      HabitDraft(
        name: h.name,
        iconKey: h.iconKey,
        colorHex: h.colorHex,
        kind: h.kind,
        schedule: schedule ?? h.schedule,
        startDate: start == null ? h.startDate : LocalDate.fromKey(start),
        reminderTimes: h.reminderTimes,
        remindOnlyIfNotDone: h.remindOnlyIfNotDone,
        unit: h.unit,
      );

  Future<List<HabitScheduleRow>> versionRows(String habitId) =>
      (t.db.select(t.db.habitSchedules)
            ..where((s) => s.habitId.equals(habitId))
            ..orderBy([(s) => OrderingTerm.asc(s.effectiveFromKey)]))
          .get();

  Future<HabitRow> habitRow(String id) =>
      (t.db.select(t.db.habits)..where((h) => h.id.equals(id))).getSingle();

  /// Invariant 2: the habits row mirrors the newest live version.
  Future<void> expectMirrorsNewest(String id) async {
    final live = [
      for (final v in await versionRows(id))
        if (v.deletedAt == null) v,
    ];
    final newest = live.last.toEntity().schedule;
    expect((await habitRow(id)).schedule, newest);
  }

  group('create', () {
    test('writes version 1 from the start date and mirrors it', () async {
      final h = await t.habit(schedule: mwf, start: '2026-10-05');
      final versions = await versionRows(h.id);
      expect(versions, hasLength(1));
      expect(versions.single.effectiveFromKey, '2026-10-05');
      expect(versions.single.toEntity().schedule, mwf);
      expect(h.schedule, mwf);
      expect(h.startDate, LocalDate.fromKey('2026-10-05'));
      expect(h.freezesAvailable, 0);
      expect(h.celebratedMilestones, isEmpty);
      expect(h.isArchived, isFalse);
      expect(h.createdAt, t.clock.now().toUtc());
      await expectMirrorsNewest(h.id);
    });

    test('appends to the end of the list', () async {
      final a = await t.habit(name: 'A');
      final b = await t.habit(name: 'B');
      final c = await t.habit(name: 'C');
      expect([a.sortOrder, b.sortOrder, c.sortOrder], [0, 1, 2]);
      expect(
        [for (final h in await t.habits.activeHabits()) h.name],
        ['A', 'B', 'C'],
      );
    });

    test('trims the name, sorts reminders, and drops a yes/no unit', () async {
      final h = await t.habits.create(
        HabitDraft(
          name: '  Walk  ',
          iconKey: 'walk',
          colorHex: '#0F766E',
          kind: HabitKind.yesNo,
          schedule: const HabitSchedule(
            type: ScheduleType.daily,
            target: 1,
            weekdays: {1}, // not used by daily
            timesPerWeek: 3,
          ),
          startDate: t.today,
          unit: 'km',
          reminderTimes: const [ReminderTime(21, 0), ReminderTime(7, 0)],
          remindOnlyIfNotDone: false,
        ),
      );
      expect(h.name, 'Walk');
      expect(h.unit, isNull);
      expect(h.reminderTimes, const [ReminderTime(7, 0), ReminderTime(21, 0)]);
      expect(h.remindOnlyIfNotDone, isFalse);
      expect(h.schedule, daily);
      final row = await habitRow(h.id);
      expect(row.weekdaysMask, 0);
      expect(row.timesPerWeek, isNull);
    });

    test('a count habit keeps its unit and target', () async {
      final h = await t.habits.create(
        HabitDraft(
          name: 'Read',
          iconKey: 'book',
          colorHex: '#0F766E',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 20),
          startDate: t.today,
          unit: 'pages',
        ),
      );
      expect((h.unit, h.schedule.target), ('pages', 20));
    });

    test('a storage failure surfaces as HabitStorageFailure', () async {
      await expectLater(
        t.habit(name: '   '),
        throwsA(isA<HabitStorageFailure>()),
      );
      expect(await t.habits.activeHabits(), isEmpty);
    });
  });

  group('update (research R3)', () {
    test('a schedule change adds a version from today; past days keep the '
        'old schedule', () async {
      final h = await t.habit();
      final updated = await t.habits.update(h.id, draftOf(h, schedule: mwf));
      expect(updated.schedule, mwf);
      final versions = await versionRows(h.id);
      expect(
        [for (final v in versions) v.effectiveFromKey],
        ['2026-10-01', '2026-10-21'],
      );
      final history = (await t.entries.history(h.id))!;
      expect(
        t.engine.scheduleOn(history, LocalDate.fromKey('2026-10-20')),
        daily,
      );
      expect(t.engine.scheduleOn(history, t.today), mwf);
      await expectMirrorsNewest(h.id);
    });

    test('several changes on one day keep only the last', () async {
      final h = await t.habit();
      await t.habits.update(h.id, draftOf(h, schedule: mwf));
      const last = HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 1,
        timesPerWeek: 4,
      );
      await t.habits.update(h.id, draftOf(h, schedule: last));
      final versions = await versionRows(h.id);
      expect(versions, hasLength(2));
      expect(versions.last.toEntity().schedule, last);
      await expectMirrorsNewest(h.id);
    });

    test('a change on a later day adds another version', () async {
      final h = await t.habit();
      await t.habits.update(h.id, draftOf(h, schedule: mwf));
      t.clock.advance(const Duration(days: 2));
      await t.habits.update(h.id, draftOf(h, schedule: daily));
      expect(
        [for (final v in await versionRows(h.id)) v.effectiveFromKey],
        ['2026-10-01', '2026-10-21', '2026-10-23'],
      );
      await expectMirrorsNewest(h.id);
    });

    test('a target change is a schedule change', () async {
      final h = await t.habits.create(
        HabitDraft(
          name: 'Read',
          iconKey: 'book',
          colorHex: '#0F766E',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 10),
          startDate: LocalDate.fromKey('2026-10-01'),
        ),
      );
      await t.habits.update(
        h.id,
        draftOf(
          h,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 20),
        ),
      );
      final versions = await versionRows(h.id);
      expect([for (final v in versions) v.targetValue], [10, 20]);
    });

    test('other edits add no version', () async {
      final h = await t.habit();
      final renamed = await t.habits.update(
        h.id,
        draftOf(h).copyWith(name: 'Read more', colorHex: '#B91C1C'),
      );
      expect(renamed.name, 'Read more');
      expect(renamed.colorHex, '#B91C1C');
      expect(await versionRows(h.id), hasLength(1));
    });

    test(
      'a habit that has not started changes its first version in place',
      () async {
        final h = await t.habit(start: '2026-10-25');
        await t.habits.update(h.id, draftOf(h, schedule: mwf));
        final versions = await versionRows(h.id);
        expect(versions, hasLength(1));
        expect(versions.single.effectiveFromKey, '2026-10-25');
        expect(versions.single.toEntity().schedule, mwf);
      },
    );

    test('moving the start date earlier moves a lone first version', () async {
      final h = await t.habit(start: '2026-10-10');
      await t.habits.update(h.id, draftOf(h, start: '2026-10-03'));
      final versions = await versionRows(h.id);
      expect(versions.single.effectiveFromKey, '2026-10-03');
      expect((await t.habits.byId(h.id))!.startDate.key, '2026-10-03');
    });

    test('a different kind throws KindLocked and changes nothing', () async {
      final h = await t.habit();
      await expectLater(
        t.habits.update(
          h.id,
          draftOf(h).copyWith(
            kind: HabitKind.count,
            schedule: const HabitSchedule(type: ScheduleType.daily, target: 5),
          ),
        ),
        throwsA(isA<KindLocked>()),
      );
      expect(await t.habits.byId(h.id), h);
    });

    test('an unknown or deleted habit throws HabitNotFound', () async {
      final h = await t.habit();
      await expectLater(
        t.habits.update('nope', draftOf(h)),
        throwsA(isA<HabitNotFound>()),
      );
      await t.habits.delete(h.id);
      await expectLater(
        t.habits.update(h.id, draftOf(h)),
        throwsA(isA<HabitNotFound>()),
      );
    });
  });

  group('archive, undo, restore', () {
    test('archive hides the habit and keeps its sort order; undo puts it back '
        'in place', () async {
      final a = await t.habit(name: 'A');
      final b = await t.habit(name: 'B');
      await t.habit(name: 'C');
      await t.habits.archive(b.id);
      final archived = (await t.habits.byId(b.id))!;
      expect(archived.isArchived, isTrue);
      expect(archived.archivedAt, t.clock.now().toUtc());
      expect(archived.sortOrder, 1);
      expect(
        [for (final h in await t.habits.activeHabits()) h.name],
        ['A', 'C'],
      );
      await t.habits.undoArchive(b.id);
      final back = (await t.habits.byId(b.id))!;
      expect(
        (back.isArchived, back.archivedAt, back.sortOrder),
        (false, null, 1),
      );
      expect(
        [for (final h in await t.habits.activeHabits()) h.name],
        ['A', 'B', 'C'],
      );
      expect(a.sortOrder, 0);
    });

    test('restore puts the habit at the end (max active + 1)', () async {
      final a = await t.habit(name: 'A');
      await t.habit(name: 'B');
      await t.habit(name: 'C');
      await t.habits.archive(a.id);
      await t.habits.restore(a.id);
      final restored = (await t.habits.byId(a.id))!;
      expect((restored.isArchived, restored.archivedAt), (false, null));
      expect(restored.sortOrder, 3);
      expect(
        [for (final h in await t.habits.activeHabits()) h.name],
        ['B', 'C', 'A'],
      );
    });

    test('archived habits keep entries and milestones', () async {
      final h = await t.habit(start: '2026-10-15');
      for (var day = 15; day <= 21; day++) {
        await t.entries.apply(h.id, LocalDate(2026, 10, day), const Toggle());
      }
      await t.habits.archive(h.id);
      await t.habits.restore(h.id);
      final back = (await t.habits.byId(h.id))!;
      expect(back.celebratedMilestones, isNotEmpty);
      expect((await t.entries.history(h.id))!.entries, hasLength(7));
    });

    test('watchArchived lists the most recently archived first', () async {
      final a = await t.habit(name: 'A');
      final b = await t.habit(name: 'B');
      await t.habits.archive(a.id);
      t.clock.advance(const Duration(minutes: 1));
      await t.habits.archive(b.id);
      final archived = await t.habits.watchArchived().first;
      expect([for (final h in archived) h.name], ['B', 'A']);
      expect(await t.habits.watchActive().first, isEmpty);
    });

    test('archive of an unknown habit throws HabitNotFound', () async {
      await expectLater(
        t.habits.archive('nope'),
        throwsA(isA<HabitNotFound>()),
      );
      await expectLater(
        t.habits.restore('nope'),
        throwsA(isA<HabitNotFound>()),
      );
      await expectLater(
        t.habits.undoArchive('nope'),
        throwsA(isA<HabitNotFound>()),
      );
    });
  });

  group('delete (invariant 3)', () {
    test(
      'soft-deletes the habit, its versions, and its entries together',
      () async {
        final h = await t.habit();
        await t.habits.update(h.id, draftOf(h, schedule: mwf));
        await t.entries.apply(
          h.id,
          LocalDate.fromKey('2026-10-20'),
          const Toggle(),
        );
        await t.entries.apply(h.id, t.today, const Toggle());
        final other = await t.habit(name: 'Other');
        await t.entries.apply(other.id, t.today, const Toggle());

        await t.habits.delete(h.id);

        final now = t.clock.now().toUtc().millisecondsSinceEpoch;
        expect((await habitRow(h.id)).deletedAt, now);
        for (final v in await versionRows(h.id)) {
          expect(v.deletedAt, now);
        }
        final rows = await (t.db.select(
          t.db.habitEntries,
        )..where((e) => e.habitId.equals(h.id))).get();
        expect(rows, hasLength(2));
        for (final r in rows) {
          expect(r.deletedAt, now);
        }
        expect(await t.habits.byId(h.id), isNull);
        expect(await t.habits.watchById(h.id).first, isNull);
        expect(await t.entries.history(h.id), isNull);
        expect(
          [for (final x in await t.habits.activeHabits()) x.id],
          [other.id],
        );
        // The other habit is untouched.
        expect((await t.entries.history(other.id))!.entries, hasLength(1));
      },
    );

    test('writes to a deleted habit throw HabitNotFound', () async {
      final h = await t.habit();
      await t.habits.delete(h.id);
      await expectLater(t.habits.delete(h.id), throwsA(isA<HabitNotFound>()));
      await expectLater(
        t.entries.apply(h.id, t.today, const Toggle()),
        throwsA(isA<HabitNotFound>()),
      );
      await expectLater(
        t.habits.addFreeze(h.id),
        throwsA(isA<HabitNotFound>()),
      );
    });
  });

  test('reorder rewrites only active habits to 0..n-1', () async {
    final a = await t.habit(name: 'A');
    final b = await t.habit(name: 'B');
    final c = await t.habit(name: 'C');
    final d = await t.habit(name: 'D');
    await t.habits.archive(b.id);
    await t.habits.reorder([d.id, b.id, c.id, a.id, 'unknown']);
    expect(
      [for (final h in await t.habits.activeHabits()) h.name],
      ['D', 'C', 'A'],
    );
    expect(
      [
        for (final id in [d.id, c.id, a.id])
          (await t.habits.byId(id))!.sortOrder,
      ],
      [0, 1, 2],
    );
    expect((await t.habits.byId(b.id))!.sortOrder, 1, reason: 'archived');
  });

  group('freezes (research R9, invariant 4)', () {
    test('addFreeze counts up to the cap of 2', () async {
      final h = await t.habit();
      expect(await t.habits.addFreeze(h.id), 1);
      expect(await t.habits.addFreeze(h.id), 2);
      expect(await t.habits.addFreeze(h.id), 2);
      expect((await t.habits.byId(h.id))!.freezesAvailable, 2);
    });

    test('concurrent grants never pass 2', () async {
      final h = await t.habit();
      await Future.wait([for (var i = 0; i < 5; i++) t.habits.addFreeze(h.id)]);
      expect((await t.habits.byId(h.id))!.freezesAvailable, 2);
    });

    test('an unknown habit throws HabitNotFound', () async {
      await expectLater(
        t.habits.addFreeze('nope'),
        throwsA(isA<HabitNotFound>()),
      );
    });
  });

  test('streams re-emit after changes', () async {
    final events = <List<String>>[];
    final sub = t.habits.watchActive().listen(
      (hs) => events.add([for (final h in hs) h.name]),
    );
    addTearDown(sub.cancel);
    await pumpEventQueue();
    final h = await t.habit(name: 'A');
    await pumpEventQueue();
    await t.habits.archive(h.id);
    await pumpEventQueue();
    expect(events, [
      <String>[],
      ['A'],
      <String>[],
    ]);
    expect(await t.habits.watchById('nope').first, isNull);
  });
}
