import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/domain/entities/repeat_settings.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_draft.dart';

/// Recurring rules store (contracts/repositories.md). Deleted rules are
/// excluded everywhere unless stated.
abstract interface class RecurringRuleRepository {
  /// EXP-10: active rules first (by next run), then paused or ended.
  Stream<List<RecurringRuleView>> watchAll();

  /// The rule, deleted or not (EXP-03 says when it was deleted).
  Future<RecurringRule?> findById(String id);

  /// EXP-02 new with Repeat: inserts the transaction (the first occurrence)
  /// and the rule, linked, in one transaction.
  Future<({Transaction txn, RecurringRule rule})> createWithFirstOccurrence(
    TransactionDraft draft,
    RepeatSettings repeat,
  );

  /// EXP-02 edit of an unlinked entry with Repeat on (Q3): updates the
  /// entry, creates the rule, and links them. Throws
  /// `TransactionAlreadyLinked` or `TransactionNotFound`.
  Future<({Transaction txn, RecurringRule rule})> attachNewRule(
    String txnId,
    TransactionDraft draft,
    RepeatSettings repeat,
  );

  /// Undo of either call above: soft-deletes the rule and every row linked
  /// to it. With [restoreSnapshot], that entry is restored and unlinked
  /// instead of deleted.
  Future<void> undoRuleCreation(String ruleId, {Transaction? restoreSnapshot});

  /// Rule-edit save: template and schedule change for future occurrences
  /// only; anchor = [nextDateLocal], next run = first occurrence ≥
  /// max(that, now). Throws `RuleNotFound`.
  Future<RecurringRule> updateRule(
    String id,
    TransactionDraft template,
    RepeatSettings repeat,
    DateTime nextDateLocal,
  );

  /// Undo of [updateRule]: rewrites every field from [snapshot].
  Future<void> restoreRule(RecurringRule snapshot);

  Future<void> pause(String id);

  /// Next run = first occurrence after now; missed ones are skipped (US3
  /// s10).
  Future<void> resume(String id);

  /// Generated rows are kept with their link.
  Future<void> softDelete(String id);

  Future<void> undelete(String id);

  /// Ids of active, live rules with next run ≤ [now].
  Future<List<String>> dueRuleIds(DateTime now);

  /// Research R9: creates every due occurrence of [ruleId] up to [now] and
  /// advances its next run, in one transaction with a compare-and-set.
  /// Returns the created rows (empty when another run got there first).
  Future<List<Transaction>> generateDue(String ruleId, DateTime now);
}
