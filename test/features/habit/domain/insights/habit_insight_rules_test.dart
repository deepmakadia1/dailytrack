import 'package:clock/clock.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/domain/insights/habit_insight_rules.dart';
import 'package:flutter_test/flutter_test.dart';

/// Habit insight rules (T039, research R8). "Now" is Wednesday 21 October
/// 2026 at 12:00; a Monday week starts on the 19th, a Sunday week on the
/// 18th.
void main() {
  final rules = HabitInsightRules(Clock.fixed(DateTime(2026, 10, 21, 12)));

  LocalDate d(String key) => LocalDate.fromKey(key);

  HabitInsightHabit h(
    String id, {
    int current = 0,
    int best = 0,
    StreakUnit unit = StreakUnit.days,
    Set<String> done = const {},
    bool scheduledToday = true,
  }) => HabitInsightHabit(
    habit: Habit(
      id: id,
      name: 'Name $id',
      iconKey: 'menu_book',
      colorHex: '#2B7ACA',
      kind: HabitKind.yesNo,
      schedule: const HabitSchedule(type: ScheduleType.daily, target: 1),
      reminderTimes: const [],
      remindOnlyIfNotDone: true,
      startDate: d('2025-01-01'),
      isArchived: false,
      sortOrder: 0,
      freezesAvailable: 0,
      celebratedMilestones: const {},
      createdAt: DateTime.utc(2025),
      updatedAt: DateTime.utc(2025),
    ),
    summary: StreakSummary(
      current: current,
      best: best < current ? current : best,
      totalCompletions: current,
      unit: unit,
    ),
    completedDays: {for (final k in done) d(k)},
    scheduledToday: scheduledToday,
  );

  List<HabitInsightFact> evaluate(
    List<HabitInsightHabit> habits, {
    int firstDayOfWeek = 1,
  }) => rules.evaluate(
    HabitInsightInputs(habits: habits, firstDayOfWeek: firstDayOfWeek),
  );

  List<HabitInsightFact> only<T extends HabitInsightFact>(
    List<HabitInsightFact> facts,
  ) => facts.whereType<T>().toList();

  test('rule ids are stable and in rotation order', () {
    expect(HabitInsightRules.ruleIds, [
      'habit.nextMilestone',
      'habit.bestThisWeek',
      'habit.comeback',
    ]);
  });

  group('DSH-01 habit.nextMilestone', () {
    for (final m in Milestone.values) {
      test('gaps 1–3 before ${m.value} apply, 4 does not', () {
        for (final gap in [1, 2, 3]) {
          expect(
            only<NextMilestone>(evaluate([h('a', current: m.value - gap)])),
            [
              NextMilestone(
                habitId: 'a',
                name: 'Name a',
                daysLeft: gap,
                milestone: m,
                unit: StreakUnit.days,
              ),
            ],
            reason: 'gap $gap',
          );
        }
        expect(
          only<NextMilestone>(evaluate([h('a', current: m.value - 4)])),
          isEmpty,
        );
      });
    }

    test('a streak at or past 365 has no next milestone', () {
      expect(only<NextMilestone>(evaluate([h('a', current: 365)])), isEmpty);
      expect(only<NextMilestone>(evaluate([h('a', current: 400)])), isEmpty);
    });

    test('picks the smallest gap', () {
      final facts = only<NextMilestone>(
        evaluate([
          h('a', current: 5),
          h('b', current: 28),
          h('c', current: 20),
        ]),
      );
      expect(
        facts.single,
        isA<NextMilestone>().having((f) => f.habitId, 'id', 'c'),
      );
    });

    test('an equal gap goes to the longer streak', () {
      final facts = only<NextMilestone>(
        evaluate([h('a', current: 5), h('b', current: 28)]),
      );
      expect(
        facts.single,
        isA<NextMilestone>()
            .having((f) => f.habitId, 'id', 'b')
            .having((f) => f.milestone, 'milestone', Milestone.d30),
      );
    });

    test('handles the week unit', () {
      expect(
        only<NextMilestone>(
          evaluate([h('w', current: 6, unit: StreakUnit.weeks)]),
        ),
        [
          const NextMilestone(
            habitId: 'w',
            name: 'Name w',
            daysLeft: 1,
            milestone: Milestone.d7,
            unit: StreakUnit.weeks,
          ),
        ],
      );
    });

    test('a week gap counts as 7 days when comparing habits', () {
      final facts = only<NextMilestone>(
        evaluate([
          h('w', current: 6, unit: StreakUnit.weeks),
          h('a', current: 4),
        ]),
      );
      expect(
        facts.single,
        isA<NextMilestone>().having((f) => f.habitId, 'id', 'a'),
      );
    });
  });

  group('DSH-01 habit.bestThisWeek', () {
    test('needs at least 3 completions this week', () {
      expect(
        only<BestThisWeek>(
          evaluate([
            h('a', done: {'2026-10-19', '2026-10-20'}),
          ]),
        ),
        isEmpty,
      );
      expect(
        only<BestThisWeek>(
          evaluate([
            h('a', done: {'2026-10-19', '2026-10-20', '2026-10-21'}),
          ]),
        ),
        [const BestThisWeek(habitId: 'a', name: 'Name a', count: 3)],
      );
    });

    test('respects firstDayOfWeek (Monday vs Sunday)', () {
      final habit = h('a', done: {'2026-10-18', '2026-10-19', '2026-10-20'});
      expect(only<BestThisWeek>(evaluate([habit])), isEmpty);
      expect(only<BestThisWeek>(evaluate([habit], firstDayOfWeek: 7)), [
        const BestThisWeek(habitId: 'a', name: 'Name a', count: 3),
      ]);
    });

    test('ignores days before the week start', () {
      expect(
        only<BestThisWeek>(
          evaluate([
            h('a', done: {'2026-10-16', '2026-10-17', '2026-10-21'}),
          ]),
        ),
        isEmpty,
      );
    });

    test('picks the most completions; a tie goes to the first habit', () {
      final three = {'2026-10-19', '2026-10-20', '2026-10-21'};
      expect(
        only<BestThisWeek>(
          evaluate([
            h('a', done: three),
            h('b', done: {...three, '2026-10-18'}),
          ], firstDayOfWeek: 7),
        ),
        [const BestThisWeek(habitId: 'b', name: 'Name b', count: 4)],
      );
      expect(
        only<BestThisWeek>(
          evaluate([h('a', done: three), h('b', done: three)]),
        ),
        [const BestThisWeek(habitId: 'a', name: 'Name a', count: 3)],
      );
    });
  });

  group('DSH-01 habit.comeback', () {
    test('needs current 0, best ≥ 7, and the habit scheduled today', () {
      expect(only<Comeback>(evaluate([h('a', best: 7)])), [
        const Comeback(
          habitId: 'a',
          name: 'Name a',
          best: 7,
          unit: StreakUnit.days,
        ),
      ]);
      expect(only<Comeback>(evaluate([h('a', best: 6)])), isEmpty);
      expect(only<Comeback>(evaluate([h('a', current: 1, best: 9)])), isEmpty);
    });

    test('does not apply when the habit is not scheduled today', () {
      expect(
        only<Comeback>(evaluate([h('a', best: 21, scheduledToday: false)])),
        isEmpty,
      );
    });

    test('picks the best streak, weeks counted as 7 days', () {
      expect(
        only<Comeback>(
          evaluate([h('a', best: 21), h('w', best: 7, unit: StreakUnit.weeks)]),
        ),
        [
          const Comeback(
            habitId: 'w',
            name: 'Name w',
            best: 7,
            unit: StreakUnit.weeks,
          ),
        ],
      );
    });
  });

  test('facts come in rule order, at most one per rule', () {
    final facts = evaluate([
      h('a', current: 5, done: {'2026-10-19', '2026-10-20', '2026-10-21'}),
      h('b', best: 10),
    ]);
    expect(facts.map((f) => f.ruleId), HabitInsightRules.ruleIds);
  });

  test('no habits give no facts', () {
    expect(evaluate(const []), isEmpty);
  });
}
