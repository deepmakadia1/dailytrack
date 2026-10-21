import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () => AppBottomSheet.show<void>(
              context,
              title: 'Pick one',
              child: const TextField(),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('has a title, a drag handle and 28 dp top corners', (
    tester,
  ) async {
    await openSheet(tester);
    expect(find.text('Pick one'), findsOneWidget);
    final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
    expect(sheet.showDragHandle, isTrue);
    final shape = sheet.shape! as RoundedRectangleBorder;
    expect(
      shape.borderRadius,
      const BorderRadius.vertical(top: Radius.circular(28)),
    );
  });

  testWidgets('pads its content above the keyboard', (tester) async {
    await openSheet(tester);
    final before = tester.getBottomLeft(find.byType(TextField)).dy;

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pumpAndSettle();

    final after = tester.getBottomLeft(find.byType(TextField)).dy;
    final dpr = tester.view.devicePixelRatio;
    expect(before - after, closeTo(300 / dpr, 1));
  });
}
