import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/seed_names.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final keys = [
    ...ExpenseDefaultsSeeder.expenseKeys,
    ...ExpenseDefaultsSeeder.incomeKeys,
    ExpenseDefaultsSeeder.cashAccountKey,
  ];

  for (final code in ['en', 'hi', 'gu']) {
    test('every seeded name translates in $code', () async {
      final l10n = await AppLocalizations.delegate.load(Locale(code));
      for (final key in keys) {
        final name = localizedSeedName(l10n, key);
        expect(name, isNot(key), reason: '$key in $code');
        expect(name, isNotEmpty);
      }
    });
  }

  test('user-created names are returned unchanged', () async {
    final l10n = await AppLocalizations.delegate.load(const Locale('en'));
    expect(localizedSeedName(l10n, 'Chai'), 'Chai');
  });

  test('a few translations are what the spec expects', () async {
    final gu = await AppLocalizations.delegate.load(const Locale('gu'));
    expect(localizedSeedName(gu, 'expense_cat_food'), 'ખોરાક');
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    expect(localizedSeedName(en, ExpenseDefaultsSeeder.cashAccountKey), 'Cash');
  });
}
