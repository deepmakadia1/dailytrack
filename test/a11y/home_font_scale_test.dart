import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/fakes.dart';
import '../features/habit/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// SC-005 / §15.10 (T058): DSH-01 with seeded content at 200% font scale on
/// a 360×780 dp screen, in en and gu, light and dark: no overflow (reported
/// as a test failure), 48 dp labelled tap targets, and text contrast.
void main() {
  const phone = Size(360, 780);

  ({ExpenseFakes expense, HabitFakes habits}) seeded() {
    final expense = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addBudget(limit: 1000000)
      ..addTransaction(amount: 85000, category: 'food', note: 'Lunch with team')
      ..addTransaction(amount: 120000, category: 'groceries')
      ..addTransaction(amount: 500000, type: TxnType.transfer, toAccount: 'sbi')
      ..addTransaction(amount: 30000, category: 'transport');
    final habits = HabitFakes(expense.clock);
    final read = habits.addHabit('Read every evening').id;
    habits
      ..addHabit('Walk')
      ..addHabit('Meditate')
      ..doneRange(read, '2026-10-08', '2026-10-13');
    return (expense: expense, habits: habits);
  }

  Future<void> pumpHome(
    WidgetTester tester,
    String lang,
    String themeMode,
  ) async {
    tester.view
      ..physicalSize = phone
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final s = seeded();
    await pumpTestApp(
      tester,
      expense: s.expense,
      habit: s.habits,
      settings: FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          locale: lang,
          themeMode: themeMode,
        ),
      ),
    );
  }

  Future<void> expectAccessible(WidgetTester tester) async {
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
  }

  for (final lang in const ['en', 'gu']) {
    for (final theme in const ['light', 'dark']) {
      testWidgets('DSH-01 SC-005 at 200% in $lang ($theme)', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpHome(tester, lang, theme);
        await expectAccessible(tester);
        // Every slot down to the Coming soon card.
        final scroll = find.byKey(const Key('home_scroll'));
        for (var i = 0; i < 12; i++) {
          await tester.drag(scroll, const Offset(0, -250));
          await tester.pumpAndSettle();
          await expectAccessible(tester);
        }
        expect(find.byKey(const Key('home_coming_soon')), findsOneWidget);
        // The + menu.
        await tester.drag(scroll, const Offset(0, 300));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('home_fab')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });
    }
  }
}
