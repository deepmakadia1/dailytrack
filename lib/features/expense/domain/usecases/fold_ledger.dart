import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// Folds the slim ledger projection into period and per-local-day totals
/// (research R4). Transfers are excluded from every total. Local days come
/// from [toLocal], which defaults to the device time zone; it is injectable
/// so the "Time zone change" edge case is testable.
PeriodLedger foldLedger(
  Iterable<(int occurredAtUtcMs, TxnType type, int amountMinor)> rows, {
  DateTime Function(int utcMs) toLocal = Epoch.toLocal,
}) {
  var income = 0;
  var expense = 0;
  final days = <String, (int, int)>{};

  for (final (occurredAt, type, amount) in rows) {
    if (type == TxnType.transfer) continue;
    final key = DateKeys.fromLocal(toLocal(occurredAt));
    final (dayIncome, dayExpense) = days[key] ?? (0, 0);
    if (type == TxnType.income) {
      income += amount;
      days[key] = (dayIncome + amount, dayExpense);
    } else {
      expense += amount;
      days[key] = (dayIncome, dayExpense + amount);
    }
  }

  return PeriodLedger(
    incomeMinor: income,
    expenseMinor: expense,
    dayTotals: {
      for (final MapEntry(:key, value: (i, e)) in days.entries)
        key: DayTotal(incomeMinor: i, expenseMinor: e),
    },
  );
}
