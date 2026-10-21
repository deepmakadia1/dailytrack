import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'habit.freezed.dart';

/// Something the user wants to do regularly (spec §4 habits, data-model.md
/// §5). [schedule] mirrors the newest schedule version (research R3).
@freezed
abstract class Habit with _$Habit {
  const factory({
    required String id,

    /// 1–40 characters.
    required String name,
    required String iconKey,
    required String colorHex,

    /// Fixed after create.
    required HabitKind kind,
    required HabitSchedule schedule,
    required List<ReminderTime> reminderTimes,
    required bool remindOnlyIfNotDone,
    required LocalDate startDate,
    required bool isArchived,
    required int sortOrder,

    /// 0–2 stored streak freezes.
    required int freezesAvailable,
    required Set<Milestone> celebratedMilestones,

    /// UTC.
    required DateTime createdAt,
    required DateTime updatedAt,

    /// Count habits only, at most 20 characters.
    String? unit,

    /// UTC; set while archived.
    DateTime? archivedAt,
  }) = _Habit;
}

/// Everything HAB-02 edits (data-model.md §5.1).
@freezed
abstract class HabitDraft with _$HabitDraft {
  const factory({
    required String name,
    required String iconKey,
    required String colorHex,
    required HabitKind kind,
    required HabitSchedule schedule,
    required LocalDate startDate,
    @Default(<ReminderTime>[]) List<ReminderTime> reminderTimes,
    @Default(true) bool remindOnlyIfNotDone,
    String? unit,
  }) = _HabitDraft;
}
