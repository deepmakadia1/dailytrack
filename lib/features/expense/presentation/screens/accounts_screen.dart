import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/presentation/controllers/accounts_controller.dart';
import 'package:dailytrack/features/expense/presentation/widgets/account_sheet.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// EXP-06 Accounts (spec §8, FR-027): total balance, accounts with derived
/// balances, a collapsed Archived section, and Add / edit through EXP-07.
/// Tap opens EXP-01 filtered to that account. No ads (banner slot empty
/// until T4.2).
class AccountsScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(accountsControllerProvider);
    final controller = ref.read(accountsControllerProvider.notifier);

    return AppScaffold(
      title: l10n.expense_accountsTitle,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      // §15.1: the empty state's own button is the one primary action.
      fab: switch (async.value) {
        AccountsData(:final active, :final archived)
            when active.isEmpty && archived.isEmpty =>
          null,
        _ => FloatingActionButton(
          key: const Key('add_account'),
          tooltip: l10n.expense_addAccount,
          onPressed: () => unawaited(AccountSheet.show(context)),
          child: const Icon(Icons.add),
        ),
      },
      body: switch (async) {
        AsyncValue(:final value?)
            when value.active.isEmpty && value.archived.isEmpty =>
          EmptyState(
            title: l10n.expense_noAccounts,
            actionLabel: l10n.expense_addAccount,
            onAction: () => unawaited(AccountSheet.show(context)),
          ),
        AsyncValue(:final value?) => _AccountsList(
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

class _AccountsList extends ConsumerWidget {
  const new({required this.data, required this.controller});

  final AccountsData data;
  final AccountsController controller;

  Future<void> _menu(BuildContext context, AccountWithBalance item) async {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final a = item.account;
    final isLastActive = !a.isArchived && !data.canRemoveActive;
    final canDelete = !item.hasTransactions && !isLastActive;
    final action = await AppBottomSheet.show<String>(
      context,
      title: l10n.accountName(a),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            key: const Key('account_menu_edit'),
            leading: const Icon(Icons.edit_outlined),
            title: Text(l10n.expense_edit),
            onTap: () => Navigator.of(context).pop('edit'),
          ),
          ListTile(
            key: const Key('account_menu_archive'),
            enabled: !isLastActive,
            leading: Icon(
              a.isArchived ? Icons.unarchive_outlined : Icons.archive_outlined,
            ),
            title: Text(
              a.isArchived ? l10n.expense_unarchive : l10n.expense_archive,
            ),
            subtitle: isLastActive ? Text(l10n.expense_lastAccountHelp) : null,
            onTap: () => Navigator.of(context).pop('archive'),
          ),
          ListTile(
            key: const Key('account_menu_delete'),
            enabled: canDelete,
            leading: Icon(
              Icons.delete_outline,
              color: canDelete ? scheme.error : null,
            ),
            title: Text(l10n.expense_deleteAccount),
            subtitle: switch ((item.hasTransactions, isLastActive)) {
              (true, _) => Text(l10n.expense_accountHasTransactions),
              (_, true) => Text(l10n.expense_lastAccountHelp),
              _ => null,
            },
            onTap: () => Navigator.of(context).pop('delete'),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    switch (action) {
      case 'edit':
        await AccountSheet.show(context, id: a.id);
      case 'archive':
        final undo = await controller.setArchived(
          a.id,
          archived: !a.isArchived,
        );
        if (undo != null && context.mounted) {
          UndoSnackBar.show(
            context,
            message: a.isArchived
                ? l10n.expense_accountRestored
                : l10n.expense_accountArchived,
            onUndo: () => unawaited(undo()),
          );
        }
      case 'delete':
        final undo = await controller.delete(a.id);
        if (undo != null && context.mounted) {
          UndoSnackBar.show(
            context,
            message: l10n.expense_accountDeleted,
            onUndo: () => unawaited(undo()),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final total = data.totalMinor;

    Widget row(AccountWithBalance item) {
      final a = item.account;
      final balance = item.balanceMinor;
      return ListTile(
        key: ValueKey('account_row_${a.id}'),
        contentPadding: EdgeInsets.zero,
        minTileHeight: tokens.s48 + tokens.s16,
        leading: CategoryAvatar(
          icon: AppIcons.byKey(a.iconKey),
          color: colorFromHex(a.colorHex),
          semanticLabel: l10n.accountName(a),
        ),
        title: Text(
          l10n.accountName(a),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(l10n.accountType(a.type)),
        trailing: AmountText(
          key: ValueKey('balance_${a.id}'),
          amountMinor: balance.abs(),
          currencyCode: currency,
          // Negative balances are red AND carry a minus sign (§15.2).
          kind: balance < 0 ? AmountKind.expense : AmountKind.neutral,
          showSign: balance < 0,
          style: theme.textTheme.titleMedium,
        ),
        onTap: () => context.go(Routes.expensesPath(accountId: a.id)),
        onLongPress: () => unawaited(_menu(context, item)),
      );
    }

    return ListView(
      key: const Key('accounts_list'),
      padding: EdgeInsets.only(top: tokens.s8, bottom: tokens.s48 * 2),
      children: [
        SummaryCard(
          key: const Key('total_balance'),
          title: l10n.expense_totalBalance,
          value: AmountText(
            amountMinor: total.abs(),
            currencyCode: currency,
            kind: total < 0 ? AmountKind.expense : AmountKind.neutral,
            showSign: total < 0,
            style: theme.textTheme.headlineSmall,
          ),
        ),
        SizedBox(height: tokens.s8),
        for (final item in data.active) row(item),
        if (data.archived.isNotEmpty)
          ExpansionTile(
            key: const Key('archived_section'),
            tilePadding: EdgeInsets.zero,
            title: Text(l10n.expense_archivedSection),
            children: [for (final item in data.archived) row(item)],
          ),
      ],
    );
  }
}
