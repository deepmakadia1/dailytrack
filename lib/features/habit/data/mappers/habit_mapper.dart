import 'dart:convert';

import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/entities/schedule_version.dart';

DateTime _utc(int ms) => DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

/// `reminder_times` JSON: a sorted list of distinct `HH:mm` strings.
String encodeReminderTimes(List<ReminderTime> times) =>
    jsonEncode([for (final t in times.toSet().toList()..sort()) t.format()]);

List<ReminderTime> decodeReminderTimes(String json) => [
  for (final item in jsonDecode(json) as List<Object?>)
    ReminderTime.parse(item! as String),
];

extension HabitRowMapper on HabitRow {
  HabitSchedule get schedule => HabitSchedule.fromMask(
    type: scheduleType,
    target: targetValue,
    weekdaysMask: weekdaysMask,
    timesPerWeek: timesPerWeek,
  );

  Habit toEntity() => Habit(
    id: id,
    name: name,
    iconKey: iconKey,
    colorHex: colorHex,
    kind: kind,
    schedule: schedule,
    unit: unit,
    reminderTimes: decodeReminderTimes(reminderTimes),
    remindOnlyIfNotDone: remindOnlyIfNotDone,
    startDate: LocalDate.fromKey(startDateKey),
    isArchived: isArchived,
    archivedAt: archivedAt == null ? null : _utc(archivedAt!),
    sortOrder: sortOrder,
    freezesAvailable: freezesAvailable,
    celebratedMilestones: Milestone.fromMask(celebratedMilestones),
    createdAt: _utc(createdAt),
    updatedAt: _utc(updatedAt),
  );
}

extension HabitScheduleRowMapper on HabitScheduleRow {
  ScheduleVersion toEntity() => ScheduleVersion(
    effectiveFrom: LocalDate.fromKey(effectiveFromKey),
    schedule: HabitSchedule.fromMask(
      type: scheduleType,
      target: targetValue,
      weekdaysMask: weekdaysMask,
      timesPerWeek: timesPerWeek,
    ),
  );
}

extension HabitEntryRowMapper on HabitEntryRow {
  HabitEntry toEntity() => HabitEntry(
    habitId: habitId,
    date: LocalDate.fromKey(dateKey),
    value: value,
    isFreeze: isFreeze,
    note: note,
  );
}
