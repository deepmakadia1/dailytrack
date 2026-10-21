import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// SET-01 date format (T047, feature 007 research R13, clarification Q5).
void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('hi');
    await initializeDateFormatting('gu');
  });

  final march5 = DateTime(2026, 3, 5, 14, 30);

  test('each format renders 5 March 2026 in English', () {
    expect(formatFullDate(march5, FullDateFormat.dMMMy, 'en'), '5 Mar 2026');
    expect(formatFullDate(march5, FullDateFormat.ddMMy, 'en'), '05/03/2026');
    expect(formatFullDate(march5, FullDateFormat.mmddy, 'en'), '03/05/2026');
    expect(formatFullDate(march5, FullDateFormat.iso, 'en'), '2026-03-05');
  });

  test('Hindi and Gujarati use their own month names', () {
    final hi = formatFullDate(march5, FullDateFormat.dMMMy, 'hi');
    final gu = formatFullDate(march5, FullDateFormat.dMMMy, 'gu');
    expect(hi, isNot(contains('Mar')));
    expect(gu, isNot(contains('Mar')));
    expect(hi, contains('2026'));
    expect(gu, contains('2026'));
  });

  test('formatFullDateTime appends the localized time', () {
    expect(
      formatFullDateTime(march5, FullDateFormat.ddMMy, 'en'),
      matches(RegExp(r'^05/03/2026 2:30\sPM$')),
    );
  });

  test('stored values map to formats; anything else is the default', () {
    expect(FullDateFormat.fromStorage('iso'), FullDateFormat.iso);
    expect(FullDateFormat.fromStorage('mmddy'), FullDateFormat.mmddy);
    expect(FullDateFormat.fromStorage('yyyy'), FullDateFormat.dMMMy);
    expect(
      [for (final f in FullDateFormat.values) f.name],
      ['dMMMy', 'ddMMy', 'mmddy', 'iso'],
    );
  });

  testWidgets('FullDateFormatScope.of falls back to the default without a '
      'scope', (tester) async {
    late FullDateFormat outside;
    late FullDateFormat inside;
    await tester.pumpWidget(
      Column(
        children: [
          Builder(
            builder: (context) {
              outside = FullDateFormatScope.of(context);
              return const SizedBox();
            },
          ),
          FullDateFormatScope(
            format: FullDateFormat.iso,
            child: Builder(
              builder: (context) {
                inside = FullDateFormatScope.of(context);
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
    expect(outside, FullDateFormat.dMMMy);
    expect(inside, FullDateFormat.iso);
  });
}
