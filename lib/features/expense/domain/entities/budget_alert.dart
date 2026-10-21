import 'package:dailytrack/features/expense/domain/repositories/budget_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_alert.freezed.dart';

/// One budget alert to send (research R6). Carries no amounts or notes, so
/// a notification built from it can't leak them (FR-020).
@freezed
abstract class BudgetAlert with _$BudgetAlert {
  const factory({
    required String budgetId,

    /// `yyyy-MM`; tapping the notification opens EXP-08 for this month.
    required String monthKey,
    required BudgetThreshold threshold,

    /// Whole percent of the limit used.
    required int percent,

    /// Null = Overall.
    String? categoryId,
  }) = _BudgetAlert;
}
