import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/features/expense/presentation/controllers/report_view_models.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// The display name of a donut slice ("Other" or the category).
String donutSliceName(AppLocalizations l10n, DonutSlice s) => s.isOther
    ? l10n.expense_reportOther
    : s.category == null
    ? l10n.expense_category
    : l10n.categoryName(s.category!);

/// EXP-11 Categories donut (US4 s3): expense by category with the total in
/// the middle. Tapping a slice calls [onSelect]; the selected one is drawn
/// larger. A text legend (name, amount, %) sits beside it in the screen.
class CategoryDonut extends StatelessWidget {
  const new({
    required this.vm,
    required this.currencyCode,
    required this.onSelect,
    super.key,
    this.selectedKey,
  });

  final DonutVm vm;
  final String currencyCode;
  final String? selectedKey;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final size = tokens.s48 * 4;
    final summary = l10n.expense_reportChartSummaryDonut(
      [
        for (final s in vm.slices)
          l10n.expense_reportChartSummaryItem(
            donutSliceName(l10n, s),
            s.percent,
          ),
      ].join(', '),
    );

    Color colorOf(DonutSlice s) => s.isOther || s.category == null
        ? theme.colorScheme.outline
        : colorFromHex(s.category!.colorHex);

    return Semantics(
      label: summary,
      excludeSemantics: true,
      child: SizedBox(
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                centerSpaceRadius: size / 4,
                sectionsSpace: tokens.s4 / 2,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    final i = response?.touchedSection?.touchedSectionIndex;
                    if (event is FlTapUpEvent &&
                        i != null &&
                        i >= 0 &&
                        i < vm.slices.length) {
                      onSelect(vm.slices[i].key);
                    }
                  },
                ),
                sections: [
                  for (final s in vm.slices)
                    PieChartSectionData(
                      value: s.amountMinor.toDouble(),
                      color: colorOf(s),
                      showTitle: false,
                      radius: s.key == selectedKey
                          ? size / 4 + tokens.s8
                          : size / 4,
                    ),
                ],
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.expense_reportTotalSpent,
                  style: theme.textTheme.bodySmall,
                ),
                AmountText(
                  amountMinor: vm.totalMinor,
                  currencyCode: currencyCode,
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
