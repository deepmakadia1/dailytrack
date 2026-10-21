import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/settings/presentation/screens/modules_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';

/// DSH-01 Coming soon card (T055, clarification Q3, research R13).
void main() {
  Future<FakeSettingsRepository> pumpHome(
    WidgetTester tester, {
    bool dismissed = false,
  }) => pumpTestApp(
    tester,
    registry: ModuleRegistry([
      FakeTrackerModule(id: 'expense', rootPath: '/expenses'),
    ]),
    settings: FakeSettingsRepository(
      knownModuleIds: const ['expense'],
      initial: AppSettings(
        onboardingDone: true,
        moduleOrder: const ['expense'],
        enabledModules: const ['expense'],
        homeComingSoonDismissed: dismissed,
      ),
    ),
  );

  final card = find.byKey(const Key('home_coming_soon'));
  final dismiss = find.byKey(const Key('home_coming_soon_dismiss'));

  testWidgets('DSH-01 US7-1 the card shows last and names Water and Period', (
    tester,
  ) async {
    await pumpHome(tester);
    expect(card, findsOneWidget);
    expect(
      find.text('Water and Period trackers are on the way'),
      findsOneWidget,
    );
    final insight = find.byKey(const Key('home_insight_starter'));
    expect(
      tester.getTopLeft(card).dy,
      greaterThan(tester.getTopLeft(insight).dy),
    );
  });

  testWidgets('DSH-01 the dismiss button is 48 dp and labelled', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpHome(tester);
    final size = tester.getSize(dismiss);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(find.byTooltip('Dismiss'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('DSH-01 US7-2 dismiss hides it with Undo; Undo brings it back', (
    tester,
  ) async {
    final repo = await pumpHome(tester);
    await tester.tap(dismiss);
    await tester.pump();
    expect(repo.calls['setHomeComingSoonDismissed'], 1);
    expect(repo.current.homeComingSoonDismissed, isTrue);
    expect(find.text('Card hidden'), findsOneWidget);
    expect(find.byType(AnimatedSize), findsWidgets);
    await tester.pumpAndSettle();
    expect(card, findsNothing);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(repo.current.homeComingSoonDismissed, isFalse);
    expect(card, findsOneWidget);
  });

  testWidgets('DSH-01 US7-2 without Undo it stays hidden after 5 s', (
    tester,
  ) async {
    final repo = await pumpHome(tester);
    await tester.tap(dismiss);
    // The 5 s starts once the snackbar has finished appearing.
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(find.text('Card hidden'), findsNothing);
    expect(card, findsNothing);
    expect(repo.current.homeComingSoonDismissed, isTrue);
  });

  testWidgets('DSH-01 US7-3 dismissed at start: no card, and SET-06 offers '
      'no way back', (tester) async {
    await pumpHome(tester, dismissed: true);
    expect(card, findsNothing);
    await tester.tap(find.text('More'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Enable or reorder trackers'));
    await tester.pumpAndSettle();
    expect(find.byType(ModulesScreen), findsOneWidget);
    expect(find.textContaining('Coming soon card'), findsNothing);
    expect(find.byKey(const Key('home_coming_soon_restore')), findsNothing);
  });
}
