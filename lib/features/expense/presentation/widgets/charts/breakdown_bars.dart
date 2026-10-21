import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// The label of a bar: the account name or the payment mode.
String barLabel(AppLocalizations l10n, BarItem item) => switch (item) {
  BarItem(:final mode?) => l10n.paymentMode(mode),
  BarItem(:final account?) => l10n.accountName(account),
  _ => l10n.expense_account,
};

/// EXP-11 Accounts (US5 s4): one bar chart (by account or by payment mode),
/// with every bar labeled by name and amount in the rows below.
class BreakdownBars extends StatelessWidget {
  const new({
    required this.title,
    required this.items,
    required this.maxYMinor,
    required this.currencyCode,
    super.key,
  });

  final String title;
  final List<BarItem> items;
  final int maxYMinor;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    String money(int v) => MoneyFormatter.format(v, currencyCode: currencyCode);
    final summary = l10n.expense_reportChartSummaryBars(
      title,
      [
        for (final b in items)
          l10n.expense_reportChartSummaryBarItem(
            barLabel(l10n, b),
            money(b.amountMinor),
          ),
      ].join(', '),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleMedium),
        SizedBox(height: tokens.s8),
        Semantics(
          label: summary,
          excludeSemantics: true,
          child: SizedBox(
            height: tokens.s48 * 3,
            child: BarChart(
              BarChartData(
                maxY: maxYMinor.toDouble(),
                barTouchData: const BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  for (final (i, b) in items.indexed)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: b.amountMinor.toDouble(),
                          color: color,
                          width: tokens.s24,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(tokens.radiusChip),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.s8),
        for (final b in items)
          Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.s4),
            child: Row(
              children: [
                Expanded(child: Text(barLabel(l10n, b))),
                AmountText(
                  amountMinor: b.amountMinor,
                  currencyCode: currencyCode,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
