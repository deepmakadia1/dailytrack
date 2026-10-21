import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// Spent ÷ limit for the progress bar only; all money math stays in paise.
double budgetRatio(BudgetStatus s) =>
    s.budget.limitMinor == 0 ? 0 : s.spentMinor / s.budget.limitMinor;

/// "Almost used · 85% used": the level as text, never color alone (§15.2).
String budgetLevelLine(AppLocalizations l10n, BudgetStatus s) =>
    l10n.expense_budgetLevelLine(l10n.budgetLevel(s.level), s.percent);

/// EXP-08 overall card (US1 s2, s11; FR-009): limit, spent, remaining, a
/// progress bar, and the per-day line for the month's phase. With no
/// Overall budget it prompts to set one.
class OverallBudgetCard extends StatelessWidget {
  const new({
    required this.status,
    required this.currencyCode,
    required this.onTap,
    super.key,
  });

  final BudgetStatus? status;
  final String currencyCode;

  /// Opens EXP-09 for the Overall budget (edit, or new when unset).
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final s = status;
    if (s == null) {
      return SummaryCard(
        key: const Key('overall_card'),
        title: l10n.expense_budgetSetOverallPrompt,
        value: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton(
            key: const Key('set_overall_budget'),
            onPressed: onTap,
            child: Text(l10n.expense_budgetSet),
          ),
        ),
      );
    }

    String money(int minor) =>
        MoneyFormatter.format(minor, currencyCode: currencyCode);
    final tabular = theme.textTheme.bodyMedium?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final remaining = s.remainingMinor;
    final dayLine = switch (s.monthPhase) {
      MonthPhase.past =>
        remaining >= 0
            ? l10n.expense_budgetUnderBy(money(remaining))
            : l10n.expense_budgetOverBy(money(-remaining)),
      MonthPhase.current => switch (s.perDayLeftMinor) {
        final perDay? => l10n.expense_budgetPerDayLeft(
          money(perDay),
          s.daysLeft!,
        ),
        null => l10n.expense_budgetNoneLeft,
      },
      MonthPhase.future => switch (s.perDayLeftMinor) {
        final perDay? => l10n.expense_budgetFuturePerDay(
          money(perDay),
          s.daysLeft!,
        ),
        null => l10n.expense_budgetNoneLeft,
      },
    };

    // MergeSemantics: Card starts its own semantics node, so without it the
    // tap target would have no label (§15.10, TalkBack).
    return MergeSemantics(
      child: InkWell(
        key: const Key('overall_card'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        child: SummaryCard(
          title: l10n.expense_budgetOverall,
          value: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.expense_budgetSpentOfLimit(
                  money(s.spentMinor),
                  money(s.budget.limitMinor),
                ),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (s.monthPhase != MonthPhase.past) ...[
                SizedBox(height: tokens.s4),
                Text(
                  key: const Key('overall_remaining'),
                  remaining >= 0
                      ? l10n.expense_budgetLeft(money(remaining))
                      : l10n.expense_budgetOverBy(money(-remaining)),
                  style: tabular,
                ),
              ],
              SizedBox(height: tokens.s4),
              Text(key: const Key('overall_day_line'), dayLine, style: tabular),
            ],
          ),
          progress: ProgressBarStatus(
            ratio: budgetRatio(s),
            label: budgetLevelLine(l10n, s),
          ),
        ),
      ),
    );
  }
}
