import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_summary.freezed.dart';

/// What streaks count: days, or weeks for "times per week" habits.
enum StreakUnit { days, weeks }

/// Computed statistics of one habit (HAB-03 stat tiles, research R6).
@freezed
abstract class StreakSummary with _$StreakSummary {
  const factory({
    required int current,
    required int best,
    required int totalCompletions,
    required StreakUnit unit,

    /// Whole percent over the last 30 days, or null when no day (week)
    /// counts yet.
    int? completionRate,
  }) = _StreakSummary;
}
