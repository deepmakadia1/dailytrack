import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';

/// Done count and target of one week of a "times per week" habit.
typedef WeekProgress = ({int done, int target});

/// How one streak unit (a due day, or a week of a "times per week" habit)
/// turned out.
enum _Outcome { hit, frozen, miss, pending }

/// One due day, or one week of "times per week" days, in time order.
final class _Unit {
  const new(this.outcome, this.last);

  final _Outcome outcome;

  /// The unit's last day, used for the completion-rate window.
  final LocalDate last;
}

/// Habit streak rules (spec §4 "Business rules for streaks", research R6).
/// Pure Dart; "today" comes from the injected [Clock].
///
/// Every day from the start date through today is judged with the schedule
/// and target in effect on that day (research R3):
/// - A day of a daily or specific-weekdays schedule is one unit when it is
///   due: done → counts, freeze → keeps the streak without adding, today
///   not done → pending (never breaks), otherwise it breaks the streak.
/// - Days of a "times per week" schedule are grouped by week; a week is one
///   unit: target met → counts, the current week unmet → pending, a past
///   unmet week with a freeze day → keeps the streak, otherwise it breaks.
/// - Days after today (clock moved back) count toward nothing.
final class StreakEngine {
  new(this._clock, {this.firstDayOfWeek = 1})
    : assert(firstDayOfWeek >= 1 && firstDayOfWeek <= 7, 'firstDayOfWeek');

  final Clock _clock;

  /// 1 = Monday … 7 = Sunday (settings `firstDayOfWeek`).
  final int firstDayOfWeek;

  /// Completion rate looks back this many days, today included.
  static const int rateWindowDays = 30;

  LocalDate get today => LocalDate.fromDateTime(_clock.now());

  /// The schedule in effect on [date]: the newest version that started on or
  /// before it, or the oldest version for earlier days (research R3).
  HabitSchedule scheduleOn(HabitHistory history, LocalDate date) {
    final versions = history.versions;
    var schedule = versions.first.schedule;
    for (final v in versions) {
      if (v.effectiveFrom.isAfter(date)) break;
      schedule = v.schedule;
    }
    return schedule;
  }

  /// Whether [date] is due for streaks, freezes, and Skip today. Every day of
  /// a "times per week" schedule is due (research R6).
  bool isScheduledOn(HabitHistory history, LocalDate date) {
    if (date.isBefore(history.startDate)) return false;
    return _due(scheduleOn(history, date), date);
  }

  /// Whether [date]'s entry reaches the target in effect that day.
  bool isDone(HabitHistory history, LocalDate date) {
    final entry = history.entries[date];
    return entry != null && entry.value >= scheduleOn(history, date).target;
  }

  DayStatus dayStatus(HabitHistory history, LocalDate date) {
    final now = today;
    if (date.isAfter(now)) return DayStatus.future;
    if (date.isBefore(history.startDate)) return DayStatus.beforeStart;
    if (isDone(history, date)) return DayStatus.done;
    final entry = history.entries[date];
    if (entry?.isFreeze ?? false) return DayStatus.freeze;
    final schedule = scheduleOn(history, date);
    if (!_due(schedule, date)) return DayStatus.unscheduled;
    if (schedule.type == ScheduleType.timesPerWeek) {
      final week = weekProgress(history, date);
      if (week.done >= week.target) return DayStatus.unscheduled;
    }
    if (date == now) return DayStatus.pending;
    return (entry?.value ?? 0) > 0 ? DayStatus.partial : DayStatus.missed;
  }

  /// Done days of [date]'s week (start date through today) and the weekly
  /// target. Like [summarize], the target is the one in effect on the
  /// week's latest "times per week" day up to today; 1 for other schedules.
  WeekProgress weekProgress(HabitHistory history, LocalDate date) {
    final weekStart = date.startOfWeek(firstDayOfWeek);
    final now = today;
    var done = 0;
    var target = scheduleOn(history, date).timesPerWeek ?? 1;
    for (var i = 0; i < 7; i++) {
      final d = weekStart.addDays(i);
      if (d.isAfter(now)) break;
      if (d.isBefore(history.startDate)) continue;
      if (isDone(history, d)) done++;
      final schedule = scheduleOn(history, d);
      if (schedule.type == ScheduleType.timesPerWeek) {
        target = schedule.timesPerWeek ?? 1;
      }
    }
    return (done: done, target: target);
  }

