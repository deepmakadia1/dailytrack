import 'package:dailytrack/features/expense/domain/usecases/amount_entry.dart';

/// EXP-09 validation errors (contracts/repositories.md). [slotTaken] comes
/// from the repository's `BudgetSlotTaken`, not from [validateBudget].
enum BudgetError { amountMissing, amountTooLarge, slotTaken }

/// A budget limit must be more than 0 and at most ₹99,99,99,999 (FR-011).
Set<BudgetError> validateBudget({required int? limitMinor}) {
  if (limitMinor == null || limitMinor <= 0) return {BudgetError.amountMissing};
  if (limitMinor > AmountEntry.maxMinor) return {BudgetError.amountTooLarge};
  return const {};
}
