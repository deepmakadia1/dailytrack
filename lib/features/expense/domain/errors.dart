// Typed failures of the Expense domain (contracts/repositories.md).

/// Any storage failure. Screens show their error state, or keep a form open.
final class ExpenseStorageFailure implements Exception {
  const new([this.cause]);

  final Object? cause;

  @override
  String toString() => 'ExpenseStorageFailure($cause)';
}

/// Update or restore of a missing or deleted transaction.
final class TransactionNotFound implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'TransactionNotFound($id)';
}

enum CategoryDeleteReason { isDefault, replacementRequired, invalidReplacement }

final class CategoryDeleteNotAllowed implements Exception {
  const new(this.reason);

  final CategoryDeleteReason reason;

  @override
  String toString() => 'CategoryDeleteNotAllowed(${reason.name})';
}

enum AccountDeleteReason { hasTransactions, lastActive }

final class AccountDeleteNotAllowed implements Exception {
  const new(this.reason);

  final AccountDeleteReason reason;

  @override
  String toString() => 'AccountDeleteNotAllowed(${reason.name})';
}

/// Archiving would leave no active account (clarification Q3).
final class AccountArchiveNotAllowed implements Exception {
  const new();

  @override
  String toString() => 'AccountArchiveNotAllowed(lastActive)';
}

/// Picking, compressing or writing a receipt failed.
final class ReceiptFailure implements Exception {
  const new([this.cause]);

  final Object? cause;

  @override
  String toString() => 'ReceiptFailure($cause)';
}

/// The category (or Overall) already has a live budget that month (R4).
final class BudgetSlotTaken implements Exception {
  const new();

  @override
  String toString() => 'BudgetSlotTaken';
}

/// Update of a missing or deleted budget.
final class BudgetNotFound implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'BudgetNotFound($id)';
}

/// Rule-edit or a rule action on a missing or deleted rule.
final class RuleNotFound implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'RuleNotFound($id)';
}

/// Repeat was turned on for an entry that already belongs to a rule (Q3).
final class TransactionAlreadyLinked implements Exception {
  const new(this.id);

  final String id;

  @override
  String toString() => 'TransactionAlreadyLinked($id)';
}
