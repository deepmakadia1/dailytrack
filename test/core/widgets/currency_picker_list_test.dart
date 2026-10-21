import 'package:dailytrack/core/widgets/currency_picker_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/widget_wrapper.dart';

/// CurrencyPickerList, shared by SYS-02 and SET-01 (feature 007 T052).
void main() {
  Future<List<String>> pump(
    WidgetTester tester, {
    String selected = 'INR',
    ValueChanged<String>? onQuery,
  }) async {
    final picked = <String>[];
    await tester.pumpWidget(
      themed(
        SizedBox(
          height: 600,
          child: CurrencyPickerList(
            selectedCode: selected,
            onSelected: picked.add,
            onQueryChanged: onQuery,
          ),
        ),
      ),
    );
    return picked;
  }

  testWidgets('marks the current currency and reports a tap', (tester) async {
    final picked = await pump(tester);
    final inr = tester.widget<ListTile>(find.byKey(const Key('currency_INR')));
    expect(inr.selected, isTrue);
    await tester.tap(find.byKey(const Key('currency_USD')));
    expect(picked, ['USD']);
  });

  testWidgets('search filters by code or name; no matches offers Clear '
      'search', (tester) async {
    final queries = <String>[];
    await pump(tester, onQuery: queries.add);
    await tester.enterText(find.byKey(const Key('currency_search')), 'dol');
    await tester.pump();
    expect(find.byKey(const Key('currency_USD')), findsOneWidget);
    expect(find.byKey(const Key('currency_INR')), findsNothing);

    await tester.enterText(find.byKey(const Key('currency_search')), 'zzz');
    await tester.pump();
    expect(find.text('No matches'), findsOneWidget);
    await tester.tap(find.text('Clear search'));
    await tester.pump();
    expect(find.byKey(const Key('currency_INR')), findsOneWidget);
    expect(queries.last, '');
  });
}
