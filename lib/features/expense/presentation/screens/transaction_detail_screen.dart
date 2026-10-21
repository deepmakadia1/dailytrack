import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/root_navigator.dart';
import 'package:dailytrack/core/share/text_sharer.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_detail_controller.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:dailytrack/features/expense/presentation/widgets/receipt_field.dart';
import 'package:dailytrack/features/expense/presentation/widgets/receipt_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// EXP-03 Transaction detail (spec §8, contracts/screens.md): every field,
/// the receipt, and Edit, Duplicate, Delete and Share. No recurring link
/// (T1.6) and no ads.
class TransactionDetailScreen extends ConsumerStatefulWidget {
  const new({required this.id, super.key});

  final String id;

  @override
  ConsumerState<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState
    extends ConsumerState<TransactionDetailScreen> {
  /// Set when this screen deletes the row itself, so the "no longer exists"
  /// message is not shown for our own delete.
  var _leaving = false;

  TransactionDetailControllerProvider get _provider =>
      transactionDetailControllerProvider(widget.id);

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context);
    final messenger = rootMessengerKey.currentState;
    _leaving = true;
    final undo = await ref.read(_provider.notifier).delete();
    if (!mounted) return;
    if (undo == null) {
      _leaving = false;
      return;
    }
    UndoSnackBar.show(
      context,
      message: l10n.expense_deleted,
      onUndo: () => unawaited(undo()),
      messenger: messenger,
    );
    context.go(Routes.expenses);
  }

  Future<void> _share() async {
    final l10n = AppLocalizations.of(context);
    final text = ref
        .read(_provider.notifier)
        .shareText(l10n, currencyCodeOf(ref));
    await ref.read(textSharerProvider).shareText(text);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(_provider);

    ref.listen(_provider, (previous, next) {
      if (_leaving) return;
      if (next case AsyncData(value: null)) {
        _leaving = true;
        rootMessengerKey.currentState?.showSnackBar(
          SnackBar(content: Text(l10n.expense_noLongerExists)),
        );
        context.go(Routes.expenses);
      }
    });

    return AppScaffold(
      title: l10n.expense_detailTitle,
      body: switch (async) {
        AsyncValue(:final value?) => _Details(
          view: value,
          onEdit: () =>
              unawaited(context.push(Routes.expenseEditPath(widget.id))),
          onDuplicate: () => unawaited(
            context.push(Routes.expenseAddPath(duplicateOf: widget.id)),
          ),
          onDelete: () => unawaited(_delete()),
          onShare: () => unawaited(_share()),
        ),
        AsyncError() => ErrorState(
          message: l10n.expense_loadError,
          onRetry: () => ref.invalidate(_provider),
        ),
        AsyncData() => const SizedBox.shrink(),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 4)),
      },
    );
  }
}

/// FR-028: opens the rule in EXP-02 rule-edit mode, or says it was deleted.
class _RuleLink extends ConsumerWidget {
  const new({required this.ruleId});

  final String ruleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rule = ref.watch(detailRuleProvider(ruleId));
    return switch (rule) {
      AsyncData(:final value?) when value.deletedAt == null => ListTile(
        key: const Key('detail_rule_link'),
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.repeat, color: theme.colorScheme.primary),
        title: Text(
          l10n.expense_createdFromRule,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () =>
            unawaited(context.push(Routes.expenseRuleEditPath(ruleId))),
      ),
      AsyncData() => ListTile(
        key: const Key('detail_rule_deleted'),
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.repeat, color: theme.colorScheme.onSurfaceVariant),
        title: Text(l10n.expense_ruleDeleted, style: theme.textTheme.bodyLarge),
      ),
      _ => const SizedBox.shrink(),
    };
  }
}

class _Details extends ConsumerWidget {
  const new({
    required this.view,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    required this.onShare,
  });

  final TransactionView view;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final currency = currencyCodeOf(ref);
    final t = view.transaction;
    final category = view.category;
    final to = view.toAccount;
    final local = t.occurredAt.toLocal();
    final locale = l10n.localeName;

