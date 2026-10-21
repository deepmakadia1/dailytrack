import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

void main() {
  late ExpenseDb x;
  late String cash;
  late String food;

  final october = TxnQuery(period: MonthPeriod(DateTime(2026, 10)));

  setUp(() async {
    x = await ExpenseDb.open();
    cash = await x.account('Cash');
    food = await x.category('Food');
  });

  Future<List<String>> pageIds([TxnQuery? q, int limit = 100]) async => [
    for (final v
        in await x.transactions.watchPage(q ?? october, limit: limit).first)
      v.transaction.id,
  ];

  test(
    'create assigns a UUID and UTC timestamps; blank notes are NULL',
    () async {
      final t = await x.add(
        account: cash,
        category: food,
        amount: 1010,
        note: '  ',
      );
      expect(t.id, hasLength(36));
      expect(t.note, isNull);
      expect(t.amountMinor, 1010);
      expect(t.createdAt.isUtc, isTrue);
      expect(t.createdAt, x.clock.now().toUtc());
      expect(t.recurringRuleId, isNull);

      final noted = await x.add(
        account: cash,
        category: food,
        amount: 5,
        note: ' chai ',
      );
      expect(noted.note, 'chai');
    },
  );

  test('page rows join category and both accounts', () async {
    final sbi = await x.account('SBI', type: AccountType.bank);
    await x.add(
      account: cash,
      toAccount: sbi,
      type: TxnType.transfer,
      amount: 500,
    );
    final view =
        (await x.transactions.watchPage(october, limit: 10).first).single;
    expect(view.account.name, 'Cash');
    expect(view.toAccount!.name, 'SBI');
    expect(view.category, isNull);
  });

  test('update and restore of a missing or deleted row throw '
      'TransactionNotFound', () async {
    final t = await x.add(account: cash, category: food, amount: 100);
    final draft = TransactionDraft(
      type: TxnType.expense,
      amountMinor: 200,
      accountId: cash,
      categoryId: food,
      paymentMode: PaymentMode.upi,
      occurredAt: t.occurredAt,
    );
    await expectLater(
      x.transactions.update('missing', draft),
      throwsA(isA<TransactionNotFound>()),
    );
    await x.transactions.softDelete(t.id);
    await expectLater(
      x.transactions.update(t.id, draft),
      throwsA(isA<TransactionNotFound>()),
    );
    await expectLater(
      x.transactions.restore(t),
      throwsA(isA<TransactionNotFound>()),
    );
  });

  test('restore(snapshot) rewrites every field (undo of an edit)', () async {
    final original = await x.add(
      account: cash,
      category: food,
      amount: 100,
      note: 'lunch',
      receipt: 'receipts/a.jpg',
    );
    final sbi = await x.account('SBI');
    final edited = await x.transactions.update(
      original.id,
      TransactionDraft(
        type: TxnType.expense,
        amountMinor: 999,
        accountId: sbi,
        categoryId: food,
        paymentMode: PaymentMode.card,
        note: 'dinner',
        occurredAt: DateTime.utc(2026, 10),
      ),
    );
    expect(edited.amountMinor, 999);
    expect(edited.receiptPath, isNull);

    await x.transactions.restore(original);
    final back = (await x.transactions.findById(original.id))!.transaction;
    expect(back, original);
  });

  test(
    'softDelete hides the row from page, ledger, watchById and findById',
    () async {
      final t = await x.add(account: cash, category: food, amount: 700);
      await x.transactions.softDelete(t.id);

      expect(await pageIds(), isEmpty);
      expect((await x.transactions.watchLedger(october).first).expenseMinor, 0);
      expect(await x.transactions.watchById(t.id).first, isNull);
      expect(await x.transactions.findById(t.id), isNull);
    },
  );

  test(
    'EXP-01 "Undo restores a deleted row in its original position."',
    () async {
      // Five rows; three share the same occurredAt, so only createdAt and id
      // break the tie.
      final same = DateTime(2026, 10, 14, 9);
      for (var i = 0; i < 3; i++) {
        await x.add(account: cash, category: food, amount: 100 + i, at: same);
      }
      await x.add(
        account: cash,
        category: food,
        amount: 1,
        at: DateTime(2026, 10, 15),
      );
      await x.add(
        account: cash,
        category: food,
        amount: 2,
        at: DateTime(2026, 10, 2),
      );

      final before = await pageIds();
      final third = before[2];
      await x.transactions.softDelete(third);
      expect(await pageIds(), isNot(contains(third)));
      await x.transactions.undelete(third);

      final after = await pageIds();
      expect(after, before);
      expect(after.indexOf(third), 2);
    },
  );

  test('page respects the limit, newest first', () async {
    for (var d = 1; d <= 5; d++) {
      await x.add(
        account: cash,
        category: food,
        amount: d,
        at: DateTime(2026, 10, d),
      );
    }
    final page = await x.transactions.watchPage(october, limit: 3).first;
    expect(page.map((v) => v.transaction.amountMinor), [5, 4, 3]);
  });

  test(
    'lastUsedAccountId is the most recently created, skipping archived',
    () async {
      expect(await x.transactions.lastUsedAccountId(), isNull);
      final card = await x.account('Card', type: AccountType.card);
      await x.add(account: cash, category: food, amount: 1);
      await x.add(
        account: card,
        category: food,
        amount: 1,
        at: DateTime(2026, 9),
      );
      // Most recently CREATED, even though its occurredAt is older.
      expect(await x.transactions.lastUsedAccountId(), card);

      await x.accounts.setArchived(card, archived: true);
      expect(await x.transactions.lastUsedAccountId(), cash);
    },
  );

  test('recentNotes are distinct, most recent first, prefix-matched', () async {
    for (final n in ['Chai', 'Lunch', 'chai', 'Chai', 'Cab', '']) {
      await x.add(account: cash, category: food, amount: 1, note: n);
    }
    final deleted = await x.add(
      account: cash,
      category: food,
      amount: 1,
      note: 'Cinema',
    );
    await x.transactions.softDelete(deleted.id);

    expect(await x.transactions.recentNotes(), [
      'Cab',
      'Chai',
      'chai',
      'Lunch',
    ]);
    expect(await x.transactions.recentNotes(prefix: 'ch'), ['Chai', 'chai']);
    expect(await x.transactions.recentNotes(limit: 1), ['Cab']);
  });

  test('watchTodayAndMonthSpend counts only expenses', () async {
    final salary = await x.category('Salary', type: CategoryType.income);
    final sbi = await x.account('SBI');
    final now = DateTime(2026, 10, 14, 18);

    var spend = await x.transactions.watchTodayAndMonthSpend(now).first;
    expect(spend.hasAnyTransaction, isFalse);

    await x.add(
      account: cash,
      category: food,
      amount: 300,
      at: DateTime(2026, 10, 14, 8),
    );
    await x.add(
      account: cash,
      category: food,
      amount: 200,
      at: DateTime(2026, 10, 14, 23, 59),
    );
    await x.add(
      account: cash,
      category: food,
      amount: 1000,
      at: DateTime(2026, 10, 2),
    );
    await x.add(
      account: cash,
      category: food,
      amount: 5000,
      at: DateTime(2026, 9, 30),
    );
    await x.add(
      account: cash,
      category: salary,
      type: TxnType.income,
      amount: 9999,
    );
    await x.add(
      account: cash,
      toAccount: sbi,
      type: TxnType.transfer,
      amount: 777,
    );

    spend = await x.transactions.watchTodayAndMonthSpend(now).first;
    expect(spend.todayMinor, 500);
    expect(spend.monthMinor, 1500);
    expect(spend.hasAnyTransaction, isTrue);
  });

  test('allReceiptPaths includes soft-deleted rows', () async {
    await x.add(
      account: cash,
      category: food,
      amount: 1,
      receipt: 'receipts/a.jpg',
    );
    final b = await x.add(
      account: cash,
      category: food,
      amount: 1,
      receipt: 'receipts/b.jpg',
    );
    await x.add(account: cash, category: food, amount: 1);
    await x.transactions.softDelete(b.id);
    expect(await x.transactions.allReceiptPaths(), {
      'receipts/a.jpg',
      'receipts/b.jpg',
    });
  });

  test('FR-008 page stream re-emits after a write to another table', () async {
    await x.add(account: cash, category: food, amount: 1);
    final names = x.transactions
        .watchPage(october, limit: 10)
        .map((rows) => rows.single.category!.name);
    final seen = expectLater(names, emitsInOrder(['Food', 'Meals']));
    await Future<void>.delayed(Duration.zero);
    await x.categories.update(
      food,
      name: 'Meals',
      iconKey: 'category',
      colorHex: '#0F766E',
    );
    await seen;
  });

  test('US3-4 soft delete leaves rows recoverable', () async {
    final t = await x.add(account: cash, category: food, amount: 1);
    final custom = await x.category('Chai & snacks');
    final spare = await x.account('Spare');

    await x.transactions.softDelete(t.id);
    await x.categories.delete(custom);
    await x.accounts.delete(spare);

    Future<int?> deletedAt(String table, String id) async =>
        (await x.db
                .customSelect(
                  'SELECT deleted_at FROM $table WHERE id = ?',
                  variables: [Variable.withString(id)],
                )
                .getSingle())
            .read<int?>('deleted_at');

    expect(await deletedAt('transactions', t.id), isNotNull);
    expect(await deletedAt('categories', custom), isNotNull);
    expect(await deletedAt('accounts', spare), isNotNull);

    await x.transactions.undelete(t.id);
    await x.categories.undelete(custom);
    await x.accounts.undelete(spare);

    expect(await deletedAt('transactions', t.id), isNull);
    expect(await deletedAt('categories', custom), isNull);
    expect(await deletedAt('accounts', spare), isNull);
  });
}
