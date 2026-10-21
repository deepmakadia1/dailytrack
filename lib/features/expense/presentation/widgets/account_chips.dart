import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// EXP-02 account chip(s) (T056): one chip for expense/income, From and To
/// for a transfer. Each opens [showAccountPicker].
class AccountChips extends StatelessWidget {
  const new({
    required this.accounts,
    required this.accountId,
    required this.onAccount,
    super.key,
    this.isTransfer = false,
    this.toAccountId,
    this.onToAccount,
  });

  final List<Account> accounts;
  final String? accountId;
  final ValueChanged<String> onAccount;
  final bool isTransfer;
  final String? toAccountId;
  final ValueChanged<String>? onToAccount;

  Account? _byId(String? id) {
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final from = _byId(accountId);
    final to = _byId(toAccountId);

    Future<void> pick(String? current, ValueChanged<String>? onPicked) async {
      final id = await showAccountPicker(
        context,
        accounts: accounts,
        selectedId: current,
      );
      if (id != null) onPicked?.call(id);
    }

    Widget chip(Key key, String label, Account? account, VoidCallback onTap) =>
        ActionChip(
          key: key,
          avatar: Icon(
            account == null
                ? Icons.account_balance_wallet_outlined
                : AppIcons.byKey(account.iconKey),
            size: tokens.chipIconSize,
          ),
          label: Text(label),
          onPressed: onTap,
        );

    if (!isTransfer) {
      return Wrap(
        children: [
          chip(
            const Key('account_chip'),
            from == null ? l10n.expense_account : l10n.accountName(from),
            from,
            () => pick(accountId, onAccount),
          ),
        ],
      );
    }
    return Wrap(
      spacing: tokens.s8,
      runSpacing: tokens.s8,
      children: [
        chip(
          const Key('from_account_chip'),
          l10n.expense_fromAccount(
            from == null ? l10n.expense_account : l10n.accountName(from),
          ),
          from,
          () => pick(accountId, onAccount),
        ),
        chip(
          const Key('to_account_chip'),
          to == null
              ? l10n.expense_chooseToAccount
              : l10n.expense_toAccount(l10n.accountName(to)),
          to,
          () => pick(toAccountId, onToAccount),
        ),
      ],
    );
  }
}

/// Bottom-sheet account list; returns the chosen id, or null if dismissed.
Future<String?> showAccountPicker(
  BuildContext context, {
  required List<Account> accounts,
  required String? selectedId,
}) {
  final l10n = AppLocalizations.of(context);
  return AppBottomSheet.show<String>(
    context,
    title: l10n.expense_account,
    child: ListView(
      shrinkWrap: true,
      children: [
        for (final a in accounts)
          ListTile(
            key: ValueKey('pick_account_${a.id}'),
            leading: CategoryAvatar(
              icon: AppIcons.byKey(a.iconKey),
              color: colorFromHex(a.colorHex),
              semanticLabel: l10n.accountName(a),
            ),
            title: Text(l10n.accountName(a)),
            subtitle: Text(l10n.accountType(a.type)),
            selected: a.id == selectedId,
            trailing: a.id == selectedId ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(context).pop(a.id),
          ),
      ],
    ),
  );
}
