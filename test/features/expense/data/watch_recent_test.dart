import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// TransactionRepository.watchRecent (T015, DSH-01 Recent transactions,
/// research R10), on a real in-memory database.
void main() {
  late ExpenseDb x;
  late String cash;
  late String food;

  setUp(() async {
    x = await ExpenseDb.open();
    cash = await x.account('Cash');
    food = await x.category('Food');
  });

  Future<List<String>> recentIds([int limit = 5]) async => [
    for (final v in await x.transactions.watchRecent(limit: limit).first)
      v.transaction.id,
  ];

  test('orders by occurredAt DESC, then createdAt DESC', () async {
    final older = await x.add(
      account: cash,
      category: food,
      amount: 100,
      at: DateTime(2026, 10, 10, 9),
    );
    final sameTimeFirst = await x.add(
      account: cash,
      category: food,
      amount: 200,
      at: DateTime(2026, 10, 12, 9),
    );
    final sameTimeSecond = await x.add(
      account: cash,
      category: food,
      amount: 300,
      at: DateTime(2026, 10, 12, 9),
    );
    expect(await recentIds(), [sameTimeSecond.id, sameTimeFirst.id, older.id]);
  });

  test('limits to 5 of 8, newest first', () async {
    final ids = <String>[];
    for (var i = 0; i < 8; i++) {
      ids.add(
        (await x.add(
          account: cash,
          category: food,
          amount: 100 + i,
          at: DateTime(2026, 10, 1 + i, 9),
        )).id,
      );
    }
    expect(await recentIds(), ids.reversed.take(5).toList());
  });

  test('excludes soft-deleted rows', () async {
    final keep = await x.add(account: cash, category: food, amount: 100);
    final gone = await x.add(account: cash, category: food, amount: 200);
    await x.transactions.softDelete(gone.id);
    expect(await recentIds(), [keep.id]);
  });

  test('includes transfers with toAccount resolved', () async {
    final sbi = await x.account('SBI', type: AccountType.bank);
    await x.add(
      account: cash,
      toAccount: sbi,
      type: TxnType.transfer,
      amount: 5000,
    );
    final [row] = await x.transactions.watchRecent().first;
    expect(row.transaction.type, TxnType.transfer);
    expect(row.account.name, 'Cash');
    expect(row.toAccount?.name, 'SBI');
  });

  test(
    're-emits after a create, a soft delete, and a category rename',
    () async {
      final emissions = <List<(String, String?)>>[];
      final sub = x.transactions.watchRecent().listen(
        (rows) => emissions.add([
          for (final r in rows) (r.transaction.id, r.category?.name),
        ]),
      );
      await pumpEventQueue();
      final t = await x.add(account: cash, category: food, amount: 100);
      await pumpEventQueue();
      await x.categories.update(
        food,
        name: 'Meals',
        iconKey: 'category',
        colorHex: '#0F766E',
      );
      await pumpEventQueue();
      await x.transactions.softDelete(t.id);
      await pumpEventQueue();
      await sub.cancel();
      expect(emissions, [
        <(String, String?)>[],
        [(t.id, 'Food')],
        [(t.id, 'Meals')],
        <(String, String?)>[],
      ]);
    },
  );
}
