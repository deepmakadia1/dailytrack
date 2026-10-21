import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/dashboard_slot.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// DashboardSlot (T010, feature 006 research R3): the card gap only around
/// visible content, and animated height changes.
void main() {
  Widget slot(Widget child, {bool disableAnimations = false}) => themed(
    MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DashboardSlot(key: const Key('slot'), child: child),
          const SizedBox(key: Key('after'), height: 10),
        ],
      ),
    ),
  );

  double gapOf(WidgetTester tester) =>
      AppTokens.of(tester.element(find.byKey(const Key('slot')))).cardGap;

  testWidgets('adds a top gap of cardGap around a visible child', (
    tester,
  ) async {
    await tester.pumpWidget(slot(const SizedBox(height: 50)));
    await tester.pumpAndSettle();
    final gap = gapOf(tester);
    expect(gap, 12);
    expect(tester.getSize(find.byKey(const Key('slot'))).height, 50 + gap);
    final slotTop = tester.getTopLeft(find.byKey(const Key('slot'))).dy;
    final childTop = tester.getTopLeft(find.byType(SizedBox).first).dy;
    expect(childTop - slotTop, gap);
  });

  testWidgets('adds no height when the child is SizedBox.shrink()', (
    tester,
  ) async {
    await tester.pumpWidget(slot(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('slot'))).height, 0);
    expect(
      tester.getTopLeft(find.byKey(const Key('after'))).dy,
      tester.getTopLeft(find.byKey(const Key('slot'))).dy,
    );
  });

  testWidgets('animates a height change over 200 ms', (tester) async {
    await tester.pumpWidget(slot(const SizedBox.shrink()));
    await tester.pumpAndSettle();
    await tester.pumpWidget(slot(const SizedBox(height: 100)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = tester.getSize(find.byKey(const Key('slot'))).height;
    expect(mid, greaterThan(0));
    expect(mid, lessThan(112));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('slot'))).height, 112);
  });

  testWidgets('changes height instantly with disableAnimations', (
    tester,
  ) async {
    await tester.pumpWidget(
      slot(const SizedBox.shrink(), disableAnimations: true),
    );
    await tester.pumpWidget(
      slot(const SizedBox(height: 100), disableAnimations: true),
    );
    await tester.pump();
    expect(tester.getSize(find.byKey(const Key('slot'))).height, 112);
  });

  testWidgets('a tap below the gap hits the child; a tap in the gap does not', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      slot(
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => taps++,
          child: const SizedBox(height: 50),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(find.byKey(const Key('slot')));
    await tester.tapAt(topLeft + const Offset(20, 6));
    expect(taps, 0);
    await tester.tapAt(topLeft + const Offset(20, 14));
    expect(taps, 1);
  });
}
