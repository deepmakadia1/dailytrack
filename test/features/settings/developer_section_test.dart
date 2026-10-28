import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/expense_module.dart';
import 'package:dailytrack/features/habit/habit_module.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fake_webview.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-01 Developer section rows from `TrackerModule.devActions` (feature
/// 012 T036, contracts/dev-seed.md "SET-01 Developer section", spec
/// FR-012, FR-013). Fakes only: the action never touches a database.
void main() {
  setUp(FakeWebViewPlatform.install);

  const row = Key('dev_expense.seed10k');

  Future<_GatedExpense> open(
    WidgetTester tester, {
    bool devTools = true,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 3200)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final module = _GatedExpense();
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true, locale: 'en'),
      ),
      registry: ModuleRegistry([module, const HabitModule()]),
      debugTools: devTools,
    );
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    return module;
  }

  Future<void> tapRow(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(row));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(row));
    await tester.pumpAndSettle();
  }

  testWidgets('SET-01 dev build: the Developer section shows "Seed 10,000 '
      'transactions"; Cancel in the confirm dialog runs nothing', (
    tester,
  ) async {
    final module = await open(tester);
    expect(find.byKey(const Key('developer_section')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(row),
        matching: find.text('Seed 10,000 transactions'),
      ),
      findsOneWidget,
    );
    await tapRow(tester);
    expect(find.byKey(const Key('dev_confirm')), findsOneWidget);
    expect(
      find.textContaining('Add 10,000 sample transactions'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('dev_confirm_cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dev_confirm')), findsNothing);
    expect(module.runs, 0);
  });

  testWidgets('SET-01 confirming shows progress with the row disabled, then '
      '"Added 10,000 transactions"', (tester) async {
    final module = await open(tester);
    await tapRow(tester);
    await tester.tap(find.byKey(const Key('dev_confirm_ok')));
    await tester.pump();
    await tester.pump();
    expect(module.runs, 1);
    expect(find.byKey(const Key('dev_progress')), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byKey(const Key('dev_progress')),
          )
          .value,
      0.5,
    );
    expect(tester.widget<ListTile>(find.byKey(row)).enabled, isFalse);

    module.gate.complete(const DevActionDone(10000));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dev_progress')), findsNothing);
    expect(tester.widget<ListTile>(find.byKey(row)).enabled, isTrue);
    expect(find.byKey(const Key('dev_done')), findsOneWidget);
    expect(find.text('Added 10,000 transactions'), findsOneWidget);
  });

  testWidgets('SET-01 a running backup or restore: "A backup or restore is '
      'running"', (tester) async {
    final module = await open(tester);
    await tapRow(tester);
    await tester.tap(find.byKey(const Key('dev_confirm_ok')));
    await tester.pump();
    module.gate.complete(const DevActionBusy());
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('dev_busy')), findsOneWidget);
    expect(
      find.text('A backup or restore is running. Try again when it finishes.'),
      findsOneWidget,
    );
  });

  testWidgets('SET-01 prod build: neither the Developer section nor the seed '
      'row exists (spec FR-013)', (tester) async {
    await open(tester, devTools: false);
    final list = find.byType(Scrollable).first;
    for (var i = 0; i < 30; i++) {
      expect(find.byKey(const Key('developer_section')), findsNothing);
      expect(find.byKey(row), findsNothing);
      final position = tester.state<ScrollableState>(list).position;
      if (position.pixels >= position.maxScrollExtent) break;
      await tester.drag(list, const Offset(0, -600));
      await tester.pumpAndSettle();
    }
    expect(find.text('Seed 10,000 transactions'), findsNothing);
  });

  test('the real Expense module offers the seed action only when debug '
      'tools are available', () {
    for (final available in [false, true]) {
      final container = ProviderContainer(
        overrides: [debugToolsAvailableProvider.overrideWithValue(available)],
      );
      addTearDown(container.dispose);
      final actions = const ExpenseModule().devActions(container.read);
      expect(
        [for (final a in actions) a.id],
        available ? ['expense.seed10k'] : isEmpty,
        reason: 'available: $available',
      );
    }
  });
}

/// The real Expense module with its seed action swapped for one that waits
/// on [gate], so the widget test never opens a database.
final class _GatedExpense extends TrackerModule {
  new();

  static const ExpenseModule _real = ExpenseModule();

  int runs = 0;
  final gate = Completer<DevActionResult>();

  @override
  List<DevAction> devActions(ProviderReader read) => [
    for (final a in _real.devActions(read))
      DevAction(
        id: a.id,
        labelKey: a.labelKey,
        confirmKey: a.confirmKey,
        icon: a.icon,
        run: (read, onProgress) {
          runs++;
          onProgress(0.5);
          return gate.future;
        },
      ),
  ];

  @override
  String get id => _real.id;
  @override
  String displayName(BuildContext context) => _real.displayName(context);
  @override
  String tabLabel(BuildContext context) => _real.tabLabel(context);
  @override
  IconData get icon => _real.icon;
  @override
  IconData get selectedIcon => _real.selectedIcon;
  @override
  String get rootPath => _real.rootPath;
  @override
  List<RouteBase> get routes => _real.routes;
  @override
  Widget dashboardCard(BuildContext context) => _real.dashboardCard(context);
  @override
  List<QuickAddAction> quickAddActions() => _real.quickAddActions();
  @override
  List<DashboardSection> dashboardSections() => _real.dashboardSections();
  @override
  InsightSource? insights() => _real.insights();
  @override
  Widget? appBarBadge(BuildContext context) => _real.appBarBadge(context);
  @override
  BackupSection? backupSection() => _real.backupSection();
  @override
  List<ExportDataset> exportDatasets() => _real.exportDatasets();
  @override
  Future<void> contributeGlance(
    GlanceBuilder b,
    ProviderReader read,
    DateTime nowLocal,
  ) => _real.contributeGlance(b, read, nowLocal);
  @override
  Future<bool> handleAction(AppAction action, ProviderReader read) =>
      _real.handleAction(action, read);
  @override
  List<Seeder> get seeders => _real.seeders;
  @override
  Future<void> onEnable(ProviderReader read) => _real.onEnable(read);
  @override
  Future<void> onDisable(ProviderReader read) => _real.onDisable(read);
  @override
  Future<void> onAppOpen(ProviderReader read) => _real.onAppOpen(read);
  @override
  Future<void> onNotificationSettingsChanged(ProviderReader read) =>
      _real.onNotificationSettingsChanged(read);
  @override
  Future<void> onEraseAll(ProviderReader read) => _real.onEraseAll(read);
  @override
  Map<String, BackgroundTask> get backgroundTasks => _real.backgroundTasks;
}
