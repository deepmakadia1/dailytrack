import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

void main() {
  late ExpenseDb x;
  late String cash;

  setUp(() async {
    x = await ExpenseDb.open(seedDefaults: true);
    cash = (await x.accounts.watchPickable().first).single.id;
  });

  Future<List<String>> pickable([
    CategoryType t = CategoryType.expense,
  ]) async => [
    for (final c in await x.categories.watchPickable(t).first) c.name,
  ];

  Matcher reason(CategoryDeleteReason r) => throwsA(
    isA<CategoryDeleteNotAllowed>().having((e) => e.reason, 'reason', r),
  );

  test('with no history the pickable order is the EXP-04 order', () async {
    expect(await pickable(), [
      'expense_cat_food',
      'expense_cat_groceries',
      'expense_cat_transport',
      'expense_cat_fuel',
      'expense_cat_shopping',
      'expense_cat_bills',
      'expense_cat_rent',
      'expense_cat_health',
      'expense_cat_education',
      'expense_cat_entertainment',
      'expense_cat_travel',
      'expense_cat_other',
    ]);
    expect(await pickable(CategoryType.income), hasLength(5));
  });

  test('Q2: usage count DESC, then EXP-04 order as the tiebreak', () async {
    final fuel = await x.defaultCategory('expense_cat_fuel');
    final rent = await x.defaultCategory('expense_cat_rent');
    final bills = await x.defaultCategory('expense_cat_bills');
    for (var i = 0; i < 3; i++) {
      await x.add(account: cash, category: rent, amount: 1);
    }
    for (var i = 0; i < 2; i++) {
      await x.add(account: cash, category: fuel, amount: 1);
      await x.add(account: cash, category: bills, amount: 1);
    }
    // A deleted transaction does not count.
    final deleted = await x.add(account: cash, category: bills, amount: 1);
    await x.transactions.softDelete(deleted.id);

    final order = await pickable();
    expect(order.take(4), [
      'expense_cat_rent', // 3
      'expense_cat_fuel', // 2, sortOrder 3
      'expense_cat_bills', // 2, sortOrder 5
      'expense_cat_food', // 0, sortOrder 0
    ]);
  });

  test(
    'hidden categories leave EXP-02 but stay in watchAll and EXP-04',
    () async {
      final fuel = await x.defaultCategory('expense_cat_fuel');
      await x.categories.setHidden(fuel, hidden: true);

      expect(await pickable(), isNot(contains('expense_cat_fuel')));
      expect(
        (await x.categories.watchAll().first).map((c) => c.id),
        contains(fuel),
      );
      final row =
          (await x.categories
                  .watchByType(
                    CategoryType.expense,
                    month: MonthPeriod(DateTime(2026, 10)),
                  )
                  .first)
              .singleWhere((s) => s.category.id == fuel);
      expect(row.category.isHidden, isTrue);

      await x.categories.setHidden(fuel, hidden: false);
      expect(await pickable(), contains('expense_cat_fuel'));
    },
  );

  test('create appends (sortOrder = max + 1); reorder persists', () async {
    final chai = await x.categories.create(
      name: '  Chai & snacks ',
      type: CategoryType.expense,
      iconKey: 'local_cafe',
      colorHex: '#B45309',
    );
    expect(chai.name, 'Chai & snacks');
    expect(chai.sortOrder, 12);
    expect(chai.isDefault, isFalse);

    final ids = [
      for (final c
          in await x.categories.watchPickable(CategoryType.expense).first)
        c.id,
    ];
    final reordered = [ids.last, ...ids.take(ids.length - 1)];
    await x.categories.reorder(CategoryType.expense, reordered);
    expect([
      for (final c
          in await x.categories.watchPickable(CategoryType.expense).first)
        c.id,
    ], reordered);
  });

  test('default categories cannot be deleted', () async {
    final food = await x.defaultCategory('expense_cat_food');
    await expectLater(
      x.categories.delete(food),
      reason(CategoryDeleteReason.isDefault),
    );
  });

  test('deleting a custom category with transactions needs a valid '
      'same-type replacement', () async {
    final chai = await x.category('Chai');
    final salary = await x.defaultCategory('income_cat_salary');
    final food = await x.defaultCategory('expense_cat_food');
    await x.add(account: cash, category: chai, amount: 100);
    await x.add(account: cash, category: chai, amount: 200);

    expect(await x.categories.transactionCount(chai), 2);
    await expectLater(
      x.categories.delete(chai),
      reason(CategoryDeleteReason.replacementRequired),
    );
    await expectLater(
      x.categories.delete(chai, replacementId: salary),
      reason(CategoryDeleteReason.invalidReplacement),
    );
    await expectLater(
      x.categories.delete(chai, replacementId: chai),
      reason(CategoryDeleteReason.invalidReplacement),
    );
    await expectLater(
      x.categories.delete(chai, replacementId: 'missing'),
      reason(CategoryDeleteReason.invalidReplacement),
    );

    await x.categories.delete(chai, replacementId: food);
    expect(await x.categories.transactionCount(food), 2);
    expect(await x.categories.transactionCount(chai), 0);
    expect(
      (await x.categories.watchAll().first).map((c) => c.id),
      isNot(contains(chai)),
    );
  });

  test('the move and the delete are atomic', () async {
    final chai = await x.category('Chai');
    final food = await x.defaultCategory('expense_cat_food');
    await x.add(account: cash, category: chai, amount: 100);

    // Make the final step (soft-deleting the category) fail after the
    // transactions were already moved.
    await x.db.customStatement('''
      CREATE TRIGGER fail_category_delete BEFORE UPDATE OF deleted_at
      ON categories WHEN NEW.deleted_at IS NOT NULL
      BEGIN SELECT RAISE(ABORT, 'forced'); END''');

    await expectLater(
      x.categories.delete(chai, replacementId: food),
      throwsA(isA<ExpenseStorageFailure>()),
    );
    expect(await x.categories.transactionCount(chai), 1, reason: 'rolled back');
    expect(await x.categories.transactionCount(food), 0);
  });

  test(
    'a custom category without transactions deletes and undeletes',
    () async {
      final chai = await x.category('Chai');
      await x.categories.delete(chai);
      expect(await pickable(), isNot(contains('Chai')));
      await x.categories.undelete(chai);
      expect(await pickable(), contains('Chai'));
    },
  );

  test(
    'month totals use local month boundaries and skip deleted rows',
    () async {
      final food = await x.defaultCategory('expense_cat_food');
      await x.add(
        account: cash,
        category: food,
        amount: 100,
        at: DateTime(2026, 10),
      );
      await x.add(
        account: cash,
        category: food,
        amount: 200,
        at: DateTime(2026, 10, 31, 23, 59),
      );
      await x.add(
        account: cash,
        category: food,
        amount: 400,
        at: DateTime(2026, 11),
      );
      await x.add(
        account: cash,
        category: food,
        amount: 800,
        at: DateTime(2026, 9, 30, 23, 59),
      );
      final gone = await x.add(
        account: cash,
        category: food,
        amount: 1600,
        at: DateTime(2026, 10, 5),
      );
      await x.transactions.softDelete(gone.id);

      Future<CategoryWithStats> foodStats(DateTime month) async =>
          (await x.categories
                  .watchByType(CategoryType.expense, month: MonthPeriod(month))
                  .first)
              .singleWhere((s) => s.category.id == food);

      final october = await foodStats(DateTime(2026, 10));
      expect(october.monthTotalMinor, 300);
      expect(october.usageCount, 4);
      expect((await foodStats(DateTime(2026, 11))).monthTotalMinor, 400);
    },
  );

  test('update renames and keeps the type', () async {
    final food = await x.defaultCategory('expense_cat_food');
    await x.categories.update(
      food,
      name: 'Meals',
      iconKey: 'restaurant',
      colorHex: '#0F766E',
    );
    final row = await x.db
        .customSelect(
          'SELECT name, type, is_default FROM categories WHERE id = ?',
          variables: [Variable.withString(food)],
        )
        .getSingle();
    expect(row.read<String>('name'), 'Meals');
    expect(row.read<int>('type'), CategoryType.expense.index);
    expect(row.read<bool>('is_default'), isTrue);
  });
}
