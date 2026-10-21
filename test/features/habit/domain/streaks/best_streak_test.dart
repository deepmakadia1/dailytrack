import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/streaks/best_streak.dart';
import 'package:flutter_test/flutter_test.dart';

/// bestActiveStreak (T014, DSH-01 streak flame, data-model.md §3).
void main() {
  Habit habit(String id) => Habit(
    id: id,
    name: id,
    iconKey: 'menu_book',
    colorHex: '#2B7ACA',
    kind: HabitKind.yesNo,
    schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
    reminderTimes: const [],
    remindOnlyIfNotDone: true,
    startDate: LocalDate.fromKey('2026-01-01'),
    isArchived: false,
    sortOrder: 0,
    freezesAvailable: 0,
    celebratedMilestones: const {},
    createdAt: DateTime.utc(2026),
    updatedAt: DateTime.utc(2026),
  );

  (Habit, StreakSummary) entry(
    String id,
    int current, {
    StreakUnit unit = StreakUnit.days,
  }) => (
    habit(id),
    StreakSummary(
      current: current,
      best: current,
      totalCompletions: current,
      unit: unit,
    ),
  );

  test('an empty list gives null', () {
    expect(bestActiveStreak(const []), isNull);
  });

  test('picks the highest current streak', () {
    expect(
      bestActiveStreak([entry('a', 4), entry('b', 12), entry('c', 7)]),
      const BestStreak(habitId: 'b', current: 12, unit: StreakUnit.days),
    );
  });

  test('a weekly streak compares as current × 7', () {
    expect(
      bestActiveStreak([entry('d', 13), entry('w', 2, unit: StreakUnit.weeks)]),
      const BestStreak(habitId: 'w', current: 2, unit: StreakUnit.weeks),
    );
    expect(
      bestActiveStreak([entry('w', 1, unit: StreakUnit.weeks), entry('d', 8)]),
      const BestStreak(habitId: 'd', current: 8, unit: StreakUnit.days),
    );
  });

  test('a tie goes to the first habit in sort order', () {
    expect(
      bestActiveStreak([
        entry('a', 7),
        entry('w', 1, unit: StreakUnit.weeks),
        entry('b', 7),
      ]),
      const BestStreak(habitId: 'a', current: 7, unit: StreakUnit.days),
    );
  });

  test('all zeros give the first habit with 0', () {
    expect(
      bestActiveStreak([entry('a', 0), entry('b', 0)]),
      const BestStreak(habitId: 'a', current: 0, unit: StreakUnit.days),
    );
  });
}
