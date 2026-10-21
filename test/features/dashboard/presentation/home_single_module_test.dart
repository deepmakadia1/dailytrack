import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/habit/presentation/screens/habit_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/test_app.dart';
import '../../expense/fakes.dart';
import '../../habit/fakes.dart';
import '../fakes.dart';

/// DSH-01 first day and single-module layouts (T050, US5, AC3, FR-037),
/// with the real Expense and Habit modules over fakes. "Now" is
/// 2026-10-14 10:00.
void main() {
  late ExpenseFakes expense;
  late HabitFakes habits;

  setUp(() {
    expense = ExpenseFakes.withDefaults();
    habits = HabitFakes(expense.clock);
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    List<String> enabled = const ['expense', 'habit'],
    List<String> order = const ['expense', 'habit'],
    Size size = const Size(412, 1400),
  }) async {
    tester.view
      ..physicalSize = size
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await pumpTestApp(
      tester,
      expense: expense,
      habit: habits,
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          enabledModules: enabled,
          moduleOrder: order,
        ),
      ),
    );
  }

  Future<void> openFab(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('home_fab')));
    await tester.pumpAndSettle();
  }

  /// Vertical gaps between consecutive visible slots, in screen order.
  List<double> gaps(WidgetTester tester, List<String> keys) {
    final rects =
        [
            for (final k in keys)
              if (find.byKey(Key(k)).evaluate().isNotEmpty)
                tester.getRect(find.byKey(Key(k))),
          ]
          ..removeWhere((r) => r.height == 0)
          ..sort((a, b) => a.top.compareTo(b.top));
    return [
      for (var i = 1; i < rects.length; i++) rects[i].top - rects[i - 1].bottom,
    ];
  }

  const slotKeys = [
    'home_card_expense',
    'home_card_habit',
    'home_section_expense.recentTransactions',
    'home_insight',
    'home_insight_starter',
    'home_coming_soon',
  ];

  group('DSH-01 AC3 screen renders correctly with only one module enabled', () {
    testWidgets('only expense', (tester) async {
      expense.addTransaction(amount: 1200, category: 'food');
      await pumpHome(tester, enabled: const ['expense']);
      expect(find.byKey(const Key('home_card_habit')), findsNothing);
      expect(find.byKey(const Key('home_badge_habit')), findsNothing);
      expect(find.byKey(const Key('home_card_expense')), findsOneWidget);
      expect(find.byKey(const Key('recent_transactions')), findsOneWidget);
      expect(
        find.byKey(const Key('home_insight')).evaluate().length +
            find.byKey(const Key('home_insight_starter')).evaluate().length,
        1,
      );
      final cardGap = AppTokens.of(
        tester.element(find.byKey(const Key('home_card_expense'))),
      ).cardGap;
      expect(gaps(tester, slotKeys), everyElement(cardGap));
      await openFab(tester);
      expect(find.text('Check in habit'), findsNothing);
      expect(find.text('Add expense'), findsOneWidget);
      expect(anyAdWidget, findsNothing);
    });

    testWidgets('only habit', (tester) async {
      habits.addHabit('Read');
      expense.addTransaction(amount: 1200, category: 'food');
      await pumpHome(tester, enabled: const ['habit']);
      expect(find.byKey(const Key('home_card_expense')), findsNothing);
      expect(
        find.byKey(const Key('home_section_expense.recentTransactions')),
        findsNothing,
      );
      expect(find.byKey(const Key('home_card_habit')), findsOneWidget);
      expect(find.byKey(const Key('home_badge_habit')), findsOneWidget);
      final cardGap = AppTokens.of(
        tester.element(find.byKey(const Key('home_card_habit'))),
      ).cardGap;
      expect(gaps(tester, slotKeys), everyElement(cardGap));
      await openFab(tester);
      expect(find.text('Add expense'), findsNothing);
      expect(find.text('Add income'), findsNothing);
      expect(find.text('Check in habit'), findsOneWidget);
    });
  });

  group('US5 first day', () {
    testWidgets('DSH-01 US5-1..5 friendly empty states with one action each', (
      tester,
    ) async {
      await pumpHome(tester);
      // US5-2: no transactions, so no Recent transactions and no gap.
      expect(find.byKey(const Key('recent_transactions')), findsNothing);
      // US5-4: the flame shows 0.
      expect(
        tester.widget<Text>(find.byKey(const Key('streak_flame_count'))).data,
        '0',
      );
      // US5-5: the starter tip.
      expect(find.byKey(const Key('home_insight_starter')), findsOneWidget);
      final cardGap = AppTokens.of(
        tester.element(find.byKey(const Key('home_card_expense'))),
      ).cardGap;
      expect(gaps(tester, slotKeys), everyElement(cardGap));
      // US5-1: "Add your first expense" opens EXP-02.
      await tester.tap(find.text('Add your first expense'));
      await tester.pumpAndSettle();
      expect(find.byType(TransactionFormScreen), findsOneWidget);
    });

    testWidgets('DSH-01 US5-3 "Create your first habit" opens HAB-02', (
      tester,
    ) async {
      await pumpHome(tester);
      await tester.tap(find.text('Create your first habit'));
      await tester.pumpAndSettle();
      expect(find.byType(HabitFormScreen), findsOneWidget);
    });
  });

  testWidgets('DSH-01 an error shows only in its own card', (tester) async {
    habits.addHabit('Read');
    expense.world.failWatch = const ExpenseStorageFailure('boom');
    await pumpHome(tester);
    expect(find.byKey(const Key('expense_card_error')), findsOneWidget);
    expect(find.byKey(const Key('habit_card_error')), findsNothing);
    expect(find.text('0 of 1 done today'), findsOneWidget);
  });

  for (final order in const [
    ['habit', 'expense'],
    ['expense', 'habit'],
  ]) {
    testWidgets('DSH-01 FR-037 every check button is visible without '
        'scrolling on 360×780 ($order)', (tester) async {
      for (var i = 0; i < 4; i++) {
        habits.addHabit('Habit $i');
      }
      expense
        ..addBudget(limit: 1000000)
        ..addTransaction(amount: 1200, category: 'food');
      await pumpHome(tester, order: order, size: const Size(360, 780));
      final fab = tester.getRect(find.byKey(const Key('home_fab')));
      final viewport = tester.getRect(find.byKey(const Key('home_scroll')));
      final checks = find.byWidgetPredicate(
        (w) =>
            w.key is ValueKey<String> &&
            (w.key! as ValueKey<String>).value.startsWith('home_check_'),
      );
      expect(checks, findsWidgets);
      for (final e in checks.evaluate()) {
        final r = tester.getRect(find.byWidget(e.widget));
        // Inside the scroll viewport, above the FAB's top edge.
        expect(r.top, greaterThanOrEqualTo(viewport.top));
        expect(r.bottom, lessThanOrEqualTo(fab.top));
      }
    });
  }
}
