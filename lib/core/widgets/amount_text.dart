import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/money_formatter.dart';
import 'package:flutter/material.dart';

enum AmountKind { income, expense, neutral }

/// A money amount from integer minor units (§15.4): currency grouping,
/// optional +/− sign, income/expense color and tabular figures, so columns
/// of amounts line up.
class AmountText extends StatelessWidget {
  const new({
    required this.amountMinor,
    required this.currencyCode,
    super.key,
    this.kind = AmountKind.neutral,
    this.showSign = false,
    this.style,
  });

  final int amountMinor;
  final String currencyCode;
  final AmountKind kind;

  /// Shows + for income and − for expense.
  final bool showSign;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final sign = !showSign
        ? MoneySign.auto
        : switch (kind) {
            AmountKind.income => MoneySign.plus,
            AmountKind.expense => MoneySign.minus,
            AmountKind.neutral => MoneySign.auto,
          };
    final formatted = MoneyFormatter.format(
      amountMinor,
      currencyCode: currencyCode,
      sign: sign,
    );
    final color = switch (kind) {
      AmountKind.income => tokens.income,
      AmountKind.expense => tokens.expense,
      AmountKind.neutral => null,
    };
    final base = style ?? DefaultTextStyle.of(context).style;

    return Semantics(
      label: formatted,
      excludeSemantics: true,
      child: Text(
        formatted,
        style: base.copyWith(
          color: color,
          fontFeatures: [
            ...?base.fontFeatures,
            const FontFeature.tabularFigures(),
          ],
        ),
      ),
    );
  }
}
