import 'dart:async';

import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/reset/data/drift_app_reset_service.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/backup/expense_backup_section.dart';
import 'package:dailytrack/features/expense/data/dev/large_data_seeder.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import 'expense_db_fixture.dart';

/// Dev-only "Seed 10,000 transactions" (feature 012 T035, contracts/
/// dev-seed.md "Seeder", data-model §5), over a real in-memory database.
void main() {
  late ExpenseDb x;
  late LargeDataSeeder seeder;
  late BackupCoordinator coordinator;
  late List<double> progress;

  setUp(() async {
    x = await ExpenseDb.open(seedDefaults: true);
    // A second account, so transfers can happen.
    await x.account('SBI', type: AccountType.bank);
    coordinator = BackupCoordinator(x.db, x.clock);
    seeder = LargeDataSeeder(x.db, x.clock, coordinator);
    progress = [];
  });

  Future<List<TransactionRow>> all() => x.db.select(x.db.transactions).get();

  Future<int> changeCounter() async => (await SettingsRepositoryImpl(
    x.db,
    knownModuleIds: const ['expense', 'habit'],
  ).load()).dataChangeCounter;

  test('adds exactly 10,000 ordinary transactions in 20 chunks, with '
      'progress after each', () async {
    final result = await seeder.seed(onProgress: progress.add);
    expect(result, isA<DevActionDone>());
    expect((result as DevActionDone).count, 10000);
    expect(await all(), hasLength(10000));
    expect(progress, hasLength(20));
    expect(progress.last, 1.0);
    for (var i = 1; i < progress.length; i++) {
      expect(progress[i], greaterThan(progress[i - 1]));
    }
  });

  test('the type mix is 80% expense, 15% income, 5% transfer (±2%); every '
      'amount is an int in [₹10, ₹50,000] paise; dates fall within the '
      'past 365 days', () async {
    await seeder.seed(onProgress: progress.add);
    final rows = await all();
    double share(TxnType t) =>
        rows.where((r) => r.type == t).length / rows.length;
    expect(share(TxnType.expense), closeTo(0.80, 0.02));
    expect(share(TxnType.income), closeTo(0.15, 0.02));
    expect(share(TxnType.transfer), closeTo(0.05, 0.02));

    final nowMs = x.clock.now().toUtc().millisecondsSinceEpoch;
    const yearMs = 365 * Duration.millisecondsPerDay;
    for (final r in rows) {
      expect(r.amountMinor, inInclusiveRange(1000, 5000000));
      expect(r.occurredAt, inInclusiveRange(nowMs - yearMs, nowMs));
      expect(r.deletedAt, isNull);
      expect(r.receiptPath, isNull);
    }
  });

  test('transfers use two distinct non-archived accounts and no category; '
      'expenses and income use a non-hidden category of their type; every '
      '4th row has a note', () async {
    final hidden = await x.category('Hidden');
    await (x.db.update(x.db.categories)..where((c) => c.id.equals(hidden)))
        .write(const CategoriesCompanion(isArchived: Value(true)));
    await seeder.seed(onProgress: progress.add);

    final accounts = {
      for (final a in await (x.db.select(
        x.db.accounts,
      )..where((a) => a.isArchived.equals(false))).get())
        a.id,
    };
    final categoryType = {
      for (final c in await x.db.select(x.db.categories).get()) c.id: c,
    };
    final rows = await all();
    var notes = 0;
    for (final r in rows) {
      expect(accounts, contains(r.accountId));
      if (r.note != null) notes++;
      switch (r.type) {
        case TxnType.transfer:
          expect(r.categoryId, isNull);
          expect(accounts, contains(r.toAccountId));
          expect(r.toAccountId, isNot(r.accountId));
        case TxnType.expense || TxnType.income:
          final c = categoryType[r.categoryId]!;
          expect(c.isArchived, isFalse);
          expect(
            c.type,
            r.type == TxnType.expense
                ? CategoryType.expense
                : CategoryType.income,
          );
          expect(r.toAccountId, isNull);
      }
    }
    expect(notes, 2500);
  });

  test('the same seed gives the same rows', () async {
    Future<List<(TxnType, int, int, String, String?)>> shape() async => [
      for (final r in await (x.db.select(
        x.db.transactions,
      )..orderBy([(t) => OrderingTerm(expression: t.rowId)])).get())
        (r.type, r.amountMinor, r.occurredAt, r.accountId, r.categoryId),
    ];
    await seeder.seed(onProgress: (_) {}, count: 500);
    final first = await shape();
    await x.db.delete(x.db.transactions).go();
    await seeder.seed(onProgress: (_) {}, count: 500);
    expect(await shape(), first);
  });

  test('a second run adds another 10,000 and never deletes data; the change '
      'counter goes up, as for any write', () async {
    final before = await changeCounter();
    await seeder.seed(onProgress: (_) {});
    expect(await changeCounter(), greaterThan(before));
    await seeder.seed(onProgress: (_) {});
    expect(await all(), hasLength(20000));
  });

  test('no budget alert fires: apart from the change counter, no settings '
      'row (alert markers, interstitial counters) is written', () async {
    await x.db
        .into(x.db.budgets)
        .insert(
          BudgetsCompanion.insert(
            id: 'b1',
            monthKey: '2026-10',
            limitMinor: 100,
            rollover: false,
            createdAt: 0,
            updatedAt: 0,
          ),
        );
    Future<Set<String>> keys() async => {
      for (final r in await x.db.select(x.db.settings).get()) r.key,
    };
    final before = await keys();
    await seeder.seed(onProgress: (_) {});
    expect(
      (await keys()).difference(before),
      everyElement(anyOf('dataChangeCounter', BackupCoordinator.leaseKey)),
    );
  });

  test('seeded rows are in the backup and the export (spec FR-014)', () async {
    await seeder.seed(onProgress: (_) {});
    const section = ExpenseBackupSection();
    final backup = await section.export(x.db);
    expect(section.counts(backup)['transactions'], 10000);

    await x.db.delete(x.db.transactions).go();
    await section.restore(x.db, backup);
    expect(await all(), hasLength(10000));

    final now = x.clock.now();
    final exported = await x.transactions.listForExport(
      TxnQuery(
        period: CustomPeriod(now.subtract(const Duration(days: 366)), now),
      ),
    );
    expect(exported, hasLength(10000));
  });

  test('Erase all data removes the seeded rows', () async {
    await seeder.seed(onProgress: (_) {});
    await DriftAppResetService(
      db: x.db,
      modules: const [],
      read: <T>(_) => throw UnimplementedError(),
      notifications: FakeNotificationService(),
      resetLock: () async {},
      afterErase: () {},
    ).eraseAll();
    expect(await all(), isEmpty);
  });

  test('while a backup or restore holds the lease, it returns busy and adds '
      'nothing; afterwards the lease is released', () async {
    final gate = Completer<void>();
    final backup = coordinator.run(() => gate.future);
    expect(await seeder.seed(onProgress: progress.add), isA<DevActionBusy>());
    expect(await all(), isEmpty);
    expect(progress, isEmpty);
    gate.complete();
    await backup;

    expect(
      await seeder.seed(onProgress: (_) {}, count: 10),
      isA<DevActionDone>(),
    );
    final lease =
        await (x.db.select(x.db.settings)
              ..where((s) => s.key.equals(BackupCoordinator.leaseKey)))
            .getSingleOrNull();
    final until = lease == null ? 0 : int.parse(lease.value);
    expect(
      until,
      lessThanOrEqualTo(x.clock.now().toUtc().millisecondsSinceEpoch),
    );
  });
}
