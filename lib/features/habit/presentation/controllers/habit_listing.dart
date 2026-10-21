import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';

/// Whether HAB-01 and the Home card list the habit of [h] as scheduled on
/// [day] (spec Edge Cases "Times per week listing"): due that day, and for
/// "times per week" either done that day or the week's target not yet met
/// before it. A future start date is never scheduled.
bool listedOn(StreakEngine engine, HabitHistory h, LocalDate day) {
  if (!engine.isScheduledOn(h, day)) return false;
  final schedule = engine.scheduleOn(h, day);
  if (schedule.type != ScheduleType.timesPerWeek) return true;
  if (engine.isDone(h, day)) return true;
  var doneBefore = 0;
  for (
    var d = day.startOfWeek(engine.firstDayOfWeek);
    d.isBefore(day);
    d = d.addDays(1)
  ) {
    if (!d.isBefore(h.startDate) && engine.isDone(h, d)) doneBefore++;
  }
  return doneBefore < (schedule.timesPerWeek ?? 1);
}
