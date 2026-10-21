import 'package:dailytrack/features/habit/domain/entities/habit.dart';

/// Habits store (contracts/repositories.md "HabitRepository"). Deleted
/// habits are excluded everywhere. Failures surface as `HabitStorageFailure`.
abstract interface class HabitRepository {
  /// Active (not archived, not deleted) habits in sort order.
  Stream<List<Habit>> watchActive();

  /// Archived habits, most recently archived first.
  Stream<List<Habit>> watchArchived();

  /// Emits null once the habit is deleted or missing.
  Stream<Habit?> watchById(String id);

  Future<Habit?> byId(String id);

  /// One-shot list of active habits, e.g. for reminders.
  Future<List<Habit>> activeHabits();

  /// Creates the habit at the end of the list, with schedule version 1
  /// effective from its start date (research R3).
  Future<Habit> create(HabitDraft draft);

  /// Saves an edit. A changed schedule or target is recorded as a version
  /// effective from today (same-day versions are replaced), so past days
  /// keep their settings (research R3). Throws `HabitNotFound`, `KindLocked`.
  Future<Habit> update(String id, HabitDraft draft);

  /// Sets `archivedAt`; keeps the sort position for Undo.
  Future<void> archive(String id);

  /// Undo of [archive]: active again at the same sort position.
  Future<void> undoArchive(String id);

  /// HAB-04 Restore: active again at the end of the list (data-model §6).
  Future<void> restore(String id);

  /// Soft-deletes the habit, its schedule versions, and its entries in one
  /// transaction.
  Future<void> delete(String id);

  /// Rewrites the sort order of the given active habits to 0..n-1.
  Future<void> reorder(List<String> idsInOrder);

  /// Dev-only freeze grant (research R9). Returns the new count; no change
  /// at the cap of 2.
  Future<int> addFreeze(String id);
}
