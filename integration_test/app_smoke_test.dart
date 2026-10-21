import 'package:dailytrack/app/app.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// End-to-end smoke test on a device (T103): the real database, real
/// settings repository and real bootstrap, exactly as `main()` wires them.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const primary = Key('onboarding_primary');
  const skip = Key('onboarding_skip');

  /// Simulates a fresh install by emptying every table of the app database.
  Future<void> wipeData() async {
    final db = AppDatabase.open();
    await db.transaction(() async {
      // Reverse order: transactions reference categories and accounts.
      for (final table in db.allTables.toList().reversed) {
        await db.delete(table).go();
      }
    });
    await db.close();
  }

  Future<void> launchApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: productionOverrides(),
        child: const DailyTrackApp(),
      ),
    );
    // Bootstrap does real disk I/O off the frame loop, so pumpAndSettle can
    // return while the splash is still up. Wait for it to hand over.
    final deadline = DateTime.now().add(const Duration(seconds: 15));
    while (find.byType(SplashScreen).evaluate().isNotEmpty &&
        DateTime.now().isBefore(deadline)) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
  }

  /// Disposes the provider scope (closing the database), as on app exit.
  Future<void> closeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
  }

  Finder navLabel(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  testWidgets('SYS-02 Skip on a fresh install lands on Home with four tabs', (
    tester,
  ) async {
    await wipeData();
    await launchApp(tester);
    expect(find.byType(OnboardingScreen), findsOneWidget);

    await tester.tap(find.byKey(skip));
    await tester.pumpAndSettle();

    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(4));
    for (final label in ['Home', 'Expenses', 'Habits', 'More']) {
      expect(navLabel(label), findsOneWidget);
    }
    await closeApp(tester);
  });

  testWidgets('SC-006 the chosen language survives a restart with the real '
      'database', (tester) async {
    await wipeData();
    await launchApp(tester);

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
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navLabel('હોમ'), findsOneWidget);

    await closeApp(tester);
    await launchApp(tester);

    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(navLabel('હોમ'), findsOneWidget);
    expect(navLabel('Home'), findsNothing);
    await closeApp(tester);
  });
}
