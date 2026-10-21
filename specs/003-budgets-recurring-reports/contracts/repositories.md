# Contract: Expense domain interfaces and use cases (feature 003)

Pure Dart under `lib/features/expense/domain/`. Implementations live in
`lib/features/expense/data/repositories/drift_*.dart`. They are bound in `expense_bindings.dart`
and exposed by providers in `presentation/expense_providers.dart`, which throw unless overridden
(feature 002 R11). Every `watch*` stream re-emits after any write to the tables it reads. Deleted
rows are excluded unless stated. Storage failures surface as the existing `ExpenseStorageFailure`.

## BudgetRepository (new)

```dart
abstract interface class BudgetRepository {
  /// EXP-08: budgets with live spending for [monthKey] (`yyyy-MM`), built
  /// from watchBreakdown + categories. Re-emits on budget, transaction or
  /// category changes, and when the local day changes (days left).
  Stream<BudgetsOverview> watchOverview(String monthKey);

  Future<Budget?> findById(String id);

  /// Budgets of [monthKey] for the alert check: the category's and Overall.
  Future<({Budget? category, Budget? overall})> forAlert(
    String monthKey, String? categoryId);

  /// Alert check (R6): non-deleted expense total for [monthKey], for
  /// [categoryId] or all categories when null. Same where-builder as
  /// watchBreakdown, so it equals the EXP-08 "spent".
  Future<int> spentFor(String monthKey, String? categoryId);

  /// Create. Throws BudgetSlotTaken if the slot already has a live budget.
  Future<Budget> create(BudgetDraft draft);

  /// Edit limit and rollover (the category is fixed). In the same
  /// transaction, clears alert markers that are no longer reached (Q4).
  Future<Budget> update(String id, {required int limitMinor, required bool rollover});

  Future<void> softDelete(String id);

  /// Undo. Throws BudgetSlotTaken if the slot was filled meanwhile.
  Future<void> undelete(String id);

  /// EXP-08 overflow. Copies live budgets of the month before [monthKey]
  /// into empty slots. Returns the number copied. Never overwrites.
  Future<int> copyPreviousMonth(String monthKey);

  /// App open (R7). No-op if the marker equals [currentMonthKey].
  Future<void> rolloverIfNeeded(String currentMonthKey);

  /// Compare-and-set marker writes (R6). True only if this call set it.
  Future<bool> markAlertSent(String id, BudgetThreshold threshold, int atUtcMs);
}

enum BudgetThreshold { p80, p100 }
final class BudgetSlotTaken implements Exception { ... }
```

## RecurringRuleRepository (new)

```dart
abstract interface class RecurringRuleRepository {
  /// EXP-10: active first (by nextRunAt), then paused or ended.
  Stream<List<RecurringRuleView>> watchAll();

  Future<RecurringRule?> findById(String id);

  /// EXP-02 new with Repeat: inserts the transaction (first occurrence) and
  /// the rule, linked, in one transaction.
  Future<({Transaction txn, RecurringRule rule})> createWithFirstOccurrence(
    TransactionDraft draft, RepeatSettings repeat);

  /// EXP-02 edit of an unlinked entry with Repeat on (Q3): updates the entry,
  /// creates the rule, and links them. Throws TransactionAlreadyLinked.
  Future<({Transaction txn, RecurringRule rule})> attachNewRule(
    String txnId, TransactionDraft draft, RepeatSettings repeat);

  /// Undo of either call above: soft-deletes the rule and every row linked
  /// to it. With [restoreSnapshot], restores that entry and clears its link
  /// instead of deleting it.
  Future<void> undoRuleCreation(String ruleId, {Transaction? restoreSnapshot});

  /// Rule-edit mode save. Template and schedule; anchorAt = [nextDateLocal],
  /// nextRunAt = first occurrence ≥ max(that, now). Future occurrences only.
  Future<RecurringRule> updateRule(
    String id, TransactionDraft template, RepeatSettings repeat, DateTime nextDateLocal);

  /// Undo of updateRule (rule-edit "Saved · Undo"): rewrites every field
  /// from [snapshot].
  Future<void> restoreRule(RecurringRule snapshot);

  Future<void> pause(String id);

  /// nextRunAt = first occurrence after now. Missed occurrences are skipped.
  Future<void> resume(String id);

  Future<void> softDelete(String id);   // generated rows are kept
  Future<void> undelete(String id);

  /// Ids of active, live rules with nextRunAt ≤ [now].
  Future<List<String>> dueRuleIds(DateTime now);

  /// R9: one transaction per rule, with a compare-and-set on next_run_at.
  /// Returns the created rows (empty if another run got there first).
  Future<List<Transaction>> generateDue(String ruleId, DateTime now);
}
```

