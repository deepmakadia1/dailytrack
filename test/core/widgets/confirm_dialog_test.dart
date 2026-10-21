import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  late Future<bool> result;

  Future<void> open(WidgetTester tester, {bool destructive = true}) async {
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => result = ConfirmDialog.show(
              context,
              title: 'Delete habit?',
              consequence: 'Its history will be removed.',
              confirmLabel: 'Delete',
              destructive: destructive,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('confirm returns true', (tester) async {
    await open(tester);
    expect(find.text('Delete habit?'), findsOneWidget);
    expect(find.text('Its history will be removed.'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('cancel returns false', (tester) async {
    await open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('dismissing returns false', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });

  testWidgets('the destructive button uses colorScheme.error', (tester) async {
    await open(tester);
    final scheme = Theme.of(tester.element(find.text('Delete'))).colorScheme;
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Delete'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.style?.backgroundColor?.resolve({}), scheme.error);
    expect(button.style?.foregroundColor?.resolve({}), scheme.onError);
  });

  testWidgets('a non-destructive confirm uses the default style', (
    tester,
  ) async {
    await open(tester, destructive: false);
    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('Delete'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.style, isNull);
  });
}
