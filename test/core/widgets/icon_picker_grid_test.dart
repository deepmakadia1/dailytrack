import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/widgets/icon_picker_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  Widget picker(String selected, ValueChanged<String> onSelected) => themed(
    SingleChildScrollView(
      child: IconPickerGrid(selectedKey: selected, onSelected: onSelected),
    ),
  );

  testWidgets('shows every icon in its group and reports the tapped key', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(picker('restaurant', (k) => picked = k));
    for (final key in AppIcons.keys) {
      expect(find.byKey(ValueKey('icon_$key')), findsOneWidget, reason: key);
    }
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Money'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('icon_local_cafe')));
    expect(picked, 'local_cafe');
  });

  testWidgets('selection is a check, not color alone; cells are 48 dp and '
      'labelled', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(picker('local_cafe', (_) {}));
    final cafe = find.byKey(const ValueKey('icon_local_cafe'));
    expect(
      find.descendant(of: cafe, matching: find.byIcon(Icons.check_circle)),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    final size = tester.getSize(cafe);
    expect(size.width, greaterThanOrEqualTo(48));
    expect(size.height, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(cafe),
      isSemantics(
        label: 'Cafe',
        isButton: true,
        isSelected: true,

        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });

  testWidgets('labels translate', (tester) async {
    await tester.pumpWidget(
      themed(
        SingleChildScrollView(
          child: IconPickerGrid(selectedKey: 'x', onSelected: (_) {}),
        ),
        locale: const Locale('gu'),
      ),
    );
    expect(find.text('ખોરાક'), findsOneWidget, reason: 'Food group');
  });
}
