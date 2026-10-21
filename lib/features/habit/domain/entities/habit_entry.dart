import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_entry.freezed.dart';

/// One live `habit_entries` row: one habit on one local day (spec §4).
@freezed
abstract class HabitEntry with _$HabitEntry {
  const factory({
    required String habitId,
    required LocalDate date,

    /// 1 for a done yes/no day, or the count achieved; 0 on a note-only or
    /// freeze day.
    required int value,
    required bool isFreeze,

    /// At most 200 characters.
    String? note,
  }) = _HabitEntry;
}

/// The state of one day before a write, so Undo can put it back exactly
/// (research R8).
@freezed
abstract class EntrySnapshot with _$EntrySnapshot {
  const factory({
    required String habitId,
    required LocalDate date,

    /// Whether a live row existed.
    required bool wasLive,
    required int value,
    required bool isFreeze,
    required int freezesAvailableBefore,
    String? note,
  }) = _EntrySnapshot;
}