    Widget row(Key key, IconData icon, String label, String value) => ListTile(
      key: key,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label, style: theme.textTheme.bodySmall),
      subtitle: Text(value, style: theme.textTheme.bodyLarge),
    );

    return ListView(
      padding: EdgeInsets.symmetric(vertical: tokens.s16),
      children: [
        Center(
          child: AmountText(
            key: const Key('detail_amount'),
            amountMinor: t.amountMinor,
            currencyCode: currency,
            kind: amountKindFor(t.type),
            showSign: !t.isTransfer,
            style: theme.textTheme.displaySmall,
          ),
        ),
        SizedBox(height: tokens.s8),
        Center(
          child: Chip(
            key: const Key('detail_type'),
            avatar: Icon(switch (t.type) {
              TxnType.expense => Icons.arrow_upward,
              TxnType.income => Icons.arrow_downward,
              TxnType.transfer => Icons.swap_horiz,
            }, size: tokens.chipIconSize),
            label: Text(l10n.txnType(t.type)),
          ),
        ),
        SizedBox(height: tokens.s16),
        if (category != null && !t.isTransfer)
          ListTile(
            key: const Key('detail_category'),
            contentPadding: EdgeInsets.zero,
            leading: CategoryAvatar(
              icon: AppIcons.byKey(category.iconKey),
              color: colorFromHex(category.colorHex),
              semanticLabel: l10n.categoryName(category),
            ),
            title: Text(
              l10n.expense_category,
              style: theme.textTheme.bodySmall,
            ),
            subtitle: Text(
              l10n.categoryName(category),
              style: theme.textTheme.bodyLarge,
            ),
          ),
        if (t.isTransfer && to != null)
          row(
            const Key('detail_accounts'),
            Icons.swap_horiz,
            l10n.expense_account,
            l10n.expense_transferLabel(
              l10n.accountName(view.account),
              l10n.accountName(to),
            ),
          )
        else
          row(
            const Key('detail_account'),
            Icons.account_balance_wallet_outlined,
            l10n.expense_account,
            l10n.accountName(view.account),
          ),
        row(
          const Key('detail_mode'),
          Icons.payments_outlined,
          l10n.expense_paymentMode,
          l10n.paymentMode(t.paymentMode),
        ),
        row(
          const Key('detail_date'),
          Icons.calendar_today,
          l10n.expense_pickDate,
          // Weekday plus the SET-01 full-date format (feature 007 R13).
          DateFormat(
            'EEE, ${FullDateFormatScope.of(context).pattern}',
            locale,
          ).add_jm().format(local),
        ),
        if (t.recurringRuleId case final ruleId?) _RuleLink(ruleId: ruleId),
        if (t.note case final note?)
          row(
            const Key('detail_note'),
            Icons.notes,
            l10n.expense_noteLabel,
            note,
          ),
        if (t.receiptPath case final path?) ...[
          SizedBox(height: tokens.s8),
          Row(
            children: [
              ReceiptThumbnail(
                relativePath: path,
                onTap: () async {
                  final absolute = await ref
                      .read(receiptStoreProvider)
                      .resolve(path);
                  if (absolute != null && context.mounted) {
                    await ReceiptViewer.open(context, absolute);
                  }
                },
              ),
              SizedBox(width: tokens.s12),
              Expanded(child: Text(l10n.expense_receipt)),
            ],
          ),
        ],
        SizedBox(height: tokens.s24),
        Wrap(
          spacing: tokens.s8,
          runSpacing: tokens.s8,
          children: [
            FilledButton.tonalIcon(
              key: const Key('detail_edit'),
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
              label: Text(l10n.expense_edit),
            ),
            OutlinedButton.icon(
              key: const Key('detail_duplicate'),
              onPressed: onDuplicate,
              icon: const Icon(Icons.copy_outlined),
              label: Text(l10n.expense_duplicate),
            ),
            OutlinedButton.icon(
              key: const Key('detail_share'),
              onPressed: onShare,
              icon: const Icon(Icons.share_outlined),
              label: Text(l10n.expense_share),
            ),
            TextButton.icon(
              key: const Key('detail_delete'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.expense_delete),
            ),
          ],
        ),
      ],
    );
  }
}
