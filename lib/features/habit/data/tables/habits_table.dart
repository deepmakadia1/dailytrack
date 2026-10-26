// coverage:ignore-file
// Drift schema DSL: read by the code generator, never executed at runtime.
// The schema itself is verified by test/drift/app_database/migration_test.dart
// and test/features/habit/data/habit_tables_test.dart.
// Drift column check() constraints reference their own column by design.
// ignore_for_file: recursive_getters

import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:drift/drift.dart';

/// Habits (spec §4, data-model.md §3.1). Added in schema v4. The schedule
/// and target columns mirror the newest `habit_schedules` row (research R3).
@DataClassName('HabitRow')
@TableIndex(
  name: 'habits_active_order',
  columns: {#deletedAt, #isArchived, #sortOrder},
)
class Habits extends Table {
  /// UUID v4.
  TextColumn get id => text()();

  /// 1–40 characters after trimming.
  TextColumn get name => text()();

  TextColumn get iconKey => text()();
  TextColumn get colorHex => text()();

  /// Fixed after create.
  IntColumn get kind => intEnum<HabitKind>()();

  /// 1 for yes/no; 1–9,999 for count (CHECK in [customConstraints]).
  IntColumn get targetValue => integer()();

  /// Count habits only.
  TextColumn get unit => text().nullable().check(
    unit.isNull() | unit.length.isSmallerOrEqualValue(20),
  )();

  IntColumn get scheduleType => intEnum<ScheduleType>()();

  /// Mon=1 … Sun=64.
  IntColumn get weekdaysMask =>
      integer().check(weekdaysMask.isBetweenValues(0, 127))();

  IntColumn get timesPerWeek => integer().nullable().check(
    timesPerWeek.isNull() | timesPerWeek.isBetweenValues(1, 6),
  )();

  /// JSON list of distinct `HH:mm`, 0–3 items, sorted.
  TextColumn get reminderTimes => text().withDefault(const Constant('[]'))();

  BoolColumn get remindOnlyIfNotDone =>
      boolean().withDefault(const Constant(true))();

  /// Local `yyyy-MM-dd`.
  TextColumn get startDateKey => text()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  /// UTC ms; set while archived.
  IntColumn get archivedAt => integer().nullable()();

  IntColumn get sortOrder => integer()();

  /// Stored streak freezes (FR-034).
  IntColumn get freezesAvailable => integer()
      .withDefault(const Constant(0))
      .check(freezesAvailable.isBetweenValues(0, 2))();

  /// Bit i = `Milestone.values[i]` was celebrated (FR-044).
  IntColumn get celebratedMilestones => integer()
      .withDefault(const Constant(0))
      .check(celebratedMilestones.isBetweenValues(0, 63))();

  /// UTC epoch milliseconds.
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();

  /// Soft delete (Constitution III).
  IntColumn get deletedAt => integer().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  // Literals only: `make-migrations` drops constraints given as constant
  // references from the schema snapshot.
  @override
  List<String> get customConstraints => const [
    'CHECK (length(trim(name)) BETWEEN 1 AND 40)',
    // Yes/no habits always have target 1; count habits 1–9,999.
    // ignore: lines_longer_than_80_chars, one literal for the snapshot
    'CHECK ((kind = 0 AND target_value = 1) OR (kind = 1 AND target_value BETWEEN 1 AND 9999))',
    "CHECK (start_date_key GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]-[0-3][0-9]')",
  ];
}
