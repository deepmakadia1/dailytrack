import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/planned_reminder.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';

/// The notifications to register for [habit] (research R10, FR-038,
/// FR-039). Each reminder time is one repeating notification (one per
/// selected weekday for "Specific days"); its first fire is the next due
/// occurrence after [now], on or after the start date, that "Remind me only
/// if not done yet" does not suppress:
/// - today, when it is already done ([doneToday]);
/// - for "times per week", the rest of a week whose target is met
///   ([weekTargetMet]): the first fire moves to the start of next week.
///
/// Later days are not checked here: the scheduler reconciles again after
/// every check-in in the current week and on every app open.
List<PlannedReminder> planReminders(
  Habit habit, {
  required DateTime now,
  required bool doneToday,
  required bool weekTargetMet,
  required int firstDayOfWeek,
}) {
  final today = LocalDate.fromDateTime(now);
  final from = habit.startDate.isAfter(today) ? habit.startDate : today;
  final nextWeek = today.startOfWeek(firstDayOfWeek).addDays(7);

  bool suppressed(LocalDate day) {
    if (!habit.remindOnlyIfNotDone) return false;
    if (day == today && doneToday) return true;
    return habit.schedule.type == ScheduleType.timesPerWeek &&
        weekTargetMet &&
        day.isBefore(nextWeek);
  }

  /// The first fire on or after [from] on a day matching [due]. Always
  /// found within two weeks, since every weekday recurs.
  DateTime first(ReminderTime t, bool Function(LocalDate day) due) {
    for (var day = from; ; day = day.addDays(1)) {
      final fire = DateTime(day.year, day.month, day.day, t.hour, t.minute);
      if (due(day) && fire.isAfter(now) && !suppressed(day)) return fire;
    }
  }

  final times = [...habit.reminderTimes]..sort();
  final weekly = habit.schedule.type == ScheduleType.specificWeekdays;
  return [
    for (final (index, t) in times.take(maxReminders).indexed)
      if (weekly)
        for (final weekday in habit.schedule.weekdays.toList()..sort())
          PlannedReminder(
            id: reminderIdFor(habit.id, index, weekday),
            firstAt: first(t, (day) => day.weekday == weekday),
            repeat: ReminderRepeat.weekly,
          )
      else
        PlannedReminder(
          id: reminderIdFor(habit.id, index, 0),
          firstAt: first(t, (_) => true),
          repeat: ReminderRepeat.daily,
        ),
  ];
}
