import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/tables/habit_schedules_table.dart';
import 'package:dailytrack/features/habit/data/tables/habits_table.dart';
import 'package:drift/drift.dart';

part 'habits_dao.g.dart';

/// Habits and schedule-version queries (research R3, R8, R9). Every query
/// excludes soft-deleted rows unless its name says otherwise.
@DriftAccessor(tables: [Habits, HabitSchedules])
class HabitsDao extends DatabaseAccessor<AppDatabase> with _$HabitsDaoMixin {
  new(super.attachedDatabase);

  SimpleSelectStatement<$HabitsTable, HabitRow> _activeQuery() => select(habits)
    ..where((h) => h.deletedAt.isNull() & h.isArchived.equals(false))
    ..orderBy([
      (h) => OrderingTerm.asc(h.sortOrder),
      (h) => OrderingTerm.asc(h.createdAt),
    ]);

  SimpleSelectStatement<$HabitsTable, HabitRow> _archivedQuery() =>
      select(habits)
        ..where((h) => h.deletedAt.isNull() & h.isArchived.equals(true))
        ..orderBy([(h) => OrderingTerm.desc(h.archivedAt)]);

  Future<List<HabitRow>> active() => _activeQuery().get();

  Stream<List<HabitRow>> watchActive() => _activeQuery().watch();

  Stream<List<HabitRow>> watchArchived() => _archivedQuery().watch();

  Future<HabitRow?> liveById(String id) => (select(
    habits,
  )..where((h) => h.id.equals(id) & h.deletedAt.isNull())).getSingleOrNull();

  Stream<HabitRow?> watchLiveById(String id) => (select(
    habits,
  )..where((h) => h.id.equals(id) & h.deletedAt.isNull())).watchSingleOrNull();

  /// The next free sort position at the end of the active list.
  Future<int> nextSortOrder() async {
    final max = habits.sortOrder.max();
    final q = selectOnly(habits)
      ..addColumns([max])
      ..where(habits.deletedAt.isNull() & habits.isArchived.equals(false));
    return ((await q.getSingle()).read(max) ?? -1) + 1;
  }

  Future<void> insertHabit(HabitsCompanion row) => into(habits).insert(row);

  /// Updates a live habit; returns the number of rows changed.
  Future<int> updateLive(String id, HabitsCompanion row) => (update(
    habits,
  )..where((h) => h.id.equals(id) & h.deletedAt.isNull())).write(row);

  /// Compare-and-set on the milestone bits (research R8). Returns true only
  /// when this call changed them.
  Future<bool> casMilestones(
    String id, {
    required int from,
    required int to,
  }) async {
    final changed =
        await (update(habits)..where(
              (h) =>
                  h.id.equals(id) &
                  h.deletedAt.isNull() &
                  h.celebratedMilestones.equals(from),
            ))
            .write(HabitsCompanion(celebratedMilestones: Value(to)));
    return changed == 1;
  }

  /// Changes the freeze count by [delta] only while the result stays within
  /// 0–2. Returns true when it changed.
  Future<bool> addFreezes(String id, int delta) async {
    final changed = await customUpdate(
      'UPDATE habits SET freezes_available = freezes_available + ? '
      'WHERE id = ? AND deleted_at IS NULL '
      'AND freezes_available + ? BETWEEN 0 AND 2',
      variables: [
        Variable.withInt(delta),
        Variable.withString(id),
        Variable.withInt(delta),
      ],
      updates: {habits},
      updateKind: UpdateKind.update,
    );
    return changed == 1;
  }

  /// Live schedule versions of [habitId], oldest first.
  Future<List<HabitScheduleRow>> versionsOf(String habitId) =>
      (select(habitSchedules)
            ..where((s) => s.habitId.equals(habitId) & s.deletedAt.isNull())
            ..orderBy([(s) => OrderingTerm.asc(s.effectiveFromKey)]))
          .get();

  /// Live schedule versions of several habits, oldest first.
  Future<List<HabitScheduleRow>> versionsOfAll(Iterable<String> habitIds) =>
      (select(habitSchedules)
            ..where(
              (s) => s.habitId.isIn(habitIds.toList()) & s.deletedAt.isNull(),
            )
            ..orderBy([(s) => OrderingTerm.asc(s.effectiveFromKey)]))
          .get();

  Future<HabitScheduleRow?> versionAt(
    String habitId,
    String effectiveFromKey,
  ) =>
      (select(habitSchedules)..where(
            (s) =>
                s.habitId.equals(habitId) &
                s.effectiveFromKey.equals(effectiveFromKey) &
                s.deletedAt.isNull(),
          ))
          .getSingleOrNull();

  Future<void> insertVersion(HabitSchedulesCompanion row) =>
      into(habitSchedules).insert(row);

  Future<void> updateVersion(String id, HabitSchedulesCompanion row) =>
      (update(habitSchedules)..where((s) => s.id.equals(id))).write(row);

  Future<void> softDeleteVersions(String habitId, int now) =>
      (update(habitSchedules)
            ..where((s) => s.habitId.equals(habitId) & s.deletedAt.isNull()))
          .write(HabitSchedulesCompanion(deletedAt: Value(now)));
}
