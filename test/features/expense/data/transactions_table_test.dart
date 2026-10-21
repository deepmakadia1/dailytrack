import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The table's own constraints are the last line of defense under domain
/// validation (data-model.md §3.1, research R3).
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    for (final id in ['a1', 'a2']) {
      await db
          .into(db.accounts)
          .insert(
            AccountsCompanion.insert(
              id: id,
              name: id,
              type: AccountType.cash,
              iconKey: 'wallet',
              colorHex: '#0F766E',
              sortOrder: 0,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
    }
    await db
        .into(db.categories)
        .insert(
          CategoriesCompanion.insert(
            id: 'c1',
            name: 'Food',
            type: CategoryType.expense,
            iconKey: 'restaurant',
            colorHex: '#0F766E',
            sortOrder: 0,
            createdAt: 0,
            updatedAt: 0,
          ),
        );
  });
  tearDown(() => db.close());

  Future<void> insert({
    String id = 't',
    TxnType type = TxnType.expense,
    int amount = 100,
    String accountId = 'a1',
    String? toAccountId,
    String? categoryId = 'c1',
    String? note,
  }) => db
      .into(db.transactions)
      .insert(
        TransactionsCompanion.insert(
          id: id,
          type: type,
          amountMinor: amount,
          accountId: accountId,
          toAccountId: Value(toAccountId),
          categoryId: Value(categoryId),
          paymentMode: PaymentMode.cash,
          note: Value(note),
          occurredAt: 0,
          createdAt: 0,
          updatedAt: 0,
        ),
      );

  final rejects = throwsA(isA<SqliteException>());

  test('a valid expense, income and transfer are accepted', () async {
    await insert(id: 'e');
    await insert(id: 'i', type: TxnType.income);
    await insert(type: TxnType.transfer, toAccountId: 'a2', categoryId: null);
    expect(await db.select(db.transactions).get(), hasLength(3));
  });

  test('amount must be between ₹0.01 and ₹99,99,99,999.00', () async {
    await expectLater(insert(amount: 0), rejects);
    await expectLater(insert(amount: -1), rejects);
    await expectLater(insert(amount: 99999999901), rejects);
    await insert(id: 'max', amount: 99999999900);
    await insert(id: 'min', amount: 1);
  });

  test('a transfer needs a destination, no category, two accounts', () async {
    await expectLater(
      insert(type: TxnType.transfer, toAccountId: 'a2'),
      rejects,
      reason: 'transfer with a category',
    );
    await expectLater(
      insert(type: TxnType.transfer, categoryId: null),
      rejects,
      reason: 'transfer without a destination',
    );
    await expectLater(
      insert(type: TxnType.transfer, toAccountId: 'a1', categoryId: null),
      rejects,
      reason: 'same source and destination',
    );
  });

  test('expense and income need a category and no destination', () async {
    await expectLater(insert(categoryId: null), rejects);
    await expectLater(insert(type: TxnType.income, categoryId: null), rejects);
    await expectLater(insert(toAccountId: 'a2'), rejects);
  });

  test('note is at most 200 characters', () async {
    await insert(id: 'ok', note: 'x' * 200);
    await expectLater(insert(id: 'long', note: 'x' * 201), rejects);
  });

  test('accounts and categories must exist (foreign keys)', () async {
    await expectLater(insert(accountId: 'missing'), rejects);
    await expectLater(insert(categoryId: 'missing'), rejects);
    await expectLater(
      insert(type: TxnType.transfer, toAccountId: 'missing', categoryId: null),
      rejects,
    );
  });

  test('the three spec §4 indexes exist', () async {
    final rows = await db
        .customSelect("PRAGMA index_list('transactions')")
        .get();
    final names = rows.map((r) => r.read<String>('name')).toSet();
    expect(
      names,
      containsAll([
        'transactions_occurred',
        'transactions_category_occurred',
        'transactions_account_occurred',
      ]),
    );

    Future<List<String>> columns(String index) async =>
        (await db.customSelect("PRAGMA index_info('$index')").get())
            .map((r) => r.read<String>('name'))
            .toList();
    expect(await columns('transactions_occurred'), ['occurred_at']);
    expect(await columns('transactions_category_occurred'), [
      'category_id',
      'occurred_at',
    ]);
    expect(await columns('transactions_account_occurred'), [
      'account_id',
      'occurred_at',
    ]);
  });
}
