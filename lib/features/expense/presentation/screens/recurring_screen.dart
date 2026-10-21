import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/recurring_rule.dart';
import 'package:dailytrack/features/expense/presentation/controllers/recurring_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/recurring_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EXP-10 Recurring transactions (spec §8, FR-026, US3 s8–s12): active
/// rules, then a "Paused" section (ended rules included). Tap opens EXP-02
/// in rule-edit mode. No ads.
class RecurringScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(recurringControllerProvider);
    final controller = ref.read(recurringControllerProvider.notifier);
    void add() => unawaited(context.push(Routes.expenseRecurringAdd));

    return AppScaffold(
      title: l10n.expense_recurringTitle,
      // §15.1: the empty state's own button is the one primary action.
      fab: switch (async.value) {
        final data? when !data.isEmpty => FloatingActionButton(
          key: const Key('add_recurring'),
          tooltip: l10n.expense_recurringAdd,
          onPressed: add,
          child: const Icon(Icons.add),
        ),
        _ => null,
      },
      body: switch (async) {
        AsyncValue(:final value?) when value.isEmpty => EmptyState(
          title: l10n.expense_recurringEmptyTitle,
          message: l10n.expense_recurringEmptyBody,
          actionLabel: l10n.expense_recurringAdd,
          onAction: add,
        ),
        AsyncValue(:final value?) => _RulesList(
          data: value,
          controller: controller,
        ),
        AsyncError() => ErrorState(
          message: l10n.expense_loadDataError,
          onRetry: controller.retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList()),
      },
    );
  }
}

class _RulesList extends ConsumerWidget {
  const new({required this.data, required this.controller});

  final RecurringData data;
  final RecurringController controller;

  Future<void> _delete(BuildContext context, RecurringRule rule) async {
    final l10n = AppLocalizations.of(context);
    final undo = await controller.delete(rule.id);
    if (undo == null || !context.mounted) return;
    UndoSnackBar.show(
      context,
      message: l10n.expense_recurringDeleted,
      onUndo: () => unawaited(undo()),
    );
  }

  Future<void> _menu(BuildContext context, RecurringRule rule) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final paused = !rule.isActive;
    final action = await AppBottomSheet.show<String>(
      context,
      title: l10n.expense_recurringTitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('rule_menu_pause'),
            enabled: !rule.isEnded,
            leading: Icon(paused ? Icons.play_arrow : Icons.pause),
            title: Text(
              paused
                  ? l10n.expense_recurringResume
                  : l10n.expense_recurringPause,
            ),
            onTap: () => Navigator.of(context).pop('pause'),
          ),
          ListTile(
            key: const Key('rule_menu_delete'),
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text(l10n.expense_recurringDelete),
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'pause':
        await controller.setPaused(rule.id, paused: !paused);
      case 'delete':
        await _delete(context, rule);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);

    Widget row(RecurringRuleView v) => RecurringRow(
      view: v,
      currencyCode: currency,
      onTap: () =>
          unawaited(context.push(Routes.expenseRuleEditPath(v.rule.id))),
      onTogglePause: () =>
          unawaited(controller.setPaused(v.rule.id, paused: v.rule.isActive)),
      onDelete: () => unawaited(_delete(context, v.rule)),
      onMenu: () => unawaited(_menu(context, v.rule)),
    );

    return ListView(
      key: const Key('recurring_list'),
      padding: EdgeInsets.only(top: tokens.s8, bottom: tokens.s48 * 2),
      children: [
        for (final v in data.active) row(v),
        if (data.paused.isNotEmpty) ...[
          Padding(
            key: const Key('paused_heading'),
            padding: EdgeInsets.only(top: tokens.s24, bottom: tokens.s8),
            child: Text(
              l10n.expense_recurringPaused,
              style: theme.textTheme.titleMedium,
            ),
          ),
          for (final v in data.paused) row(v),
        ],
      ],
    );
  }
}
