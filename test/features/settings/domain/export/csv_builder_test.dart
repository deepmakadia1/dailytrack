import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/features/settings/domain/export/csv_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'export_test_documents.dart';

/// SET-03 CSV (feature 008 T083, FR-027, research R13), including the
/// SET-03 AC "Gujarati and Hindi notes render correctly in ... CSV".
void main() {
  final bytes = const CsvBuilder().build(sampleDocument());

  test('SET-03 AC CSV starts with the UTF-8 byte-order mark, so Excel reads '
      'it as UTF-8', () {
    expect(bytes.sublist(0, 3), [0xEF, 0xBB, 0xBF]);
  });

  test('SET-03 AC Gujarati and Hindi notes are the exact UTF-8 bytes of the '
      'original text', () {
    String find(List<int> needle) {
      final haystack = String.fromCharCodes(bytes);
      return haystack.contains(String.fromCharCodes(needle)) ? 'found' : '';
    }

    expect(find(utf8.encode(gujaratiNote)), 'found');
    // The Hindi note is quoted (it has a comma and quotes): "" doubles.
    expect(find(utf8.encode('"दूध, ब्रेड ""और"" क्षमा"')), 'found');
    // Decoding gives back every field as written, conjuncts intact.
    final rows = Csv().decode(utf8.decode(bytes.sublist(3)));
    expect(rows[1][3], gujaratiNote);
    expect(rows[2][3], hindiNote);
    expect(rows[1][3], contains('ક્ષ'));
    expect(rows[2][3], contains('क्ष'));
  });

  test('header row, CRLF line endings, and quoted line breaks', () {
    final text = utf8.decode(bytes.sublist(3));
    expect(text.startsWith('Date,Type,Amount,Note\r\n'), isTrue);
    expect(text, contains('"line one\nline two"'));
    final rows = Csv().decode(text);
    expect(rows, hasLength(4));
    expect(rows[3][3], 'line one\nline two');
  });

  test('amounts are plain decimals in major units: no symbol, no grouping', () {
    final rows = Csv().decode(utf8.decode(bytes.sublist(3)));
    expect(
      [for (final r in rows.skip(1)) r[2]],
      ['1250.50', '999999999.00', '0.05'],
    );
    expect(
      const MoneyCell(500, fractionDigits: 0, display: '¥500').plain,
      '500',
    );
    expect(
      const MoneyCell(1234, fractionDigits: 3, display: 'KD1.234').plain,
      '1.234',
    );
  });
}
