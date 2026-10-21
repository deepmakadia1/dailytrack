import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/daos/transactions_dao.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

import 'expense_db_fixture.dart';

/// EXP-01 search rules (research R5, spec §8 EXP-01 updated by T001).
void main() {
  late ExpenseDb x;
  late String cash;
  late String food;
  late String travel;
  final ids = <String, String>{};

  setUp(() async {
    x = await ExpenseDb.open();
    cash = await x.account('Cash');
    food = await x.category('Food');
    travel = await x.category('Travel');
    ids.clear();
    Future<void> add(String key, int amount, String note, {String? cat}) async {
      ids[key] = (await x.add(
        account: cash,
        category: cat ?? food,
        amount: amount,
        note: note,
      )).id;
    }

    await add('r12', 1200, 'Samosa');
    await add('r120', 12000, 'Groceries');
    await add('r1250', 125000, 'Rent share');
    await add('r12_50', 1250, 'Auto');
    await add('r2_12', 212, 'Gum');
    await add('hindi', 5000, 'चाय और नाश्ता');
    await add('gujarati', 6000, 'ચા નાસ્તો');
    await add('percent', 700, '50% off sale');
    await add('underscore', 800, 'file_name');
    await add('backslash', 900, r'a\b');
    await add('cab', 300, 'Cab home', cat: travel);
  });

  Future<Set<String>> search(
    String q, {
    Set<String> matchingCategoryIds = const {},
    Set<TxnType> types = const {},
  }) async {
    final rows = await x.transactions
        .watchPage(
          TxnQuery(
            period: MonthPeriod(DateTime(2026, 10)),
            search: q,
            matchingCategoryIds: matchingCategoryIds,
            types: types,
          ),
          limit: 100,
        )
        .first;
    final byId = {for (final e in ids.entries) e.value: e.key};
    return {for (final r in rows) byId[r.transaction.id]!};
  }

  test('note substring is case-insensitive', () async {
    expect(await search('samosa'), {'r12'});
    expect(await search('SAMO'), {'r12'});
    expect(await search('home'), {'cab'});
  });

  test('Hindi and Gujarati notes match', () async {
    expect(await search('नाश्ता'), {'hindi'});
    expect(await search('ચા'), {'gujarati'});
  });

  test(
    'categories resolved by localized name match (matchingCategoryIds)',
    () async {
      expect(await search('Yatra', matchingCategoryIds: {travel}), {'cab'});
    },
  );

  test('"12" finds ₹12, ₹120, ₹1,250 and ₹12.50, not ₹2.12', () async {
    expect(await search('12'), {'r12', 'r120', 'r1250', 'r12_50'});
  });

  test('"12.5" finds only ₹12.50; "12.50" too', () async {
    expect(await search('12.5'), {'r12_50'});
    expect(await search('12.50'), {'r12_50'});
  });

  test(r'%, _ and \ are literal', () async {
    expect(await search('%'), {'percent'});
    expect(await search('_'), {'underscore'});
    expect(await search(r'\'), {'backslash'});
  });

  test('search combines with other filters', () async {
    expect(await search('12', types: {TxnType.income}), isEmpty);
    expect(await search('12', types: {TxnType.expense}), hasLength(4));
  });

  test('parseSearchAmount accepts at most 2 decimals', () {
    expect(TransactionsDao.parseSearchAmount('12'), 1200);
    expect(TransactionsDao.parseSearchAmount('12.5'), 1250);
    expect(TransactionsDao.parseSearchAmount('0.29'), 29);
    expect(TransactionsDao.parseSearchAmount('12.505'), isNull);
    expect(TransactionsDao.parseSearchAmount('-3'), isNull);
    expect(TransactionsDao.parseSearchAmount('chai'), isNull);
  });
}
