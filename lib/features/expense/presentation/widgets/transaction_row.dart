import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/expense/domain/entities/transaction_view.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// Row height before text scaling (§15.3: 64–72 dp).
const double transactionRowHeight = 72;

/// EXP-01 row: category icon in a colored circle, category name, one-line
/// note, account · payment mode, and the signed amount on the right. A
/// transfer shows "From → To" with a neutral amount.
class TransactionRow extends StatelessWidget {
  const new({
    required this.view,
    required this.currency,
    required this.onTap,
    required this.onLongPress,
    this.horizontalPadding = 0,
    super.key,
  });

  final TransactionView view;
  final String currency;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Inset inside the ink, so the ripple still spans the full width.
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final t = view.transaction;
    final category = view.category;
    final to = view.toAccount;

    final title = t.isTransfer && to != null
        ? l10n.expense_transferLabel(
            l10n.accountName(view.account),
            l10n.accountName(to),
          )
        : category == null
        ? l10n.txnType(t.type)
        : l10n.categoryName(category);
    final avatar = t.isTransfer || category == null
        ? CategoryAvatar(
            icon: Icons.swap_horiz,
            color: theme.colorScheme.outline,
            semanticLabel: l10n.expense_typeTransfer,
          )
        : CategoryAvatar(
            icon: AppIcons.byKey(category.iconKey),
            color: colorFromHex(category.colorHex),
            semanticLabel: l10n.categoryName(category),
          );
    final subtitle = t.isTransfer
        ? l10n.paymentMode(t.paymentMode)
        : l10n.expense_accountAndMode(
            l10n.accountName(view.account),
            l10n.paymentMode(t.paymentMode),
          );
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      // 4 dp padding keeps three text lines inside the 72 dp row.
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: tokens.s4,
          horizontal: horizontalPadding,
        ),
        child: Row(
          children: [
            avatar,
            SizedBox(width: tokens.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      // FR-028: created from a recurring rule. Inline, so
                      // the row height is unchanged.
                      if (view.isRecurring) ...[
                        SizedBox(width: tokens.s4),
                        Icon(
                          Icons.repeat,
                          key: ValueKey('repeat_icon_${t.id}'),
                          size: tokens.chipIconSize,
                          color: theme.colorScheme.onSurfaceVariant,
                          semanticLabel: l10n.expense_recurringLabel,
                        ),
                      ],
                    ],
                  ),
                  if (t.note case final note?)
                    Text(
                      note,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: muted,
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.s8),
            AmountText(
              amountMinor: t.amountMinor,
              currencyCode: currency,
              kind: amountKindFor(t.type),
              showSign: !t.isTransfer,
              style: theme.textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}
