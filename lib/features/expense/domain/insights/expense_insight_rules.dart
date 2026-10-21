import 'package:clock/clock.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

// Expense insight rules for the Home insight card (DSH-01, research R8).
// Pure functions of plain inputs and the injected clock. Money is whole
// paise and every percentage is integer math (Constitution III).

/// What the rules read. The source fills it from the breakdowns of
/// [ExpenseInsightRules.periods] and the current month's budgets overview.
final class ExpenseInsightInputs {
  const new({
    required this.thisMonthByCategory,
    required this.lastMonthSameDaysByCategory,
    this.overall,
  });

  /// Expense paise per category id, from the 1st through today.
  final Map<String, int> thisMonthByCategory;

  /// Expense paise per category id, from the 1st of last month through the
  /// same day-of-month, capped at last month's length.
  final Map<String, int> lastMonthSameDaysByCategory;

  /// The Overall budget of the current month, if one is set.
  final BudgetStatus? overall;
}

/// One applicable expense rule, before localization.
sealed class ExpenseInsightFact {
  const new();

  /// The rule that produced this fact (one of [ExpenseInsightRules.ruleIds]).
  String get ruleId;
}

/// `expense.categoryVsLastMonth`: [categoryId] spent [percent] more
/// ([higher]) or less than the same days last month.
@immutable
final class CategoryChange extends ExpenseInsightFact {
  const new({
    required this.categoryId,
    required this.percent,
    required this.higher,
  });

  final String categoryId;

  /// Whole percent of change, always positive; [higher] gives the
  /// direction.
  final int percent;
  final bool higher;

  @override
  String get ruleId => ExpenseInsightRules.categoryVsLastMonth;

  @override
  bool operator ==(Object other) =>
      other is CategoryChange &&
      other.categoryId == categoryId &&
      other.percent == percent &&
      other.higher == higher;

  @override
  int get hashCode => Object.hash(categoryId, percent, higher);

  @override
  String toString() => 'CategoryChange($categoryId, $percent, higher: $higher)';
}

/// `expense.budgetOnTrack`: [remainingMinor] left for [daysLeft] days,
/// today included.
@immutable
final class BudgetOnTrack extends ExpenseInsightFact {
  const new({required this.remainingMinor, required this.daysLeft});

  final int remainingMinor;
  final int daysLeft;

  @override
  String get ruleId => ExpenseInsightRules.budgetOnTrack;

  @override
  bool operator ==(Object other) =>
      other is BudgetOnTrack &&
      other.remainingMinor == remainingMinor &&
      other.daysLeft == daysLeft;

  @override
  int get hashCode => Object.hash(remainingMinor, daysLeft);

  @override
  String toString() => 'BudgetOnTrack($remainingMinor, $daysLeft)';
}

/// `expense.budgetNearLimit` at 80–100% of the Overall budget.
@immutable
final class BudgetNearLimit extends ExpenseInsightFact {
  const new({required this.percentUsed});

  /// Whole percent used, rounded down.
  final int percentUsed;

  @override
  String get ruleId => ExpenseInsightRules.budgetNearLimit;

  @override
  bool operator ==(Object other) =>
      other is BudgetNearLimit && other.percentUsed == percentUsed;

  @override
  int get hashCode => percentUsed.hashCode;

  @override
  String toString() => 'BudgetNearLimit($percentUsed)';
}

/// `expense.budgetNearLimit` above 100%: [overMinor] over the limit.
@immutable
final class BudgetOver extends ExpenseInsightFact {
  const new({required this.overMinor});

  final int overMinor;

  @override
  String get ruleId => ExpenseInsightRules.budgetNearLimit;

  @override
  bool operator ==(Object other) =>
      other is BudgetOver && other.overMinor == overMinor;

  @override
  int get hashCode => overMinor.hashCode;

  @override
  String toString() => 'BudgetOver($overMinor)';
}

/// Local days the category comparison covers, both ends included.
typedef ExpenseInsightPeriods = ({
  DateTime thisMonthFrom,
  DateTime thisMonthTo,
  DateTime lastMonthFrom,
  DateTime lastMonthTo,
});

/// The Expense module's insight rules (research R8).
final class ExpenseInsightRules {
  const new(this._clock);

  final Clock _clock;

