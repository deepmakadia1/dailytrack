import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every key used by the default seeder resolves to its own icon', () {
    // Keys from ExpenseDefaultsSeeder (categories and the Cash account).
    const seederKeys = [
      'restaurant',
      'local_grocery_store',
      'directions_bus',
      'local_gas_station',
      'shopping_bag',
      'receipt',
      'home',
      'medical_services',
      'school',
      'movie',
      'flight',
      'category',
      'payments',
      'storefront',
      'redeem',
      'savings',
      'attach_money',
      'wallet',
    ];
    for (final key in seederKeys) {
      expect(AppIcons.isKnown(key), isTrue, reason: key);
    }
    expect(AppIcons.byKey('restaurant'), Icons.restaurant);
  });

  test('keys are unique and every grouped key has an icon', () {
    final keys = AppIcons.keys;
    expect(keys.toSet(), hasLength(keys.length));
    expect(keys.length, inInclusiveRange(70, 90), reason: 'about 80 icons');
    for (final key in keys) {
      expect(AppIcons.isKnown(key), isTrue, reason: key);
    }
  });

  test('unknown keys fall back to the category icon', () {
    expect(AppIcons.byKey('no_such_icon'), AppIcons.fallback);
  });

  test('every icon and group has a label in every language (T012)', () {
    for (final code in ['en', 'hi', 'gu']) {
      final l10n = lookupAppLocalizations(Locale(code));
      for (final key in AppIcons.keys) {
        expect(l10nByKey(l10n, 'icon_$key'), isNotNull, reason: '$code $key');
      }
      for (final group in AppIcons.groups.keys) {
        expect(
          l10nByKey(l10n, 'common_iconGroup_$group'),
          isNotNull,
          reason: '$code $group',
        );
      }
    }
  });
}
