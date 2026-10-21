import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// The best active streak across habits, for the DSH-01 streak flame
/// (feature 006 data-model.md §3, research R5).
@immutable
final class BestStreak {
  const new({required this.habitId, required this.current, required this.unit});

  final String habitId;
  final int current;

  /// The winner's own unit, so the badge can show "2 wk".
  final StreakUnit unit;

  @override
  bool operator ==(Object other) =>
      other is BestStreak &&
      other.habitId == habitId &&
      other.current == current &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(habitId, current, unit);

  @override
  String toString() => 'BestStreak($habitId, $current ${unit.name})';
}

/// The highest current streak in [habits] (in sort order). Weekly units
/// compare as `current × 7`. Ties go to the habit that sorts first. Returns
/// null when there are no habits.
BestStreak? bestActiveStreak(List<(Habit, StreakSummary)> habits) {
  BestStreak? best;
  var bestDays = -1;
  for (final (habit, summary) in habits) {
    final days = summary.unit == StreakUnit.weeks
        ? summary.current * 7
        : summary.current;
    if (days > bestDays) {
      bestDays = days;
      best = BestStreak(
        habitId: habit.id,
        current: summary.current,
        unit: summary.unit,
      );
    }
  }
  return best;
}
