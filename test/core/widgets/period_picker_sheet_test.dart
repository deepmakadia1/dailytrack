import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/period_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  final now = DateTime(2026, 10, 14, 10);

  Future<Period?> pick(
    WidgetTester tester,
    String kind, {
    Period? current,
    int firstDayOfWeek = 1,
  }) async {
    Period? result;
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await PeriodPickerSheet.show(
              context,
              current: current ?? MonthPeriod(now),
              firstDayOfWeek: firstDayOfWeek,
              now: now,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a period'), findsOneWidget);
    await tester.tap(find.text(kind));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('each kind returns the matching period around today', (
    tester,
  ) async {
    expect(await pick(tester, 'Day'), SingleDayPeriod(now));
    expect(
      await pick(tester, 'Week', firstDayOfWeek: 7),
      WeekPeriod(now, firstDayOfWeek: 7),
    );
    expect(await pick(tester, 'Year'), YearPeriod(now));
    expect(
      await pick(tester, 'Month', current: SingleDayPeriod(now)),
      MonthPeriod(now),
    );
  });

  testWidgets('a period not containing today anchors on its start', (
    tester,
  ) async {
    final march = MonthPeriod(DateTime(2026, 3));
    expect(
      await pick(tester, 'Day', current: march),
      SingleDayPeriod(DateTime(2026, 3)),
    );
  });

  testWidgets('custom opens the range picker and returns its range', (
    tester,
  ) async {
    Period? result;
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await PeriodPickerSheet.show(
              context,
              current: WeekPeriod(now, firstDayOfWeek: 1),
              firstDayOfWeek: 1,
              now: now,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom range'));
    await tester.pumpAndSettle();
    // The range picker opens with the current week preselected; save it.
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      result,
      CustomPeriod(DateTime(2026, 10, 12), DateTime(2026, 10, 18)),
    );
  });

  testWidgets('kinds hides options and lockedKinds marks them with a lock '
      '(EXP-11, feature 003)', (tester) async {
    Period? result;
    await tester.pumpWidget(
      themed(
        Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await PeriodPickerSheet.show(
              context,
              current: MonthPeriod(now),
              firstDayOfWeek: 1,
              now: now,
              kinds: const {
                PeriodKind.week,
                PeriodKind.month,
                PeriodKind.year,
                PeriodKind.custom,
              },
              lockedKinds: const {PeriodKind.year, PeriodKind.custom},
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Day'), findsNothing);
    expect(find.byIcon(Icons.lock), findsNWidgets(2));
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('period_kind_year')),
        matching: find.byIcon(Icons.lock),
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel(RegExp('Locked')), findsNWidgets(2));
    // A locked option is still selectable (its preview is shown blurred).
    await tester.tap(find.text('Year'));
    await tester.pumpAndSettle();
    expect(result, YearPeriod(now));
  });
}
