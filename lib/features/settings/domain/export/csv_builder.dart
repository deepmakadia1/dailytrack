import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:dailytrack/core/export/export_document.dart';

/// Builds the SET-03 CSV (FR-027, feature 008 research R13): UTF-8 with a
/// byte-order mark, so Excel shows ₹ and Hindi and Gujarati text correctly;
/// CRLF line endings; RFC 4180 quoting for commas, quotes, and line breaks;
/// amounts as plain decimals in major units. Pure Dart.
final class CsvBuilder {
  const new();

  Uint8List build(ExportDocument doc) {
    final rows = [
      [for (final c in doc.columns) c.header],
      for (final row in doc.rows)
        [
          for (final cell in row)
            switch (cell) {
              TextCell(:final text) => text,
              MoneyCell() => cell.plain,
            },
        ],
    ];
    return utf8.encode(Csv(addBom: true).encode(rows));
  }
}
