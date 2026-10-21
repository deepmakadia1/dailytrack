import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_form_state.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-01 repeat icon and EXP-03 rule link (T067, US3 s7, FR-028, edge
/// case "Rule deleted while entries exist").
void main() {
  /// A linked rent entry and a plain food entry.
  (ExpenseFakes, String linked, String plain, String rule) seeded() {
    final f = ExpenseFakes.withDefaults();
    final rule = f.addRule(amount: 1500000, anchor: DateTime(2026, 9, 5, 9));
    final linked = f.addTransaction(
      amount: 1500000,
      category: 'rent',
      at: DateTime(2026, 10, 5, 9),
    );
    f.world.transactions[linked.id] = linked.copyWith(recurringRuleId: rule.id);
    final plain = f.addTransaction(amount: 25000, category: 'food');
    return (f, linked.id, plain.id, rule.id);
  }

  testWidgets('EXP-01 US3-7 a generated row shows a labelled repeat icon; '
      'the row height is unchanged', (tester) async {
    final (f, linked, plain, _) = seeded();
    await pumpExpenseApp(tester, fakes: f);
    expect(find.byKey(ValueKey('repeat_icon_$linked')), findsOneWidget);
    expect(find.byKey(ValueKey('repeat_icon_$plain')), findsNothing);
    // The row merges its parts into one node; the icon carries the label.
    expect(
      tester
          .widget<Icon>(find.byKey(ValueKey('repeat_icon_$linked')))
          .semanticLabel,
      'Recurring',
    );
    expect(find.bySemanticsLabel(RegExp('Recurring')), findsOneWidget);
    final heights = [
      for (final id in [linked, plain])
        tester.getSize(find.byKey(ValueKey('txn_$id'))).height,
    ];
    expect(heights.first, heights.last);
  });

  testWidgets('EXP-03 US3-7 "Created from recurring rule" opens the rule in '
      'rule-edit mode', (tester) async {
    final (f, linked, plain, rule) = seeded();
    await pumpExpenseApp(
      tester,
      fakes: f,
      location: Routes.expenseDetailPath(linked),
    );
    expect(find.text('Created from recurring rule'), findsOneWidget);
    await tester.tap(find.byKey(const Key('detail_rule_link')));
    await tester.pumpAndSettle();
    final form = tester.widget<TransactionFormScreen>(
      find.byType(TransactionFormScreen),
    );
    expect(form.args.mode, FormMode.ruleEdit);
    expect(form.args.ruleId, rule);
    expect(plain, isNotEmpty);
  });

  testWidgets('EXP-03 when the rule is deleted the text says so and is not a '
      'link', (tester) async {
    final (f, linked, _, rule) = seeded();
    f.world.rules[rule] = f.world.rules[rule]!.copyWith(
      deletedAt: DateTime.utc(2026, 10, 10),
    );
    await pumpExpenseApp(
      tester,
      fakes: f,
      location: Routes.expenseDetailPath(linked),
    );
    expect(find.text('Recurring rule deleted'), findsOneWidget);
    expect(find.byKey(const Key('detail_rule_link')), findsNothing);
    expect(
      tester
          .widget<ListTile>(find.byKey(const Key('detail_rule_deleted')))
          .onTap,
      isNull,
    );
  });

  testWidgets('EXP-03 a plain entry has no rule line', (tester) async {
    final (f, _, plain, _) = seeded();
    await pumpExpenseApp(
      tester,
      fakes: f,
      location: Routes.expenseDetailPath(plain),
    );
    expect(find.byKey(const Key('detail_rule_link')), findsNothing);
    expect(find.byKey(const Key('detail_rule_deleted')), findsNothing);
  });
}
