import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';

/// Guest journey on a device (feature 012 T019, spec FR-007, US2 scenario
/// 4): Intro → AUTH-01 "Continue as guest" → add an expense → SET-01 "Log
/// out of guest" → ACC-04 "Log out and delete" → AUTH-01, and a restart
/// opens AUTH-01 again. No Google sign-in or Drive request is made at any
/// point. Real database and erase; Google is a recording fake.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  Future<int> liveTransactions(WidgetTester tester) async {
    final db = containerOf(tester).read(appDatabaseProvider);
    final rows = await db
        .customSelect(
          'SELECT COUNT(*) AS n FROM transactions WHERE deleted_at IS NULL',
        )
        .getSingle();
    return rows.read<int>('n');
  }

  testWidgets('Intro → AUTH-01 guest → add expense → Log out of guest → '
      'AUTH-01; a restart opens AUTH-01; no Google or Drive call', (
    tester,
  ) async {
    final world = HarnessWorld();
    await launch(tester, world);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await startAsGuest(tester);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(
      containerOf(tester).read(appSettingsProvider).value!.authMode,
      AuthMode.guest,
    );

    // Add ₹250 through DSH-01's + menu.
    await tapKey(tester, 'home_fab');
    await tapKey(tester, 'home_quick_add_expense_quickAdd');
    for (final d in ['2', '5', '0']) {
      await tester.tap(
        find.descendant(of: find.byType(NumericKeypad), matching: find.text(d)),
      );
      await tester.pump();
    }
    await tester.tap(find.text('Food'));
    await tapKey(tester, 'save_transaction');
    expect(find.text('₹250.00'), findsWidgets);
    expect(await liveTransactions(tester), 1);

    // SET-01 → "Log out of guest" → ACC-04 "Log out and delete".
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('More'),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'set01_logOutGuest');
    expect(find.byKey(const Key('acc04_dialog')), findsOneWidget);
    await tapKey(tester, 'acc04_confirm');
    await pumpUntil(tester, () => shows(find.byType(LoginScreen)));
    expect(await liveTransactions(tester), 0);
    expect(
      containerOf(tester).read(appSettingsProvider).value!.authMode,
      AuthMode.none,
    );

    await restart(tester, world);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(UnlockScreen), findsNothing);

    // Guest data never reaches Google (spec §13 data safety).
    expect(world.auth.calls, isEmpty);
    expect(world.drive.calls, isEmpty);
    await closeApp(tester);
  });
}
