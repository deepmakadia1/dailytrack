import 'dart:math';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Dev-only "Seed 10,000 transactions" (feature 012 T040, data-model §5,
/// research R11). Adds ordinary transactions for the §13 performance pass:
/// 80% expenses, 15% income, 5% transfers, spread over the past year and
/// the existing accounts and categories. Rows are inserted in chunks, each
/// in its own transaction, so the UI stays responsive and an interrupted run
/// leaves only whole chunks. It writes rows directly, never through the save
/// use case, so no budget alert, notification, or interstitial counter
/// fires. The database triggers raise `dataChangeCounter` as for any write.
final class LargeDataSeeder {
  const new(this._db, this._clock, this._coordinator);

  final AppDatabase _db;
  final Clock _clock;
  final BackupCoordinator _coordinator;

  static const int chunkSize = 500;
  static const Uuid _uuid = Uuid();

  /// Fixed seed, so every run makes the same data.
  static const int randomSeed = 42;

  static const List<String> _notes = [
    'Lunch',
    'Groceries',
    'Auto fare',
    'Coffee',
    'Medicine',
    'Recharge',
    'Movie',
    'Snacks',
  ];

  /// Adds [count] transactions on top of what is there. Runs under the
  /// backup lease, so it never overlaps a backup or restore: if one holds
  /// the lease, returns [DevActionBusy] and writes nothing.
  Future<DevActionResult> seed({
    required void Function(double fraction) onProgress,
    int count = 10000,
  }) async {
    try {
      return await _coordinator.run(() => _seed(count, onProgress));
    } on BackupBusy {
      return const DevActionBusy();
    }
  }

  Future<DevActionResult> _seed(
    int count,
    void Function(double fraction) onProgress,
  ) async {
    final accounts =
        await (_db.select(_db.accounts)
              ..where((a) => a.isArchived.equals(false) & a.deletedAt.isNull()))
            .map((a) => a.id)
            .get();
    final categories = await (_db.select(
      _db.categories,
    )..where((c) => c.isArchived.equals(false) & c.deletedAt.isNull())).get();
    final expense = [
      for (final c in categories)
        if (c.type == CategoryType.expense) c.id,
    ];
    final income = [
      for (final c in categories)
        if (c.type == CategoryType.income) c.id,
    ];
    if (accounts.isEmpty || expense.isEmpty || income.isEmpty) {
      return const DevActionDone(0);
    }

    final random = Random(randomSeed);
    final nowMs = _clock.now().toUtc().millisecondsSinceEpoch;
    const yearMs = 365 * Duration.millisecondsPerDay;
    final chunks = (count / chunkSize).ceil();
    var made = 0;
    for (var chunk = 0; chunk < chunks; chunk++) {
      final rows = <TransactionsCompanion>[];
      for (var i = 0; i < chunkSize && made < count; i++, made++) {
        final roll = random.nextDouble();
        // A transfer needs two accounts; with one, it becomes an expense.
        final type = roll < 0.80
            ? TxnType.expense
            : roll < 0.95
            ? TxnType.income
            : accounts.length > 1
            ? TxnType.transfer
            : TxnType.expense;
        final from = accounts[random.nextInt(accounts.length)];
        String? to;
        if (type == TxnType.transfer) {
          final others = [
            for (final a in accounts)
              if (a != from) a,
          ];
          to = others[random.nextInt(others.length)];
        }
        final category = switch (type) {
          TxnType.expense => expense[random.nextInt(expense.length)],
          TxnType.income => income[random.nextInt(income.length)],
          TxnType.transfer => null,
        };
        rows.add(
          TransactionsCompanion.insert(
            id: _uuid.v4(),
            type: type,
            amountMinor: _amount(random),
            accountId: from,
            toAccountId: Value(to),
            categoryId: Value(category),
            paymentMode:
                PaymentMode.values[random.nextInt(PaymentMode.values.length)],
            note: Value(
              made % 4 == 0 ? _notes[made ~/ 4 % _notes.length] : null,
            ),
            occurredAt: nowMs - (random.nextDouble() * yearMs).round(),
            createdAt: nowMs,
            updatedAt: nowMs,
          ),
        );
      }
      await _db.transaction(
        () => _db.batch((b) => b.insertAll(_db.transactions, rows)),
      );
      onProgress((chunk + 1) / chunks);
    }
    return DevActionDone(made);
  }

  /// Log-normal around ₹500, clamped to ₹10–₹50,000, in paise.
  static int _amount(Random random) {
    // Box–Muller: a standard normal from two uniforms.
    final u1 = 1 - random.nextDouble();
    final u2 = random.nextDouble();
    final z = sqrt(-2 * log(u1)) * cos(2 * pi * u2);
    final paise = exp(log(50000) + 1.2 * z).round();
    return paise.clamp(1000, 5000000);
  }
}
