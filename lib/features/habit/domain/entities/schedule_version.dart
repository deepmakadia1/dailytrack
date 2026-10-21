import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_version.freezed.dart';

/// A habit's schedule and target from [effectiveFrom] onward (research R3).
@freezed
abstract class ScheduleVersion with _$ScheduleVersion {
  const factory({
    required LocalDate effectiveFrom,
    required HabitSchedule schedule,
  }) = _ScheduleVersion;
}
