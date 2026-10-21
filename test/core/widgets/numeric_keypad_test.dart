import 'package:dailytrack/core/utils/keypad_expression.dart';
import 'package:dailytrack/core/widgets/numeric_keypad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  late List<String> events;

  Future<void> pumpKeypad(WidgetTester tester) async {
    events = [];
    await tester.pumpWidget(
      themed(
        Align(
          alignment: Alignment.bottomCenter,
          child: NumericKeypad(
            onKey: (k) => events.add('key:$k'),
            onOperator: (o) => events.add('op:$o'),
            onBackspace: () => events.add('backspace'),
            onDone: () => events.add('done'),
          ),
        ),
      ),
    );
  }

  testWidgets('emits digits, decimal point, operators, backspace and done', (
    tester,
  ) async {
    await pumpKeypad(tester);
    for (final label in ['1', '0', '.', '9']) {
      await tester.tap(find.text(label));
    }
    for (final op in [
      KeypadExpression.plus,
      KeypadExpression.minus,
      KeypadExpression.times,
      KeypadExpression.divide,
      '=',
    ]) {
      await tester.tap(find.text(op));
    }
    await tester.tap(find.bySemanticsLabel('Delete'));
    await tester.tap(find.text('Done'));

    expect(events, [
      'key:1',
      'key:0',
      'key:.',
      'key:9',
      'op:+',
      'op:−',
      'op:×',
      'op:÷',
      'op:=',
      'backspace',
      'done',
    ]);
  });

  testWidgets('shows every digit and every key is at least 48 dp', (
    tester,
  ) async {
    await pumpKeypad(tester);
    for (var d = 0; d <= 9; d++) {
      expect(find.text('$d'), findsOneWidget);
    }
    final keys = find.byKey(const ValueKey('keypad_key'));
    expect(keys, findsNWidgets(18));
    for (final element in keys.evaluate()) {
      final size = tester.getSize(find.byWidget(element.widget));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
    }
  });

  testWidgets('backspace has a semantic label', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpKeypad(tester);
    expect(find.bySemanticsLabel('Delete'), findsOneWidget);
    semantics.dispose();
  });
}
