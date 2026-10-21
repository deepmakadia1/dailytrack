import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seed_runner.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_account_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_category_repository.dart';
import 'package:dailytrack/features/expense/data/repositories/drift_transaction_repository.dart';
import 'package:dailytrack/features/expense/data/seed/expense_defaults_seeder.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';

/// A real in-memory database with the three Drift repositories, for UNIT
/// tests only (never widget tests). The clock starts at 2026-10-14 10:00
/// local and moves one second per [add], so `createdAt` never ties.
final class ExpenseDb {
  new _(this.db, this.clock)
    : transactions = DriftTransactionRepository(db, clock),
      categories = DriftCategoryRepository(db, clock),
      accounts = DriftAccountRepository(db, clock);

  final AppDatabase db;
  final MutableClock clock;
  final DriftTransactionRepository transactions;
  final DriftCategoryRepository categories;
  final DriftAccountRepository accounts;

  static Future<ExpenseDb> open({bool seedDefaults = false}) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    if (seedDefaults) {
      await SeedRunner(db).runAll(const [ExpenseDefaultsSeeder()]);
    }
    return ExpenseDb._(db, MutableClock(DateTime(2026, 10, 14, 10)));
  }

  Future<String> account(
    String name, {
    AccountType type = AccountType.cash,
    int opening = 0,
  }) async => (await accounts.create(
    name: name,
    type: type,
    openingBalanceMinor: opening,
    iconKey: 'wallet',
    colorHex: '#0F766E',
  )).id;

  Future<String> category(
    String name, {
    CategoryType type = CategoryType.expense,
  }) async => (await categories.create(
    name: name,
    type: type,
    iconKey: 'category',
    colorHex: '#0F766E',
  )).id;

  /// The id of the seeded default category with ARB key [key].
  Future<String> defaultCategory(String key) async => (await (db.select(
    db.categories,
  )..where((c) => c.name.equals(key))).getSingle()).id;

  Future<Transaction> add({
    required String account,
    required int amount,
    TxnType type = TxnType.expense,
    String? category,
    String? toAccount,
    PaymentMode mode = PaymentMode.cash,
    String note = '',
    DateTime? at,
    String? receipt,
  }) {
    clock.advance(const Duration(seconds: 1));
    return transactions.create(
      TransactionDraft(
        type: type,
        amountMinor: amount,
        accountId: account,
        toAccountId: toAccount,
        categoryId: category,
        paymentMode: mode,
        note: note,
        occurredAt: (at ?? DateTime(2026, 10, 14, 9)).toUtc(),
        receiptPath: receipt,
      ),
    );
  }
}
