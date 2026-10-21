import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets(
    'DelayedSkeleton shows nothing before 300 ms, then the skeleton',
    (tester) async {
      await tester.pumpWidget(
        themed(const DelayedSkeleton(child: SkeletonList(itemCount: 2))),
      );
      expect(find.byType(SkeletonCard), findsNothing);
      await tester.pump(const Duration(milliseconds: 299));
      expect(find.byType(SkeletonCard), findsNothing);
      await tester.pump(const Duration(milliseconds: 2));
      expect(find.byType(SkeletonCard), findsNWidgets(2));
      // Replace the pulsing skeleton so the test ends without pending frames.
      await tester.pumpWidget(themed(const SizedBox()));
    },
  );

  testWidgets('skeletons do not animate when animations are disabled', (
    tester,
  ) async {
    await tester.pumpWidget(
      themed(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SkeletonCard(),
        ),
      ),
    );
    double opacity() => tester
        .widget<FadeTransition>(
          find.descendant(
            of: find.byType(SkeletonCard),
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity
        .value;
    expect(opacity(), 1);
    await tester.pump(const Duration(milliseconds: 450));
    expect(opacity(), 1);
  });

  testWidgets('skeletons pulse when animations are enabled', (tester) async {
    await tester.pumpWidget(themed(const SkeletonCard()));
    final animation = tester
        .widget<FadeTransition>(
          find.descendant(
            of: find.byType(SkeletonCard),
            matching: find.byType(FadeTransition),
          ),
        )
        .opacity;
    final start = animation.value;
    await tester.pump(const Duration(milliseconds: 450));
    expect(animation.value, isNot(start));
    await tester.pumpWidget(themed(const SizedBox()));
  });
}
