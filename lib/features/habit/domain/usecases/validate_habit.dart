import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/errors.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';

/// Longest habit name, after trimming (FR-001).
const int maxHabitNameLength = 40;

/// Longest unit (FR-001).
const int maxHabitUnitLength = 20;

/// Highest count target (FR-001).
const int maxHabitTarget = 9999;

/// The draft HAB-02 saves: trimmed text, target 1 and no unit for yes/no
/// habits, and a blank unit as none (data-model §5.1).
HabitDraft normalizeHabitDraft(HabitDraft draft) {
  final yesNo = draft.kind == HabitKind.yesNo;
  final unit = draft.unit?.trim();
  return draft.copyWith(
    name: draft.name.trim(),
    unit: yesNo || unit == null || unit.isEmpty ? null : unit,
    schedule: yesNo ? draft.schedule.copyWith(target: 1) : draft.schedule,
  );
}

/// HAB-02 field errors (FR-025, data-model §5.1), in form order. Pass
/// [existing] when editing, so a changed goal type is reported.
List<HabitFieldError> validateHabit(HabitDraft draft, {Habit? existing}) {
  final d = normalizeHabitDraft(draft);
  final s = d.schedule;
  final times = s.timesPerWeek;
  return [
    if (d.name.isEmpty) HabitFieldError.nameRequired,
    if (d.name.length > maxHabitNameLength) HabitFieldError.nameTooLong,
    if (existing != null && existing.kind != d.kind) HabitFieldError.kindLocked,
    if (d.kind == HabitKind.count &&
        (s.target < 1 || s.target > maxHabitTarget))
      HabitFieldError.targetOutOfRange,
    if ((d.unit?.length ?? 0) > maxHabitUnitLength) HabitFieldError.unitTooLong,
    if (s.type == ScheduleType.specificWeekdays && !_validWeekdays(s))
      HabitFieldError.weekdayRequired,
    if (s.type == ScheduleType.timesPerWeek &&
        (times == null || times < 1 || times > 6))
      HabitFieldError.timesOutOfRange,
    if (d.reminderTimes.length > maxReminders) HabitFieldError.tooManyReminders,
    if (d.reminderTimes.toSet().length != d.reminderTimes.length)
      HabitFieldError.duplicateReminder,
  ];
}

bool _validWeekdays(HabitSchedule s) =>
    s.weekdays.isNotEmpty && s.weekdays.every((d) => d >= 1 && d <= 7);
