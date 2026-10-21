import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/data/daos/transactions_dao.dart';
import 'package:dailytrack/features/expense/data/mappers/transaction_mapper.dart';
import 'package:dailytrack/features/expense/data/repositories/storage_guard.dart';
import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/today_and_month_spend.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/repositories/transaction_repository.dart';
import 'package:dailytrack/features/expense/domain/usecases/fold_ledger.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Drift implementation of [TransactionRepository] (research R4, R5, R7, R12).
final class DriftTransactionRepository implements TransactionRepository {
  new(AppDatabase db, this._clock) : _db = db, _dao = TransactionsDao(db);

  final AppDatabase _db;
  final TransactionsDao _dao;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  int _nowMs() => _clock.now().toUtc().millisecondsSinceEpoch;

  @override
  Stream<List<TransactionView>> watchPage(
    TxnQuery query, {
    required int limit,
  }) => _dao
      .watchPage(query, limit)
      .map((rows) => [for (final r in rows) r.toView()])
      .guardStorage();

  @override
  Stream<List<TransactionView>> watchRecent({int limit = 5}) => _dao
      .watchRecent(limit)
      .map((rows) => [for (final r in rows) r.toView()])
      .guardStorage();

  @override
  Stream<PeriodLedger> watchLedger(TxnQuery query) =>
      _dao.watchLedgerRows(query).map(foldLedger).guardStorage();

  @override
  Stream<ExpenseBreakdown> watchBreakdown(TxnQuery query) =>
      _dao.watchExpenseGroups(query).map(foldBreakdown).guardStorage();

  @override
  Stream<TransactionView?> watchById(String id) =>
      _dao.watchById(id).map((r) => r?.toView()).guardStorage();

  @override
  Future<TransactionView?> findById(String id) =>
      guardStorage(() async => (await _dao.findById(id))?.toView());

  @override
  Stream<TodayAndMonthSpend> watchTodayAndMonthSpend(DateTime nowLocal) {
    final day = SingleDayPeriod(nowLocal);
    final month = MonthPeriod(nowLocal);
    return _dao
        .watchSpend(
          dayStart: day.startUtcMs,
          dayEnd: day.endUtcMsExclusive,
          monthStart: month.startUtcMs,
          monthEnd: month.endUtcMsExclusive,
        )
        .map(
          (s) => TodayAndMonthSpend(
            todayMinor: s.today,
            monthMinor: s.month,
            hasAnyTransaction: s.count > 0,
          ),
        )
        .guardStorage();
  }

  @override
  Future<List<String>> recentNotes({String prefix = '', int limit = 5}) =>
      guardStorage(() => _dao.recentNotes(prefix.trim(), limit));

  @override
  Future<String?> lastUsedAccountId() => guardStorage(_dao.lastUsedAccountId);

  @override
  Future<Set<String>> allReceiptPaths() => guardStorage(_dao.allReceiptPaths);

  @override
  Future<Transaction> create(TransactionDraft draft) => guardStorage(() async {
    final id = _uuid.v4();
    final now = _nowMs();
    await _dao.insertRow(
      draft
          .toCompanion(updatedAt: now)
          .copyWith(id: Value(id), createdAt: Value(now)),
    );
    return (await _dao.rawById(id))!.toEntity();
  });

  @override
  Future<Transaction> update(String id, TransactionDraft draft) => guardStorage(
    () => _db.transaction(() async {
      final changed = await _dao.updateActive(
        id,
        draft.toCompanion(updatedAt: _nowMs()),
      );
      if (changed == 0) throw TransactionNotFound(id);
      return (await _dao.rawById(id))!.toEntity();
    }),
  );

  @override
  Future<void> restore(Transaction snapshot) => guardStorage(() async {
    final changed = await _dao.updateActive(
      snapshot.id,
      snapshot.toCompanion(),
    );
    if (changed == 0) throw TransactionNotFound(snapshot.id);
  });

  @override
  Future<void> softDelete(String id) =>
      guardStorage(() => _dao.setDeletedAt(id, _nowMs()));

  @override
  Future<void> undelete(String id) =>
      guardStorage(() => _dao.setDeletedAt(id, null));
}
