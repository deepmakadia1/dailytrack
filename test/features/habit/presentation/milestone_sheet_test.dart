import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/widgets/milestone_sheet.dart';
import 'package:dailytrack/features/habit/presentation/widgets/streak_share_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../habit_test_app.dart';

/// Milestone sheet (T072; HAB-01 criterion "Milestone sheet appears once
/// per milestone per habit", spec US3, FR-044, FR-045). Today is Wednesday
/// 2026-10-21.
void main() {
  Finder check(String id) => find.byKey(ValueKey('check_$id'));

  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  String keyDaysBefore(int days) =>
      DateTime(2026, 10, 21 - days).toIso8601String().substring(0, 10);

  for (final m in Milestone.values) {
    testWidgets('the check-in reaching ${m.value} shows the sheet once', (
      tester,
    ) async {
      final f = habitFakes();
      final start = keyDaysBefore(m.value - 1);
      final id = f.addHabit('Read', start: start).id;
      f.doneRange(id, start, '2026-10-20');
      await pumpHabitApp(tester, habits: f);
      await tapAndSettle(tester, check(id));
      expect(find.byType(MilestoneSheet), findsOneWidget);
      expect(find.text('${m.value}-day streak!'), findsOneWidget);
      expect(f.world.habits[id]!.celebratedMilestones, contains(m));
      await tapAndSettle(tester, find.byKey(const Key('milestone_close')));
      expect(find.byType(MilestoneSheet), findsNothing);
      // Unchecking and checking again shows nothing.
      await tapAndSettle(tester, check(id));
      await tapAndSettle(tester, check(id));
      expect(find.byType(MilestoneSheet), findsNothing);
      await flushTimers(tester);
    });
  }

  testWidgets('the next day shows no sheet; the next one comes at 21', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f.addHabit('Read', start: '2026-10-15').id;
    f.doneRange(id, '2026-10-15', '2026-10-20');
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, check(id));
    await tapAndSettle(tester, find.byKey(const Key('milestone_close')));
    f.clock.value = DateTime(2026, 10, 22, 9);
    routerOf(tester).go('/habits');
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    await tapAndSettle(tester, check(id));
    expect(f.entry(id, '2026-10-22')?.value, 1);
    expect(find.byType(MilestoneSheet), findsNothing);
  });

  testWidgets('US3-2: a broken and rebuilt streak shows no sheet again', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f
        .addHabit('Read', start: '2026-10-15', celebrated: {Milestone.d7})
        .id;
    f.doneRange(id, '2026-10-15', '2026-10-20');
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, check(id));
    expect(find.byType(MilestoneSheet), findsNothing);
  });

  testWidgets('US3-3: one back-fill passing 7 and 21 shows 21 only and '
      'records both', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Read').id;
    f
      ..doneRange(id, '2026-10-01', '2026-10-19')
      ..setDay(id, '2026-10-21');
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, find.byKey(const ValueKey('day_2026-10-20')));
    await tapAndSettle(tester, check(id));
    expect(find.text('21-day streak!'), findsOneWidget);
    expect(find.text('7-day streak!'), findsNothing);
    expect(f.world.habits[id]!.celebratedMilestones, {
      Milestone.d7,
      Milestone.d21,
    });
  });

  testWidgets('US3-5: a "times per week" habit counts weeks', (tester) async {
    final f = habitFakes();
    final id = f
        .addHabit(
          'Swim',
          start: '2026-09-07',
          schedule: const HabitSchedule(
            type: ScheduleType.timesPerWeek,
            target: 1,
            timesPerWeek: 1,
          ),
        )
        .id;
    for (final k in [
      '2026-09-07',
      '2026-09-14',
      '2026-09-21',
      '2026-09-28',
      '2026-10-05',
      '2026-10-12',
    ]) {
      f.setDay(id, k);
    }
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, check(id));
    expect(find.text('7-week streak!'), findsOneWidget);
    expect(find.text('7 weeks'), findsWidgets);
  });

  testWidgets('US3-4: "Share streak" shares streak.png with the card only', (
    tester,
  ) async {
    final f = habitFakes();
    final sharer = FakeImageSharer();
    final id = f.addHabit('Read', start: '2026-10-15').id;
    f
      ..doneRange(id, '2026-10-15', '2026-10-20')
      ..setDay(id, '2026-10-16', note: 'secret note');
    await pumpHabitApp(tester, habits: f, imageSharer: sharer);
    await tapAndSettle(tester, check(id));

    final card = find.byType(StreakShareCard);
    expect(
      find.descendant(of: card, matching: find.text('Read')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('7 days')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.text('Tracked with DailyTrack')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: card, matching: find.textContaining('secret')),
      findsNothing,
    );

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share_streak')));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(sharer.shared, hasLength(1));
    final shared = sharer.shared.single;
    expect(shared.fileName, 'streak.png');
    expect(shared.text, isNull);
    expect(shared.png.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  });

  testWidgets('a failed share says so and keeps the sheet', (tester) async {
    final f = habitFakes();
    final sharer = FakeImageSharer()..failNext = Exception('no share');
    final id = f.addHabit('Read', start: '2026-10-15').id;
    f.doneRange(id, '2026-10-15', '2026-10-20');
    await pumpHabitApp(tester, habits: f, imageSharer: sharer);
    await tapAndSettle(tester, check(id));
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share_streak')));
      await Future<void>.delayed(const Duration(milliseconds: 500));
    });
    await tester.pumpAndSettle();
    expect(find.text("Couldn't share. Try again."), findsOneWidget);
    expect(find.byType(MilestoneSheet), findsOneWidget);
  });

  testWidgets('a milestone from + on a count habit shows the sheet too', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f
        .addHabit(
          'Water',
          start: '2026-10-15',
          kind: HabitKind.count,
          schedule: const HabitSchedule(type: ScheduleType.daily, target: 2),
        )
        .id;
    f
      ..doneRange(id, '2026-10-15', '2026-10-20', value: 2)
      ..setDay(id, '2026-10-21');
    await pumpHabitApp(tester, habits: f);
    await tapAndSettle(tester, find.byKey(ValueKey('plus_$id')));
    expect(find.text('7-day streak!'), findsOneWidget);
  });
}