## TransactionRepository (changed)

- **New** `Stream<ExpenseBreakdown> watchBreakdown(TxnQuery query)`: expense totals by category,
  account, and payment mode, using the same predicate as `watchLedger` (R11).
- `TransactionView.isRecurring` is filled in from `recurringRuleId`.
- `update` keeps `recurringRuleId` unchanged. Linking happens only through
  `RecurringRuleRepository`.

## Ports (new, domain interfaces)

```dart
/// Sends one budget alert. Implemented in data with NotificationService
/// and ARB text (R6).
abstract interface class BudgetAlertNotifier {
  Future<void> notify(BudgetAlert alert);
  Future<void> cancelAll();          // ExpenseModule.onDisable
}

/// Whether a budget notification may be shown now (FR-018).
abstract interface class NotificationGate {
  Future<bool> budgetAlertsAllowed(); // master && budgetAlerts && OS permission
}
```

## Use cases

| Use case | File | Contract |
| --- | --- | --- |
| `budget_math` | `usecases/budget_math.dart` | pure functions of R5: `levelFor`, `percentOf`, `daysLeftInclusive`, `perDayLeft`, `monthPhase`, `monthKeyOf(DateTime)`, `monthRangeUtc(monthKey)` |
| `validateBudget` | `usecases/validate_budget.dart` | `Set<BudgetError>`: amountMissing, amountTooLarge, slotTaken |
| `BudgetAlertChecker` | `usecases/check_budget_alerts.dart` | `Future<List<BudgetAlert>> check({occurredAtUtcMs, categoryId, type})`. Never throws (errors are swallowed and reported as an empty list) |
| `RecurrenceSchedule` | `usecases/recurrence.dart` | R8: `occurrence(n)`, `indexAtOrAfter(t)`, `firstAfter(t)`, `describe()` |
| `RecurringGenerator` | `usecases/generate_recurring.dart` | `Future<int> runDue()`: for each due rule, `generateDue`, then alert checks for current-month expenses. Returns the number created. Never throws for a single bad rule (logs it and goes on) |
| `ReportAccess` | `usecases/report_access.dart` | `bool requiresAdvanced(ReportTab tab, Period period, DateTime now)`, the Q1 matrix below |
| `validateTransaction` (changed) | existing | adds `RepeatSettings?` → `repeatEndBeforeStart` |

**ReportAccess matrix** (clarification Q1; `now` = local today):

| Period | Overview / Categories | Trends / Accounts |
| --- | --- | --- |
| Month = current or previous | free | advanced |
| Month older than previous, or any future month | advanced | advanced |
| Week overlapping [start of previous month, end of current month] | free | advanced |
| Any other week | advanced | advanced |
| Year, Custom | advanced | advanced |
| Day (not offered in EXP-11) | n/a | n/a |

Future months and weeks are never free; there is nothing to report yet.

## Errors (additions to `domain/errors.dart`)

`BudgetSlotTaken`, `BudgetNotFound`, `RuleNotFound`, `TransactionAlreadyLinked`,
`RuleChangedConcurrently` (internal to data, never reaches presentation).
