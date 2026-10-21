import 'package:freezed_annotation/freezed_annotation.dart';

part 'period_ledger.freezed.dart';

/// Totals for one local day. Transfers are excluded.
@freezed
abstract class DayTotal with _$DayTotal {
  const factory({@Default(0) int incomeMinor, @Default(0) int expenseMinor}) =
      _DayTotal;

  const new _();

  int get netMinor => incomeMinor - expenseMinor;
}

/// Summary strip and day-header totals for every row matching a query
/// (research R4). Transfers are excluded from every total.
@freezed
abstract class PeriodLedger with _$PeriodLedger {
  const factory({
    @Default(0) int incomeMinor,
    @Default(0) int expenseMinor,

    /// Local `yyyy-MM-dd` → totals.
    @Default(<String, DayTotal>{}) Map<String, DayTotal> dayTotals,
  }) = _PeriodLedger;

  const new _();

  int get netMinor => incomeMinor - expenseMinor;
}
