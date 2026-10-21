import 'package:freezed_annotation/freezed_annotation.dart';

part 'today_and_month_spend.freezed.dart';

/// Home Expense card values (FR-030). Expenses only.
@freezed
abstract class TodayAndMonthSpend with _$TodayAndMonthSpend {
  const factory({
    required int todayMinor,
    required int monthMinor,
    required bool hasAnyTransaction,
  }) = _TodayAndMonthSpend;
}
