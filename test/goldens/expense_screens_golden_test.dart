@Tags(['golden'])
library;

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transactions_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/expense/expense_test_app.dart';
import '../features/expense/fakes.dart';
import '../helpers/fakes.dart';

/// §15.10 / Constitution IV screen goldens for EXP-01, EXP-02 and EXP-03
/// (T060, T078): light and dark × English and Gujarati on a 360×800
/// surface, with fakes only. Baselines are made and compared on Linux:
/// `flutter test --tags golden --update-goldens`.
void main() {
  ExpenseFakes sample() {
    final f = ExpenseFakes.withDefaults()
      ..addAccount('SBI', id: 'sbi')
      ..addTransaction(
        id: 'a',
        amount: 15550,
        category: 'food',
        note: 'Lunch',
        mode: PaymentMode.upi,
        at: DateTime(2026, 10, 14, 9),
      )
      ..addTransaction(
        id: 'b',
        amount: 100000,
        type: TxnType.income,
        category: 'income_salary',
        account: 'sbi',
        at: DateTime(2026, 10, 14, 8),
      )
      ..addTransaction(
        id: 'c',
        amount: 5000,
        type: TxnType.transfer,
        toAccount: 'sbi',
        at: DateTime(2026, 10, 13, 7),
      )
      ..addTransaction(
        id: 'd',
        amount: 2000,
        category: 'transport',
        at: DateTime(2026, 10, 12, 18),
      );
    return f;
  }

  final scenarios = <String, Future<void> Function(WidgetTester, AppSettings)>{
    'EXP-01 content': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenses);
    },
    'EXP-01 empty period': (tester, s) async {
      await _pump(tester, s, ExpenseFakes.withDefaults(), Routes.expenses);
    },
    'EXP-01 no matches': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenses);
      containerOf(tester)
          .read(transactionsControllerProvider.notifier)
          .setSearch('zzz', displayName: (c) => c.name);
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();
    },
    'EXP-01 search open': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenses);
      await tester.tap(find.byKey(const Key('open_search')));
      await tester.pumpAndSettle();
    },
    'EXP-02 new with amount': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseAdd);
      await typeAmount(tester, '120+35.5');
      await tester.tap(find.byKey(const ValueKey('category_food')));
      await tester.pumpAndSettle();
    },
    'EXP-02 transfer': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseAddPath(type: 'transfer'));
    },
    'EXP-02 validation errors': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseAdd);
      await tester.tap(find.byKey(const Key('save_transaction')));
      await tester.pumpAndSettle();
    },
    'EXP-04 content with hidden expanded': (tester, s) async {
      final f = sample();
      f.world.categories['fuel'] = f.world.categories['fuel']!.copyWith(
        isHidden: true,
      );
      await _pump(tester, s, f, Routes.expenseCategories);
      await tester.drag(
        find.byKey(const Key('categories_list')),
        const Offset(0, -2000),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('hidden_section')));
      await tester.pumpAndSettle();
    },
    'EXP-04 empty income tab': (tester, s) async {
      final f = ExpenseFakes.empty()..addCategory('Chai', id: 'chai');
      await _pump(tester, s, f, Routes.expenseCategories);
      await tester.tap(find.byType(Tab).last);
      await tester.pumpAndSettle();
    },
    'EXP-05 new': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseCategories);
      await tester.tap(find.byKey(const Key('add_category')));
      await tester.pumpAndSettle();
    },
    'EXP-05 duplicate error': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseCategories);
      await tester.tap(find.byKey(const Key('add_category')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('category_name')), 'Food');
      await tester.ensureVisible(find.byKey(const Key('save_category')));
      await tester.tap(find.byKey(const Key('save_category')));
      await tester.pumpAndSettle();
    },
    'EXP-06 content with archived expanded': (tester, s) async {
      final f = sample()
        ..addAccount(
          'Card',
          id: 'card',
          type: AccountType.card,
          opening: -250000,
        )
        ..addAccount('Old wallet', id: 'old', archived: true);
      await _pump(tester, s, f, Routes.expenseAccounts);
      await tester.tap(find.byKey(const Key('archived_section')));
      await tester.pumpAndSettle();
    },
    'EXP-07 new with negative opening': (tester, s) async {
      await _pump(tester, s, sample(), Routes.expenseAccounts);
      await tester.tap(find.byKey(const Key('add_account')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('−'));
      await tester.tap(find.byKey(const Key('opening_balance')));
      await tester.pumpAndSettle();
      await typeAmount(tester, '2500');
    },
    'EXP-03 expense with receipt placeholder': (tester, s) async {
      final f = sample()
        ..addTransaction(
          id: 'r',
          amount: 99900,
          category: 'shopping',
          note: 'Shoes',
          receipt: 'receipts/missing.jpg',
          at: DateTime(2026, 10, 14, 9, 30),
        );
      await _pump(tester, s, f, Routes.expenseDetailPath('r'));
    },
  };

  for (final MapEntry(key: name, value: build) in scenarios.entries) {
    for (final theme in const ['light', 'dark']) {
      for (final lang in const ['en', 'gu']) {
        testWidgets('$name golden $theme $lang', (tester) async {
          await build(
            tester,
            AppSettings(onboardingDone: true, locale: lang, themeMode: theme),
          );
          final file =
              '${name.toLowerCase().replaceAll(' ', '_')}'
              '_${theme}_$lang.png';
          await expectLater(find.byType(MaterialApp), matchesGoldenFile(file));
        });
      }
    }
  }
}

Future<void> _pump(
  WidgetTester tester,
  AppSettings settings,
  ExpenseFakes fakes,
  String location,
) async {
  await pumpExpenseApp(
    tester,
    fakes: fakes,
    size: const Size(360, 800),
    settings: FakeSettingsRepository(initial: settings),
    location: location,
  );
}
