import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/overall_budget_card.dart';
import 'package:flutter/material.dart';

Widget _avatar(BuildContext context, Category? c) => CategoryAvatar(
  icon: AppIcons.byKey(c?.iconKey ?? 'category'),
  color: c == null
      ? Theme.of(context).colorScheme.primary
      : colorFromHex(c.colorHex),
  semanticLabel: AppLocalizations.of(context).budgetName(c),
);

/// EXP-08 category budget row (US1 s3): icon, name (with a "Hidden" label
/// for a hidden or deleted category), spent of limit, and a progress bar
/// whose level is also written out.
class BudgetRow extends StatelessWidget {
  const new({
    required this.status,
    required this.currencyCode,
    required this.onTap,
    super.key,
  });

  final BudgetStatus status;
  final String currencyCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final s = status;
    String money(int minor) =>
        MoneyFormatter.format(minor, currencyCode: currencyCode);

    return MergeSemantics(
      child: InkWell(
        key: ValueKey('budget_row_${s.budget.id}'),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.s48 + tokens.s16),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.s8),
            child: Row(
              children: [
                _avatar(context, s.category),
                SizedBox(width: tokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Wrap(
                        spacing: tokens.s8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            l10n.budgetName(s.category),
                            style: theme.textTheme.titleSmall,
                          ),
                          if (s.categoryHidden)
                            Text(
                              l10n.expense_budgetHidden,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                      Text(
                        l10n.expense_budgetSpentOfLimit(
                          money(s.spentMinor),
                          money(s.budget.limitMinor),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                      SizedBox(height: tokens.s4),
                      ProgressBarStatus(
                        ratio: budgetRatio(s),
                        label: budgetLevelLine(l10n, s),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// EXP-08 "Categories without budget" row with a "Set budget" button.
class UnbudgetedCategoryRow extends StatelessWidget {
  const new({required this.category, required this.onSet, super.key});

  final Category category;
  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return ListTile(
      key: ValueKey('unbudgeted_${category.id}'),
      contentPadding: EdgeInsets.zero,
      minTileHeight: tokens.s48 + tokens.s16,
      leading: _avatar(context, category),
      title: Text(
        l10n.categoryName(category),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: TextButton(
        key: ValueKey('set_budget_${category.id}'),
        onPressed: onSet,
        child: Text(l10n.expense_budgetSet),
      ),
    );
  }
}
