import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_op.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';

/// Habit days store (contracts/repositories.md "HabitEntryRepository").
/// Streams re-emit after every change made anywhere in the app (FR-007).
abstract interface class HabitEntryRepository {
  /// Histories of all active habits with live entries on or after [from]
  /// (HAB-01 and Home window, research R7). Notes are not loaded.
  Stream<List<HabitHistory>> watchActiveHistories({required LocalDate from});

  /// Full history of one habit, or null once it is deleted.
  Stream<HabitHistory?> watchHistory(String habitId);

  Future<HabitHistory?> history(String habitId);

  /// Live entries with a note, newest first (HAB-03 notes list).
  Stream<List<HabitEntry>> watchNotes(String habitId);

  /// Applies [op] to [date] in one transaction: the entry, the freeze count,
  /// and the milestone compare-and-set (research R8, data-model §6).
  /// Throws `HabitNotFound`, `DayNotEditable`, `FreezeNotAllowed`,
  /// `NoFreezesLeft`, `InvalidDayInput`.
  Future<DayWriteResult> apply(String habitId, LocalDate date, DayOp op);
}
