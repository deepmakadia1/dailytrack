import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v3 constraints on `budgets`, `recurring_rules` and the new
/// transaction foreign key (data-model.md §3, research R3/R4). They are the
/// last line of defense under domain validation.
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

  group('budgets', () {
    var seq = 0;
    Future<void> budget({
      String? categoryId,
      String month = '2026-10',
      int limit = 100000,
      int? alert80,
      int? alert100,
      int? deletedAt,
    }) => db
        .into(db.budgets)
        .insert(
          BudgetsCompanion.insert(
            id: 'b${seq++}',
            categoryId: Value(categoryId),
            monthKey: month,
            limitMinor: limit,
            rollover: true,
            alert80SentAt: Value(alert80),
            alert100SentAt: Value(alert100),
            createdAt: 0,
            updatedAt: 0,
            deletedAt: Value(deletedAt),
          ),
        );

    test('accepts the limit bounds and a valid month key', () async {
      await budget(limit: 1);
      await budget(categoryId: 'c1', limit: 99999999900);
      expect(await db.select(db.budgets).get(), hasLength(2));
    });

    test('rejects a limit of 0 or above ₹99,99,99,999', () async {
      await expectLater(budget(limit: 0), throwsA(isA<SqliteException>()));
      await expectLater(
        budget(limit: 99999999901),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects a malformed month key', () async {
      for (final bad in ['2026-1', '26-10', '2026/10', 'abcd-ef']) {
        await expectLater(
          budget(month: bad),
          throwsA(isA<SqliteException>()),
          reason: bad,
        );
      }
    });

    test('rejects a 100% marker without the 80% marker', () async {
      await expectLater(budget(alert100: 5), throwsA(isA<SqliteException>()));
      await budget(alert80: 5, alert100: 6);
    });

    test('one live Overall and one live category budget per month', () async {
      await budget();
      await budget(categoryId: 'c1');
      await expectLater(budget(), throwsA(isA<SqliteException>()));
      await expectLater(
        budget(categoryId: 'c1'),
        throwsA(isA<SqliteException>()),
      );
      // Other months are separate slots.
      await budget(month: '2026-11');
      await budget(categoryId: 'c1', month: '2026-11');
    });

    test('a soft-deleted budget frees its slot', () async {
      await budget(deletedAt: 1);
      await budget(categoryId: 'c1', deletedAt: 1);
      await budget();
      await budget(categoryId: 'c1');
      expect(await db.select(db.budgets).get(), hasLength(4));
    });
  });

  group('recurring_rules', () {
    var seq = 0;
    Future<String> rule({
      TxnType type = TxnType.expense,
      String? categoryId = 'c1',
      String? toAccountId,
      int interval = 1,
      int anchorAt = 1000,
      int? endAt,
    }) async {
      final id = 'r${seq++}';
      await db
          .into(db.recurringRules)
          .insert(
            RecurringRulesCompanion.insert(
              id: id,
              templateType: type,
              amountMinor: 1500000,
              accountId: 'a1',
              toAccountId: Value(toAccountId),
              categoryId: Value(categoryId),
              paymentMode: PaymentMode.upi,
              frequency: Frequency.monthly,
              interval: Value(interval),
              anchorAt: anchorAt,
              nextRunAt: anchorAt,
              endAt: Value(endAt),
              isActive: true,
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      return id;
    }

    test('accepts an expense rule and a transfer rule', () async {
      await rule();
      await rule(type: TxnType.transfer, categoryId: null, toAccountId: 'a2');
      await rule(endAt: 1000);
      expect(await db.select(db.recurringRules).get(), hasLength(3));
    });

    test('rejects interval 0 and an end before the anchor', () async {
      await expectLater(rule(interval: 0), throwsA(isA<SqliteException>()));
      await expectLater(rule(endAt: 999), throwsA(isA<SqliteException>()));
    });

    test('rejects a transfer without a destination', () async {
      await expectLater(
        rule(type: TxnType.transfer, categoryId: null),
        throwsA(isA<SqliteException>()),
      );
    });

    test('rejects an expense without a category', () async {
      await expectLater(
        rule(categoryId: null),
        throwsA(isA<SqliteException>()),
      );
    });

    test('a transaction must point at an existing rule', () async {
      Future<void> txn(String id, String? ruleId) => db
          .into(db.transactions)
          .insert(
            TransactionsCompanion.insert(
              id: id,
              type: TxnType.expense,
              amountMinor: 100,
              accountId: 'a1',
              categoryId: const Value('c1'),
              paymentMode: PaymentMode.cash,
              occurredAt: 0,
              recurringRuleId: Value(ruleId),
              createdAt: 0,
              updatedAt: 0,
            ),
          );
      await expectLater(txn('t1', 'missing'), throwsA(isA<SqliteException>()));
      await txn('t2', await rule());
      await txn('t3', null);
    });
  });
}
