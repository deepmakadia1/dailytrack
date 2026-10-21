import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('blurs the child, shows a lock badge and two actions', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var ads = 0;
    var pro = 0;
    var childTaps = 0;
    await tester.pumpWidget(
      themed(
        LockedFeatureOverlay(
          onWatchAd: () => ads++,
          onGetPro: () => pro++,
          child: TextButton(
            onPressed: () => childTaps++,
            child: const Text('Report'),
          ),
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('Report'),
        matching: find.byType(ImageFiltered),
      ),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.bySemanticsLabel('Pro feature, locked'), findsOneWidget);

    await tester.tap(find.text('Watch an ad'));
    await tester.tap(find.text('Get Pro'));
    expect(ads, 1);
    expect(pro, 1);

    // The locked content can't be used or read out.
    await tester.tap(find.text('Report'), warnIfMissed: false);
    expect(childTaps, 0);
    expect(find.bySemanticsLabel('Report'), findsNothing);
    semantics.dispose();
  });

  testWidgets('actions are at least 48 dp tall', (tester) async {
    await tester.pumpWidget(
      themed(
        LockedFeatureOverlay(
          onWatchAd: () {},
          onGetPro: () {},
          child: const SizedBox(height: 300),
        ),
      ),
    );
    for (final label in ['Watch an ad', 'Get Pro']) {
      final button = find.ancestor(
        of: find.text(label),
        matching: find.byWidgetPredicate((w) => w is ButtonStyleButton),
      );
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
    }
  });

  // Feature 003 (T025, research R14): EXP-11 uses the overlay without ads.
  testWidgets('without onWatchAd and onGetPro: no "Watch an ad", a disabled '
      '"Get Pro" that is still announced, and the message', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        const LockedFeatureOverlay(
          message: 'Advanced reports are part of Pro.',
          child: Text('Trends'),
        ),
      ),
    );
    expect(find.text('Watch an ad'), findsNothing);
    expect(find.byIcon(Icons.play_circle_outline), findsNothing);
    final getPro = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Get Pro'),
    );
    expect(getPro.onPressed, isNull);
    expect(find.bySemanticsLabel('Get Pro'), findsOneWidget);
    expect(find.text('Advanced reports are part of Pro.'), findsOneWidget);
    // The blurred child stays out of the semantics tree.
    expect(find.bySemanticsLabel('Trends'), findsNothing);
    semantics.dispose();
  });
}
