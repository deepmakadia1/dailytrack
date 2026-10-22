import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/reminders/reminder_ids.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/expense/fakes.dart';
import '../features/habit/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// Reminder buttons and widget taps while the app runs (feature 008 T109,
/// T128; research R16, R20; FR-046). "Now" is 2026-10-14 10:00.
void main() {
  late ExpenseFakes expense;
  late HabitFakes habit;
  late FakeNotificationService notifications;
  late FakeHomeWidgetBridge widget;
  late FakeGlanceRefresher refresher;

  setUp(() {
    expense = ExpenseFakes.withDefaults();
    habit = HabitFakes(expense.clock);
    notifications = FakeNotificationService();
    widget = FakeHomeWidgetBridge();
    refresher = FakeGlanceRefresher();
  });

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    bool lock = false,
  }) async {
    final settings = FakeSettingsRepository(
      initial: AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: lock,
      ),
    );
    TestLock? testLock;
    if (lock) {
      testLock = TestLock(settings: settings);
      await testLock.seedPin('1234');
    }
    await pumpTestApp(
      tester,
      settings: settings,
      expense: expense,
      habit: habit,
      lock: testLock,
      notifications: notifications,
      glance: refresher,
      overrides: [homeWidgetBridgeProvider.overrideWithValue(widget)],
    );
    return settings;
  }

  Future<void> unlock(WidgetTester tester) async {
    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(Key('pin_key_$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  group('T109 reminder buttons while the app runs', () {
    testWidgets('Mark done is handled in place: the habit is done, the '
        'screen stays, and the widget refreshes', (tester) async {
      final id = habit.addHabit('Meditate').id;
      await open(tester);
      routerOf(tester).go(Routes.more);
      await tester.pumpAndSettle();
      notifications.tapAction(
        HabitActions.markDone,
        '/habits?habit=$id&at=08:00&wd=0',
      );
      await tester.pumpAndSettle();
      expect(habit.world.entries[id]?[const LocalDate(2026, 10, 14)]?.value, 1);
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(refresher.refreshCalls, 1);
    });

    testWidgets('while locked: handled with no unlock prompt or navigation '
        'afterwards', (tester) async {
      final id = habit.addHabit('Meditate').id;
      await open(tester, lock: true);
      expect(find.byType(UnlockScreen), findsOneWidget);
      notifications.tapAction(
        HabitActions.markDone,
        '/habits?habit=$id&at=08:00&wd=0',
      );
      await tester.pumpAndSettle();
      expect(habit.world.entries[id]?[const LocalDate(2026, 10, 14)]?.value, 1);
      expect(find.byType(UnlockScreen), findsOneWidget);
      await unlock(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });

  group('T128 widget taps while the app runs (FR-046)', () {
    testWidgets('lock off → Home', (tester) async {
      await open(tester);
      routerOf(tester).go(Routes.more);
      await tester.pumpAndSettle();
      widget.launch();
      await tester.pumpAndSettle();
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('locked → SYS-03 stays; Home after unlocking', (tester) async {
      await open(tester, lock: true);
      expect(find.byType(UnlockScreen), findsOneWidget);
      widget.launch();
      await tester.pumpAndSettle();
      expect(find.byType(UnlockScreen), findsOneWidget);
      await unlock(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
