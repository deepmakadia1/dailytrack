import 'package:dailytrack/core/l10n/default_name_catalog_impl.dart';
import 'package:flutter_test/flutter_test.dart';

/// T010: translations of default names across en, hi and gu (research R9).
void main() {
  const catalog = L10nDefaultNameCatalog();

  test('a default category key has its three translations', () {
    expect(catalog.namesFor('expense_cat_food'), {'Food', 'खाना', 'ખોરાક'});
    expect(catalog.namesFor('expense_account_cash'), {'Cash', 'नकद', 'રોકડ'});
  });

  test('an unknown key has none', () {
    expect(catalog.namesFor('Chai & snacks'), isEmpty);
  });
}
