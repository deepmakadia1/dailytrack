import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

void main() {
  testWidgets('single select replaces the selection', (tester) async {
    Set<String>? last;
    await tester.pumpWidget(
      themed(
        ChipSelector<String>(
          options: const ['en', 'hi', 'gu'],
          selected: const {'en'},
          labelBuilder: (o) => o.toUpperCase(),
          onChanged: (s) => last = s,
        ),
      ),
    );
    await tester.tap(find.text('GU'));
    expect(last, {'gu'});
  });

  testWidgets('multi select toggles chips on and off', (tester) async {
    Set<int>? last;
    await tester.pumpWidget(
      themed(
        ChipSelector<int>(
          options: const [1, 2, 3],
          selected: const {1},
          multi: true,
          labelBuilder: (o) => 'Day $o',
          onChanged: (s) => last = s,
        ),
      ),
    );
    await tester.tap(find.text('Day 2'));
    expect(last, {1, 2});
    await tester.tap(find.text('Day 1'));
    expect(last, <int>{});
  });

  testWidgets('chips meet the 48 dp tap target guideline', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      themed(
        ChipSelector<String>(
          options: const ['a'],
          selected: const {},
          labelBuilder: (o) => o,
          onChanged: (_) {},
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    handle.dispose();
  });
}
