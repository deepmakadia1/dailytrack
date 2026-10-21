import 'package:dailytrack/features/expense/domain/entities/budget.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_status.freezed.dart';

/// Progress level of a budget (research R5): under 80%, 80–100%, over
/// 100%. Exactly 80% and exactly 100% count as reached.
enum BudgetLevel { under, warning, over }

/// Where a month lies relative to today.
enum MonthPhase { past, current, future }

/// One budget with its derived spending (data-model.md §4). All money is
/// whole paise.
@freezed
abstract class BudgetStatus with _$BudgetStatus {
  const factory({
    required Budget budget,
    required int spentMinor,

    /// limit − spent; negative when over budget.
    required int remainingMinor,

    /// Whole percent of the limit used; may exceed 100.
    required int percent,
    required BudgetLevel level,
    required MonthPhase monthPhase,

    /// Null for Overall, or when the category no longer exists.
    Category? category,

    /// The category is hidden or deleted (edge case: still shown, marked).
    @Default(false) bool categoryHidden,

    /// Days from today to the month's last day, both included (current
    /// month), or all days (future month); null for a past month.
    int? daysLeft,

    /// remaining ÷ daysLeft rounded down; null when nothing is left or for a
    /// past month.
    int? perDayLeftMinor,
  }) = _BudgetStatus;
}

/// EXP-08 content for one month.
@freezed
abstract class BudgetsOverview with _$BudgetsOverview {
  const factory({
    required String monthKey,
    required MonthPhase monthPhase,
    BudgetStatus? overall,

    /// Category budgets, highest percent first.
    @Default(<BudgetStatus>[]) List<BudgetStatus> categories,

    /// Non-hidden expense categories with no budget this month.
    @Default(<Category>[]) List<Category> withoutBudget,
  }) = _BudgetsOverview;

  const new _();

  bool get isEmpty => overall == null && categories.isEmpty;
}
