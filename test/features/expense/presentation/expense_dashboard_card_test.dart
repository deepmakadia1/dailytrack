import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:dailytrack/features/expense/presentation/screens/transactions_screen.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_dashboard_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// DSH-01 Expense card from `ExpenseModule.dashboardCard()` (US6, T109).
void main() {
  int shown(WidgetTester tester, String key) => tester
      .widget<AmountText>(
        find.descendant(
          of: find.byKey(Key(key)),
          matching: find.byType(AmountText),
        ),
      )
      .amountMinor;

  Future<ExpenseFakes> home(WidgetTester tester, ExpenseFakes f) =>
      pumpExpenseApp(tester, fakes: f, location: Routes.home);

  testWidgets('DSH-01 Expense card US6-1 shows expense-only totals for today '
      'and this month', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addTransaction(
        amount: 300,
        category: 'food',
        at: DateTime(2026, 10, 14, 8),
      )
      ..addTransaction(
        amount: 200,
        category: 'food',
        at: DateTime(2026, 10, 14, 9),
      )
      ..addTransaction(
        amount: 1000,
        category: 'food',
        at: DateTime(2026, 10, 2),
      )
      ..addTransaction(
        amount: 9999,
        type: TxnType.income,
        category: 'income_salary',
      )
      ..addTransaction(amount: 777, type: TxnType.transfer, toAccount: 'sbi');
    await home(tester, f);
    expect(find.byType(ExpenseDashboardCard), findsOneWidget);
    expect(find.text('Spent today'), findsOneWidget);
    expect(shown(tester, 'spent_today'), 500);
    expect(shown(tester, 'spent_month'), 1500);
  });

  testWidgets('DSH-01 Expense card US6-2 offers "Add your first expense" '
      'with no transactions', (tester) async {
    await home(tester, ExpenseFakes.withDefaults());
    expect(find.text('Add your first expense'), findsOneWidget);
    await tester.tap(find.byKey(const Key('expense_card_empty')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
  });

  testWidgets('DSH-01 Expense card US6-3 tap opens EXP-01', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 100, category: 'food');
    await home(tester, f);
    await tester.tap(find.byKey(const Key('expense_card')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionsScreen), findsOneWidget);
  });

  testWidgets('DSH-01 Expense card US6-4 updates live', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 100, category: 'food');
    await home(tester, f);
    expect(shown(tester, 'spent_today'), 100);
    f.addTransaction(
      amount: 250,
      category: 'food',
      at: DateTime(2026, 10, 14, 9, 45),
    );
    await tester.pumpAndSettle();
    expect(shown(tester, 'spent_today'), 350);
  });

  testWidgets('DSH-01 Expense card US6-6 hidden when Expense is disabled; '
      'the data stays', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 100, category: 'food');
    await pumpExpenseApp(
      tester,
      fakes: f,
      location: Routes.home,
      settings: FakeSettingsRepository(
        initial: const AppSettings(
          onboardingDone: true,
          enabledModules: ['habit'],
        ),
      ),
    );
    expect(find.byType(ExpenseDashboardCard), findsNothing);
    expect(f.active, hasLength(1));
  });

  testWidgets('DSH-01 Expense card moves to the new day after midnight', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults(now: DateTime(2026, 10, 14, 23, 59))
      ..addTransaction(
        amount: 100,
        category: 'food',
        at: DateTime(2026, 10, 14, 20),
      );
    await home(tester, f);
    expect(shown(tester, 'spent_today'), 100);
    f.clock.value = DateTime(2026, 10, 15, 0, 1);
    await tester.pump(const Duration(minutes: 2));
    await tester.pumpAndSettle();
    expect(shown(tester, 'spent_today'), 0);
    expect(shown(tester, 'spent_month'), 100);
  });

  testWidgets('DSH-01 Expense card shows a compact error with Try again', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    f.world.failWatch = const ExpenseStorageFailure('boom');
    await home(tester, f);
    expect(find.byKey(const Key('expense_card_error')), findsOneWidget);
    f.world.failWatch = null;
    // The card's own button: Recent transactions may show its error too.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('expense_card_error')),
        matching: find.text('Try again'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Add your first expense'), findsOneWidget);
  });
  // --- Feature 006 (T016): budget bar, Set budget, and the + Expense chip.

  Color barColor(WidgetTester tester) => tester
      .widget<LinearProgressIndicator>(
        find.descendant(
          of: find.byKey(const Key('expense_card_budget_bar')),
          matching: find.byType(LinearProgressIndicator),
        ),
      )
      .color!;

  bool overIcon(WidgetTester tester) => find
      .descendant(
        of: find.byKey(const Key('expense_card_budget_bar')),
        matching: find.byIcon(Icons.error_outline),
      )
      .evaluate()
      .isNotEmpty;

  ExpenseFakes withBudget(int spent) => ExpenseFakes.withDefaults()
    ..addBudget(limit: 10000)
    ..addTransaction(amount: spent, category: 'food');

  testWidgets('DSH-01 AC2 budget bar color changes at 80% and 100% '
      'thresholds', (tester) async {
    for (final (spent, level, color, over) in [
      (7900, 'On track · 79% used', 'success', false),
      (8000, 'Almost used · 80% used', 'warning', false),
      (10000, 'Almost used · 100% used', 'warning', false),
      (10100, 'Over budget · 101% used', 'expense', true),
    ]) {
      await home(tester, withBudget(spent));
      final tokens = AppTokens.of(
        tester.element(find.byKey(const Key('expense_card_budget_bar'))),
      );
      final expected = switch (color) {
        'success' => tokens.success,
        'warning' => tokens.warning,
        _ => tokens.expense,
      };
      expect(barColor(tester), expected, reason: '$spent');
      expect(find.text(level), findsOneWidget, reason: '$spent');
      expect(overIcon(tester), over, reason: '$spent');
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('DSH-01 US1-3 "This month" reads spent of limit', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addBudget(limit: 1000000)
      ..addTransaction(amount: 600000, category: 'food');
    await home(tester, f);
    expect(
      find.descendant(
        of: find.byKey(const Key('spent_month')),
        matching: find.text('₹6,000.00 of ₹10,000.00'),
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('expense_card_set_budget')), findsNothing);
  });

  testWidgets('DSH-01 without a budget the card shows the month total and '
      '"Set budget" opens EXP-09 for Overall', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 1500, category: 'food');
    await home(tester, f);
    expect(find.byKey(const Key('expense_card_budget_bar')), findsNothing);
    expect(shown(tester, 'spent_month'), 1500);
    await tester.tap(find.byKey(const Key('expense_card_set_budget')));
    await tester.pumpAndSettle();
    expect(find.text('Set budget'), findsWidgets);
    expect(find.byType(BottomSheet), findsOneWidget);
    expect(find.text('Overall'), findsWidgets);
  });

  testWidgets('DSH-01 "+ Expense" opens EXP-02 as an expense', (tester) async {
    final f = ExpenseFakes.withDefaults()
      ..addTransaction(amount: 100, category: 'food');
    await home(tester, f);
    await tester.tap(find.byKey(const Key('expense_card_add')));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
  });
}
