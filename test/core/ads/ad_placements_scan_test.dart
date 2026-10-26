import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Spec §11 placement table and FR-009 (feature 009 T036): ad widgets are
/// placed exactly on the listed screens and nowhere else, so no form, lock,
/// onboarding, or premium screen can ever show one.
void main() {
  Map<String, int> uses(String widget) {
    final result = <String, int>{};
    for (final f in Directory('lib').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final path = f.path.replaceAll(r'\', '/');
      // The widgets' own files define them.
      if (path.startsWith('lib/core/ads/')) continue;
      final count = '$widget('.allMatches(f.readAsStringSync()).length;
      if (count > 0) result[path] = count;
    }
    return result;
  }

  const screens = 'lib/features';

  test('banners: exactly EXP-01, EXP-03, EXP-04, EXP-06, EXP-11, HAB-01, '
      'HAB-03, HAB-04, SET-01, SET-02', () {
    expect(uses('AppBannerAd').keys.toSet(), {
      '$screens/expense/presentation/screens/transactions_screen.dart',
      '$screens/expense/presentation/screens/transaction_detail_screen.dart',
      '$screens/expense/presentation/screens/categories_screen.dart',
      '$screens/expense/presentation/screens/accounts_screen.dart',
      '$screens/expense/presentation/screens/reports_screen.dart',
      '$screens/habit/presentation/screens/habits_today_screen.dart',
      '$screens/habit/presentation/screens/habit_detail_screen.dart',
      '$screens/habit/presentation/screens/archived_habits_screen.dart',
      '$screens/settings/presentation/screens/settings_screen.dart',
      '$screens/settings/presentation/screens/backup_screen.dart',
    });
  });

  test('natives: exactly DSH-01, EXP-01, EXP-08, HAB-01, one slot each', () {
    expect(uses('AppNativeAd'), {
      '$screens/dashboard/presentation/screens/home_screen.dart': 1,
      '$screens/expense/presentation/screens/transactions_screen.dart': 1,
      '$screens/expense/presentation/screens/budgets_screen.dart': 1,
      '$screens/habit/presentation/screens/habits_today_screen.dart': 1,
    });
  });
}
