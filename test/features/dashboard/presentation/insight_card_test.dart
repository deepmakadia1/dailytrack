import 'package:dailytrack/core/module/insight.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../fakes.dart';

/// DSH-01 insight card (T042, FR-024–FR-028).
void main() {
  late FakeInsightSource source;

  Future<void> pumpHome(WidgetTester tester) async {
    await pumpTestApp(
      tester,
      registry: ModuleRegistry([
        FakeTrackerModule(
          id: 'tips',
          insightSource: source,
          routes: [
            GoRoute(
              path: '/tips',
              builder: (context, state) => const Scaffold(body: Text('tips')),
              routes: [
                GoRoute(
                  path: 'detail',
                  builder: (context, state) =>
                      const Scaffold(body: Text('tips detail')),
                ),
              ],
            ),
          ],
        ),
      ]),
      settings: FakeSettingsRepository(
        knownModuleIds: const ['tips'],
        initial: const AppSettings(
          onboardingDone: true,
          moduleOrder: ['tips'],
          enabledModules: ['tips'],
        ),
      ),
    );
  }

  setUp(() {
    source = FakeInsightSource(
      const ['tips.one'],
      insights: const [
        Insight(
          ruleId: 'tips.one',
          text: 'Drink water before lunch',
          location: '/tips/detail',
          semanticLabel: 'Opens tips: Drink water before lunch',
        ),
      ],
    );
  });

  testWidgets('DSH-01 renders the title and the text', (tester) async {
    await pumpHome(tester);
    final card = find.byKey(const Key('home_insight'));
    expect(card, findsOneWidget);
    expect(
      find.descendant(of: card, matching: find.text('Tip for today')),
      findsOneWidget,
    );
    expect(find.text('Drink water before lunch'), findsOneWidget);
  });

  testWidgets('DSH-01 US4-7 a tap opens the insight location', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const Key('home_insight')));
    await tester.pumpAndSettle();
    expect(find.text('tips detail'), findsOneWidget);
  });

  testWidgets('DSH-01 the semantic label names the destination', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await pumpHome(tester);
    final data = tester
        .getSemantics(find.byKey(const Key('home_insight')))
        .getSemanticsData();
    expect(data.label, 'Opens tips: Drink water before lunch');
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });

  testWidgets('DSH-01 the starter tip is not tappable', (tester) async {
    final semantics = tester.ensureSemantics();
    source.insights = const [];
    await pumpHome(tester);
    final starter = find.byKey(const Key('home_insight_starter'));
    expect(starter, findsOneWidget);
    expect(
      find.text('Log something today and tips will show up here'),
      findsOneWidget,
    );
    final data = tester.getSemantics(starter).getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isFalse);
    expect(
      find.descendant(of: starter, matching: find.byType(InkWell)),
      findsNothing,
    );
    semantics.dispose();
  });

  testWidgets('DSH-01 a failed evaluation shows the starter', (tester) async {
    source.error = StateError('boom');
    await pumpHome(tester);
    expect(find.byKey(const Key('home_insight_starter')), findsOneWidget);
  });

  testWidgets('DSH-01 US4-4 pull-to-refresh re-evaluates once', (tester) async {
    await pumpHome(tester);
    final before = source.calls;
    await tester.fling(
      find.byKey(const Key('home_scroll')),
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();
    expect(source.calls, before + 1);
  });
}
