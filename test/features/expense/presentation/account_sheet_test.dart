import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/widgets/account_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense_test_app.dart';
import '../fakes.dart';

/// EXP-07 Add / edit account sheet (spec §8, US5-7, T100).
void main() {
  Future<({Future<Account?> result})> openSheet(
    WidgetTester tester, {
    String? id,
    ExpenseFakes? fakes,
  }) async {
    await pumpExpenseApp(
      tester,
      fakes: fakes,
      location: Routes.expenseAccounts,
    );
    final context = tester.element(find.byType(Scaffold).last);
    final result = AccountSheet.show(context, id: id);
    await tester.pumpAndSettle();
    return (result: result);
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.byKey(const Key('save_account')));
    await tester.tap(find.byKey(const Key('save_account')));
    await tester.pumpAndSettle();
  }

  Future<void> typeBalance(WidgetTester tester, String digits) async {
    await tester.tap(find.byKey(const Key('opening_balance')));
    await tester.pumpAndSettle();
    await typeAmount(tester, digits);
  }

  testWidgets('US5-7 fields: name, type chips, opening balance with +/−, '
      'icon, color', (tester) async {
    await openSheet(tester);
    expect(find.byKey(const Key('account_name')), findsOneWidget);
    expect(find.byType(ChipSelector<AccountType>), findsOneWidget);
    for (final t in ['Cash', 'Bank', 'UPI wallet', 'Card', 'Wallet']) {
      expect(find.widgetWithText(ChoiceChip, t), findsOneWidget);
    }
    expect(find.byKey(const Key('balance_sign')), findsOneWidget);
    expect(find.byType(IconPickerGrid), findsOneWidget);
    expect(find.byType(ColorPickerRow), findsOneWidget);
    // Empty state: a blank new form, name focused, type Cash, ₹0.
    final field = tester.widget<TextField>(
      find.byKey(const Key('account_name')),
    );
    expect(field.autofocus, isTrue);
    expect(
      tester.widget<Text>(find.byKey(const Key('opening_balance_value'))).data,
      '₹0.00',
    );
  });

  testWidgets('US5-7 a negative opening balance (−500) stores −50000', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults();
    final (:result) = await openSheet(tester, fakes: f);
    await tester.enterText(find.byKey(const Key('account_name')), 'HDFC card');
    await tester.tap(find.widgetWithText(ChoiceChip, 'Card'));
    await tester.tap(find.text('−'));
    await tester.pump();
    await typeBalance(tester, '500');
    await save(tester);
    final account = await result;
    expect(account!.openingBalanceMinor, -50000);
    expect(account.type, AccountType.card);
    expect(f.world.accounts[account.id]!.name, 'HDFC card');
  });

  testWidgets('US5-7 validation errors show inline', (tester) async {
    final f = ExpenseFakes.withDefaults();
    await openSheet(tester, fakes: f);
    await save(tester);
    expect(find.text('Enter a name'), findsOneWidget);
    // The field enforces 40 characters while typing; ValidateAccount is
    // the backstop (validate_account_test).
    await tester.enterText(find.byKey(const Key('account_name')), 'x' * 41);
    await tester.pump();
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('account_name')))
          .controller!
          .text,
      hasLength(40),
    );
    expect(f.world.accounts, hasLength(1));
  });

  testWidgets('US5-7 edit is prefilled; a default shows its translation', (
    tester,
  ) async {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('Card', id: 'card', type: AccountType.card, opening: -2500);
    await openSheet(tester, fakes: f, id: 'card');
    expect(find.text('Edit account'), findsOneWidget);
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('account_name')))
          .controller!
          .text,
      'Card',
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('opening_balance_value'))).data,
      '−₹25.00',
    );
    expect(
      tester
          .widget<SegmentedButton<bool>>(find.byKey(const Key('balance_sign')))
          .selected,
      {true},
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await openSheet(tester, fakes: f, id: 'cash');
    expect(
      tester
          .widget<TextField>(find.byKey(const Key('account_name')))
          .controller!
          .text,
      'Cash',
    );
  });

  testWidgets('a save failure keeps the sheet open; a missing account is '
      'an error state', (tester) async {
    final f = ExpenseFakes.withDefaults();
    await openSheet(tester, fakes: f);
    await tester.enterText(find.byKey(const Key('account_name')), 'Paytm');
    f.world.failNextWrite = true;
    await save(tester);
    expect(find.byKey(const Key('save_account')), findsOneWidget);
    expect(
      find.text("Couldn't save. Your changes are still here. Try again."),
      findsOneWidget,
    );
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    await openSheet(tester, fakes: f, id: 'missing');
    expect(find.byType(ErrorState), findsOneWidget);
  });
}
