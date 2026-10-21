import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-02 runs the budget check after a save (T051, US2 scenarios 1, 7, 8;
/// FR-015, FR-018). Fakes only: the real checker over fake ports.
void main() {
  Finder save() => find.byKey(const Key('save_transaction'));
  Finder category(String id) => find.byKey(ValueKey('category_$id'));

  /// ₹1,000 Food budget for October; "today" is 14 Oct.
  ExpenseFakes withFoodBudget() =>
      ExpenseFakes.withDefaults()..addBudget(limit: 100000, category: 'food');

  Future<ExpenseFakes> openAdd(
    WidgetTester tester,
    ExpenseFakes f, {
    String type = 'expense',
  }) async {
    await pumpExpenseApp(tester, fakes: f);
    routerOf(tester).go(Routes.expenseAddPath(type: type));
    await tester.pumpAndSettle();
    return f;
  }

  testWidgets('EXP-02 US2-1 saving a current-month expense that reaches 80% '
      'sends one Budget alert for its category', (tester) async {
    final f = await openAdd(tester, withFoodBudget());
    await typeAmount(tester, '850');
    await tester.tap(category('food'));
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(f.alertNotifier.sent, hasLength(1));
    final alert = f.alertNotifier.sent.single;
    expect(alert.categoryId, 'food');
    expect(alert.threshold, BudgetThreshold.p80);
    expect(alert.percent, 85);
    expect(alert.monthKey, '2026-10');
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US2-1 an edit is checked too', (tester) async {
    final f = withFoodBudget();
    final t = f.addTransaction(amount: 10000, category: 'food');
    await pumpExpenseApp(tester, fakes: f);
    routerOf(tester).go(Routes.expenseEditPath(t.id));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('amount_display')));
    await tester.pump();
    await typeAmount(tester, '0'); // ₹100 → ₹1,000
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(f.alertNotifier.sent.single.threshold, BudgetThreshold.p100);
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US2-7 saving income runs no budget check', (
    tester,
  ) async {
    final f = withFoodBudget()..addBudget(limit: 100);
    await openAdd(tester, f, type: 'income');
    await typeAmount(tester, '5000');
    await tester.tap(category('income_salary'));
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(f.budgets.calls['forAlert'], isNull);
    expect(f.alertNotifier.sent, isEmpty);
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US2-8 a check that never completes still closes the '
      'form with "Saved · Undo"', (tester) async {
    final f = withFoodBudget();
    f.notificationGate.hold = Completer<bool>();
    await openAdd(tester, f);
    await typeAmount(tester, '950');
    await tester.tap(category('food'));
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(f.notificationGate.checks, 1);
    f.notificationGate.hold!.complete(true);
    await flushTimers(tester);
  });

  testWidgets('EXP-02 US2-8 a failing notification still closes the form '
      'with "Saved · Undo"', (tester) async {
    final f = withFoodBudget();
    f.alertNotifier.error = Exception('plugin down');
    await openAdd(tester, f);
    await typeAmount(tester, '950');
    await tester.tap(category('food'));
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(find.text('Saved'), findsOneWidget);
    expect(f.active, hasLength(1));
    await flushTimers(tester);
  });
}
