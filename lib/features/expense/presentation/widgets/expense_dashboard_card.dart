import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budget_form_state.dart';
import 'package:dailytrack/features/expense/presentation/controllers/expense_dashboard_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/budget_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/overall_budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `ExpenseModule.dashboardCard()` (T111, FR-030; DSH-01, feature 006
/// contracts/screens.md "Expense card"): "Spent today", and "This month"
/// against the Overall budget with a progress bar (under 80%, 80–100%,
/// over 100%; level text, never color alone), or the month total with "Set
/// budget" when none is set. A "+ Expense" chip opens EXP-02; a tap
/// elsewhere opens EXP-01. With no transactions yet it offers "Add your
/// first expense".
class ExpenseDashboardCard extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(expenseDashboardControllerProvider);
    final currency = currencyCodeOf(ref);

    Widget line(Key key, String label, Widget amount) => Row(
      key: key,
      children: [
        Expanded(child: Text(label)),
        amount,
      ],
    );

    Widget amount(int minor) => AmountText(
      amountMinor: minor,
      currencyCode: currency,
      kind: AmountKind.expense,
      style: theme.textTheme.titleMedium,
    );

    String money(int minor) =>
        MoneyFormatter.format(minor, currencyCode: currency);

    void setBudget() {
      final now = ref.read(clockProvider).now();
      unawaited(
        BudgetSheet.show(context, BudgetFormArgs(monthKey: monthKeyOf(now))),
      );
    }

    final value = switch (async) {
      AsyncValue(:final value?) when !value.hasAnyTransaction => Align(
        alignment: AlignmentDirectional.centerStart,
        child: ActionChip(
          key: const Key('expense_card_empty'),
          avatar: Icon(Icons.add, size: tokens.chipIconSize),
          label: Text(l10n.expense_cardEmpty),
          onPressed: () => unawaited(context.push(Routes.expenseAddPath())),
        ),
      ),
      AsyncValue(:final value?) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          line(
            const Key('spent_today'),
            l10n.expense_spentToday,
            amount(value.todayMinor),
          ),
          SizedBox(height: tokens.s4),
          if (value.overall case final overall?) ...[
            line(
              const Key('spent_month'),
              l10n.expense_thisMonth,
              Flexible(
                child: Text(
                  l10n.expense_cardMonthOfBudget(
                    money(overall.spentMinor),
                    money(overall.budget.limitMinor),
                  ),
                  textAlign: TextAlign.end,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            SizedBox(height: tokens.s8),
            ProgressBarStatus(
              key: const Key('expense_card_budget_bar'),
              ratio: budgetRatio(overall),
              label: budgetLevelLine(l10n, overall),
            ),
          ] else ...[
            line(
              const Key('spent_month'),
              l10n.expense_thisMonth,
              amount(value.monthMinor),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton(
                key: const Key('expense_card_set_budget'),
                onPressed: setBudget,
                child: Text(l10n.expense_cardSetBudget),
              ),
            ),
          ],
        ],
      ),
      AsyncError() => Row(
        key: const Key('expense_card_error'),
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          SizedBox(width: tokens.s8),
          Expanded(child: Text(l10n.expense_loadDataError)),
          TextButton(
            onPressed: ref
                .read(expenseDashboardControllerProvider.notifier)
                .retry,
            child: Text(l10n.common_tryAgain),
          ),
        ],
      ),
      _ => const DelayedSkeleton(child: SkeletonCard()),
    };

    // The whole card is one button labelled with the module name, so screen
    // readers announce what a tap opens.
    return Semantics(
      button: true,
      label: l10n.modules_expense,
      child: InkWell(
        key: const Key('expense_card'),
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        onTap: () => context.go(Routes.expenses),
        child: SummaryCard(
          leading: CategoryAvatar(
            icon: Icons.receipt_long,
            color: theme.colorScheme.primary,
            semanticLabel: l10n.modules_expense,
          ),
          title: l10n.modules_expense,
          // The empty state already offers one action (§15.6).
          actionChip: async.value?.hasAnyTransaction != true
              ? null
              : ActionChip(
                  key: const Key('expense_card_add'),
                  avatar: Icon(Icons.add, size: tokens.chipIconSize),
                  label: Text(l10n.expense_cardAdd),
                  onPressed: () => unawaited(
                    context.push(
                      Routes.expenseAddPath(type: TxnType.expense.name),
                    ),
                  ),
                ),
          value: value,
        ),
      ),
    );
  }
}
