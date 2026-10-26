import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/features/habit/presentation/screens/archived_habits_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../habit_test_app.dart';

/// HAB-04 Archived habits (T086; spec US6, FR-033). Today is Wednesday
/// 2026-10-21.
void main() {
  Future<void> tapAndSettle(WidgetTester tester, Finder f) async {
    await tester.tap(f);
    await tester.pumpAndSettle();
  }

  testWidgets('US6-1 rows show name, archive date, and best streak', (
    tester,
  ) async {
    final f = habitFakes();
    final id = f.addHabit('Swim', archived: true, start: '2026-09-01').id;
    f
      ..doneRange(id, '2026-09-01', '2026-09-10')
      ..doneRange(id, '2026-09-20', '2026-09-22');
    await pumpHabitApp(tester, habits: f, location: '/habits/archived');
    expect(find.text('Archived habits'), findsWidgets);
    expect(find.text('Swim'), findsOneWidget);
    expect(find.text('Archived 21 Oct 2026'), findsOneWidget);
    expect(find.text('Best streak: 10 days'), findsOneWidget);
  });

  testWidgets('entry from the HAB-01 overflow menu', (tester) async {
    await pumpHabitApp(tester, habits: habitFakes()..addHabit('Read'));
    await tapAndSettle(tester, find.byKey(const Key('habits_overflow')));
    await tapAndSettle(tester, find.byKey(const Key('menu_archived')));
    expect(find.byType(ArchivedHabitsScreen), findsOneWidget);
  });

  testWidgets('US6-2 Restore: back at the end of HAB-01, reminders '
      'rescheduled, Undo archives again', (tester) async {
    final f = habitFakes()
      ..addHabit('Read')
      ..addHabit('Walk');
    final id = f.addHabit('Swim', archived: true).id;
    await pumpHabitApp(tester, habits: f, location: '/habits/archived');
    await tapAndSettle(tester, find.byKey(ValueKey('restore_$id')));
    expect(find.text('Habit restored'), findsOneWidget);
    expect(f.world.habits[id]!.isArchived, isFalse);
    expect(f.world.habits[id]!.sortOrder, 2, reason: 'end of the list');
    expect(f.scheduler.calls, ['reconcile:$id']);
    expect(find.text('Archived habits appear here'), findsOneWidget);

    await tapAndSettle(tester, find.text('Undo'));
    expect(f.world.habits[id]!.isArchived, isTrue);
    expect(f.scheduler.calls, ['reconcile:$id', 'cancel:$id']);
    await flushTimers(tester);

    await tapAndSettle(tester, find.byKey(ValueKey('restore_$id')));
    await flushTimers(tester);
    routerOf(tester).go('/habits');
    await tester.pumpAndSettle();
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Walk')).dy,
      lessThan(tester.getTopLeft(find.text('Swim')).dy),
    );
  });

  testWidgets('US6-3 Delete permanently asks first, then removes it '
      'everywhere and cancels reminders', (tester) async {
    final f = habitFakes();
    final id = f.addHabit('Swim', archived: true).id;
    await pumpHabitApp(tester, habits: f, location: '/habits/archived');
    await tapAndSettle(tester, find.byKey(ValueKey('delete_$id')));
    expect(find.text('Delete habit?'), findsOneWidget);
    expect(find.text('This removes Swim and all its history.'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancel'));
    expect(f.world.habits, contains(id));
    await tapAndSettle(tester, find.byKey(ValueKey('delete_$id')));
    await tapAndSettle(tester, find.text('Delete habit'));
    expect(f.world.habits, isEmpty);
    expect(f.scheduler.calls, ['cancel:$id']);
    expect(find.text('Swim'), findsNothing);
    expect(find.text('Habit deleted'), findsOneWidget);
    await flushTimers(tester);
  });

  testWidgets('US6-4 empty state; the bottom banner slot (spec §11)', (
    tester,
  ) async {
    await pumpHabitApp(
      tester,
      habits: habitFakes()..addHabit('Read'),
      location: '/habits/archived',
    );
    expect(find.text('Archived habits appear here'), findsOneWidget);
    final scaffold = tester.widget<AppScaffold>(
      find.descendant(
        of: find.byType(ArchivedHabitsScreen),
        matching: find.byType(AppScaffold),
      ),
    );
    expect(scaffold.bannerSlot, isA<AppBannerAd>());
  });

  testWidgets('an error shows Try again', (tester) async {
    final f = habitFakes()
      ..addHabit('Swim', archived: true)
      ..world.failWatch = Exception('boom');
    await pumpHabitApp(tester, habits: f, location: '/habits/archived');
    expect(find.text('Try again'), findsOneWidget);
    f.world.failWatch = null;
    await tapAndSettle(tester, find.text('Try again'));
    expect(find.text('Swim'), findsOneWidget);
  });
}
