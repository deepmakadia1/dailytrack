import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/widgets/color_picker_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  final first = AppColors.toHex(AppColors.palette.first);
  final third = AppColors.toHex(AppColors.palette[2]);

  testWidgets('shows the 16 palette colors and reports the tapped one', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      themed(ColorPickerRow(selectedHex: first, onSelected: (h) => picked = h)),
    );
    for (final c in AppColors.palette) {
      expect(
        find.byKey(ValueKey('color_${AppColors.toHex(c)}')),
        findsOneWidget,
      );
    }
    await tester.tap(find.byKey(ValueKey('color_$third')));
    expect(picked, third);
  });

  testWidgets('selection is shown by a check; swatches are 48 dp and '
      'labelled "Color N of 16"', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        ColorPickerRow(selectedHex: third.toLowerCase(), onSelected: (_) {}),
      ),
    );
    expect(find.byIcon(Icons.check), findsOneWidget);
    final swatch = find.byKey(ValueKey('color_$third'));
    expect(
      find.descendant(of: swatch, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(tester.getSize(swatch).width, greaterThanOrEqualTo(48));
    expect(
      tester.getSemantics(swatch),
      isSemantics(
        label: 'Color 3 of 16',
        isButton: true,
        isSelected: true,

        hasTapAction: true,
      ),
    );
    semantics.dispose();
  });
}
