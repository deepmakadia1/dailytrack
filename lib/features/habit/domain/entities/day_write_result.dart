import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'day_write_result.freezed.dart';

/// Outcome of one day write (contracts/repositories.md).
@freezed
abstract class DayWriteResult with _$DayWriteResult {
  const factory({
    /// The day before the write, for Undo.
    required EntrySnapshot before,

    /// Statistics after the write.
    required StreakSummary summary,

    /// The highest milestone this write celebrated for the first time.
    Milestone? milestone,
  }) = _DayWriteResult;
}
