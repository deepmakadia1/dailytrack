import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';
import '../expense/fakes.dart';
import 'fakes.dart';

export '../expense/expense_test_app.dart'
    show containerOf, flushTimers, locationOf, routerOf;

/// Wednesday 2026-10-21 10:00 local; weeks start on Monday 19.
final DateTime habitNow = DateTime(2026, 10, 21, 10);

/// The Expense fakes whose clock each [HabitFakes] shares: the app clock
/// (`clockProvider`) is bound by the Expense fakes.
final _expenseOf = Expando<ExpenseFakes>('expense fakes');

/// Habit fakes on the app clock at [now] (default [habitNow]).
HabitFakes habitFakes({DateTime? now}) {
  final expense = ExpenseFakes.empty(now: now ?? habitNow);
  final habits = HabitFakes(expense.clock);
  _expenseOf[habits] = expense;
  return habits;
}

/// Pumps the app past onboarding with Habit fakes (no database) on a
/// phone-sized surface and opens [location]. [habits] must come from
/// [habitFakes], so the app clock is the fakes' clock.
Future<FakeSettingsRepository> pumpHabitApp(
  WidgetTester tester, {
  required HabitFakes habits,
  String location = Routes.habits,
  String locale = 'en',
  int firstDayOfWeek = 1,
  FakeNotificationService? notifications,
  FakeImageSharer? imageSharer,
  FakeFeatureGate? gate,
  bool debugTools = false,
  bool debugUnlockAll = false,
  String themeMode = 'system',
  Size size = const Size(412, 915),
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  habits.world.firstDayOfWeek = firstDayOfWeek;
  final settings = await pumpTestApp(
    tester,
    settings: FakeSettingsRepository(
      initial: AppSettings(
        onboardingDone: true,
        locale: locale,
        firstDayOfWeek: firstDayOfWeek,
        debugUnlockAll: debugUnlockAll,
        themeMode: themeMode,
      ),
    ),
    expense: _expenseOf[habits] ?? (throw ArgumentError('use habitFakes()')),
    habit: habits,
    notifications: notifications,
    imageSharer: imageSharer,
    gate: gate,
    debugTools: debugTools,
  );
  routerOf(tester).go(location);
  await tester.pumpAndSettle();
  return settings;
}

/// Five habits covering every HAB-01 card shape: yes/no done with a
/// streak, count partial with a note and a freeze, times per week, not
/// scheduled today, and a long name (T093/T094 data set).
HabitFakes sampleHabits() {
  final f = habitFakes();
  final read = f.addHabit('Read').id;
  f.doneRange(read, '2026-10-12', '2026-10-21');
  final water = f
      .addHabit(
        'Drink water',
        kind: HabitKind.count,
        schedule: const HabitSchedule(type: ScheduleType.daily, target: 8),
        unit: 'glasses',
        freezes: 1,
      )
      .id;
  return f
    ..setDay(water, '2026-10-21', value: 3, note: 'Hot day')
    ..addHabit(
      'Swim',
      schedule: const HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 1,
        timesPerWeek: 3,
      ),
    )
    ..addHabit(
      'Tennis',
      schedule: const HabitSchedule(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdays: {2, 4},
      ),
    )
    ..addHabit('Stretching before bed every evening', start: '2026-09-01');
}
