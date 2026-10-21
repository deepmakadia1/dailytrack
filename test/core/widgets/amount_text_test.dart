import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  Text textOf(WidgetTester tester) => tester.widget<Text>(
    find.descendant(of: find.byType(AmountText), matching: find.byType(Text)),
  );

  AppTokens tokensOf(WidgetTester tester) =>
      AppTokens.of(tester.element(find.byType(AmountText)));

  testWidgets('expense shows −, Indian grouping, expense color and tabular '
      'figures', (tester) async {
    await tester.pumpWidget(
      themed(
        const AmountText(
          amountMinor: 123456700,
          currencyCode: 'INR',
          kind: AmountKind.expense,
          showSign: true,
        ),
      ),
    );
    final text = textOf(tester);
    expect(text.data, '−₹12,34,567.00');
    expect(text.style?.color, tokensOf(tester).expense);
    expect(
      text.style?.fontFeatures,
      contains(const FontFeature.tabularFigures()),
    );
  });

  testWidgets('income shows + and the income color', (tester) async {
    await tester.pumpWidget(
      themed(
        const AmountText(
          amountMinor: 1050,
          currencyCode: 'INR',
          kind: AmountKind.income,
          showSign: true,
        ),
      ),
    );
    final text = textOf(tester);
    expect(text.data, '+₹10.50');
    expect(text.style?.color, tokensOf(tester).income);
  });

  testWidgets('without showSign a positive amount has no sign', (tester) async {
    await tester.pumpWidget(
      themed(
        const AmountText(
          amountMinor: 1050,
          currencyCode: 'USD',
          kind: AmountKind.expense,
        ),
      ),
    );
    expect(textOf(tester).data, r'$10.50');
  });

  testWidgets('the semantics label contains the formatted amount', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        const AmountText(
          amountMinor: 123456700,
          currencyCode: 'INR',
          kind: AmountKind.expense,
          showSign: true,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(AmountText)).label,
      contains('₹12,34,567.00'),
    );
    semantics.dispose();
  });
}
