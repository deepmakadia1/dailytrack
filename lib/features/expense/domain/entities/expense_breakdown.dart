import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense_breakdown.freezed.dart';

/// Expense totals for a query, grouped three ways (feature 003 research
/// R11). Income and transfers are excluded, so each map sums to
/// [totalExpenseMinor], which equals the ledger's expense for the same
/// query. Groups with no spending are absent.
@freezed
abstract class ExpenseBreakdown with _$ExpenseBreakdown {
  const factory({
    /// Category id → paise.
    @Default(<String, int>{}) Map<String, int> byCategory,

    /// Source account id → paise.
    @Default(<String, int>{}) Map<String, int> byAccount,
    @Default(<PaymentMode, int>{}) Map<PaymentMode, int> byPaymentMode,
    @Default(0) int totalExpenseMinor,
  }) = _ExpenseBreakdown;
}

/// Folds `(categoryId, accountId, paymentMode, sum)` groups into an
/// [ExpenseBreakdown]. Pure; shared by the Drift repository and test fakes.
ExpenseBreakdown foldBreakdown(
  Iterable<(String? categoryId, String accountId, PaymentMode mode, int sum)>
  groups,
) {
  final byCategory = <String, int>{};
  final byAccount = <String, int>{};
  final byMode = <PaymentMode, int>{};
  var total = 0;
  for (final (category, account, mode, sum) in groups) {
    if (category != null) {
      byCategory[category] = (byCategory[category] ?? 0) + sum;
    }
    byAccount[account] = (byAccount[account] ?? 0) + sum;
    byMode[mode] = (byMode[mode] ?? 0) + sum;
    total += sum;
  }
  return ExpenseBreakdown(
    byCategory: byCategory,
    byAccount: byAccount,
    byPaymentMode: byMode,
    totalExpenseMinor: total,
  );
}
