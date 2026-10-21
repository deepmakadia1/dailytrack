import 'package:dailytrack/core/l10n/default_name_catalog_impl.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_category_name.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-05 names (FR-025, clarification Q5, research R9).
void main() {
  const validate = ValidateCategoryName(L10nDefaultNameCatalog());

  Category cat(
    String id,
    String name, {
    CategoryType? type,
    bool def = false,
  }) => Category(
    id: id,
    name: name,
    type: type ?? CategoryType.expense,
    iconKey: 'category',
    colorHex: '#0F766E',
    isDefault: def,
    isHidden: false,
    sortOrder: 0,
  );

  final existing = [
    cat('food', 'expense_cat_food', def: true),
    cat('rent', 'Home rent', def: true), // a renamed default
    cat('chai', 'Chai  snacks'),
    cat('salary', 'income_cat_salary', type: CategoryType.income, def: true),
  ];

  CategoryNameError? check(
    String name, {
    CategoryType type = CategoryType.expense,
    String? editingId,
  }) => validate(name, type: type, existing: existing, editingId: editingId);

  test('empty or whitespace is required; over 30 characters is too long', () {
    expect(check(''), CategoryNameError.required);
    expect(check('   '), CategoryNameError.required);
    expect(check('x' * 30), isNull);
    expect(check('${'x' * 31}  '), CategoryNameError.tooLong);
    expect(check('  ${'x' * 30}  '), isNull, reason: 'trimmed first');
  });

  test('names that look like ARB keys are reserved', () {
    expect(check('expense_cat_x'), CategoryNameError.reserved);
    expect(check('income_account_y'), CategoryNameError.reserved);
  });

  test('Q5: a non-renamed default is matched in English, Hindi and '
      'Gujarati', () {
    for (final name in ['Food', 'food', '  FOOD ', 'खाना', 'ખોરાક']) {
      expect(check(name), CategoryNameError.duplicate, reason: name);
    }
  });

  test('custom names compare case-insensitively, trimmed, with repeated '
      'inner spaces as one', () {
    expect(check('chai snacks'), CategoryNameError.duplicate);
    expect(check(' CHAI   SNACKS '), CategoryNameError.duplicate);
    expect(check('Chai & snacks'), isNull);
  });

  test('a renamed default is compared by its new name only', () {
    expect(check('home rent'), CategoryNameError.duplicate);
    expect(
      check('Rent'),
      isNull,
      reason:
          'its old translations no longer '
          'apply once renamed',
    );
  });

  test('the same name in the other type is allowed', () {
    expect(check('Food', type: CategoryType.income), isNull);
    expect(
      check('Salary', type: CategoryType.income),
      CategoryNameError.duplicate,
    );
    expect(check('Salary'), isNull);
  });

  test('editing a category to its own name is allowed', () {
    expect(check('Food', editingId: 'food'), isNull);
    expect(check('chai snacks', editingId: 'chai'), isNull);
  });
}
