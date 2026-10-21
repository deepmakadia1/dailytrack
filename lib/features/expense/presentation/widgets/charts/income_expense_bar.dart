import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// EXP-11 Overview "Income vs expense" (US4 s2): two bars with a text
/// legend and values, so meaning never rests on color (FR-047). Maps the
/// view model 1:1; no arithmetic beyond pixel scaling.
class IncomeExpenseBar extends StatelessWidget {
  const new({required this.vm, required this.currencyCode, super.key});

  final OverviewVm vm;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final maxY = niceCeil(
      vm.incomeMinor > vm.expenseMinor ? vm.incomeMinor : vm.expenseMinor,
    ).toDouble();
    String money(int v) => MoneyFormatter.format(v, currencyCode: currencyCode);

    BarChartGroupData group(int x, int value, Color color) => BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          color: color,
          width: tokens.s48,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusChip),
          ),
        ),
      ],
    );

    Widget legend(String label, int value, AmountKind kind, Color color) => Row(
      children: [
        Container(width: tokens.s12, height: tokens.s12, color: color),
        SizedBox(width: tokens.s8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        AmountText(
          amountMinor: value,
          currencyCode: currencyCode,
          kind: kind,
          showSign: true,
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.expense_reportChartSummaryBar(
            money(vm.incomeMinor),
            money(vm.expenseMinor),
          ),
          excludeSemantics: true,
          child: SizedBox(
            height: tokens.s48 * 3,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                alignment: BarChartAlignment.spaceEvenly,
                barTouchData: const BarTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                barGroups: [
                  group(0, vm.incomeMinor, tokens.income),
                  group(1, vm.expenseMinor, tokens.expense),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.s8),
        legend(
          l10n.expense_typeIncome,
          vm.incomeMinor,
          AmountKind.income,
          tokens.income,
        ),
        SizedBox(height: tokens.s4),
        legend(
          l10n.expense_typeExpense,
          vm.expenseMinor,
          AmountKind.expense,
          tokens.expense,
        ),
      ],
    );
  }
}
