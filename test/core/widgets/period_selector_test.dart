import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/period_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  final now = DateTime(2026, 10, 14, 10);

  Widget selector(
    Period p, {
    ValueChanged<Period>? onChanged,
    VoidCallback? onPick,
  }) => themed(
    PeriodSelector(
      period: p,
      now: now,
      onChanged: onChanged ?? (_) {},
      onPick: onPick,
    ),
  );

  testWidgets('shows the month and steps back and forward', (tester) async {
    final changes = <Period>[];
    var picks = 0;
    await tester.pumpWidget(
      selector(
        MonthPeriod(DateTime(2026, 3)),
        onChanged: changes.add,
        onPick: () => picks++,
      ),
    );
    expect(find.text('March 2026'), findsOneWidget);

    await tester.tap(find.byTooltip('Previous month'));
    await tester.tap(find.byTooltip('Next month'));
    await tester.tap(find.text('March 2026'));
    expect(changes, [
      MonthPeriod(DateTime(2026, 2)),
      MonthPeriod(DateTime(2026, 4)),
    ]);
    expect(picks, 1);
  });

  testWidgets('day, week and year have their own labels and tooltips', (
    tester,
  ) async {
    final changes = <Period>[];
    await tester.pumpWidget(
      selector(SingleDayPeriod(now), onChanged: changes.add),
    );
    expect(find.text('Today'), findsOneWidget);
    await tester.tap(find.byTooltip('Previous day'));
    expect(changes.single, SingleDayPeriod(DateTime(2026, 10, 13)));

    await tester.pumpWidget(selector(WeekPeriod(now, firstDayOfWeek: 1)));
    expect(find.text('12 Oct – 18 Oct'), findsOneWidget);
    expect(find.byTooltip('Next week'), findsOneWidget);

    await tester.pumpWidget(selector(YearPeriod(now)));
    expect(find.text('2026'), findsOneWidget);
    expect(find.byTooltip('Previous year'), findsOneWidget);
  });

  testWidgets('a custom range hides the arrows', (tester) async {
    await tester.pumpWidget(
      selector(CustomPeriod(DateTime(2026, 10, 3), DateTime(2026, 10, 9))),
    );
    expect(find.text('3 Oct 2026 – 9 Oct 2026'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing);
  });

  testWidgets('arrows are at least 48 dp and labelled', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(selector(MonthPeriod(DateTime(2026, 10))));
    for (final label in ['Previous month', 'Next month']) {
      final size = tester.getSize(find.byTooltip(label));
      expect(size.width, greaterThanOrEqualTo(48));
      expect(size.height, greaterThanOrEqualTo(48));
      // IconButton exposes its tooltip to screen readers.
      final button = find.ancestor(
        of: find.byTooltip(label),
        matching: find.byType(IconButton),
      );
      expect(tester.getSemantics(button).tooltip, label);
    }
    semantics.dispose();
  });

  testWidgets('formats the month in Gujarati', (tester) async {
    await tester.pumpWidget(
      themed(
        PeriodSelector(
          period: MonthPeriod(DateTime(2026, 10)),
          now: now,
          onChanged: (_) {},
        ),
        locale: const Locale('gu'),
      ),
    );
    expect(find.textContaining('2026'), findsOneWidget);
    expect(find.text('October 2026'), findsNothing);
  });

  testWidgets('month-only mode shows the label as text, not a picker '
      '(EXP-08, feature 003)', (tester) async {
    final changes = <Period>[];
    await tester.pumpWidget(
      themed(
        PeriodSelector(
          period: MonthPeriod(DateTime(2026, 10)),
          now: now,
          onChanged: changes.add,
          onPick: () => fail('the picker must not open'),
          monthOnly: true,
        ),
      ),
    );
    expect(find.byType(TextButton), findsNothing);
    await tester.tap(find.text('October 2026'));
    await tester.tap(find.byTooltip('Next month'));
    expect(changes, [MonthPeriod(DateTime(2026, 11))]);
  });

  testWidgets('a locked period shows a labelled lock icon', (tester) async {
    await tester.pumpWidget(
      themed(
        PeriodSelector(
          period: MonthPeriod(DateTime(2026, 7)),
          now: now,
          onChanged: (_) {},
          locked: true,
        ),
      ),
    );
    expect(find.byKey(const Key('period_locked')), findsOneWidget);
    expect(find.bySemanticsLabel('Locked'), findsOneWidget);
  });
}
