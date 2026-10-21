import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// What a habit card says about its schedule (spec US1-6). Data only; the
/// presentation layer formats it with ARB strings and localized day names.
@immutable
sealed class ScheduleTextData {
  const new();
}

/// "Daily", also for "Specific days" with all 7 days.
final class DailyText extends ScheduleTextData {
  const new();

  @override
  bool operator ==(Object other) => other is DailyText;

  @override
  int get hashCode => 0;
}

/// "Mon, Wed, Fri": weekdays (1 = Monday … 7 = Sunday) in week order.
final class WeekdaysText extends ScheduleTextData {
  const new(this.weekdays);

  final List<int> weekdays;

  @override
  bool operator ==(Object other) =>
      other is WeekdaysText &&
      other.weekdays.length == weekdays.length &&
      [
        for (var i = 0; i < weekdays.length; i++)
          other.weekdays[i] == weekdays[i],
      ].every((same) => same);

  @override
  int get hashCode => Object.hashAll(weekdays);
}

/// "3× per week · 1 left".
final class TimesPerWeekText extends ScheduleTextData {
  const new(this.times, {required this.left});

  final int times;

  /// Never below 0.
  final int left;

  @override
  bool operator ==(Object other) =>
      other is TimesPerWeekText && other.times == times && other.left == left;

  @override
  int get hashCode => Object.hash(times, left);
}

/// The schedule text of [schedule]: weekdays ordered from [firstDayOfWeek],
/// and for "times per week" what is left after [doneThisWeek].
ScheduleTextData scheduleText(
  HabitSchedule schedule, {
  int doneThisWeek = 0,
  int firstDayOfWeek = 1,
}) {
  switch (schedule.type) {
    case ScheduleType.daily:
      return const DailyText();
    case ScheduleType.specificWeekdays:
      if (schedule.weekdays.length >= 7) return const DailyText();
      return WeekdaysText([
        for (var i = 0; i < 7; i++)
          if (schedule.weekdays.contains((firstDayOfWeek - 1 + i) % 7 + 1))
            (firstDayOfWeek - 1 + i) % 7 + 1,
      ]);
    case ScheduleType.timesPerWeek:
      final times = schedule.timesPerWeek ?? 1;
      return TimesPerWeekText(times, left: (times - doneThisWeek).clamp(0, 6));
  }
}
