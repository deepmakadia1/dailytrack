import 'package:dailytrack/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v4 habit tables (data-model.md §3, T012–T014): every CHECK, the
/// full unique entry index (research R4), the partial unique schedule index,
/// and the foreign keys, on a real in-memory database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get(); // runs onCreate + beforeOpen
  });
  tearDown(() => db.close());

  const t0 = 1760000000000;

  Future<void> insert(String table, Map<String, Object?> row) {
    final columns = row.keys.join(', ');
    final marks = List.filled(row.length, '?').join(', ');
    return db.customInsert(
      'INSERT INTO $table ($columns) VALUES ($marks)',
      variables: [for (final v in row.values) _variable(v)],
    );
  }

  Map<String, Object?> habit([Map<String, Object?> overrides = const {}]) => {
    'id': 'h1',
    'name': 'Read',
    'icon_key': 'book',
    'color_hex': '#0F766E',
    'kind': 0,
    'target_value': 1,
    'unit': null,
    'schedule_type': 0,
    'weekdays_mask': 0,
    'times_per_week': null,
    'start_date_key': '2026-10-01',
    'sort_order': 0,
    'created_at': t0,
    'updated_at': t0,
    ...overrides,
  };

  Map<String, Object?> schedule([Map<String, Object?> overrides = const {}]) =>
      {
        'id': 's1',
        'habit_id': 'h1',
        'effective_from_key': '2026-10-01',
        'schedule_type': 0,
        'weekdays_mask': 0,
        'times_per_week': null,
        'target_value': 1,
        'created_at': t0,
        'updated_at': t0,
        ...overrides,
      };

  Map<String, Object?> entry([Map<String, Object?> overrides = const {}]) => {
    'id': 'e1',
    'habit_id': 'h1',
    'date_key': '2026-10-21',
    'value': 1,
    'created_at': t0,
    'updated_at': t0,
    ...overrides,
  };

  Matcher rejects() => throwsA(isA<SqliteException>());

  test('a valid row in each table is accepted with the defaults', () async {
    await insert('habits', habit());
    await insert('habit_schedules', schedule());
    await insert('habit_entries', entry());
    final h = await db.customSelect('SELECT * FROM habits').getSingle();
    expect(h.data['reminder_times'], '[]');
    expect(h.data['remind_only_if_not_done'], 1);
    expect(h.data['is_archived'], 0);
    expect(h.data['freezes_available'], 0);
    expect(h.data['celebrated_milestones'], 0);
    final e = await db.customSelect('SELECT * FROM habit_entries').getSingle();
    expect(e.data['is_freeze'], 0);
  });

  group('habits CHECKs', () {
    final bad = <String, Map<String, Object?>>{
      'blank name': {'name': '   '},
      '41-char name': {'name': 'x' * 41},
      'yes/no target 2': {'target_value': 2},
      'count target 0': {'kind': 1, 'target_value': 0},
      'count target 10000': {'kind': 1, 'target_value': 10000},
      '21-char unit': {'kind': 1, 'target_value': 5, 'unit': 'u' * 21},
      'weekdays mask 128': {'weekdays_mask': 128},
      'weekdays mask -1': {'weekdays_mask': -1},
      'times per week 0': {'times_per_week': 0},
      'times per week 7': {'times_per_week': 7},
      'freezes 3': {'freezes_available': 3},
      'freezes -1': {'freezes_available': -1},
      'milestones 64': {'celebrated_milestones': 64},
      'milestones -1': {'celebrated_milestones': -1},
      'bad start key': {'start_date_key': '21-10-2026'},
    };
    for (final MapEntry(key: name, value: overrides) in bad.entries) {
      test('rejects $name', () async {
        await expectLater(insert('habits', habit(overrides)), rejects());
      });
    }

    test('accepts the edges', () async {
      await insert('habits', habit({'id': 'a', 'name': 'x' * 40}));
      await insert(
        'habits',
        habit({
          'id': 'b',
          'kind': 1,
          'target_value': 9999,
          'unit': 'u' * 20,
          'weekdays_mask': 127,
          'times_per_week': 6,
          'freezes_available': 2,
          'celebrated_milestones': 63,
        }),
      );
      await insert('habits', habit({'id': 'c', 'name': '  Read  '}));
    });
  });

  group('habit_schedules CHECKs', () {
    setUp(() => insert('habits', habit()));

    final bad = <String, Map<String, Object?>>{
      'target 0': {'target_value': 0},
      'target 10000': {'target_value': 10000},
      'weekdays mask 128': {'weekdays_mask': 128},
      'times per week 7': {'times_per_week': 7},
      'bad key': {'effective_from_key': '2026/10/01'},
      'unknown habit': {'habit_id': 'nope'},
    };
    for (final MapEntry(key: name, value: overrides) in bad.entries) {
      test('rejects $name', () async {
        await expectLater(
          insert('habit_schedules', schedule(overrides)),
          rejects(),
        );
      });
    }

    test('two live versions on the same day fail', () async {
      await insert('habit_schedules', schedule());
      await expectLater(
        insert('habit_schedules', schedule({'id': 's2'})),
        rejects(),
      );
    });

    test('a live and a deleted version on the same day are fine', () async {
      await insert('habit_schedules', schedule({'deleted_at': t0}));
      await insert('habit_schedules', schedule({'id': 's2'}));
      await insert(
        'habit_schedules',
        schedule({'id': 's3', 'deleted_at': t0 + 1}),
      );
      final rows = await db.customSelect('SELECT * FROM habit_schedules').get();
      expect(rows, hasLength(3));
    });
  });

  group('habit_entries CHECKs', () {
    setUp(() => insert('habits', habit()));

    final bad = <String, Map<String, Object?>>{
      'value -1': {'value': -1},
      'value 10000': {'value': 10000},
      '201-char note': {'note': 'n' * 201},
      'bad key': {'date_key': '2026-10-1'},
      'unknown habit': {'habit_id': 'nope'},
    };
    for (final MapEntry(key: name, value: overrides) in bad.entries) {
      test('rejects $name', () async {
        await expectLater(insert('habit_entries', entry(overrides)), rejects());
      });
    }

    test('accepts the edges', () async {
      await insert('habit_entries', entry({'value': 0, 'note': 'n' * 200}));
      await insert(
        'habit_entries',
        entry({'id': 'e2', 'date_key': '2026-10-20', 'value': 9999}),
      );
    });

    test('a second physical row for the same habit and day fails, even when '
        'the first is soft-deleted (research R4)', () async {
      await insert('habit_entries', entry({'deleted_at': t0}));
      await expectLater(
        insert('habit_entries', entry({'id': 'e2'})),
        rejects(),
      );
    });

    test('the same day for another habit is fine', () async {
      await insert('habits', habit({'id': 'h2', 'sort_order': 1}));
      await insert('habit_entries', entry());
      await insert('habit_entries', entry({'id': 'e2', 'habit_id': 'h2'}));
    });
  });

  test('the 4 habit indexes exist', () async {
    final names = {
      for (final r
          in await db
              .customSelect(
                "SELECT name FROM sqlite_master WHERE type = 'index'",
              )
              .get())
        r.data['name'],
    };
    expect(
      names,
      containsAll([
        'habits_active_order',
        'habit_schedules_habit_from_unique',
        'habit_entries_habit_date_unique',
        'habit_entries_date',
      ]),
    );
  });
}

Variable<Object> _variable(Object? value) => switch (value) {
  null => const Variable(null),
  final int v => Variable.withInt(v),
  final String v => Variable.withString(v),
  _ => throw ArgumentError.value(value),
};
