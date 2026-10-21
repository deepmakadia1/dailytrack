import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/settings/presentation/screens/modules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../features/dashboard/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// SC-008 (T111): a third tracker needs only a registry entry. The router,
/// tab bar, Home and SET-06 pick it up with no other code changes. The id is
/// neutral so it doesn't clash with the built-in "Coming soon" rows.
void main() {
  late FakeTrackerModule notes;

  setUp(() {
    notes = FakeTrackerModule(
      id: 'notes',
      rootPath: '/notes',
      name: 'Notes',
      routes: [
        GoRoute(
          path: '/notes',
          builder: (context, state) =>
              const Scaffold(body: Text('Notes screen')),
        ),
      ],
    );
  });

  Future<FakeSettingsRepository> pumpWithNotes(WidgetTester tester) =>
      pumpTestApp(
        tester,
        registry: ModuleRegistry([...registeredModules, notes]),
        settings: FakeSettingsRepository(
          knownModuleIds: const ['expense', 'habit', 'notes'],
          initial: const AppSettings(
            onboardingDone: true,
            moduleOrder: ['expense', 'habit', 'notes'],
            enabledModules: ['expense', 'habit', 'notes'],
          ),
        ),
      );

  List<String> navLabels(WidgetTester tester) => [
    for (final d in tester.widgetList<NavigationDestination>(
      find.byType(NavigationDestination),
    ))
      d.label,
  ];

  Future<void> tapNav(WidgetTester tester, String label) async {
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text(label),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openModules(WidgetTester tester) async {
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(appRouterProvider)
        .go(Routes.modules);
    await tester.pumpAndSettle();
    expect(find.byType(ModulesScreen), findsOneWidget);
  }

  testWidgets('SC-008 a registered module gets a tab, a route and a Home '
      'card', (tester) async {
    await pumpWithNotes(tester);
    expect(navLabels(tester), ['Home', 'Expenses', 'Habits', 'Notes', 'More']);
    expect(find.text('Notes card'), findsOneWidget);

    await tapNav(tester, 'Notes');
    expect(find.text('Notes screen'), findsOneWidget);
  });

  testWidgets('SC-008 SET-06 lists it with a working toggle and drag handle', (
    tester,
  ) async {
    final settings = await pumpWithNotes(tester);
    await openModules(tester);

    expect(find.byKey(const Key('modules_toggle_notes')), findsOneWidget);
    expect(find.byKey(const Key('modules_handle_notes')), findsOneWidget);
    // "Coming soon" still shows exactly Water and Period.
    final soon = find.byWidgetPredicate(
      (w) =>
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('modules_soon_'),
    );
    expect(
      tester.widgetList(soon).map((w) => (w.key! as ValueKey<String>).value),
      unorderedEquals(['modules_soon_water', 'modules_soon_period']),
    );

    // Drag Notes just above Habit (one row up).
    final from = tester.getCenter(
      find.byKey(const Key('modules_handle_notes')),
    );
    final to = tester.getCenter(find.byKey(const Key('modules_handle_habit')));
    final step = Offset(0, (to.dy - from.dy - 8) / 10);
    final gesture = await tester.startGesture(from);
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(step);
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();
    expect(settings.current.moduleOrder, ['expense', 'notes', 'habit']);
    expect(navLabels(tester), ['Home', 'Expenses', 'Notes', 'Habits', 'More']);

    // Disabling hides the tab and calls its hook.
    await tester.tap(find.byKey(const Key('modules_toggle_notes')));
    await tester.pumpAndSettle();
    expect(navLabels(tester), ['Home', 'Expenses', 'Habits', 'More']);
    expect(notes.disableCalls, 1);
    expect(settings.current.enabledModules, isNot(contains('notes')));
  });
  // --- Feature 006 (T057, FR-005): Home extensibility.

  testWidgets('SC-008 a third module contributes a card, a section, a badge, '
      'a quick add, and an insight to Home; disabling it removes all five', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(412, 2000)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final full = FakeTrackerModule(
      id: 'notes',
      rootPath: '/notes',
      name: 'Notes',
      routes: [
        GoRoute(
          path: '/notes',
          builder: (context, state) =>
              const Scaffold(body: Text('Notes screen')),
        ),
      ],
      sections: [
        DashboardSection(
          id: 'notes.pinned',
          build: (_) => const Text('Pinned notes'),
        ),
      ],
      badge: const SizedBox.square(dimension: 48, child: Text('N')),
      quickAdds: const [
        QuickAddAction(
          labelKey: 'notes_add',
          icon: Icons.note_add,
          location: '/notes',
        ),
      ],
      insightSource: FakeInsightSource(
        const ['notes.tip'],
        insights: const [Insight(ruleId: 'notes.tip', text: 'Write one line')],
      ),
    );
    final repo = await pumpTestApp(
      tester,
      registry: ModuleRegistry([...registeredModules, full]),
      settings: FakeSettingsRepository(
        knownModuleIds: const ['expense', 'habit', 'notes'],
        initial: const AppSettings(
          onboardingDone: true,
          moduleOrder: ['expense', 'habit', 'notes'],
          enabledModules: ['expense', 'habit', 'notes'],
        ),
      ),
    );
    expect(find.byKey(const Key('home_card_notes')), findsOneWidget);
    expect(find.byKey(const Key('home_section_notes.pinned')), findsOneWidget);
    expect(find.byKey(const Key('home_badge_notes')), findsOneWidget);
    expect(find.text('Write one line'), findsOneWidget);
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_quick_add_notes_add')), findsOneWidget);
    await tester.tapAt(Offset.zero);
    await tester.pumpAndSettle();

    await repo.setModules(
      order: const ['expense', 'habit', 'notes'],
      enabled: const ['expense', 'habit'],
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_card_notes')), findsNothing);
    expect(find.byKey(const Key('home_section_notes.pinned')), findsNothing);
    expect(find.byKey(const Key('home_badge_notes')), findsNothing);
    expect(find.text('Write one line'), findsNothing);
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home_quick_add_notes_add')), findsNothing);
  });
}
