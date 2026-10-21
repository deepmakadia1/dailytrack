import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';

/// The two alert thresholds (FR-016).
enum BudgetThreshold { p80, p100 }

/// Budgets store (contracts/repositories.md "BudgetRepository"). Deleted
/// budgets are excluded everywhere unless stated.
abstract interface class BudgetRepository {
  /// EXP-08: budgets with live spending for [monthKey] (`yyyy-MM`). Re-emits
  /// on budget, transaction or category changes, and when the local day
  /// changes (days left).
  Stream<BudgetsOverview> watchOverview(String monthKey);

  Future<Budget?> findById(String id);

  /// Budgets of [monthKey] for the alert check: the category's and Overall.
  Future<({Budget? category, Budget? overall})> forAlert(
    String monthKey,
    String? categoryId,
  );

  /// Alert check (R6): non-deleted expense total for [monthKey], for
  /// [categoryId] or all categories when null. Equals the EXP-08 "spent".
  Future<int> spentFor(String monthKey, String? categoryId);

  /// Throws `BudgetSlotTaken` if the slot already has a live budget.
  Future<Budget> create(BudgetDraft draft);

  /// Edits limit and rollover (the category is fixed). In the same
  /// transaction, clears alert markers no longer reached (clarification Q4).
  /// Throws `BudgetNotFound`.
  Future<Budget> update(
    String id, {
    required int limitMinor,
    required bool rollover,
  });

  Future<void> softDelete(String id);

  /// Undo. Throws `BudgetSlotTaken` if the slot was filled meanwhile.
  Future<void> undelete(String id);

  /// EXP-08 overflow: copies the live budgets of the month before
  /// [monthKey] into empty slots, skipping hidden or deleted categories.
  /// Returns the number copied. Never overwrites.
  Future<int> copyPreviousMonth(String monthKey);

  /// App open (R7): once per month, copies the repeating budgets of the
  /// latest earlier month with budgets into [currentMonthKey]'s empty slots.
  Future<void> rolloverIfNeeded(String currentMonthKey);

  /// Compare-and-set marker write (R6). True only if this call set it. The
  /// 100% marker also sets the 80% one when it is missing.
  Future<bool> markAlertSent(String id, BudgetThreshold threshold, int atUtcMs);
}
