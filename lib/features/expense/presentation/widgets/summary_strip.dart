import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/domain/entities/period_ledger.dart';
import 'package:flutter/material.dart';

/// EXP-01 summary strip: Income, Expense and Net for every matching row,
/// transfers excluded (FR-018). Signs as well as colors (§15.2).
class SummaryStrip extends StatelessWidget {
  const new({required this.ledger, required this.currency, super.key});

  final PeriodLedger ledger;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final net = ledger.netMinor;

    Widget cell(Key key, String label, Widget amount) => Expanded(
      child: Column(
        key: key,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: tokens.s4),
          FittedBox(child: amount),
        ],
      ),
    );

    return Card(
      child: Padding(
        padding: EdgeInsets.all(tokens.s12),
        child: Row(
          children: [
            cell(
              const Key('summary_income'),
              l10n.expense_income,
              AmountText(
                amountMinor: ledger.incomeMinor,
                currencyCode: currency,
                kind: AmountKind.income,
                showSign: true,
                style: theme.textTheme.titleMedium,
              ),
            ),
            cell(
              const Key('summary_expense'),
              l10n.expense_expense,
              AmountText(
                amountMinor: ledger.expenseMinor,
                currencyCode: currency,
                kind: AmountKind.expense,
                showSign: true,
                style: theme.textTheme.titleMedium,
              ),
            ),
            cell(
              const Key('summary_net'),
              l10n.expense_net,
              AmountText(
                amountMinor: net.abs(),
                currencyCode: currency,
                kind: net < 0 ? AmountKind.expense : AmountKind.income,
                showSign: net != 0,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
