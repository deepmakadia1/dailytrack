import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/presentation/screens/budgets_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// EXP-02 US2-6 / FR-019: tapping a budget alert opens EXP-08 for its
/// month. The cold-start (launch payload) cases are in bootstrap_test.dart.
void main() {
  const payload = '/expenses/budgets?month=2026-09';

  testWidgets('EXP-02 US2-6 a tap while the app runs opens EXP-08 for the '
      "alert's month", (tester) async {
    final notifications = FakeNotificationService();
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true, locale: 'en'),
      ),
      expense: ExpenseFakes.withDefaults(),
      notifications: notifications,
    );
    notifications.tap(payload);
    await tester.pumpAndSettle();
    expect(find.byType(BudgetsScreen), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    expect(Routes.expenseBudgetsPath(month: '2026-09'), payload);
  });

  testWidgets('EXP-02 US2-6 / SYS-03 a tap while locked shows SYS-03 first, '
      'then opens EXP-08 after unlocking (feature 007 T074)', (tester) async {
    final notifications = FakeNotificationService();
    final settings = FakeSettingsRepository(
      initial: const AppSettings(
        onboardingDone: true,
        lockEnabled: true,
        locale: 'en',
      ),
    );
    final lock = TestLock(settings: settings);
    await lock.seedPin('1234');
    await pumpTestApp(
      tester,
      settings: settings,
      lock: lock,
      expense: ExpenseFakes.withDefaults(),
      notifications: notifications,
    );
    notifications.tap(payload);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(BudgetsScreen), findsNothing);

    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.byKey(Key('pin_key_$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsNothing);
    expect(find.byType(BudgetsScreen), findsOneWidget);
  });
}
