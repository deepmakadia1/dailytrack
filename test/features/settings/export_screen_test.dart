import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/share/file_sharer.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/features/expense/presentation/screens/reports_screen.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:dailytrack/features/settings/export_providers.dart';
import 'package:dailytrack/features/settings/presentation/screens/export_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';
import '../expense/fakes.dart';

/// SET-03 Export data (feature 008 T090, T091; US5; FR-026 – FR-034).
void main() {
  late FakeExportUseCase useCase;
  late FakeFileSharer sharer;
  late FakeFeatureGate gate;

  setUp(() {
    useCase = FakeExportUseCase();
    sharer = FakeFileSharer();
    gate = FakeFeatureGate(
      unlocked: {FeatureKey.exportCsv: true, FeatureKey.exportPdf: true},
    );
  });

  Future<ExpenseFakes> open(
    WidgetTester tester, {
    String location = Routes.export,
    AppSettings initial = const AppSettings(onboardingDone: true, locale: 'en'),
    FakeRewardedUnlockPresenter? presenter,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 1400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final expense = ExpenseFakes.withDefaults(now: DateTime(2026, 10, 21, 12));
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(initial: initial),
      expense: expense,
      gate: gate,
      rewardedPresenter: presenter,
      overrides: [
        exportUseCaseProvider.overrideWithValue(useCase),
        fileSharerProvider.overrideWithValue(sharer),
      ],
    );
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
    return expense;
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('SET-03 US5-1 data type, period (this month), format, filters, '
      'and one Export button', (tester) async {
    await open(tester);
    expect(find.byType(ExportScreen), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Habits'), findsOneWidget);
    expect(find.text('October 2026'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.byKey(const Key('export_filter_accounts')), findsOneWidget);
    expect(find.byKey(const Key('export_filter_categories')), findsOneWidget);
    expect(find.byType(FilledButton), findsOneWidget);
    expect(find.byType(LockedFeatureOverlay), findsNothing);
  });

  testWidgets('SET-03 filters are for Transactions only', (tester) async {
    await open(tester);
    await tester.tap(find.text('Habits'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('export_filter_accounts')), findsNothing);
  });

  testWidgets('SET-03 only enabled modules offer data types', (tester) async {
    await open(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        enabledModules: ['expense'],
      ),
    );
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Habits'), findsNothing);
  });

  testWidgets('SET-03 US5-7 a locked format shows the locked overlay with '
      '"Watch an ad" and "Get Pro", and Export does nothing; the debug unlock '
      'opens it live', (tester) async {
    gate
      ..set(FeatureKey.exportCsv, unlocked: false)
      ..set(FeatureKey.exportPdf, unlocked: false);
    await open(tester);
    expect(find.byType(LockedFeatureOverlay), findsOneWidget);
    expect(
      find.text(
        'Exports are part of DailyTrack Pro. Watch an ad for one export, '
        'or get Pro.',
      ),
      findsOneWidget,
    );
    expect(find.text('Watch an ad to unlock one export'), findsOneWidget);
    final button = tester.widget<ButtonStyleButton>(
      find.byKey(const Key('export_button')),
    );
    expect(button.onPressed, isNull);

    gate.set(FeatureKey.exportCsv, unlocked: true);
    await tester.pumpAndSettle();
    expect(find.byType(LockedFeatureOverlay), findsNothing);
    // PDF is still locked.
    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();
    expect(find.byType(LockedFeatureOverlay), findsOneWidget);
    expect(useCase.requests, isEmpty);
  });

  testWidgets('SET-03 US5-2/10 Export opens the share sheet with the file; '
      'the choices stay', (tester) async {
    await open(tester);
    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'export_button');
    final r = useCase.requests.single;
    expect(r.datasetId, 'transactions');
    expect(r.format, ExportFormat.pdf);
    expect(r.period, isA<MonthPeriod>());
    expect(sharer.shared, [
      '/cache/exports/dailytrack_transactions_2026-10.csv',
    ]);
    // Still on SET-03 with PDF chosen.
    expect(find.byType(ExportScreen), findsOneWidget);
    await tapKey(tester, 'export_button');
    expect(useCase.requests.last.format, ExportFormat.pdf);
  });

  testWidgets('SET-03 US5-6 nothing to export: a message and no share', (
    tester,
  ) async {
    useCase.outcome = const ExportNothing();
    await open(tester);
    await tapKey(tester, 'export_button');
    expect(find.text('Nothing to export for this period'), findsOneWidget);
    expect(sharer.shared, isEmpty);
  });

  testWidgets('SET-03 a failed export explains it', (tester) async {
    useCase.outcome = ExportFailed(StateError('disk'));
    await open(tester);
    await tapKey(tester, 'export_button');
    expect(find.byKey(const Key('export_error')), findsOneWidget);
    expect(
      find.text("Couldn't create the file. Nothing was shared. Try again."),
      findsOneWidget,
    );
    expect(sharer.shared, isEmpty);
  });

  testWidgets('SET-03 US5-5 an account filter shows "1 selected" and is sent '
      'with the export', (tester) async {
    await open(tester);
    await tapKey(tester, 'export_filter_accounts');
    await tester.tap(find.byKey(const Key('export_option_cash')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('export_filter_apply')));
    await tester.pumpAndSettle();
    expect(find.text('1 selected'), findsOneWidget);
    await tapKey(tester, 'export_button');
    expect(useCase.requests.single.filters['accounts'], {'cash'});
  });

  testWidgets('SET-03 opened with a dataset and period starts on them', (
    tester,
  ) async {
    await open(
      tester,
      location: Routes.exportPath(
        dataset: 'habits',
        period: periodToQuery(MonthPeriod(DateTime(2026, 9))),
      ),
    );
    expect(find.text('September 2026'), findsOneWidget);
    await tapKey(tester, 'export_button');
    final r = useCase.requests.single;
    expect(r.datasetId, 'habits');
    expect(r.period.startLocal, DateTime(2026, 9));
  });

  testWidgets('SET-01 FR-034 Export data sits between Backup and Erase all '
      'data and opens SET-03', (tester) async {
    await open(tester, location: Routes.more);
    final row = find.byKey(const Key('settings_export'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    final backup = tester.getTopLeft(find.byKey(const Key('settings_backup')));
    final erase = tester.getTopLeft(
      find.byKey(const Key('settings_erase_all')),
    );
    final export = tester.getTopLeft(row);
    expect(backup.dy < export.dy && export.dy < erase.dy, isTrue);
    // Clear of the navigation bar (the account card makes the list longer).
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(ExportScreen), findsOneWidget);
  });

  testWidgets('EXP-11 US5-9 "Export this report" opens SET-03 with the '
      "report's period; back returns to Reports", (tester) async {
    await open(tester, location: Routes.expenseReports);
    expect(find.byType(ReportsScreen), findsOneWidget);
    final action = find.byKey(const Key('reports_export'));
    expect(tester.getSemantics(action).label, contains('Export this report'));
    // Go to the previous month first.
    await tester.tap(find.byTooltip('Previous month'));
    await tester.pumpAndSettle();
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.byType(ExportScreen), findsOneWidget);
    expect(find.text('September 2026'), findsOneWidget);
    await tapKey(tester, 'export_button');
    expect(useCase.requests.single.datasetId, 'transactions');
    expect(useCase.requests.single.period.startLocal, DateTime(2026, 9));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(ReportsScreen), findsOneWidget);
  });

  test('every registered module dataset has a unique id', () {
    final ids = [
      for (final m in ModuleRegistry(registeredModules).all)
        for (final d in m.exportDatasets()) d.id,
    ];
    expect(ids, ['transactions', 'habits']);
  });

  // --- 009-ads-rewarded-pro (T066): one rewarded export. ---
  group('SET-03 rewarded export', () {
    Future<void> watchAd(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const Key('locked_watch_ad')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('locked_watch_ad')));
      await tester.pumpAndSettle();
    }

    testWidgets('SET-03 AC cancelling the rewarded ad does not start the '
        'export', (tester) async {
      gate.set(FeatureKey.exportCsv, unlocked: false);
      final presenter = FakeRewardedUnlockPresenter(earn: false);
      await open(tester, presenter: presenter);
      await watchAd(tester);
      expect(presenter.requests.single.key, FeatureKey.exportCsv);
      expect(useCase.requests, isEmpty);
    });

    testWidgets('an earned reward unlocks one export of that format, which '
        'starts at once', (tester) async {
      gate
        ..set(FeatureKey.exportCsv, unlocked: false)
        ..set(FeatureKey.exportPdf, unlocked: false);
      final presenter = FakeRewardedUnlockPresenter();
      await open(tester, presenter: presenter);
      await tester.tap(find.text('PDF'));
      await tester.pumpAndSettle();
      await watchAd(tester);
      expect(presenter.requests.single.key, FeatureKey.exportPdf);
      expect(presenter.requests.single.duration, isNull);
      expect(useCase.requests, hasLength(1));
    });
  });
}
