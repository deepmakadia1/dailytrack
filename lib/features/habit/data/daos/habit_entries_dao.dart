import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/tables/habit_entries_table.dart';
import 'package:drift/drift.dart';

part 'habit_entries_dao.g.dart';

/// Habit day queries (research R4, R7). Every query excludes soft-deleted
/// rows unless its name says otherwise.
@DriftAccessor(tables: [HabitEntries])
class HabitEntriesDao extends DatabaseAccessor<AppDatabase>
    with _$HabitEntriesDaoMixin {
  new(super.attachedDatabase);

  /// The one physical row of a habit and day, live or soft-deleted
  /// (research R4).
  Future<HabitEntryRow?> physicalRow(String habitId, String dateKey) =>
      (select(habitEntries)..where(
            (e) => e.habitId.equals(habitId) & e.dateKey.equals(dateKey),
          ))
          .getSingleOrNull();

  Future<void> insertRow(HabitEntriesCompanion row) =>
      into(habitEntries).insert(row);

  Future<void> updateRow(String id, HabitEntriesCompanion row) =>
      (update(habitEntries)..where((e) => e.id.equals(id))).write(row);

  /// Every live entry of [habitId].
  Future<List<HabitEntryRow>> liveOf(String habitId) => (select(
    habitEntries,
  )..where((e) => e.habitId.equals(habitId) & e.deletedAt.isNull())).get();

  /// Live entries of [habitIds] on or after [fromKey] (research R7).
  Future<List<HabitEntryRow>> liveSince(
    Iterable<String> habitIds,
    String fromKey,
  ) =>
      (select(habitEntries)..where(
            (e) =>
                e.habitId.isIn(habitIds.toList()) &
                e.deletedAt.isNull() &
                e.dateKey.isBiggerOrEqualValue(fromKey),
          ))
          .get();

  /// Live entries of [habitId] that carry a note, newest first.
  Future<List<HabitEntryRow>> notesOf(String habitId) =>
      (select(habitEntries)
            ..where(
              (e) =>
                  e.habitId.equals(habitId) &
                  e.deletedAt.isNull() &
                  e.note.isNotNull(),
            )
            ..orderBy([(e) => OrderingTerm.desc(e.dateKey)]))
          .get();

  Future<void> softDeleteAllOf(String habitId, int now) =>
      (update(habitEntries)
            ..where((e) => e.habitId.equals(habitId) & e.deletedAt.isNull()))
          .write(HabitEntriesCompanion(deletedAt: Value(now)));
}