  StreakSummary summarize(HabitHistory history) {
    final now = today;
    final units = _units(history, now);

    var current = 0;
    for (final u in units.reversed) {
      if (u.outcome == _Outcome.miss) break;
      if (u.outcome == _Outcome.hit) current++;
    }

    var best = 0;
    var run = 0;
    for (final u in units) {
      switch (u.outcome) {
        case _Outcome.hit:
          run++;
          if (run > best) best = run;
        case _Outcome.miss:
          run = 0;
        case _Outcome.frozen:
        case _Outcome.pending:
          break;
      }
    }

    final windowStart = now.addDays(-(rateWindowDays - 1));
    var hits = 0;
    var counted = 0;
    for (final u in units) {
      if (u.last.isBefore(windowStart)) continue;
      if (u.outcome == _Outcome.hit) {
        hits++;
        counted++;
      } else if (u.outcome == _Outcome.miss) {
        counted++;
      }
    }

    var total = 0;
    if (!history.startDate.isAfter(now)) {
      for (final date in history.entries.keys) {
        if (!date.isBefore(history.startDate) &&
            !date.isAfter(now) &&
            isDone(history, date)) {
          total++;
        }
      }
    }

    final weekly = scheduleOn(history, now).type == ScheduleType.timesPerWeek;
    return StreakSummary(
      current: current,
      best: best,
      totalCompletions: total,
      unit: weekly ? StreakUnit.weeks : StreakUnit.days,
      // Whole percent, rounded half up.
      completionRate: counted == 0
          ? null
          : (hits * 200 + counted) ~/ (2 * counted),
    );
  }

  /// Whether the current run reaches back past [day] without a break, so a
  /// history loaded only from [day] may undercount it (research R7: HAB-01
  /// then loads the full history).
  bool currentRunReaches(HabitHistory history, LocalDate day) {
    for (final u in _units(history, today).reversed) {
      if (u.last.isBefore(day)) return true;
      if (u.outcome == _Outcome.miss) return false;
    }
    return true;
  }

  bool _due(HabitSchedule schedule, LocalDate date) => switch (schedule.type) {
    ScheduleType.daily || ScheduleType.timesPerWeek => true,
    ScheduleType.specificWeekdays => schedule.weekdays.contains(date.weekday),
  };

  /// Streak units from the start date through [now], oldest first.
  List<_Unit> _units(HabitHistory history, LocalDate now) {
    final units = <_Unit>[];
    if (history.startDate.isAfter(now)) return units;

    // Days of the open "times per week" week: first day, done count,
    // target (from the week's latest day), and whether a freeze is in it.
    LocalDate? weekFirst;
    LocalDate? weekLast;
    var weekDone = 0;
    var weekTarget = 1;
    var weekFrozen = false;

    void closeWeek() {
      if (weekFirst == null) return;
      final containsToday = !weekLast!.isBefore(
        now.startOfWeek(firstDayOfWeek),
      );
      final outcome = weekDone >= weekTarget
          ? _Outcome.hit
          : containsToday
          ? _Outcome.pending
          : weekFrozen
          ? _Outcome.frozen
          : _Outcome.miss;
      units.add(_Unit(outcome, weekLast!));
      weekFirst = null;
      weekLast = null;
      weekDone = 0;
      weekTarget = 1;
      weekFrozen = false;
    }

    final versions = history.versions;
    var next = 0;
    var schedule = versions.first.schedule;
    for (
      var date = history.startDate;
      !date.isAfter(now);
      date = date.addDays(1)
    ) {
      while (next < versions.length &&
          !versions[next].effectiveFrom.isAfter(date)) {
        schedule = versions[next].schedule;
        next++;
      }
      if (weekFirst != null &&
          date.startOfWeek(firstDayOfWeek) !=
              weekFirst!.startOfWeek(firstDayOfWeek)) {
        closeWeek();
      }

      final entry = history.entries[date];
      final done = entry != null && entry.value >= schedule.target;
      final frozen = !done && (entry?.isFreeze ?? false);

      if (schedule.type == ScheduleType.timesPerWeek) {
        weekFirst ??= date;
        weekLast = date;
        if (done) weekDone++;
        if (frozen) weekFrozen = true;
        weekTarget = schedule.timesPerWeek ?? 1;
        continue;
      }
      // A switch away from "times per week" ends that week's unit.
      closeWeek();
      if (!_due(schedule, date)) continue;
      final outcome = done
          ? _Outcome.hit
          : frozen
          ? _Outcome.frozen
          : date == now
          ? _Outcome.pending
          : _Outcome.miss;
      units.add(_Unit(outcome, date));
    }
    closeWeek();
    return units;
  }
}
