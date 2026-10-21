import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  const cases = <(double, String)>[
    (0.5, 'success'),
    (0.85, 'warning'),
    (1.2, 'expense'),
  ];

  Color expected(AppTokens tokens, String name) => switch (name) {
    'success' => tokens.success,
    'warning' => tokens.warning,
    _ => tokens.expense,
  };

  for (final (ratio, name) in cases) {
    testWidgets('ProgressBarStatus at $ratio uses the $name color and a text '
        'label', (tester) async {
      await tester.pumpWidget(
        themed(ProgressBarStatus(ratio: ratio, label: 'label $ratio')),
      );
      final tokens = AppTokens.of(
        tester.element(find.byType(ProgressBarStatus)),
      );
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.color, expected(tokens, name));
      expect(bar.value, ratio.clamp(0, 1));
      expect(find.text('label $ratio'), findsOneWidget);
      expect(
        find.byIcon(Icons.error_outline),
        ratio > 1 ? findsOneWidget : findsNothing,
      );
    });

    testWidgets('ProgressRing at $ratio uses the $name color and a text '
        'label', (tester) async {
      await tester.pumpWidget(
        themed(ProgressRing(ratio: ratio, label: 'label $ratio')),
      );
      final tokens = AppTokens.of(tester.element(find.byType(ProgressRing)));
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(ring.color, expected(tokens, name));
      expect(find.text('label $ratio'), findsOneWidget);
      expect(
        find.byIcon(Icons.error_outline),
        ratio > 1 ? findsOneWidget : findsNothing,
      );
    });
  }

  test('thresholds: 0.8 and 1.0 are warning, just above 1.0 is over', () {
    expect(progressStatusOf(0.79), ProgressStatus.onTrack);
    expect(progressStatusOf(0.8), ProgressStatus.near);
    expect(progressStatusOf(1), ProgressStatus.near);
    expect(progressStatusOf(1.01), ProgressStatus.over);
  });
}
