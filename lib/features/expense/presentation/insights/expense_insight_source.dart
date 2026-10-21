import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/l10n/seed_names.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/insights/expense_insight_rules.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';

/// `ExpenseModule.insights()` (DSH-01, feature 006 research R4, R8): loads
/// this month's and the same days of last month's category totals and the
/// Overall budget, runs [ExpenseInsightRules], and localizes each fact. Any
/// input or fact that fails is skipped; the rest still return.
final class ExpenseInsightSource implements InsightSource {
  const new();

  @override
  List<String> get ruleIds => ExpenseInsightRules.ruleIds;

  @override
  Future<List<Insight>> evaluate(ProviderReader read) async {
    final settings = read(appSettingsProvider).value ?? const AppSettings();
    final l10n = l10nFor(settings.locale);
    final clock = read(clockProvider);
    final rules = ExpenseInsightRules(clock);
    final periods = rules.periods();
    final transactions = read(transactionRepositoryProvider);

    Future<Map<String, int>> byCategory(DateTime from, DateTime to) async {
      try {
        final breakdown = await transactions
            .watchBreakdown(TxnQuery(period: CustomPeriod(from, to)))
            .first;
        return breakdown.byCategory;
      } on Object {
        return const {};
      }
    }

    final thisMonth = await byCategory(
      periods.thisMonthFrom,
      periods.thisMonthTo,
    );
    final lastMonth = await byCategory(
      periods.lastMonthFrom,
      periods.lastMonthTo,
    );
    BudgetStatus? overall;
    try {
      overall = (await read(
        budgetRepositoryProvider,
      ).watchOverview(monthKeyOf(clock.now())).first).overall;
    } on Object {
      overall = null;
    }
    var categories = const <String, Category>{};
    try {
      categories = {
        for (final c in await read(categoryRepositoryProvider).watchAll().first)
          c.id: c,
      };
    } on Object {
      // Category facts are then skipped below.
    }

    final facts = rules.evaluate(
      ExpenseInsightInputs(
        thisMonthByCategory: thisMonth,
        lastMonthSameDaysByCategory: lastMonth,
        overall: overall,
      ),
    );
    return [
      for (final fact in facts)
        ?_localize(fact, l10n, settings.currencyCode, categories),
    ];
  }

  static Insight? _localize(
    ExpenseInsightFact fact,
    AppLocalizations l10n,
    String currency,
    Map<String, Category> categories,
  ) {
    try {
      String money(int minor) =>
          MoneyFormatter.format(minor, currencyCode: currency);
      final (text, location) = switch (fact) {
        CategoryChange(:final categoryId, :final percent, :final higher) => (
          higher
              ? l10n.expense_insightCategoryHigher(
                  localizedSeedName(l10n, categories[categoryId]!.name),
                  percent,
                )
              : l10n.expense_insightCategoryLower(
                  localizedSeedName(l10n, categories[categoryId]!.name),
                  percent,
                ),
          Routes.expenseReports,
        ),
        BudgetOnTrack(:final remainingMinor, :final daysLeft) => (
          l10n.expense_insightBudgetOnTrack(money(remainingMinor), daysLeft),
          Routes.expenseBudgets,
        ),
        BudgetNearLimit(:final percentUsed) => (
          l10n.expense_insightBudgetNear(percentUsed),
          Routes.expenseBudgets,
        ),
        BudgetOver(:final overMinor) => (
          l10n.expense_insightBudgetOver(money(overMinor)),
          Routes.expenseBudgets,
        ),
      };
      return Insight(
        ruleId: fact.ruleId,
        text: text,
        location: location,
        semanticLabel: location == Routes.expenseReports
            ? l10n.expense_insightOpensReports(text)
            : l10n.expense_insightOpensBudgets(text),
      );
    } on Object {
      return null;
    }
  }
}
