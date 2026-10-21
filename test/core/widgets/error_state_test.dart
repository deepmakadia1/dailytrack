import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('shows the message and a localized "Try again" by default', (
    tester,
  ) async {
    var retries = 0;
    await tester.pumpWidget(
      themed(ErrorState(message: "Couldn't load", onRetry: () => retries++)),
    );
    expect(find.text("Couldn't load"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retries, 1);
  });

  testWidgets('uses the Gujarati retry label in Gujarati', (tester) async {
    await tester.pumpWidget(
      themed(
        ErrorState(message: 'x', onRetry: () {}),
        locale: const Locale('gu'),
      ),
    );
    expect(find.text('ફરી પ્રયાસ કરો'), findsOneWidget);
  });

  testWidgets('a custom label and secondary action can be given', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        ErrorState(
          message: 'x',
          onRetry: () {},
          retryLabel: 'Retry',
          secondaryAction: TextButton(
            onPressed: () {},
            child: const Text('Other'),
          ),
        ),
      ),
    );
    expect(find.text('Retry'), findsOneWidget);
    expect(find.text('Other'), findsOneWidget);
  });
}
