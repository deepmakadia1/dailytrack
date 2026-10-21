import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import 'fakes.dart';

/// Pumps the app past onboarding with Expense fakes (no database), on a
/// phone-sized surface, and opens [location]. Returns the fakes.
Future<ExpenseFakes> pumpExpenseApp(
  WidgetTester tester, {
  ExpenseFakes? fakes,
  String location = Routes.expenses,
  String locale = 'en',
  FakeTextSharer? sharer,
  Size size = const Size(412, 915),
  FakeSettingsRepository? settings,
  FakeFeatureGate? gate,
}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final f = fakes ?? ExpenseFakes.withDefaults();
  await pumpTestApp(
    tester,
    settings:
        settings ??
        FakeSettingsRepository(
          initial: AppSettings(onboardingDone: true, locale: locale),
        ),
    expense: f,
    sharer: sharer,
    gate: gate,
  );
  if (location != Routes.home) {
    routerOf(tester).go(location);
    await tester.pumpAndSettle();
  }
  return f;
}

GoRouter routerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)))
        .read(appRouterProvider);

ProviderContainer containerOf(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(MaterialApp)));

String locationOf(WidgetTester tester) =>
    routerOf(tester).routerDelegate.currentConfiguration.uri.toString();

/// Types [input] on the visible `NumericKeypad` (ASCII + - * / accepted).
Future<void> typeAmount(WidgetTester tester, String input) async {
  const ops = {
    '+': KeypadExpression.plus,
    '-': KeypadExpression.minus,
    '*': KeypadExpression.times,
    '/': KeypadExpression.divide,
  };
  for (final ch in input.split('')) {
    final label = ops[ch] ?? ch;
    await tester.tap(
      find.descendant(
        of: find.byType(NumericKeypad),
        matching: find.text(label),
      ),
    );
    await tester.pump();
  }
}

/// Lets snackbars and debounce timers expire so no timer outlives a test.
Future<void> flushTimers(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 6));
  await tester.pumpAndSettle();
}
