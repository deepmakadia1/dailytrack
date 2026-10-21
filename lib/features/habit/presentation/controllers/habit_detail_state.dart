import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habit_detail_state.freezed.dart';

/// HAB-03 state (contracts/screens.md). [notFound] once the habit is
/// deleted or archived away.
@freezed
abstract class HabitDetailState with _$HabitDetailState {
  const factory({
    @Default(AsyncLoading<HabitDetailData>()) AsyncValue<HabitDetailData> data,
    @Default(false) bool notFound,
  }) = _HabitDetailState;
}

@freezed
abstract class HabitDetailData with _$HabitDetailData {
  const factory({
    required Habit habit,
    required StreakSummary summary,
    required HabitDetailViewModel vm,
    required ScheduleTextData schedule,

    /// Entries with notes, newest first (US5-6).
    required List<HabitEntry> notes,
    required bool advancedReportsUnlocked,

    /// Dev tools available and "Unlock all features (debug)" on (FR-037).
    required bool showDebugFreezeButton,

    /// Missed days 1–3 back a freeze can go on (FR-035), newest first.
    required List<LocalDate> freezeableDays,
  }) = _HabitDetailData;
}
