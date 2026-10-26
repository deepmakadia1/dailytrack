import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/router_ad_screen_probe.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/features/expense/presentation/screens/transaction_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-02 interstitial trigger (feature 009 T099, spec §11, clarification
/// Q4): only new entries count, and the trigger fires after the form has
/// closed. The cap itself is tested in interstitial_cap_test.dart.
void main() {
  Finder save() => find.byKey(const Key('save_transaction'));
  Finder category(String id) => find.byKey(ValueKey('category_$id'));

  late FakeAdService ads;
  late List<String> locationsAtTrigger;

  setUp(() {
    ads = FakeAdService();
    locationsAtTrigger = [];
  });

  Future<ExpenseFakes> open(
    WidgetTester tester,
    String location, {
    ExpenseFakes? fakes,
    String from = Routes.expenses,
  }) async {
    final f = await pumpExpenseApp(
      tester,
      fakes: fakes,
      ads: ads,
      location: from,
    );
    ads.onTrigger = (_) => locationsAtTrigger.add(locationOf(tester));
    // Pushed, so closing the form returns to [from].
    unawaited(routerOf(tester).push<void>(location));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    return f;
  }

  Future<void> saveExpense(WidgetTester tester) async {
    await typeAmount(tester, '120');
    await tester.tap(category('food'));
    await tester.tap(save());
    await tester.pumpAndSettle();
  }

  testWidgets('EXP-02 AC interstitial never appears while the keypad or form '
      'is visible: the trigger fires only after the form has closed', (
    tester,
  ) async {
    await open(tester, Routes.expenseAdd);
    await saveExpense(tester);
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(ads.triggers, hasLength(1));
    final trigger = ads.triggers.single as ExpenseSaved;
    expect(trigger.screenClosing, isTrue);
    expect(locationsAtTrigger.single, isNot(startsWith(Routes.expenseAdd)));
    // And the real screen check never allows a full-screen ad on the form.
    expect(isReadingLocation(Routes.expenseAdd), isFalse);
    await flushTimers(tester);
  });

  testWidgets('clarification Q1: a save that closes back to Home triggers '
      'with Home showing, a reading screen', (tester) async {
    await open(tester, Routes.expenseAdd, from: Routes.home);
    await saveExpense(tester);
    expect(ads.triggers, hasLength(1));
    expect(locationsAtTrigger.single, Routes.home);
    expect(isReadingLocation(Routes.home), isTrue);
    await flushTimers(tester);
  });

  testWidgets('clarification Q4: "Save and add another" counts the entry '
      'but keeps the form open', (tester) async {
    await open(tester, Routes.expenseAdd);
    await typeAmount(tester, '120');
    await tester.tap(category('food'));
    await tester.longPress(save());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save and add another'));
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsOneWidget);
    final trigger = ads.triggers.single as ExpenseSaved;
    expect(trigger.screenClosing, isFalse);
    await flushTimers(tester);
  });

  testWidgets('clarification Q4: a swipe-right duplicate is a new entry', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(amount: 5000, category: 'food');
    await open(tester, Routes.expenseAddPath(duplicateOf: t.id), fakes: f);
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(ads.triggers.single, isA<ExpenseSaved>());
    await flushTimers(tester);
  });

  testWidgets('clarification Q4: editing an existing entry never triggers', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    final t = f.addTransaction(amount: 5000, category: 'food');
    await open(tester, Routes.expenseEditPath(t.id), fakes: f);
    await tester.tap(find.byKey(const Key('amount_display')));
    await tester.pump();
    await typeAmount(tester, '0');
    await tester.tap(save());
    await tester.pumpAndSettle();
    expect(find.byType(TransactionFormScreen), findsNothing);
    expect(ads.triggers, isEmpty);
    await flushTimers(tester);
  });
}
