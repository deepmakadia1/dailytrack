import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// HAB-03 weekly bar chart (FR-032): completions per week for the last 12
/// weeks. The only `fl_chart` importer in the habit feature (research R13);
/// the bars are described as text for screen readers.
class WeeklyBarsChart extends StatelessWidget {
  const new({required this.bars, required this.color, super.key});

  final List<WeekBar> bars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final date = DateFormat.MMMd(l10n.localeName);
    String label(WeekBar b) => date.format(
      DateTime(b.weekStart.year, b.weekStart.month, b.weekStart.day),
    );
    final summary = l10n.habit_weeklyChartSummary(
      [for (final b in bars) l10n.habit_weeklyChartItem(label(b), b.done)]
          .join(', '),
    );
    final maxY = bars.fold(0, (m, b) => b.done > m ? b.done : m);

    return Semantics(
      label: summary,
      excludeSemantics: true,
      child: SizedBox(
        height: tokens.s48 * 3,
        child: BarChart(
          BarChartData(
            maxY: (maxY < 7 ? 7 : maxY).toDouble(),
            barTouchData: const BarTouchData(enabled: false),
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              leftTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: tokens.s24,
                  getTitlesWidget: (value, meta) {
                    final i = value.toInt();
                    // Every third week, so labels never overlap.
                    if (i % 3 != 2 || i >= bars.length) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      label(bars[i]),
                      style: theme.textTheme.labelSmall,
                    );
                  },
                ),
              ),
            ),
            barGroups: [
              for (final (i, b) in bars.indexed)
                BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: b.done.toDouble(),
                      color: color,
                      width: tokens.s12,
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
    );
  }
}
