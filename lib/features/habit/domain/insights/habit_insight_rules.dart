import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

// Habit insight rules for the Home insight card (DSH-01, research R8). Pure
// functions of plain inputs and the injected clock. When habits with day and
// week streaks are compared, a week counts as 7 days, as in the streak
// flame (data-model.md §3).

/// One active habit as the rules see it.
final class HabitInsightHabit {
  const new({
    required this.habit,
    required this.summary,
    required this.completedDays,
    required this.scheduledToday,
  });

  final Habit habit;
  final StreakSummary summary;

  /// Days the habit was completed (target reached), covering at least the
  /// current week.
  final Set<LocalDate> completedDays;

  /// Whether the habit is due today.
  final bool scheduledToday;
}

/// What the rules read: the active habits in sort order.
final class HabitInsightInputs {
  const new({required this.habits, this.firstDayOfWeek = 1});

  final List<HabitInsightHabit> habits;

  /// 1 = Monday … 7 = Sunday (settings `firstDayOfWeek`).
  final int firstDayOfWeek;
}

/// One applicable habit rule, before localization.
sealed class HabitInsightFact {
  const new({required this.habitId, required this.name});

  final String habitId;
  final String name;

  /// The rule that produced this fact (one of [HabitInsightRules.ruleIds]).
  String get ruleId;
}

/// `habit.nextMilestone`: [daysLeft] more [unit] reach [milestone].
@immutable
final class NextMilestone extends HabitInsightFact {
  const new({
    required super.habitId,
    required super.name,
    required this.daysLeft,
    required this.milestone,
    required this.unit,
  });

  /// 1–3, counted in [unit] (weeks for a weekly streak).
  final int daysLeft;
  final Milestone milestone;
  final StreakUnit unit;

  @override
  String get ruleId => HabitInsightRules.nextMilestone;

  @override
  bool operator ==(Object other) =>
      other is NextMilestone &&
      other.habitId == habitId &&
      other.name == name &&
      other.daysLeft == daysLeft &&
      other.milestone == milestone &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(habitId, name, daysLeft, milestone, unit);

  @override
  String toString() =>
      'NextMilestone($habitId, $daysLeft ${unit.name} to ${milestone.value})';
}

/// `habit.bestThisWeek`: done [count] times this week.
@immutable
final class BestThisWeek extends HabitInsightFact {
  const new({required super.habitId, required super.name, required this.count});

  final int count;

  @override
  String get ruleId => HabitInsightRules.bestThisWeek;

  @override
  bool operator ==(Object other) =>
      other is BestThisWeek &&
      other.habitId == habitId &&
      other.name == name &&
      other.count == count;

  @override
  int get hashCode => Object.hash(habitId, name, count);

  @override
  String toString() => 'BestThisWeek($habitId, $count)';
}

/// `habit.comeback`: the streak broke, but the best was [best] [unit].
@immutable
final class Comeback extends HabitInsightFact {
  const new({
    required super.habitId,
    required super.name,
    required this.best,
    required this.unit,
  });

  final int best;
  final StreakUnit unit;

  @override
  String get ruleId => HabitInsightRules.comeback;

  @override
  bool operator ==(Object other) =>
      other is Comeback &&
      other.habitId == habitId &&
      other.name == name &&
      other.best == best &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(habitId, name, best, unit);

  @override
  String toString() => 'Comeback($habitId, best $best ${unit.name})';
}

/// The Habit module's insight rules (research R8).
final class HabitInsightRules {
  const new(this._clock);

  final Clock _clock;

  static const String nextMilestone = 'habit.nextMilestone';
  static const String bestThisWeek = 'habit.bestThisWeek';
  static const String comeback = 'habit.comeback';

  /// Rotation order. Stable across releases.
  static const List<String> ruleIds = [nextMilestone, bestThisWeek, comeback];

  /// `nextMilestone` applies 1 to this many units short of a milestone.
  static const int maxMilestoneGap = 3;

  /// `bestThisWeek` needs at least this many completions this week.
  static const int minWeekCompletions = 3;

  /// `comeback` needs a best streak of at least this many units.
  static const int minComebackBest = 7;

  /// The applicable facts, at most one per rule, in [ruleIds] order.
  List<HabitInsightFact> evaluate(HabitInsightInputs inputs) {
    final today = LocalDate.fromDateTime(_clock.now());
    final weekStart = today.startOfWeek(inputs.firstDayOfWeek);
    return [
      ?_nextMilestone(inputs.habits),
      ?_bestThisWeek(inputs.habits, weekStart, today),
      ?_comeback(inputs.habits),
    ];
  }

  /// The smallest gap to the next milestone; an equal gap goes to the longer
  /// streak, then to the first habit.
  static NextMilestone? _nextMilestone(List<HabitInsightHabit> habits) {
    NextMilestone? best;
    var bestGap = 0;
    var bestCurrent = 0;
    for (final h in habits) {
      final current = h.summary.current;
      final next = _milestoneAfter(current);
      if (next == null) continue;
      final gap = next.value - current;
      if (gap < 1 || gap > maxMilestoneGap) continue;
      final unit = h.summary.unit;
      final gapDays = _inDays(gap, unit);
      final currentDays = _inDays(current, unit);
      if (best == null ||
          gapDays < bestGap ||
          (gapDays == bestGap && currentDays > bestCurrent)) {
        best = NextMilestone(
          habitId: h.habit.id,
          name: h.habit.name,
          daysLeft: gap,
          milestone: next,
          unit: unit,
        );
        bestGap = gapDays;
        bestCurrent = currentDays;
      }
    }
    return best;
  }

  /// The most completions from [weekStart] through [today]; a tie goes to
  /// the first habit.
  static BestThisWeek? _bestThisWeek(
    List<HabitInsightHabit> habits,
    LocalDate weekStart,
    LocalDate today,
  ) {
    BestThisWeek? best;
    for (final h in habits) {
      final count = h.completedDays
          .where((d) => !d.isBefore(weekStart) && !d.isAfter(today))
          .length;
      if (count < minWeekCompletions) continue;
      if (best == null || count > best.count) {
        best = BestThisWeek(
          habitId: h.habit.id,
          name: h.habit.name,
          count: count,
        );
      }
    }
    return best;
  }

  /// A broken streak due today with the longest best; a tie goes to the
  /// first habit.
  static Comeback? _comeback(List<HabitInsightHabit> habits) {
    Comeback? pick;
    for (final h in habits) {
      final s = h.summary;
      if (s.current != 0 || s.best < minComebackBest || !h.scheduledToday) {
        continue;
      }
      if (pick == null ||
          _inDays(s.best, s.unit) > _inDays(pick.best, pick.unit)) {
        pick = Comeback(
          habitId: h.habit.id,
          name: h.habit.name,
          best: s.best,
          unit: s.unit,
        );
      }
    }
    return pick;
  }

  static Milestone? _milestoneAfter(int current) {
    for (final m in Milestone.values) {
      if (m.value > current) return m;
    }
    return null;
  }

  static int _inDays(int value, StreakUnit unit) =>
      unit == StreakUnit.weeks ? value * 7 : value;
}
