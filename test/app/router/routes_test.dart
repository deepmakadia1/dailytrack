import 'package:dailytrack/app/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

/// Expense path helpers (contracts/routes_and_module.md).
void main() {
  test('EXP-01 with and without an account filter', () {
    expect(Routes.expensesPath(), '/expenses');
    expect(Routes.expensesPath(accountId: 'a b'), '/expenses?accountId=a+b');
  });

  test('EXP-02 new with type and duplicateOf', () {
    expect(Routes.expenseAddPath(), '/expenses/add');
    expect(Routes.expenseAddPath(type: 'income'), '/expenses/add?type=income');
    expect(
      Routes.expenseAddPath(type: 'expense', duplicateOf: 'txn-1'),
      '/expenses/add?type=expense&duplicateOf=txn-1',
    );
  });

  test('EXP-03 detail and EXP-02 edit', () {
    expect(Routes.expenseDetailPath('txn-1'), '/expenses/txn-1');
    expect(Routes.expenseEditPath('txn-1'), '/expenses/txn-1/edit');
  });

  test('every expense path lives under the module root', () {
    for (final p in [
      Routes.expenseAdd,
      Routes.expenseCategories,
      Routes.expenseAccounts,
      Routes.expenseDetail,
      Routes.expenseEdit,
    ]) {
      expect(p, startsWith('${Routes.expenses}/'));
    }
  });

  // --- 005-habit-module (T029) ---

  test('HAB-02 new, with and without a template', () {
    expect(Routes.habitAddPath(), '/habits/add');
    expect(Routes.habitAddPath(template: 'read'), '/habits/add?template=read');
    expect(
      Routes.habitAddPath(template: 'a b&c'),
      '/habits/add?template=a+b%26c',
    );
  });

  test('HAB-03 detail and HAB-02 edit encode the id', () {
    expect(Routes.habitDetailPath('h-1'), '/habits/h-1');
    expect(Routes.habitEditPath('h-1'), '/habits/h-1/edit');
    expect(Routes.habitDetailPath('a/b'), '/habits/a%2Fb');
  });

  test('every habit path lives under the module root', () {
    for (final p in [
      Routes.habitAdd,
      Routes.habitArchived,
      Routes.habitDetail,
      Routes.habitEdit,
    ]) {
      expect(p, startsWith('${Routes.habits}/'));
    }
    expect(Routes.habitAdd, '${Routes.habits}/${Routes.habitAddSegment}');
    expect(
      Routes.habitArchived,
      '${Routes.habits}/${Routes.habitArchivedSegment}',
    );
    expect(
      Routes.habitEdit,
      '${Routes.habitDetail}/${Routes.habitEditSegment}',
    );
  });
}
