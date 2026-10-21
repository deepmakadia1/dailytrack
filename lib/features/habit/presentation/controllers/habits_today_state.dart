import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/usecases/schedule_text.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'habits_today_state.freezed.dart';

/// HAB-01 state (contracts/screens.md).
@freezed
abstract class HabitsTodayState with _$HabitsTodayState {
  const factory({
    @Default(AsyncLoading<HabitsTodayData>()) AsyncValue<HabitsTodayData> data,
  }) = _HabitsTodayState;
}

/// Everything HAB-01 shows for the selected day.
@freezed
abstract class HabitsTodayData with _$HabitsTodayData {
  const factory({
    required LocalDate today,
    required LocalDate selected,

    /// 0 = the current week, -1 = the previous one (research R14).
    required int weekOffset,

    /// The 7 days of the shown week, from the first day of the week.
    required List<WeekDayCell> week,

    /// Progress header for the selected day.
    required int doneCount,
    required int scheduledCount,
    required List<HabitCardData> scheduled,
    required List<HabitCardData> notScheduled,

    /// Every active habit in sort order (reorder mode).
    required List<Habit> habits,

    /// "All done for today" banner: only when [selected] is today.
    required bool allDoneToday,
    @Default(false) bool reorderMode,
  }) = _HabitsTodayData;

  const new _();

  bool get isEmpty => habits.isEmpty;
  bool get selectedIsToday => selected == today;
}

/// One day of the week strip.
@freezed
abstract class WeekDayCell with _$WeekDayCell {
  const factory({
    required LocalDate date,
    required int done,
    required int scheduled,

    /// Today and up to 7 days back (FR-017).
    required bool selectable,
    required bool isFuture,
    required bool isToday,
  }) = _WeekDayCell;

  const new _();

  /// Completion ring ratio; 0 with nothing scheduled.
  double get ratio => scheduled == 0 ? 0 : done / scheduled;
}

/// One habit card on the selected day.
@freezed
abstract class HabitCardData with _$HabitCardData {
  const factory({
    required Habit habit,
    required DayStatus status,

    /// The day's value (0 without an entry) and the target in effect.
    required int value,
    required int target,
    required bool isDone,
    required bool isFreeze,
    required ScheduleTextData schedule,
    required int currentStreak,
    required StreakUnit unit,

    /// Skip today is offered: today, scheduled, not done, not frozen. It is
    /// disabled with "No freezes left" when the habit has none (FR-036).
    required bool canSkipToday,
    String? note,
  }) = _HabitCardData;

  const new _();

  String get id => habit.id;
}
