import 'dart:async';

import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/screens/modules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../../helpers/widget_wrapper.dart';

/// SET-06 Modules (T086). Fake modules and a fake settings repository only;
/// no database (Constitution IV). Data retention is covered in T087.
void main() {
  late FakeTrackerModule expense;
  late FakeTrackerModule habit;
  late ModuleRegistry registry;

  setUp(() {
    expense = FakeTrackerModule(
      id: 'expense',
      rootPath: '/expenses',
      name: 'Spend',
    );
    habit = FakeTrackerModule(id: 'habit', rootPath: '/habits', name: 'Habit');
    registry = ModuleRegistry([expense, habit]);
  });

  Finder toggle(String id) => find.byKey(Key('modules_toggle_$id'));
  Finder handle(String id) => find.byKey(Key('modules_handle_$id'));

  bool isOn(WidgetTester tester, String id) =>
      tester.widget<SwitchListTile>(toggle(id)).value;

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
    await tapNav(tester, 'More');
    await tester.ensureVisible(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    expect(find.byType(ModulesScreen), findsOneWidget);
  }

  Future<FakeSettingsRepository> pumpModules(
    WidgetTester tester, {
    AppSettings settings = const AppSettings(onboardingDone: true),
  }) async {
    final repo = await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(initial: settings),
      registry: registry,
    );
    await openModules(tester);
    return repo;
  }

  testWidgets('SET-06 disabling a module hides its tab and dashboard card '
      'and calls onDisable', (tester) async {
    final repo = await pumpModules(tester);
    expect(navLabels(tester), ['Home', 'Spend', 'Habit', 'More']);
    final writesBefore = repo.writeCount;

    await tester.tap(toggle('expense'));
    await tester.pumpAndSettle();

    expect(isOn(tester, 'expense'), isFalse);
    expect(navLabels(tester), ['Home', 'Habit', 'More']);
    expect(expense.disableCalls, 1);
    expect(repo.writeCount - writesBefore, 1);
    expect(repo.calls['setModules'], 1);

    await tapNav(tester, 'Home');
    expect(find.text('Spend card'), findsNothing);
    expect(find.text('Habit card'), findsOneWidget);
  });

  testWidgets('SET-06 at least one module stays enabled', (tester) async {
    final repo = await pumpModules(
      tester,
      settings: const AppSettings(
        onboardingDone: true,
        enabledModules: ['habit'],
      ),
    );
    expect(find.text('At least one module must stay on'), findsNothing);

    await tester.tap(toggle('habit'));
    await tester.pumpAndSettle();

    expect(isOn(tester, 'habit'), isTrue);
    expect(find.text('At least one module must stay on'), findsOneWidget);
    expect(habit.disableCalls, 0);
    expect(repo.current.enabledModules, ['habit']);

    // Announced to screen readers.
    final live = find.ancestor(
      of: find.text('At least one module must stay on'),
      matching: find.byWidgetPredicate(
        (w) => w is Semantics && (w.properties.liveRegion ?? false),
      ),
    );
    expect(live, findsOneWidget);
  });

  testWidgets('SET-06 reorder changes tab and card order and persists', (
    tester,
  ) async {
    final repo = await pumpModules(tester);

    // Drag Habit's handle above Spend.
    final gesture = await tester.startGesture(
      tester.getCenter(handle('habit')),
    );
    await tester.pump();
    for (var i = 0; i < 10; i++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await gesture.up();
    await tester.pumpAndSettle();

    expect(repo.current.moduleOrder, ['habit', 'expense']);
    expect(repo.current.enabledModules, unorderedEquals(['expense', 'habit']));
    expect(navLabels(tester), ['Home', 'Habit', 'Spend', 'More']);
    expect(
      tester.getTopLeft(toggle('habit')).dy,
      lessThan(tester.getTopLeft(toggle('expense')).dy),
    );

    await restartTestApp(tester, settings: repo, registry: registry);
    expect(navLabels(tester), ['Home', 'Habit', 'Spend', 'More']);
    expect(
      tester.getTopLeft(find.text('Habit card')).dy,
      lessThan(tester.getTopLeft(find.text('Spend card')).dy),
    );
  });

  testWidgets('SET-06 coming soon rows are disabled and not reorderable', (
    tester,
  ) async {
    await pumpModules(tester);
    for (final id in ['water', 'period']) {
      final row = find.byKey(Key('modules_soon_$id'));
      await tester.scrollUntilVisible(row, 100);
      expect(row, findsOneWidget);
      final tile = tester.widget<SwitchListTile>(row);
      expect(tile.value, isFalse);
      expect(tile.onChanged, isNull);
      expect(handle(id), findsNothing);
      expect(
        find.ancestor(
          of: row,
          matching: find.byType(ReorderableDragStartListener),
        ),
        findsNothing,
      );
    }
    expect(find.text('Water'), findsOneWidget);
    expect(find.text('Period'), findsOneWidget);
    // Only the two registered modules have drag handles.
    expect(find.byType(ReorderableDragStartListener), findsNWidgets(2));
  });

  testWidgets('SET-06 re-enabling calls onEnable and restores the tab', (
    tester,
  ) async {
    await pumpModules(
      tester,
      settings: const AppSettings(
        onboardingDone: true,
        enabledModules: ['expense'],
      ),
    );
    expect(navLabels(tester), ['Home', 'Spend', 'More']);

    await tester.tap(toggle('habit'));
    await tester.pumpAndSettle();

    expect(isOn(tester, 'habit'), isTrue);
    expect(habit.enableCalls, 1);
    expect(navLabels(tester), ['Home', 'Spend', 'Habit', 'More']);
  });

  testWidgets('SET-06 drag handles and switches have semantic labels', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpModules(tester);
    expect(find.bySemanticsLabel('Reorder Spend'), findsOneWidget);
    expect(find.bySemanticsLabel('Reorder Habit'), findsOneWidget);
    expect(tester.getSize(handle('habit')).height, greaterThanOrEqualTo(48));
    expect(tester.getSize(handle('habit')).width, greaterThanOrEqualTo(48));
    semantics.dispose();
  });

  /// The screen alone, with the settings stream under test control. The
  /// whole app can't show SET-06 without settings (redirect rule 1).
  Future<void> pumpScreenOnly(
    WidgetTester tester,
    Stream<AppSettings> Function() settings,
  ) => tester.pumpWidget(
    ProviderScope(
      overrides: [
        moduleRegistryProvider.overrideWithValue(registry),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
        appSettingsProvider.overrideWith((ref) => settings()),
      ],
      child: themed(const ModulesScreen(), wrapInScaffold: false),
    ),
  );

  testWidgets('SET-06 loading shows a skeleton only after 300 ms', (
    tester,
  ) async {
    final pending = StreamController<AppSettings>();
    addTearDown(pending.close);
    await pumpScreenOnly(tester, () => pending.stream);

    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SkeletonList), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(SkeletonList), findsOneWidget);

    pending.add(const AppSettings(onboardingDone: true));
    await tester.pumpAndSettle();
    expect(find.byType(SkeletonList), findsNothing);
    expect(toggle('expense'), findsOneWidget);
  });

  testWidgets('SET-06 a settings read error shows ErrorState and Retry '
      'reloads', (tester) async {
    var attempts = 0;
    await pumpScreenOnly(tester, () {
      attempts++;
      return attempts == 1
          ? Stream.error(StateError('read failed'))
          : Stream.value(const AppSettings(onboardingDone: true));
    });
    await tester.pumpAndSettle();

    expect(find.byType(ErrorState), findsOneWidget);
    expect(
      find.text("Couldn't load or save your modules. Try again."),
      findsOneWidget,
    );

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorState), findsNothing);
    expect(toggle('habit'), findsOneWidget);
    expect(attempts, 2);
  });
  // --- Feature 006 (T052, US6, FR-034): reorder without dragging.

  Set<String> customActions(WidgetTester tester, String id) {
    final data = tester
        .getSemantics(find.byKey(Key('modules_row_$id')))
        .getSemanticsData();
    return {
      for (final actionId in data.customSemanticsActionIds ?? const <int>[])
        CustomSemanticsAction.getAction(actionId)!.label!,
    };
  }

  void perform(WidgetTester tester, String id, String label) {
    final node = tester.getSemantics(find.byKey(Key('modules_row_$id')));
    final action = node.getSemanticsData().customSemanticsActionIds!.firstWhere(
      (a) => CustomSemanticsAction.getAction(a)!.label == label,
    );
    node.owner!.performAction(node.id, SemanticsAction.customAction, action);
  }

  testWidgets('SET-06 US6-4 rows expose Move up / Move down; the ends omit '
      'the impossible one', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpModules(tester);
    expect(customActions(tester, 'expense'), {'Move down'});
    expect(customActions(tester, 'habit'), {'Move up'});
    semantics.dispose();
  });

  testWidgets('SET-06 US6-4 "Move down" reorders and persists like a drag', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final repo = await pumpModules(tester);
    perform(tester, 'expense', 'Move down');
    await tester.pumpAndSettle();
    expect(repo.current.moduleOrder, ['habit', 'expense']);
    expect(
      tester.getTopLeft(toggle('habit')).dy,
      lessThan(tester.getTopLeft(toggle('expense')).dy),
    );
    expect(navLabels(tester), ['Home', 'Habit', 'Spend', 'More']);
    expect(customActions(tester, 'expense'), {'Move up'});
    semantics.dispose();
  });
}
