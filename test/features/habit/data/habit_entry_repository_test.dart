import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'habit_db_fixture.dart';

/// DriftHabitEntryRepository on a real in-memory database (T037, research
/// R4, R7, R8, data-model.md §6). Today is Wednesday 2026-10-21.
void main() {
  late HabitDb t;

  setUp(() async => t = await HabitDb.open());

  LocalDate d(String key) => LocalDate.fromKey(key);

  Future<Habit> countHabit({int target = 5, String start = '2026-10-01'}) =>
      t.habit(
        kind: HabitKind.count,
        schedule: HabitSchedule(type: ScheduleType.daily, target: target),
        start: start,
      );

  Future<int> freezes(String id) async =>
      (await t.habits.byId(id))!.freezesAvailable;

  group('HAB-01 criterion "Toggling a yes/no habit creates or deletes the '
      'habit_entries row for that date key"', () {
    test('toggle on → one live row with value 1', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const Toggle());
      final rows = await t.physical(h.id, '2026-10-21');
      expect(rows, hasLength(1));
      expect((rows.single.value, rows.single.deletedAt), (1, null));
    });

    test('toggle off → the same physical row is soft-deleted', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const Toggle());
      final id = (await t.physical(h.id, '2026-10-21')).single.id;
      await t.entries.apply(h.id, t.today, const Toggle());
      final rows = await t.physical(h.id, '2026-10-21');
      expect(rows.single.id, id);
      expect(rows.single.deletedAt, isNotNull);
      expect((await t.entries.history(h.id))!.entries, isEmpty);
    });

    test('toggling 10 times leaves one physical row', () async {
      final h = await t.habit();
      for (var i = 0; i < 10; i++) {
        await t.entries.apply(h.id, t.today, const Toggle());
      }
      final rows = await t.physical(h.id, '2026-10-21');
      expect(rows, hasLength(1));
      expect(rows.single.deletedAt, isNotNull, reason: '10 toggles = off');
    });
  });

  test('toggle off with a note keeps the row live with value 0', () async {
    final h = await t.habit();
    await t.entries.apply(h.id, t.today, const Toggle());
    await t.entries.apply(h.id, t.today, const SetNote('Felt great'));
    await t.entries.apply(h.id, t.today, const Toggle());
    final row = (await t.physical(h.id, '2026-10-21')).single;
    expect((row.value, row.note, row.deletedAt), (0, 'Felt great', null));
  });

  group('notes', () {
    test('SetNote on an empty day makes a live value-0 row (Add note for '
        'today)', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const SetNote('  Tired  '));
      final row = (await t.physical(h.id, '2026-10-21')).single;
      expect(
        (row.value, row.isFreeze, row.note, row.deletedAt),
        (0, false, 'Tired', null),
      );
      expect(
        t.engine.isDone((await t.entries.history(h.id))!, t.today),
        isFalse,
      );
    });

    test('SetNote(null) or blank on a note-only row soft-deletes it', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const SetNote('Tired'));
      await t.entries.apply(h.id, t.today, const SetNote(null));
      expect(
        (await t.physical(h.id, '2026-10-21')).single.deletedAt,
        isNotNull,
      );
      await t.entries.apply(h.id, t.today, const SetNote('Again'));
      await t.entries.apply(h.id, t.today, const SetNote('   '));
      expect(
        (await t.physical(h.id, '2026-10-21')).single.deletedAt,
        isNotNull,
      );
    });

    test('removing the note of a done day keeps it done', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const Toggle());
      await t.entries.apply(h.id, t.today, const SetNote('x'));
      await t.entries.apply(h.id, t.today, const SetNote(null));
      final row = (await t.physical(h.id, '2026-10-21')).single;
      expect((row.value, row.note, row.deletedAt), (1, null, null));
    });

    test('a note over 200 characters is rejected', () async {
      final h = await t.habit();
      await expectLater(
        t.entries.apply(h.id, t.today, SetNote('n' * 201)),
        throwsA(isA<InvalidDayInput>()),
      );
      await t.entries.apply(h.id, t.today, SetNote('n' * 200));
    });

    test('watchNotes lists notes newest first', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, d('2026-10-18'), const SetNote('old'));
      await t.entries.apply(h.id, d('2026-10-20'), const SetNote('new'));
      await t.entries.apply(h.id, d('2026-10-19'), const Toggle());
      final notes = await t.entries.watchNotes(h.id).first;
      expect(
        [for (final n in notes) (n.date.key, n.note)],
        [('2026-10-20', 'new'), ('2026-10-18', 'old')],
      );
    });
  });

  group('count values', () {
    test('Increment adds 1; reaching the target is done', () async {
      final h = await countHabit(target: 2);
      final first = await t.entries.apply(h.id, t.today, const Increment());
      expect(first.summary.current, 0);
      final second = await t.entries.apply(h.id, t.today, const Increment());
      expect(second.summary.current, 1);
      expect((await t.physical(h.id, '2026-10-21')).single.value, 2);
    });

    test('SetValue above the target is kept', () async {
      final h = await countHabit();
      await t.entries.apply(h.id, t.today, const SetValue(42));
      expect((await t.physical(h.id, '2026-10-21')).single.value, 42);
    });

    test(
      'SetValue 0 without a note soft-deletes; with a note keeps it',
      () async {
        final h = await countHabit();
        await t.entries.apply(h.id, t.today, const SetValue(3));
        await t.entries.apply(h.id, t.today, const SetValue(0));
        expect(
          (await t.physical(h.id, '2026-10-21')).single.deletedAt,
          isNotNull,
        );
        await t.entries.apply(h.id, t.today, const SetValue(3));
        await t.entries.apply(h.id, t.today, const SetNote('n'));
        await t.entries.apply(h.id, t.today, const SetValue(0));
        final row = (await t.physical(h.id, '2026-10-21')).single;
        expect((row.value, row.deletedAt), (0, null));
      },
    );

    test('Toggle on a count habit sets the target, then clears it', () async {
      final h = await countHabit(target: 8);
      await t.entries.apply(h.id, t.today, const Toggle());
      expect((await t.physical(h.id, '2026-10-21')).single.value, 8);
      await t.entries.apply(h.id, t.today, const Toggle());
      expect(
        (await t.physical(h.id, '2026-10-21')).single.deletedAt,
        isNotNull,
      );
    });

    test(
      'values outside 0–9,999 are rejected; Increment stops at 9,999',
      () async {
        final h = await countHabit();
        for (final v in [-1, 10000]) {
          await expectLater(
            t.entries.apply(h.id, t.today, SetValue(v)),
            throwsA(isA<InvalidDayInput>()),
            reason: '$v',
          );
        }
        await t.entries.apply(h.id, t.today, const SetValue(9999));
        await t.entries.apply(h.id, t.today, const Increment());
        expect((await t.physical(h.id, '2026-10-21')).single.value, 9999);
      },
    );

    test('a yes/no day holds 0 or 1', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const Increment());
      await t.entries.apply(h.id, t.today, const Increment());
      expect((await t.physical(h.id, '2026-10-21')).single.value, 1);
      await expectLater(
        t.entries.apply(h.id, t.today, const SetValue(2)),
        throwsA(isA<InvalidDayInput>()),
      );
    });

    test('Toggle uses the target in effect on that day', () async {
      final h = await countHabit(target: 10);
      await t.habits.update(
        h.id,
        HabitDraft(
          name: h.name,
          iconKey: h.iconKey,
          colorHex: h.colorHex,
          kind: h.kind,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 20),
          startDate: h.startDate,
        ),
      );
      await t.entries.apply(h.id, d('2026-10-20'), const Toggle());
      await t.entries.apply(h.id, t.today, const Toggle());
      expect((await t.physical(h.id, '2026-10-20')).single.value, 10);
      expect((await t.physical(h.id, '2026-10-21')).single.value, 20);
    });
  });

  group('freezes', () {
    test('UseFreeze uses one freeze and marks the day', () async {
      final h = await t.habit();
      await t.habits.addFreeze(h.id);
      await t.habits.addFreeze(h.id);
      final r = await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      expect(await freezes(h.id), 1);
      expect(r.before.freezesAvailableBefore, 2);
      final row = (await t.physical(h.id, '2026-10-20')).single;
      expect((row.isFreeze, row.value, row.deletedAt), (true, 0, null));
    });

    test('a freeze on a partial count day holds no progress', () async {
      final h = await countHabit();
      await t.habits.addFreeze(h.id);
      await t.entries.apply(h.id, d('2026-10-20'), const SetValue(3));
      final r = await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      final row = (await t.physical(h.id, '2026-10-20')).single;
      expect((row.isFreeze, row.value), (true, 0));
      expect(r.before.value, 3, reason: 'Undo restores the count');
    });

    test('checking a freeze day refunds the freeze', () async {
      final h = await t.habit();
      await t.habits.addFreeze(h.id);
      await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      expect(await freezes(h.id), 0);
      await t.entries.apply(h.id, d('2026-10-20'), const Toggle());
      expect(await freezes(h.id), 1);
      final row = (await t.physical(h.id, '2026-10-20')).single;
      expect((row.isFreeze, row.value), (false, 1));
    });

    test('Skip today, then done: today becomes a normal done day', () async {
      final h = await countHabit(target: 2);
      await t.habits.addFreeze(h.id);
      await t.entries.apply(h.id, t.today, const UseFreeze(allowToday: true));
      await t.entries.apply(h.id, t.today, const Increment());
      final mid = (await t.physical(h.id, '2026-10-21')).single;
      expect((mid.isFreeze, mid.value), (true, 1), reason: 'below target');
      await t.entries.apply(h.id, t.today, const Increment());
      final row = (await t.physical(h.id, '2026-10-21')).single;
      expect((row.isFreeze, row.value), (false, 2));
      expect(await freezes(h.id), 1);
    });

    test('the refund is capped at 2', () async {
      final h = await t.habit();
      await t.habits.addFreeze(h.id);
      await t.habits.addFreeze(h.id);
      await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      expect(await t.habits.addFreeze(h.id), 2);
      await t.entries.apply(h.id, d('2026-10-20'), const Toggle());
      expect(await freezes(h.id), 2);
    });

    test('policy errors propagate and change nothing', () async {
      final h = await t.habit();
      await expectLater(
        t.entries.apply(
          h.id,
          d('2026-10-20'),
          const UseFreeze(allowToday: false),
        ),
        throwsA(isA<NoFreezesLeft>()),
      );
      await t.habits.addFreeze(h.id);
      await expectLater(
        t.entries.apply(h.id, t.today, const UseFreeze(allowToday: false)),
        throwsA(
          isA<FreezeNotAllowed>().having(
            (e) => e.reason,
            'reason',
            FreezeRejection.today,
          ),
        ),
      );
      await expectLater(
        t.entries.apply(
          h.id,
          d('2026-10-17'),
          const UseFreeze(allowToday: false),
        ),
        throwsA(isA<FreezeNotAllowed>()),
      );
      expect(await freezes(h.id), 1);
      expect(await t.physical(h.id, '2026-10-20'), isEmpty);
    });
  });

  group('Restore (Undo)', () {
    test('puts back a removed check-in exactly', () async {
      final h = await t.habit();
      await t.entries.apply(h.id, t.today, const Toggle());
      await t.entries.apply(h.id, t.today, const SetNote('kept'));
      final off = await t.entries.apply(h.id, t.today, const Toggle());
      expect(off.before.wasLive, isTrue);
      await t.entries.apply(h.id, t.today, Restore(off.before));
      final row = (await t.physical(h.id, '2026-10-21')).single;
      expect(
        (row.value, row.note, row.isFreeze, row.deletedAt),
        (1, 'kept', false, null),
      );
    });

    test('removes a new check-in again', () async {
      final h = await t.habit();
      final on = await t.entries.apply(h.id, t.today, const Toggle());
      expect(on.before.wasLive, isFalse);
      final undone = await t.entries.apply(h.id, t.today, Restore(on.before));
      expect(
        (await t.physical(h.id, '2026-10-21')).single.deletedAt,
        isNotNull,
      );
      expect(undone.summary.current, 0);
    });

    test('returns the freeze count to its previous value', () async {
      final h = await t.habit();
      await t.habits.addFreeze(h.id);
      final used = await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      expect(await freezes(h.id), 0);
      await t.entries.apply(h.id, d('2026-10-20'), Restore(used.before));
      expect(await freezes(h.id), 1);
      expect(
        (await t.physical(h.id, '2026-10-20')).single.deletedAt,
        isNotNull,
      );
    });

    test('restores a partial count that a freeze replaced', () async {
      final h = await countHabit();
      await t.habits.addFreeze(h.id);
      await t.entries.apply(h.id, d('2026-10-20'), const SetValue(3));
      final used = await t.entries.apply(
        h.id,
        d('2026-10-20'),
        const UseFreeze(allowToday: false),
      );
      await t.entries.apply(h.id, d('2026-10-20'), Restore(used.before));
      final row = (await t.physical(h.id, '2026-10-20')).single;
      expect((row.value, row.isFreeze, row.deletedAt), (3, false, null));
      expect(await freezes(h.id), 1);
    });
  });

  group('DayNotEditable', () {
    test('future days and days before the start', () async {
      final h = await t.habit(start: '2026-10-10');
      for (final key in ['2026-10-22', '2026-10-09']) {
        await expectLater(
          t.entries.apply(h.id, d(key), const Toggle()),
          throwsA(isA<DayNotEditable>()),
          reason: key,
        );
      }
      await t.entries.apply(h.id, d('2026-10-10'), const Toggle());
    });

    test('an unknown habit throws HabitNotFound', () async {
      await expectLater(
        t.entries.apply('nope', t.today, const Toggle()),
        throwsA(isA<HabitNotFound>()),
      );
    });
  });

  group('reading', () {
    test('watchActiveHistories: live entries on or after from, of active '
        'habits only', () async {
      final a = await t.habit(name: 'A');
      final b = await t.habit(name: 'B');
      final archived = await t.habit(name: 'Archived');
      for (final key in ['2026-10-10', '2026-10-15', '2026-10-20']) {
        await t.entries.apply(a.id, d(key), const Toggle());
      }
      await t.entries.apply(a.id, d('2026-10-16'), const Toggle());
      await t.entries.apply(a.id, d('2026-10-16'), const Toggle()); // deleted
      await t.entries.apply(archived.id, t.today, const Toggle());
      await t.habits.archive(archived.id);

      final histories = await t.entries
          .watchActiveHistories(from: d('2026-10-15'))
          .first;
      expect([for (final h in histories) h.habitId], [a.id, b.id]);
      expect(
        [for (final day in histories.first.entries.keys) day.key]..sort(),
        ['2026-10-15', '2026-10-20'],
      );
      expect(histories.first.loadedFrom, d('2026-10-15'));
      expect(histories.last.entries, isEmpty);
      expect(histories.first.versions, hasLength(1));
    });

    test('watchActiveHistories: no loadedFrom when the start is inside the '
        'window', () async {
      await t.habit(start: '2026-10-18');
      final histories = await t.entries
          .watchActiveHistories(from: d('2026-10-15'))
          .first;
      expect(histories.single.loadedFrom, isNull);
    });

    test('watchActiveHistories is empty without habits', () async {
      expect(
        await t.entries.watchActiveHistories(from: d('2026-10-15')).first,
        isEmpty,
      );
    });

    test(
      'watchHistory is the full history and re-emits after a write',
      () async {
        final h = await t.habit();
        await t.entries.apply(h.id, d('2026-10-02'), const Toggle());
        final sizes = <int>[];
        final sub = t.entries
            .watchHistory(h.id)
            .listen((x) => sizes.add(x!.entries.length));
        addTearDown(sub.cancel);
        await pumpEventQueue();
        await t.entries.apply(h.id, t.today, const Toggle());
        await pumpEventQueue();
        expect(sizes, [1, 2]);
      },
    );

    test('watchHistory emits null for an unknown habit', () async {
      expect(await t.entries.watchHistory('nope').first, isNull);
    });
  });

  test('HAB-01 criterion "Back-filling yesterday restores a broken streak" '
      '(data level)', () async {
    final h = await t.habit(start: '2026-10-15');
    for (final key in [
      '2026-10-15',
      '2026-10-16',
      '2026-10-17',
      '2026-10-18',
      '2026-10-19',
    ]) {
      await t.entries.apply(h.id, d(key), const Toggle());
    }
    final today = await t.entries.apply(h.id, t.today, const Toggle());
    expect(today.summary.current, 1);
    expect(today.summary.best, 5);

    final filled = await t.entries.apply(h.id, d('2026-10-20'), const Toggle());
    expect(filled.summary.current, 7);
    expect(filled.summary.best, 7);
    expect(filled.summary.completionRate, 100);
    expect(filled.milestone, Milestone.d7, reason: 'the back-fill reaches 7');
  });

  group('milestones', () {
    test('shown once per milestone per habit, also after a rebuild', () async {
      final h = await t.habit(start: '2026-10-15');
      final shown = <Milestone?>[];
      for (var day = 15; day <= 21; day++) {
        final r = await t.entries.apply(
          h.id,
          LocalDate(2026, 10, day),
          const Toggle(),
        );
        shown.add(r.milestone);
      }
      expect(shown, [null, null, null, null, null, null, Milestone.d7]);
      // Break the streak and rebuild it.
      await t.entries.apply(h.id, d('2026-10-18'), const Toggle());
      final rebuilt = await t.entries.apply(
        h.id,
        d('2026-10-18'),
        const Toggle(),
      );
      expect(rebuilt.summary.current, 7);
      expect(rebuilt.milestone, isNull);
      expect((await t.habits.byId(h.id))!.celebratedMilestones, {Milestone.d7});
    });

    test('a weekly habit counts weeks', () async {
      final h = await t.habit(
        start: '2026-09-07',
        schedule: const HabitSchedule(
          type: ScheduleType.timesPerWeek,
          target: 1,
          timesPerWeek: 1,
        ),
      );
      // Mondays Sep 7 … Oct 19: 7 weeks.
      final results = [
        for (
          var day = d('2026-09-07');
          !day.isAfter(t.today);
          day = day.addDays(7)
        )
          await t.entries.apply(h.id, day, const Toggle()),
      ];
      expect(results.last.summary.current, 7);
      expect(results.last.milestone, Milestone.d7);
    });
  });
}
