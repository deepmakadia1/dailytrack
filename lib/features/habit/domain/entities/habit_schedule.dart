import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit_schedule.freezed.dart';

/// When a habit is due and what counts as done (spec §4 schedule columns,
/// data-model.md §5). Kept per date in `habit_schedules` (research R3).
@freezed
abstract class HabitSchedule with _$HabitSchedule {
  const factory({
    required ScheduleType type,

    /// 1 for yes/no habits; 1–9,999 for count habits.
    required int target,

    /// Selected weekdays, 1 = Monday … 7 = Sunday. Used by
    /// [ScheduleType.specificWeekdays] only.
    @Default(<int>{}) Set<int> weekdays,

    /// 1–6. Used by [ScheduleType.timesPerWeek] only.
    int? timesPerWeek,
  }) = _HabitSchedule;

  const new _();

  /// Builds a schedule from the stored bitmask (Mon=1 … Sun=64).
  factory fromMask({
    required ScheduleType type,
    required int target,
    required int weekdaysMask,
    int? timesPerWeek,
  }) => HabitSchedule(
    type: type,
    target: target,
    weekdays: {
      for (var d = 1; d <= 7; d++)
        if (weekdaysMask & (1 << (d - 1)) != 0) d,
    },
    timesPerWeek: timesPerWeek,
  );

  /// Bitmask stored in `weekdays_mask`: Mon=1 … Sun=64.
  int get weekdaysMask => weekdays.fold(0, (mask, d) => mask | (1 << (d - 1)));
}