  static const String categoryVsLastMonth = 'expense.categoryVsLastMonth';
  static const String budgetOnTrack = 'expense.budgetOnTrack';
  static const String budgetNearLimit = 'expense.budgetNearLimit';

  /// Rotation order. Stable across releases.
  static const List<String> ruleIds = [
    categoryVsLastMonth,
    budgetOnTrack,
    budgetNearLimit,
  ];

  /// Smallest change, in whole percent, that `categoryVsLastMonth` reports.
  static const int minChangePercent = 20;

  /// The larger of the two periods must reach ₹200.
  static const int minLargerMinor = 20000;

  /// This month from the 1st through today, and last month from the 1st
  /// through the same day-of-month, capped at last month's length (31 March
  /// compares with 28 or 29 February).
  ExpenseInsightPeriods periods() {
    final now = _clock.now();
    final lastMonthDays = DateTime(now.year, now.month, 0).day;
    final sameDay = now.day < lastMonthDays ? now.day : lastMonthDays;
    return (
      thisMonthFrom: DateTime(now.year, now.month),
      thisMonthTo: DateTime(now.year, now.month, now.day),
      lastMonthFrom: DateTime(now.year, now.month - 1),
      lastMonthTo: DateTime(now.year, now.month - 1, sameDay),
    );
  }

  /// The applicable facts, at most one per rule, in [ruleIds] order.
  List<ExpenseInsightFact> evaluate(ExpenseInsightInputs inputs) {
    final now = _clock.now();
    final overall = _currentOverall(inputs.overall, now);
    return [
      ?_categoryChange(inputs),
      if (overall != null) ...[?_onTrack(overall, now), ?_nearLimit(overall)],
    ];
  }

  /// The largest percent change of any category; an equal percent goes to
  /// the larger amount change, then to the first category.
  static CategoryChange? _categoryChange(ExpenseInsightInputs inputs) {
    ({String id, int percent, int amount})? best;
    for (final MapEntry(key: id, value: current)
        in inputs.thisMonthByCategory.entries) {
      final before = inputs.lastMonthSameDaysByCategory[id] ?? 0;
      if (current <= 0 || before <= 0) continue;
      if ((current > before ? current : before) < minLargerMinor) continue;
      final percent = ((current - before) * 100 ~/ before).abs();
      if (percent < minChangePercent) continue;
      final amount = (current - before).abs();
      if (best == null ||
          percent > best.percent ||
          (percent == best.percent && amount > best.amount)) {
        best = (id: id, percent: percent, amount: amount);
      }
    }
    if (best == null) return null;
    return CategoryChange(
      categoryId: best.id,
      percent: best.percent,
      higher:
          inputs.thisMonthByCategory[best.id]! >
          inputs.lastMonthSameDaysByCategory[best.id]!,
    );
  }

  /// [overall] when it is the current month's and has a positive limit.
  static BudgetStatus? _currentOverall(BudgetStatus? overall, DateTime now) =>
      overall != null &&
          overall.budget.monthKey == monthKeyOf(now) &&
          overall.budget.limitMinor > 0
      ? overall
      : null;

  /// Spent under 80%, and the spent share of the limit is no more than the
  /// elapsed share of the month (today counts as elapsed).
  static BudgetOnTrack? _onTrack(BudgetStatus overall, DateTime now) {
    final limit = overall.budget.limitMinor;
    final spent = overall.spentMinor;
    if (levelFor(spentMinor: spent, limitMinor: limit) != BudgetLevel.under) {
      return null;
    }
    final total = daysInMonth(monthKeyOf(now));
    if (spent * total > limit * now.day) return null;
    return BudgetOnTrack(
      remainingMinor: limit - spent,
      daysLeft: total - now.day + 1,
    );
  }

  /// 80–100% gives [BudgetNearLimit]; above 100% gives [BudgetOver].
  static ExpenseInsightFact? _nearLimit(BudgetStatus overall) {
    final limit = overall.budget.limitMinor;
    final spent = overall.spentMinor;
    return switch (levelFor(spentMinor: spent, limitMinor: limit)) {
      BudgetLevel.under => null,
      BudgetLevel.warning => BudgetNearLimit(
        percentUsed: percentOf(spentMinor: spent, limitMinor: limit),
      ),
      BudgetLevel.over => BudgetOver(overMinor: spent - limit),
    };
  }
}
