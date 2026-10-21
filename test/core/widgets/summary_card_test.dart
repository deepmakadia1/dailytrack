import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('shows title, value, progress and action chip', (tester) async {
    await tester.pumpWidget(
      themed(
        SummaryCard(
          title: 'This month',
          value: const Text('₹1,200.00'),
          progress: const LinearProgressIndicator(value: 0.5),
          actionChip: ActionChip(
            label: const Text('Details'),
            onPressed: () {},
          ),
        ),
      ),
    );
    expect(find.text('This month'), findsOneWidget);
    expect(find.text('₹1,200.00'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
  });

  testWidgets('uses a flat card with 16 dp corners', (tester) async {
    await tester.pumpWidget(
      themed(const SummaryCard(title: 'T', value: Text('v'))),
    );
    final card = Theme.of(tester.element(find.byType(Card))).cardTheme;
    expect(card.elevation, 0);
    final shape = card.shape! as RoundedRectangleBorder;
    expect(shape.borderRadius, BorderRadius.circular(16));
  });
}
