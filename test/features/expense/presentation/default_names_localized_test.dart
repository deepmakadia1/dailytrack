import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../expense_test_app.dart';
import '../fakes.dart';

/// US3-2 (T081): default category and account names are shown in the
/// current language; switching language never changes stored data.
void main() {
  testWidgets('defaults read in Gujarati and English; stored keys never '
      'change', (tester) async {
    final f = ExpenseFakes.withDefaults();
    final settings = FakeSettingsRepository(
      initial: const AppSettings(onboardingDone: true, locale: 'gu'),
    );
    await pumpExpenseApp(
      tester,
      fakes: f,
      settings: settings,
      location: Routes.expenseCategories,
    );
    Finder foodRow() => find.byKey(const ValueKey('category_row_food'));
    expect(
      find.descendant(of: foodRow(), matching: find.text('ખોરાક')),
      findsOneWidget,
    );

    routerOf(tester).go(Routes.expenseAdd);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('category_food')),
        matching: find.text('ખોરાક'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('account_chip')),
        matching: find.text('રોકડ'),
      ),
      findsOneWidget,
    );

    await settings.setLocale('en');
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('category_food')),
        matching: find.text('Food'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('account_chip')),
        matching: find.text('Cash'),
      ),
      findsOneWidget,
    );
    expect(f.world.categories['food']!.name, 'expense_cat_food');
    expect(f.world.accounts['cash']!.name, 'expense_account_cash');
  });
}
