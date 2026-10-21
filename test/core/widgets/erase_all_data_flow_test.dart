import 'dart:async';

import 'package:dailytrack/core/widgets/erase_all_data_flow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/widget_wrapper.dart';

/// The shared erase flow (feature 007 T039; FR-047, FR-048, US7-1 – US7-4).
void main() {
  Future<FakeAppResetService> open(
    WidgetTester tester, {
    FakeAppResetService? service,
  }) async {
    final reset = service ?? FakeAppResetService();
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => unawaited(showEraseAllDataFlow(context, reset)),
            child: const Text('erase'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('erase'));
    await tester.pumpAndSettle();
    return reset;
  }

  Future<void> typeAndConfirm(WidgetTester tester, String word) async {
    await tester.enterText(find.byKey(const Key('typed_confirm_field')), word);
    await tester.pump();
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await tester.pumpAndSettle();
  }

  testWidgets('US7-1 the first dialog lists what goes and that it is final', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('Erase all data?'), findsOneWidget);
    expect(
      find.textContaining('transactions, accounts, categories'),
      findsOneWidget,
    );
    expect(find.textContaining("can't be undone"), findsOneWidget);
  });

  testWidgets('US7-4 cancelling the first step erases nothing', (tester) async {
    final reset = await open(tester);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Type DELETE to confirm'), findsNothing);
    expect(reset.calls, 0);
  });

  testWidgets('US7-2 / US7-4 the second step needs DELETE; cancel there '
      'erases nothing', (tester) async {
    final reset = await open(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('typed_confirm_field')),
      'delete',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await tester.pump();
    expect(reset.calls, 0);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(reset.calls, 0);
  });

  testWidgets('US7-3 DELETE erases once and closes every dialog', (
    tester,
  ) async {
    final reset = await open(tester);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await typeAndConfirm(tester, 'DELETE');
    expect(reset.calls, 1);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('FR-048 a failure says nothing was deleted; Try again runs it '
      'again', (tester) async {
    final reset = await open(
      tester,
      service: FakeAppResetService()..failNext = Exception('disk'),
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await typeAndConfirm(tester, 'DELETE');
    expect(reset.calls, 1);
    expect(
      find.text("Couldn't erase your data. Nothing was deleted."),
      findsOneWidget,
    );
    expect(find.byKey(const Key('erase_progress')), findsNothing);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(reset.calls, 2);
    expect(find.byType(AlertDialog), findsNothing);
  });

  test('the confirmation word is DELETE in every language', () {
    expect(eraseConfirmWord, 'DELETE');
  });
}
