import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/test_app.dart';

/// §15.10 / T104, T114: every Phase 0 and Expense screen at 200% font scale on a 360 dp wide
/// screen, in en, hi and gu, with no overflow (any overflow is reported as
/// a test failure), 48 dp tap targets and labelled controls.
void main() {
  const languages = ['en', 'hi', 'gu'];

  Future<void> setUpSurface(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  }

  Future<void> expectAccessible(WidgetTester tester) async {
    // The screen really is laid out at 200%.
    final screen = tester.element(find.byType(Scaffold).last);
    expect(MediaQuery.textScalerOf(screen).scale(10), 20);
    expect(tester.takeException(), isNull);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  }

  Future<void> go(WidgetTester tester, String location) async {
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    container.read(appRouterProvider).go(location);
    await tester.pumpAndSettle();
  }

  for (final lang in languages) {
    group(lang, () {
      testWidgets('SYS-01 error state at 200%', (tester) async {
        await setUpSurface(tester);
        final semantics = tester.ensureSemantics();
        await pumpTestApp(
          tester,
          settings: FakeSettingsRepository(initial: AppSettings(locale: lang)),
          bootstrap: FakeBootstrap(
            results: [BootstrapFailed(StateError('db'))],
          ),
        );
        expect(find.byKey(const Key('onboarding_primary')), findsNothing);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('SYS-02 steps 1–4 at 200%', (tester) async {
        await setUpSurface(tester);
        final semantics = tester.ensureSemantics();
        await pumpTestApp(
          tester,
          settings: FakeSettingsRepository(initial: AppSettings(locale: lang)),
        );
        for (var step = 1; step <= 4; step++) {
          await expectAccessible(tester);
          if (step < 4) {
            await tester.tap(find.byKey(const Key('onboarding_primary')));
            await tester.pumpAndSettle();
          }
        }
        semantics.dispose();
      });

      for (final location in [
        Routes.home,
        Routes.expenses,
        Routes.habits,
        Routes.more,
        Routes.modules,
      ]) {
        testWidgets('$location at 200%', (tester) async {
          await setUpSurface(tester);
          final semantics = tester.ensureSemantics();
          await pumpTestApp(
            tester,
            settings: FakeSettingsRepository(
              initial: AppSettings(locale: lang, onboardingDone: true),
            ),
          );
          await go(tester, location);
          await expectAccessible(tester);
          semantics.dispose();
        });
      }

      // --- 002-expense-core (T114): EXP-01..07 and the Home card, with data.
      ExpenseFakes expenseData() {
        final f = ExpenseFakes.withDefaults()
          ..addAccount(
            'SBI Savings',
            id: 'sbi',
            type: AccountType.bank,
            opening: 1000000,
          )
          ..addAccount(
            'Credit card',
            id: 'card',
            type: AccountType.card,
            opening: -2500000,
          )
          ..addAccount('Old wallet', id: 'old', archived: true)
          ..addTransaction(
            id: 't1',
            amount: 12500055,
            category: 'entertainment',
            note: 'A long note that must ellipsize instead of overflowing',
            mode: PaymentMode.netBanking,
          )
          ..addTransaction(
            id: 't2',
            amount: 300000,
            type: TxnType.income,
            category: 'income_salary',
            account: 'sbi',
          )
          ..addTransaction(
            id: 't3',
            amount: 5000,
            type: TxnType.transfer,
            account: 'sbi',
            toAccount: 'card',
            at: DateTime(2026, 10, 13, 9),
          );
        f.world.categories['fuel'] = f.world.categories['fuel']!.copyWith(
          isHidden: true,
        );
        // Feature 003: budgets at all three levels and recurring rules.
        f
          ..addBudget(limit: 3000000, id: 'b-overall')
          ..addBudget(limit: 100000, category: 'entertainment', id: 'b-fun')
          ..addBudget(limit: 9999999900, category: 'food', id: 'b-food')
          ..addRule(
            amount: 1500000,
            anchor: DateTime(2026, 9, 5, 9),
            note: 'House rent for the flat on the second floor',
            id: 'r-rent',
          )
          ..addRule(
            amount: 30000,
            anchor: DateTime(2026, 10, 5, 8),
            category: 'transport',
            frequency: Frequency.weekly,
            active: false,
            id: 'r-bus',
          );
        return f;
      }

      Future<void> pumpExpense(
        WidgetTester tester,
        String location, {
        bool unlocked = false,
      }) async {
        await setUpSurface(tester);
        final gate = FakeFeatureGate();
        if (unlocked) gate.set(FeatureKey.advancedReports, unlocked: true);
        await pumpTestApp(
          tester,
          settings: FakeSettingsRepository(
            initial: AppSettings(locale: lang, onboardingDone: true),
          ),
          expense: expenseData(),
          gate: gate,
        );
        await go(tester, location);
      }

      for (final (name, location) in [
        ('DSH-01 Expense card', Routes.home),
        ('EXP-01', Routes.expenses),
        ('EXP-02 new', Routes.expenseAdd),
        ('EXP-02 transfer', Routes.expenseAddPath(type: 'transfer')),
        ('EXP-02 edit', Routes.expenseEditPath('t1')),
        ('EXP-03', Routes.expenseDetailPath('t1')),
        ('EXP-04', Routes.expenseCategories),
        ('EXP-06', Routes.expenseAccounts),
        ('EXP-08', Routes.expenseBudgets),
        ('EXP-08 past month', Routes.expenseBudgetsPath(month: '2026-09')),
        ('EXP-10', Routes.expenseRecurring),
        ('EXP-02 Repeat on', Routes.expenseRecurringAdd),
        ('EXP-02 rule-edit', Routes.expenseRuleEditPath('r-rent')),
      ]) {
        testWidgets('$name at 200%', (tester) async {
          final semantics = tester.ensureSemantics();
          await pumpExpense(tester, location);
          await expectAccessible(tester);
          semantics.dispose();
        });
      }

      // Feature 004: the form with the keypad hidden by a scroll.
      testWidgets('EXP-02 keypad hidden by scroll at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpExpense(tester, Routes.expenseAdd);
        await tester.drag(
          find.byKey(const Key('transaction_form')),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();
        expect(find.byType(NumericKeypad), findsNothing);
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('EXP-05 sheet at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpExpense(tester, Routes.expenseCategories);
        await tester.tap(find.byKey(const Key('add_category')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('EXP-07 sheet at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpExpense(tester, Routes.expenseAccounts);
        await tester.tap(find.byKey(const Key('add_account')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      testWidgets('EXP-09 sheet (new and edit) at 200%', (tester) async {
        final semantics = tester.ensureSemantics();
        await pumpExpense(tester, Routes.expenseBudgets);
        // At 200% the row is below the fold.
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('budget_row_b-fun')),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        // Align it to the top so the navigation bar can't cover it.
        await tester.ensureVisible(
          find.byKey(const ValueKey('budget_row_b-fun')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('budget_row_b-fun')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        Navigator.of(tester.element(find.byKey(const Key('budget_amount'))))
            .pop();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byKey(const ValueKey('set_budget_groceries')),
          200,
          scrollable: find.byType(Scrollable).last,
        );
        await tester.ensureVisible(
          find.byKey(const ValueKey('set_budget_groceries')),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('set_budget_groceries')));
        await tester.pumpAndSettle();
        await expectAccessible(tester);
        semantics.dispose();
      });

      for (final unlocked in [false, true]) {
        testWidgets(
          'EXP-11 every tab at 200% (${unlocked ? 'unlocked' : 'locked'})',
          (tester) async {
            final semantics = tester.ensureSemantics();
            await pumpExpense(
              tester,
              Routes.expenseReports,
              unlocked: unlocked,
            );
            for (final tab in [
              'overview',
              'categories',
              'trends',
              'accounts',
            ]) {
              await tester.tap(find.byKey(ValueKey('tab_$tab')));
              await tester.pumpAndSettle();
              await expectAccessible(tester);
            }
            semantics.dispose();
          },
        );
      }

      testWidgets('SYS-03 /lock placeholder at 200%', (tester) async {
        await setUpSurface(tester);
        final semantics = tester.ensureSemantics();
        await pumpTestApp(
          tester,
          settings: FakeSettingsRepository(
            initial: AppSettings(
              locale: lang,
              onboardingDone: true,
              lockEnabled: true,
            ),
          ),
        );
        await expectAccessible(tester);
        semantics.dispose();
      });
    });
  }
}
