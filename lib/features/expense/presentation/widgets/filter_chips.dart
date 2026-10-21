import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/features/expense/domain/entities/account.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/entities/txn_query.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/presentation/controllers/transaction_query_ops.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// EXP-01 active filter chips, each with an × that removes it (FR-020).
class FilterChips extends StatelessWidget {
  const new({
    required this.query,
    required this.categories,
    required this.accounts,
    required this.currency,
    required this.onRemove,
    super.key,
  });

  final TxnQuery query;
  final Map<String, Category> categories;
  final Map<String, Account> accounts;
  final String currency;
  final ValueChanged<FilterChipId> onRemove;

  String _label(AppLocalizations l10n, FilterChipId chip) {
    String money(int minor) =>
        MoneyFormatter.format(minor, currencyCode: currency);
    return switch (chip) {
      (kind: FilterKind.type, :final TxnType value) => l10n.txnType(value),
      (kind: FilterKind.mode, :final PaymentMode value) => l10n.paymentMode(
        value,
      ),
      (kind: FilterKind.category, :final String value) =>
        categories[value] == null
            ? value
            : l10n.categoryName(categories[value]!),
      (kind: FilterKind.account, :final String value) =>
        accounts[value] == null ? value : l10n.accountName(accounts[value]!),
      _ => switch ((query.minAmountMinor, query.maxAmountMinor)) {
        (final min?, final max?) => l10n.expense_amountBetween(
          money(min),
          money(max),
        ),
        (final min?, null) => l10n.expense_amountAtLeast(money(min)),
        (null, final max?) => l10n.expense_amountAtMost(money(max)),
        (null, null) => '',
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    final chips = query.chips;
    if (chips.isEmpty) return const SizedBox.shrink();
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    return Wrap(
      spacing: tokens.s8,
      runSpacing: tokens.s8,
      children: [
        for (final chip in chips)
          InputChip(
            key: ValueKey('filter_${chip.kind.name}_${chip.value}'),
            label: Text(_label(l10n, chip)),
            onDeleted: () => onRemove(chip),
            deleteButtonTooltipMessage: l10n.expense_removeFilter(
              _label(l10n, chip),
            ),
          ),
      ],
    );
  }
}
