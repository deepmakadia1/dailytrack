import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// Phase 2 checkpoint: the app boots through the splash to the right first
/// screen, using fakes only.
void main() {
  testWidgets('a fresh install goes to onboarding', (tester) async {
    await pumpTestApp(tester);
    expect(find.byType(HomeScreen), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
  });

  testWidgets('a returning user lands on Home with four tabs', (tester) async {
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['Home', 'Expenses', 'Habits', 'More']) {
      expect(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(label),
        ),
        findsOneWidget,
      );
    }
    // Home lists both modules' placeholder cards.
    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Habit'), findsOneWidget);
  });

  testWidgets('a startup failure shows the splash error with Retry', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      bootstrap: FakeBootstrap(
        results: [
          BootstrapFailed(StateError('db')),
          const BootstrapReady(Routes.onboarding),
        ],
      ),
    );
    expect(find.text("Couldn't open your data. Try again."), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text("Couldn't open your data. Try again."), findsNothing);
  });

  testWidgets('tabs switch between placeholder screens', (tester) async {
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      ),
    );
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await scrollSettingsTo(tester, find.text('Modules'));
    expect(find.text('Modules'), findsOneWidget);
  });
}
