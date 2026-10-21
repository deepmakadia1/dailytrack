import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('shows title, message and one action', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      themed(
        EmptyState(
          title: 'No expenses yet',
          message: 'Add your first expense',
          actionLabel: 'Add expense',
          onAction: () => tapped++,
        ),
      ),
    );
    expect(find.text('No expenses yet'), findsOneWidget);
    expect(find.text('Add your first expense'), findsOneWidget);
    await tester.tap(find.text('Add expense'));
    expect(tapped, 1);
  });

  testWidgets('has no button when no action is given', (tester) async {
    await tester.pumpWidget(themed(const EmptyState(title: 'Nothing here')));
    expect(find.byType(FilledButton), findsNothing);
  });
}
