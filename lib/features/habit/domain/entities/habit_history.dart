import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_history.freezed.dart';

/// Input of the streak engine: a habit's settings over time and its live
/// entries (research R6).
@freezed
abstract class HabitHistory with _$HabitHistory {
  const factory({
    required String habitId,
    required HabitKind kind,
    required LocalDate startDate,

    /// Oldest first; never empty.
    required List<ScheduleVersion> versions,
    required Map<LocalDate, HabitEntry> entries,

    /// Set when only entries on or after this day were loaded (research R7);
    /// streaks reaching it may be longer than computed.
    LocalDate? loadedFrom,
  }) = _HabitHistory;
}
