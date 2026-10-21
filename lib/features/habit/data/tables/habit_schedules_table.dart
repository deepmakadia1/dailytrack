// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/habit/data/habit_tables_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/habit/data/tables/habits_table.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';

/// A habit's schedule and target from a local date onward (data-model.md
/// §3.2, research R3). Added in schema v4.
@DataClassName('HabitScheduleRow')
@TableIndex.sql(
  'CREATE UNIQUE INDEX habit_schedules_habit_from_unique ON habit_schedules '
  '(habit_id, effective_from_key) WHERE deleted_at IS NULL',
)
class HabitSchedules extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  TextColumn get habitId => text().references(Habits, #id)();

  /// Local `yyyy-MM-dd` the version takes effect.
  TextColumn get effectiveFromKey => text()();

  IntColumn get scheduleType => intEnum<ScheduleType>()();

  /// Mon=1 … Sun=64.
  IntColumn get weekdaysMask =>
      integer().check(weekdaysMask.isBetweenValues(0, 127))();

  IntColumn get timesPerWeek => integer().nullable().check(
    timesPerWeek.isNull() | timesPerWeek.isBetweenValues(1, 6),
  )();

  /// The habit's kind decides whether 1 or 1–9,999 is valid.
  IntColumn get targetValue =>
      integer().check(targetValue.isBetweenValues(1, 9999))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Set together with the habit's.
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  static const String _dateKeyFormat =
      'CHECK (effective_from_key GLOB '
      "'[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]')";

  @override
  List<String> get customConstraints => const [_dateKeyFormat];
}
