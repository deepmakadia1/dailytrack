import 'package:dailytrack/core/widgets/share_capture.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// captureBoundaryPng (feature 005 T028).
void main() {
  testWidgets('renders a pumped boundary to PNG bytes', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox(
              width: 40,
              height: 20,
              child: ColoredBox(color: Color(0xFF0F766E)),
            ),
          ),
        ),
      ),
    );
    final png = await tester.runAsync(
      () => captureBoundaryPng(key, pixelRatio: 1),
    );
    expect(png, isNotNull);
    // The 8-byte PNG signature.
    expect(png!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  });

  testWidgets('returns null when the boundary is missing', (tester) async {
    await tester.pumpWidget(const SizedBox());
    expect(await captureBoundaryPng(GlobalKey()), isNull);
  });
}
