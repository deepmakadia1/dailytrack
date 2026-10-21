import 'package:dailytrack/core/widgets/typed_confirm_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// TypedConfirmDialog (feature 007 T039, FR-047).
void main() {
  late Future<bool> result;

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => result = TypedConfirmDialog.show(
              context,
              title: 'Type DELETE to confirm',
              word: 'DELETE',
              confirmLabel: 'Erase everything',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  FilledButton button(WidgetTester tester) => tester.widget<FilledButton>(
    find.byKey(const Key('typed_confirm_button')),
  );

  testWidgets('the button works only for the exact word', (tester) async {
    await open(tester);
    for (final almost in ['delete', 'DELETE ', 'DELET', 'Delete']) {
      await tester.enterText(
        find.byKey(const Key('typed_confirm_field')),
        almost,
      );
      await tester.pump();
      expect(button(tester).onPressed, isNull, reason: almost);
    }
    await tester.enterText(
      find.byKey(const Key('typed_confirm_field')),
      'DELETE',
    );
    await tester.pump();
    expect(button(tester).onPressed, isNotNull);
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await tester.pumpAndSettle();
    expect(await result, isTrue);
  });

  testWidgets('cancel returns false; the field has no autocorrect and the '
      'button uses the error color', (tester) async {
    await open(tester);
    final field = tester.widget<TextField>(
      find.byKey(const Key('typed_confirm_field')),
    );
    expect(field.autocorrect, isFalse);
    expect(field.enableSuggestions, isFalse);
    final context = tester.element(find.byType(TypedConfirmDialog));
    expect(
      button(tester).style?.backgroundColor?.resolve({}),
      Theme.of(context).colorScheme.error,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await result, isFalse);
  });
}
