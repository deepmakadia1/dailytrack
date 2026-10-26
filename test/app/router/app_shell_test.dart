import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habits_today_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// AppShell: registry-driven, settings-ordered bottom navigation (spec §5,
/// contracts/routes.md "Shell").
void main() {
  Future<void> pumpShell(
    WidgetTester tester, {
    AppSettings settings = const AppSettings(onboardingDone: true),
  }) =>
      pumpTestApp(tester, settings: FakeSettingsRepository(initial: settings));

  List<String> navLabels(WidgetTester tester) => [
    for (final d in tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    ))
      d.label,
  ];

  int selectedIndex(WidgetTester tester) =>
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex;

  Finder navItem(String label) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  );

  Finder navIcon(IconData icon) => find.descendant(
    of: find.byType(NavigationBar),
    matching: find.byIcon(icon),
  );

  Future<void> tapTab(WidgetTester tester, String label) async {
    await tester.tap(navItem(label));
    await tester.pumpAndSettle();
  }

  testWidgets('DSH-01 default settings show Home, Expenses, Habits, More', (
    tester,
  ) async {
    await pumpShell(tester);
    expect(navLabels(tester), ['Home', 'Expenses', 'Habits', 'More']);

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(
      bar.labelBehavior ??
          Theme.of(tester.element(find.byType(NavigationBar)))
              .navigationBarTheme
              .labelBehavior,
      NavigationDestinationLabelBehavior.alwaysShow,
    );
    expect(tester.getSize(find.byType(NavigationBar)).height, 80);

    // The selected destination shows its filled icon; the others outlined.
    expect(selectedIndex(tester), 0);
    expect(navIcon(Icons.home), findsOneWidget);
    expect(navIcon(Icons.receipt_long_outlined), findsOneWidget);
    await tapTab(tester, 'Expenses');
    expect(selectedIndex(tester), 1);
    expect(navIcon(Icons.receipt_long), findsOneWidget);
    expect(navIcon(Icons.home_outlined), findsOneWidget);
  });

  testWidgets('DSH-01 a disabled module has no tab', (tester) async {
    await pumpShell(
      tester,
      settings: const AppSettings(
        onboardingDone: true,
        enabledModules: ['habit'],
      ),
    );
    expect(navLabels(tester), ['Home', 'Habits', 'More']);
  });

  testWidgets('DSH-01 tabs follow the module order', (tester) async {
    await pumpShell(
      tester,
      settings: const AppSettings(
        onboardingDone: true,
        moduleOrder: ['habit', 'expense'],
      ),
    );
    expect(navLabels(tester), ['Home', 'Habits', 'Expenses', 'More']);

    // Each destination opens its own module, not the one at that branch slot.
    await tapTab(tester, 'Habits');
    expect(find.byType(HabitsTodayScreen), findsOneWidget);
    expect(selectedIndex(tester), 1);
    await tapTab(tester, 'Expenses');
    expect(find.byType(TransactionsScreen), findsOneWidget);
    expect(selectedIndex(tester), 2);
  });

  testWidgets('SET-01 each tab keeps its own back stack', (tester) async {
    await pumpShell(tester);
    await tapTab(tester, 'More');
    await scrollSettingsTo(tester, find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);

    await tapTab(tester, 'Habits');
    expect(find.byType(HabitsTodayScreen), findsOneWidget);

    await tapTab(tester, 'More');
    // Still on SET-06, pushed above the More root.
    expect(find.byType(BackButton), findsOneWidget);
  });

  testWidgets('DSH-01 back on a tab root goes to Home', (tester) async {
    await pumpShell(tester);
    await tapTab(tester, 'Expenses');
    expect(find.byType(TransactionsScreen), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(selectedIndex(tester), 0);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('DSH-01 back on a pushed screen pops it, not the tab', (
    tester,
  ) async {
    await pumpShell(tester);
    await tapTab(tester, 'More');
    await scrollSettingsTo(tester, find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(selectedIndex(tester), 3);
    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Modules'), findsOneWidget);
  });

  testWidgets('DSH-01 back on Home exits the app', (tester) async {
    await pumpShell(tester);
    final handled = await tester.binding.handlePopRoute();
    expect(handled, isFalse);
  });

  testWidgets('DSH-01 tapping the active tab pops it to its root', (
    tester,
  ) async {
    await pumpShell(tester);
    await tapTab(tester, 'More');
    await scrollSettingsTo(tester, find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);

    await tapTab(tester, 'More');
    expect(find.byType(BackButton), findsNothing);
    expect(find.text('Modules'), findsOneWidget);
  });
}
