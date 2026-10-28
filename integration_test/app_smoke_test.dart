import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';

/// End-to-end smoke test on a device (T103, feature 012 T015): the real
/// database, settings repository and bootstrap, as `main()` wires them, with
/// the harness fakes for Google, ads and notifications. A fresh install now
/// opens SYS-02 Intro and then AUTH-01 Login (feature 011).
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const primary = Key('onboarding_primary');

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  setUp(freshInstall);

  testWidgets('SYS-02 Skip on a fresh install opens AUTH-01 Login; '
      '"Continue as guest" lands on Home with four tabs', (tester) async {
    final world = HarnessWorld();
    await launch(tester, world);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tapKey(tester, 'onboarding_skip');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tapKey(tester, 'auth01_guest');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['Home', 'Expenses', 'Habits', 'More']) {
      expect(navLabel(label), findsOneWidget);
    }
    expect(world.auth.calls, isEmpty);
    await closeApp(tester);
  });

  testWidgets('SC-006 the chosen language survives a restart with the real '
      'database', (tester) async {
    final world = HarnessWorld();
    await launch(tester, world);

    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('onboarding_language')),
        matching: find.text('ગુજરાતી'),
      ),
    );
    await tester.pumpAndSettle();
    for (var step = 1; step <= 4; step++) {
      // Next on steps 1–3, then Get started on step 4.
      await tester.tap(find.byKey(primary));
      await tester.pumpAndSettle();
    }
    expect(find.byType(LoginScreen), findsOneWidget);
    await tapKey(tester, 'auth01_guest');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navLabel('હોમ'), findsOneWidget);

    await restart(tester, world);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navLabel('હોમ'), findsOneWidget);
    expect(navLabel('Home'), findsNothing);
    await closeApp(tester);
  });
}
