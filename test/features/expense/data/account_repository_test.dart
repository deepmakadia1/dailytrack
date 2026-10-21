import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

void main() {
  late ExpenseDb x;
  late String food;
  late String salary;

  setUp(() async {
    x = await ExpenseDb.open();
    food = await x.category('Food');
    salary = await x.category('Salary', type: CategoryType.income);
  });

  Future<Map<String, AccountWithBalance>> balances() async => {
    for (final a in await x.accounts.watchAllWithBalances().first)
      a.account.name: a,
  };

  test('US5-2 balance = opening + income − expense − out + in', () async {
    final cash = await x.account('Cash', opening: 10000);
    final card = await x.account(
      'Card',
      type: AccountType.card,
      opening: -50000,
    );
    await x.add(
      account: cash,
      category: salary,
      type: TxnType.income,
      amount: 300000,
    );
    await x.add(account: cash, category: food, amount: 15550);
    await x.add(account: card, category: food, amount: 2000);
    await x.add(
      account: cash,
      toAccount: card,
      type: TxnType.transfer,
      amount: 40000,
    );
    final gone = await x.add(account: cash, category: food, amount: 99999);
    await x.transactions.softDelete(gone.id);

    final b = await balances();
    expect(b['Cash']!.balanceMinor, 10000 + 300000 - 15550 - 40000);
    expect(b['Card']!.balanceMinor, -50000 - 2000 + 40000);
    expect(b['Cash']!.hasTransactions, isTrue);
    expect(
      await x.accounts.watchTotalBalance().first,
      b['Cash']!.balanceMinor + b['Card']!.balanceMinor,
    );
  });

  test('total balance covers non-archived accounts only', () async {
    await x.account('Cash', opening: 100);
    final old = await x.account('Old', opening: 900);
    await x.accounts.setArchived(old, archived: true);
    expect(await x.accounts.watchTotalBalance().first, 100);
    expect((await balances()).keys, containsAll(['Cash', 'Old']));
  });

  test('an account with transactions (source or destination) cannot be '
      'deleted', () async {
    final cash = await x.account('Cash');
    final sbi = await x.account('SBI');
    final spare = await x.account('Spare');
    await x.add(
      account: cash,
      toAccount: sbi,
      type: TxnType.transfer,
      amount: 1,
    );

    for (final id in [cash, sbi]) {
      await expectLater(
        x.accounts.delete(id),
        throwsA(
          isA<AccountDeleteNotAllowed>().having(
            (e) => e.reason,
            'reason',
            AccountDeleteReason.hasTransactions,
          ),
        ),
      );
    }
    await x.accounts.delete(spare);
    expect((await balances()).keys, isNot(contains('Spare')));
  });

  test('Q3: the last active account cannot be archived or deleted', () async {
    final cash = await x.account('Cash');
    final old = await x.account('Old');
    await x.accounts.setArchived(old, archived: true);

    await expectLater(
      x.accounts.setArchived(cash, archived: true),
      throwsA(isA<AccountArchiveNotAllowed>()),
    );
    await expectLater(
      x.accounts.delete(cash),
      throwsA(
        isA<AccountDeleteNotAllowed>().having(
          (e) => e.reason,
          'reason',
          AccountDeleteReason.lastActive,
        ),
      ),
    );
    // Deleting an ARCHIVED account never reduces the active count.
    await x.accounts.delete(old);

    // With a second active account, archiving is allowed again.
    await x.account('SBI');
    await x.accounts.setArchived(cash, archived: true);
  });

  test('pickable excludes archived and deleted; unarchive and undelete '
      'restore them', () async {
    final cash = await x.account('Cash');
    final card = await x.account('Card');
    final spare = await x.account('Spare');
    await x.accounts.setArchived(card, archived: true);
    await x.accounts.delete(spare);
    expect(
      [for (final a in await x.accounts.watchPickable().first) a.id],
      [cash],
    );

    await x.accounts.setArchived(card, archived: false);
    await x.accounts.undelete(spare);
    expect(
      [for (final a in await x.accounts.watchPickable().first) a.id],
      [cash, card, spare],
    );
  });

  test('create appends in sort order; update rewrites the fields', () async {
    final cash = await x.account('Cash');
    final sbi = await x.accounts.create(
      name: ' SBI Savings ',
      type: AccountType.bank,
      openingBalanceMinor: 1000000,
      iconKey: 'account_balance',
      colorHex: '#1D4ED8',
    );
    expect(sbi.name, 'SBI Savings');
    expect(sbi.sortOrder, 1);

    await x.accounts.update(
      cash,
      name: 'Wallet cash',
      type: AccountType.wallet,
      openingBalanceMinor: -500,
      iconKey: 'wallet',
      colorHex: '#0F766E',
    );
    final updated = (await balances())['Wallet cash']!.account;
    expect(updated.type, AccountType.wallet);
    expect(updated.openingBalanceMinor, -500);
  });
}
