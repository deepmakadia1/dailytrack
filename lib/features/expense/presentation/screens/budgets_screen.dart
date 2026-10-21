import 'dart:async';

import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/budget_status.dart';
import 'package:dailytrack/features/expense/domain/usecases/budget_math.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budget_form_controller.dart';
import 'package:dailytrack/features/expense/presentation/controllers/budgets_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/budget_row.dart';
import 'package:dailytrack/features/expense/presentation/widgets/budget_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/overall_budget_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// EXP-08 Budgets (spec §8, FR-007–FR-014): a month selector, the Overall
/// card, category budgets, and categories without a budget. Rows open the
/// EXP-09 sheet. No ads: the native ad slot is left out until the ads
/// feature (FR-049).
class BudgetsScreen extends ConsumerWidget {
  const new({super.key, this.month});

  /// `yyyy-MM` to open (from a notification); null = this month.
  final String? month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final provider = budgetsControllerProvider(month);
    final state = ref.watch(provider);
    final controller = ref.read(provider.notifier);

    Future<void> copyLastMonth() async {
      final copied = await controller.copyLastMonth();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              copied == null
                  ? l10n.expense_saveError
                  : l10n.expense_budgetCopied(copied),
            ),
          ),
        );
    }

    return AppScaffold(
      title: l10n.expense_budgetsTitle,
      actions: [
        PopupMenuButton<String>(
          key: const Key('budgets_overflow'),
          onSelected: (_) => unawaited(copyLastMonth()),
          itemBuilder: (context) => [
            PopupMenuItem(
              key: const Key('menu_copy_last_month'),
              value: 'copy',
              child: Text(l10n.expense_budgetCopyLastMonth),
            ),
          ],
        ),
      ],
      body: Column(
        children: [
          PeriodSelector(
            key: const Key('budgets_month'),
            period: MonthPeriod(monthStartLocal(state.monthKey)),
            now: ref.watch(clockProvider).now(),
            monthOnly: true,
            onChanged: (p) =>
                p.startLocal.isBefore(monthStartLocal(state.monthKey))
                ? controller.previousMonth()
                : controller.nextMonth(),
          ),
          SizedBox(height: tokens.s8),
          Expanded(
            child: switch (state.overview) {
              AsyncValue(:final value?) when value.isEmpty => EmptyState(
                title: l10n.expense_budgetEmptyTitle,
                message: l10n.expense_budgetEmptyBody,
                actionLabel: l10n.expense_budgetSetMonthly,
                onAction: () => unawaited(
                  _openSheet(
                    context,
                    controller,
                    BudgetFormArgs(monthKey: state.monthKey),
                  ),
                ),
              ),
              AsyncValue(:final value?) => _BudgetsList(
                overview: value,
                controller: controller,
              ),
              AsyncError() => ErrorState(
                message: l10n.expense_loadDataError,
                onRetry: controller.retry,
              ),
              _ => const DelayedSkeleton(child: SkeletonList()),
            },
          ),
        ],
      ),
    );
  }
}

/// Opens EXP-09 and shows the delete Undo snackbar when it closes that way.
Future<void> _openSheet(
  BuildContext context,
  BudgetsController controller,
  BudgetFormArgs args,
) async {
  final l10n = AppLocalizations.of(context);
  final outcome = await BudgetSheet.show(context, args);
  if (outcome is! BudgetDeleted || !context.mounted) return;
  final messenger = ScaffoldMessenger.of(context);
  UndoSnackBar.show(
    context,
    message: l10n.expense_budgetDeleted,
    onUndo: () => unawaited(() async {
      if (!await outcome.undo()) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.expense_budgetRestoreFailed)),
        );
      }
    }()),
  );
}

class _BudgetsList extends ConsumerWidget {
  const new({required this.overview, required this.controller});

  final BudgetsOverview overview;
  final BudgetsController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final month = overview.monthKey;

    void open(BudgetFormArgs args) =>
        unawaited(_openSheet(context, controller, args));

    Widget heading(String text, Key key) => Padding(
      key: key,
      padding: EdgeInsets.only(top: tokens.s24, bottom: tokens.s8),
      child: Text(text, style: theme.textTheme.titleMedium),
    );

    final overall = overview.overall;
    return ListView(
      key: const Key('budgets_list'),
      padding: EdgeInsets.only(bottom: tokens.s48),
      children: [
        OverallBudgetCard(
          status: overall,
          currencyCode: currency,
          onTap: () => open(
            BudgetFormArgs(monthKey: month, budgetId: overall?.budget.id),
          ),
        ),
        if (overview.categories.isNotEmpty) ...[
          heading(
            l10n.expense_budgetCategoryBudgets,
            const Key('category_budgets_heading'),
          ),
          for (final s in overview.categories)
            BudgetRow(
              status: s,
              currencyCode: currency,
              onTap: () =>
                  open(BudgetFormArgs(monthKey: month, budgetId: s.budget.id)),
            ),
        ],
        if (overview.withoutBudget.isNotEmpty) ...[
          heading(
            l10n.expense_budgetWithoutBudget,
            const Key('without_budget_heading'),
          ),
          for (final c in overview.withoutBudget)
            UnbudgetedCategoryRow(
              category: c,
              onSet: () =>
                  open(BudgetFormArgs(monthKey: month, categoryId: c.id)),
            ),
        ],
      ],
    );
  }
}
