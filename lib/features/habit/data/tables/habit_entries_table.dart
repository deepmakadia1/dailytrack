// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/habit/data/habit_tables_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/habit/data/tables/habits_table.dart';
import 'package:drift/drift.dart';

/// One habit on one local day (spec §4, data-model.md §3.3). Added in
/// schema v4. The unique index is full, not partial: there is one physical
/// row per habit and day, live or soft-deleted (research R4).
@DataClassName('HabitEntryRow')
@TableIndex(
  name: 'habit_entries_habit_date_unique',
  columns: {#habitId, #dateKey},
  unique: true,
)
@TableIndex(name: 'habit_entries_date', columns: {#dateKey})
class HabitEntries extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  TextColumn get habitId => text().references(Habits, #id)();

  /// Local `yyyy-MM-dd`.
  TextColumn get dateKey => text()();

  /// 1 for a done yes/no day, or the count achieved.
  IntColumn get value => integer().check(value.isBetweenValues(0, 9999))();

  BoolColumn get isFreeze => boolean().withDefault(const Constant(false))();

  TextColumn get note => text().nullable().check(
    note.isNull() | note.length.isSmallerOrEqualValue(200),
  )();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<String> get customConstraints => const [
    "CHECK (date_key GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]')",
  ];
}
