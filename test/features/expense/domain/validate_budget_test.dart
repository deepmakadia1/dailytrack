import 'package:dailytrack/features/expense/domain/usecases/validate_budget.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-09 amount rules (US1 s5, FR-011).
void main() {
  test('missing or zero → amountMissing', () {
    expect(validateBudget(limitMinor: null), {BudgetError.amountMissing});
    expect(validateBudget(limitMinor: 0), {BudgetError.amountMissing});
    expect(validateBudget(limitMinor: -100), {BudgetError.amountMissing});
  });

  test('above ₹99,99,99,999 → amountTooLarge; the maximum is valid', () {
    expect(validateBudget(limitMinor: 99999999901), {
      BudgetError.amountTooLarge,
    });
    expect(validateBudget(limitMinor: 99999999900), isEmpty);
    expect(validateBudget(limitMinor: 1), isEmpty);
  });
}
