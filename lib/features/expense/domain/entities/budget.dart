import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget.freezed.dart';

/// A monthly spending limit (spec §4 budgets, data-model.md §4). Spent,
/// remaining and progress are derived, never stored.
@freezed
abstract class Budget with _$Budget {
  const factory({
    required String id,

    /// Local month `yyyy-MM`.
    required String monthKey,
    required int limitMinor,

    /// "Repeat every month" (rollover, research R7).
    required bool rollover,

    /// UTC.
    required DateTime createdAt,
    required DateTime updatedAt,

    /// Null = Overall.
    String? categoryId,

    /// UTC moments the 80% and 100% alerts were sent.
    DateTime? alert80SentAt,
    DateTime? alert100SentAt,
  }) = _Budget;

  const new _();

  bool get isOverall => categoryId == null;
}

/// What EXP-09 saves for a new budget.
@freezed
abstract class BudgetDraft with _$BudgetDraft {
  const factory({
    required String monthKey,
    required int limitMinor,
    required bool rollover,

    /// Null = Overall.
    String? categoryId,
  }) = _BudgetDraft;
}
