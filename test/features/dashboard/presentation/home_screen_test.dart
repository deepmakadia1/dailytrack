import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../../expense/fakes.dart';

/// DSH-01 Home with fake modules only (T019, T033, T053): no feature
/// imports, so these tests pin Home's own behavior.
void main() {
  FakeTrackerModule module(
    String id, {
    List<QuickAddAction> quickAdds = const [],
    bool section = false,
    bool badge = false,
    double cardHeight = 0,
  }) => FakeTrackerModule(
    id: id,
    rootPath: '/$id',
    cardHeight: cardHeight,
    routes: [
      GoRoute(
        path: '/$id',
        builder: (context, state) => Scaffold(body: Text('$id screen')),
        routes: [
          GoRoute(
            path: 'add',
            builder: (context, state) => Scaffold(
              body: Text('$id add ${state.uri.queryParameters['type']}'),
            ),
          ),
        ],
      ),
    ],
    quickAdds: quickAdds,
    sections: [
      if (section)
        DashboardSection(
          id: '$id.extra',
          build: (_) => SizedBox(key: Key('section_body_$id'), height: 40),
        ),
    ],
    badge: badge
        ? SizedBox.square(key: Key('badge_body_$id'), dimension: 48)
        : null,
  );

  Future<ExpenseFakes> pumpHome(
    WidgetTester tester, {
    required List<FakeTrackerModule> modules,
    List<String>? order,
    List<String>? enabled,
    DateTime? now,
    FakeSettingsRepository? settings,
  }) async {
    final ids = [for (final m in modules) m.id];
    final f = ExpenseFakes.empty(now: now ?? DateTime(2026, 10, 20, 8, 30));
    await pumpTestApp(
      tester,
      registry: ModuleRegistry(modules),
      expense: f,
      settings:
          settings ??
          FakeSettingsRepository(
            knownModuleIds: ids,
            initial: AppSettings(
              onboardingDone: true,
              moduleOrder: order ?? ids,
              enabledModules: enabled ?? ids,
            ),
          ),
    );
    return f;
  }

  double top(WidgetTester tester, String key) =>
      tester.getTopLeft(find.byKey(Key(key))).dy;

  group('US1', () {
    testWidgets('DSH-01 US1-1 greeting and date; the greeting changes at '
        '12:00 without a restart', (tester) async {
      final f = await pumpHome(tester, modules: [module('expense')]);
      expect(find.text('Good morning'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('home_date'))).data,
        'Tue, 20 Oct',
      );
      f.clock.value = DateTime(2026, 10, 20, 11, 59);
      await tester.pump(const Duration(hours: 3, minutes: 29));
      expect(find.text('Good morning'), findsOneWidget);
      f.clock.value = DateTime(2026, 10, 20, 12);
      await tester.pump(const Duration(minutes: 1));
      await tester.pump();
      expect(find.text('Good afternoon'), findsOneWidget);
    });

    testWidgets('DSH-01 the date follows the locale', (tester) async {
      await pumpHome(
        tester,
        modules: [module('expense')],
        settings: FakeSettingsRepository(
          knownModuleIds: const ['expense'],
          initial: const AppSettings(
            onboardingDone: true,
            locale: 'gu',
            moduleOrder: ['expense'],
            enabledModules: ['expense'],
          ),
        ),
      );
      expect(find.text('સુપ્રભાત'), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const Key('home_date'))).data,
        isNot('Tue, 20 Oct'),
      );
    });

    testWidgets('DSH-01 US1-2 module badges show in the app bar in module '
        'order', (tester) async {
      await pumpHome(
        tester,
        modules: [module('expense', badge: true), module('habit', badge: true)],
        order: const ['habit', 'expense'],
      );
      expect(find.byKey(const Key('home_badge_habit')), findsOneWidget);
      expect(find.byKey(const Key('home_badge_expense')), findsOneWidget);
      expect(
        tester.getTopLeft(find.byKey(const Key('home_badge_habit'))).dx,
        lessThan(
          tester.getTopLeft(find.byKey(const Key('home_badge_expense'))).dx,
        ),
      );
      expect(
        find.ancestor(
          of: find.byKey(const Key('home_badge_habit')),
          matching: find.byType(AppBar),
        ),
        findsOneWidget,
      );
    });

    testWidgets('DSH-01 US1-3 sections render after every card and before '
        'the insight', (tester) async {
      await pumpHome(
        tester,
        modules: [module('expense', section: true), module('habit')],
      );
      final section = top(tester, 'home_section_expense.extra');
      expect(section, greaterThan(top(tester, 'home_card_expense')));
      expect(section, greaterThan(top(tester, 'home_card_habit')));
      final insight = find.byKey(const Key('home_insight_starter'));
      expect(insight, findsOneWidget);
      expect(tester.getTopLeft(insight).dy, greaterThan(section));
      expect(
        tester.getTopLeft(find.byKey(const Key('home_coming_soon'))).dy,
        greaterThan(tester.getTopLeft(insight).dy),
      );
    });

    testWidgets('DSH-01 US1-8 moduleOrder [habit, expense] puts the habit '
        'card first', (tester) async {
      await pumpHome(
        tester,
        modules: [module('expense'), module('habit')],
        order: const ['habit', 'expense'],
      );
      expect(
        top(tester, 'home_card_habit'),
        lessThan(top(tester, 'home_card_expense')),
      );
    });
  });
  // Real ARB keys, so labels resolve through l10nByKey.
  const a1 = QuickAddAction(
    labelKey: 'expense_quickAdd',
    icon: Icons.add,
    location: '/expense/add?type=expense',
  );
  const a2 = QuickAddAction(
    labelKey: 'expense_quickAddIncome',
    icon: Icons.add_card,
    location: '/expense/add?type=income',
  );
  const b1 = QuickAddAction(
    labelKey: 'habit_quickAddCheckIn',
    icon: Icons.check_circle,
    location: '/habit',
  );

  List<FakeTrackerModule> withQuickAdds({double cardHeight = 0}) => [
    module('expense', quickAdds: const [a1, a2], cardHeight: cardHeight),
    module('habit', quickAdds: const [b1], cardHeight: cardHeight),
  ];

  Finder entry(QuickAddAction a) =>
      find.byKey(Key('home_quick_add_${a.labelKey}'));

  group('US3', () {
    testWidgets("DSH-01 US3-1 the + menu lists every visible module's quick "
        'adds in module order', (tester) async {
      await pumpHome(tester, modules: withQuickAdds());
      expect(find.byType(FloatingActionButton), findsOneWidget);
      await tester.tap(find.byKey(const Key('home_fab')));
      await tester.pumpAndSettle();
      final tops = [
        for (final a in const [a1, a2, b1]) tester.getTopLeft(entry(a)).dy,
      ];
      expect(tops, [...tops]..sort());
      expect(find.text('Add expense'), findsOneWidget);
      expect(find.text('Add income'), findsOneWidget);
      expect(find.text('Check in habit'), findsOneWidget);
      for (final a in const [a1, a2, b1]) {
        expect(tester.getSize(entry(a)).height, greaterThanOrEqualTo(48));
      }
    });

    testWidgets('DSH-01 US3-2 picking an entry opens its location; SC-002 '
        'two taps', (tester) async {
      await pumpHome(tester, modules: withQuickAdds());
      var taps = 0;
      Future<void> tap(Finder f) async {
        taps++;
        await tester.tap(f);
        await tester.pumpAndSettle();
      }

      await tap(find.byKey(const Key('home_fab')));
      await tap(entry(a2));
      expect(find.text('expense add income'), findsOneWidget);
      expect(taps, 2);
    });

    testWidgets('DSH-01 US3-3 a disabled module adds no entries', (
      tester,
    ) async {
      await pumpHome(
        tester,
        modules: withQuickAdds(),
        enabled: const ['expense'],
      );
      await tester.tap(find.byKey(const Key('home_fab')));
      await tester.pumpAndSettle();
      expect(entry(a1), findsOneWidget);
      expect(entry(b1), findsNothing);
    });

    testWidgets('DSH-01 no quick adds means no FAB', (tester) async {
      await pumpHome(tester, modules: [module('expense')]);
      expect(find.byKey(const Key('home_fab')), findsNothing);
    });

    testWidgets('DSH-01 US3-4 scrolling down hides the FAB; up shows it', (
      tester,
    ) async {
      await pumpHome(tester, modules: withQuickAdds(cardHeight: 600));
      double opacity() => tester
          .widget<AnimatedOpacity>(
            find.ancestor(
              of: find.byKey(const Key('home_fab')),
              matching: find.byType(AnimatedOpacity),
            ),
          )
          .opacity;
      expect(opacity(), 1);
      await tester.drag(
        find.byKey(const Key('home_scroll')),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(opacity(), 0);
      await tester.drag(
        find.byKey(const Key('home_scroll')),
        const Offset(0, 200),
      );
      await tester.pumpAndSettle();
      expect(opacity(), 1);
    });
  });
  group('US6', () {
    List<String> navLabels(WidgetTester tester) => [
      for (final d in tester.widgetList<NavigationDestination>(
        find.byType(NavigationDestination),
      ))
        d.label,
    ];

    Future<void> tapText(WidgetTester tester, String text) async {
      // SET-01 rows can sit below the fold on the test surface.
      await tester.ensureVisible(find.text(text).last);
      await tester.pumpAndSettle();
      await tester.tap(find.text(text).last);
      await tester.pumpAndSettle();
    }

    void moveDown(WidgetTester tester, String id) {
      final node = tester.getSemantics(find.byKey(Key('modules_row_$id')));
      final action = node
          .getSemanticsData()
          .customSemanticsActionIds!
          .firstWhere(
            (a) => CustomSemanticsAction.getAction(a)!.label == 'Move down',
          );
      node.owner!.performAction(node.id, SemanticsAction.customAction, action);
    }

    testWidgets('DSH-01 US6-1 a SET-06 reorder changes Home cards, the + '
        'menu, and the tabs at once; US6-2 it persists', (tester) async {
      final semantics = tester.ensureSemantics();
      final modules = withQuickAdds();
      final settings = FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      );
      await pumpHome(tester, modules: modules, settings: settings);
      expect(navLabels(tester), [
        'Home',
        'Module expense',
        'Module habit',
        'More',
      ]);

      await tapText(tester, 'More');
      await tapText(tester, 'Enable or reorder trackers');
      moveDown(tester, 'expense');
      await tester.pumpAndSettle();
      await tapText(tester, 'Home');

      expect(
        top(tester, 'home_card_habit'),
        lessThan(top(tester, 'home_card_expense')),
      );
      expect(navLabels(tester), [
        'Home',
        'Module habit',
        'Module expense',
        'More',
      ]);
      await tester.tap(find.byKey(const Key('home_fab')));
      await tester.pumpAndSettle();
      expect(
        tester.getTopLeft(entry(b1)).dy,
        lessThan(tester.getTopLeft(entry(a1)).dy),
      );
      semantics.dispose();

      // US6-2: a restart over the same repository keeps the order.
      await restartTestApp(
        tester,
        settings: settings,
        registry: ModuleRegistry(modules),
      );
      expect(settings.current.moduleOrder, ['habit', 'expense']);
      expect(
        top(tester, 'home_card_habit'),
        lessThan(top(tester, 'home_card_expense')),
      );
    });
  });
}
