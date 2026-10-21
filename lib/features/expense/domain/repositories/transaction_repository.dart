import 'package:dailytrack/features/expense/domain/entities/expense_breakdown.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/entities/today_and_month_spend.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';

/// Transactions store (contracts/repositories.md). Every `watch*` stream
/// re-emits after any write to transactions, categories or accounts.
/// Deleted rows are excluded everywhere unless stated.
abstract interface class TransactionRepository {
  /// Rows matching [query], newest first (occurredAt, createdAt, id DESC),
  /// at most [limit] (research R4).
  Stream<List<TransactionView>> watchPage(TxnQuery query, {required int limit});

  /// The newest [limit] rows of all time, transfers included, in the same
  /// order as [watchPage] (DSH-01 Recent transactions, feature 006 R10).
  Stream<List<TransactionView>> watchRecent({int limit = 5});

  /// Income/expense/net and per-local-day totals for ALL rows matching
  /// [query]; transfers excluded from every total (FR-018).
  Stream<PeriodLedger> watchLedger(TxnQuery query);

  /// Expense totals by category, account and payment mode for ALL rows
  /// matching [query], with the same predicate as [watchLedger], so the
  /// totals always match the EXP-01 summary strip (feature 003 R11).
  Stream<ExpenseBreakdown> watchBreakdown(TxnQuery query);

  /// EXP-03; emits null when the row is missing or deleted.
  Stream<TransactionView?> watchById(String id);

  /// EXP-02 edit and duplicate.
  Future<TransactionView?> findById(String id);

  /// Expenses spent today and this month, in local time (FR-030).
  Stream<TodayAndMonthSpend> watchTodayAndMonthSpend(DateTime nowLocal);

  /// Up to [limit] distinct non-empty notes, most recent first, starting with
  /// [prefix] (case-insensitive).
  Future<List<String>> recentNotes({String prefix = '', int limit = 5});

  /// Account of the most recently created non-deleted transaction whose
  /// account is not archived, or null (research R7).
  Future<String?> lastUsedAccountId();

  /// Every non-null receiptPath, including soft-deleted rows, so a later
  /// restore keeps its file (research R8).
  Future<Set<String>> allReceiptPaths();

  /// The caller validates [draft] first. Id and timestamps are assigned here.
  Future<Transaction> create(TransactionDraft draft);

  /// Throws `TransactionNotFound` if the row is missing or deleted.
  Future<Transaction> update(String id, TransactionDraft draft);

  /// Undo of an edit: rewrites every field from [snapshot] (research R12).
  /// Throws `TransactionNotFound` if the row is missing or deleted.
  Future<void> restore(Transaction snapshot);

  Future<void> softDelete(String id);

  Future<void> undelete(String id);
}
