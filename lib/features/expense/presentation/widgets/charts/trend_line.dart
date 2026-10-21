import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// EXP-11 Trends (US5 s3): spending per day (per month for a year), the
/// current period solid and the previous one dashed, with a legend that
/// names both lines and their totals (not color alone).
class TrendLine extends StatelessWidget {
  const new({required this.vm, required this.currencyCode, super.key});

  final TrendVm vm;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    String money(int v) => MoneyFormatter.format(v, currencyCode: currencyCode);

    LineChartBarData line(
      List<TrendPoint> points,
      Color color, {
      bool dashed = false,
    }) => LineChartBarData(
      spots: [
        for (final p in points) FlSpot(p.x.toDouble(), p.yMinor.toDouble()),
      ],
      color: color,
      barWidth: dashed ? tokens.s4 / 2 : tokens.s4 * 0.75,
      dashArray: dashed ? const [6, 4] : null,
      dotData: const FlDotData(show: false),
    );

    Widget legend(String label, int total, Widget swatch) => Row(
      children: [
        swatch,
        SizedBox(width: tokens.s8),
        Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
        AmountText(amountMinor: total, currencyCode: currencyCode),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          label: l10n.expense_reportChartSummaryTrend(
            money(vm.currentTotalMinor),
            money(vm.previousTotalMinor),
          ),
          excludeSemantics: true,
          child: SizedBox(
            height: tokens.s48 * 4,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: vm.maxYMinor.toDouble(),
                lineTouchData: const LineTouchData(enabled: false),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: const FlTitlesData(show: false),
                lineBarsData: [
                  line(vm.previous, scheme.outline, dashed: true),
                  line(vm.current, scheme.primary),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: tokens.s8),
        legend(
          l10n.expense_reportThisPeriod,
          vm.currentTotalMinor,
          Container(
            key: const Key('trend_legend_current'),
            width: tokens.s16,
            height: tokens.s4,
            color: scheme.primary,
          ),
        ),
        SizedBox(height: tokens.s4),
        legend(
          l10n.expense_reportPreviousPeriod,
          vm.previousTotalMinor,
          SizedBox(
            key: const Key('trend_legend_previous'),
            width: tokens.s16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (var i = 0; i < 2; i++)
                  Container(
                    width: tokens.s4 * 1.5,
                    height: tokens.s4 / 2,
                    color: scheme.outline,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
