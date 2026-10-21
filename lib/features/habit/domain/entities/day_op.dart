import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// A change to one habit day, applied atomically by
/// `HabitEntryRepository.apply` (research R8, data-model.md §6).
@immutable
sealed class DayOp {
  const new();
}

/// Done ↔ not done. Done sets the value to the day's target.
final class Toggle extends DayOp {
  const new();
}

/// Count habits: +1.
final class Increment extends DayOp {
  const new();
}

/// Count habits: an exact value, 0–9,999.
final class SetValue extends DayOp {
  const new(this.value);

  final int value;
}

/// Adds, changes, or (null or blank) removes the day's note.
final class SetNote extends DayOp {
  const new(this.note);

  final String? note;
}

/// Puts a stored freeze on the day. [allowToday] is true only for HAB-01
/// "Skip today" (clarification Q1).
final class UseFreeze extends DayOp {
  const new({required this.allowToday});

  final bool allowToday;
}

/// Undo: puts the day and the freeze count back to [snapshot].
final class Restore extends DayOp {
  const new(this.snapshot);

  final EntrySnapshot snapshot;
}
