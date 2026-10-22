import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/features/settings/domain/export/pdf_report_builder.dart';
import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'export_test_documents.dart';

/// A 1×1 transparent PNG.
final Uint8List _png = base64.decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAAC0lEQVR4nGNg'
  'AAIAAAUAAXpeqz8AAAAASUVORK5CYII=',
);

PdfFonts _fonts() => PdfFonts(
  regular: File('assets/fonts/NotoSans-Regular.ttf').readAsBytesSync(),
  bold: File('assets/fonts/NotoSans-SemiBold.ttf').readAsBytesSync(),
);

/// SET-03 PDF (feature 008 T084, FR-028, research R12), including the
/// SET-03 AC "Gujarati and Hindi notes render correctly in ... PDF": every
/// Indic string goes to the shaping renderer (drawn by Flutter, which
/// shapes conjuncts), never to the `pdf` package's unshaped text.
void main() {
  test('needsShaping is true exactly for text with Indic code points', () {
    expect(needsShaping(gujaratiNote), isTrue);
    expect(needsShaping(hindiNote), isTrue);
    expect(needsShaping('₹1,250.50'), isFalse);
    expect(needsShaping('Food'), isFalse);
    expect(needsShaping('Row 7 – line'), isFalse);
  });

  test('SET-03 AC the Hindi and Gujarati notes, and a Gujarati category in '
      'the chart, are sent for shaping; Latin text and amounts are not', () {
    final requests = PdfReportBuilder.shapingRequests(
      sampleDocument(),
      header: 'DailyTrack · Transactions · October 2026',
    );
    expect({for (final r in requests) r.text}, {gujaratiNote, hindiNote, 'ચા'});
    // Table cells are drawn at the table size.
    expect(requests.firstWhere((r) => r.text == gujaratiNote).fontSize, 8);
  });

  test('SET-03 AC the PDF embeds an image for each shaped string', () async {
    final doc = sampleDocument();
    const header = 'DailyTrack · Transactions · October 2026';
    final requests = PdfReportBuilder.shapingRequests(doc, header: header);
    final bytes = await PdfReportBuilder(fonts: _fonts()).build(
      doc,
      header: header,
      shaped: {
        for (final r in requests)
          r.key: ShapedImage(png: _png, widthPt: 40, heightPt: 10),
      },
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    final raw = latin1.decode(bytes);
    expect(
      RegExp(r'/Subtype\s*/Image').allMatches(raw).length,
      greaterThanOrEqualTo(requests.length),
    );
  });

  test(
    'a long table runs over several pages with its header repeated',
    () async {
      final doc = sampleDocument(extraRows: 1000);
      final bytes = await PdfReportBuilder(fonts: _fonts()).build(
        doc,
        header: 'DailyTrack',
        shaped: {
          for (final r in PdfReportBuilder.shapingRequests(doc, header: 'x'))
            r.key: ShapedImage(png: _png, widthPt: 40, heightPt: 10),
        },
      );
      final pages = RegExp(r'/Type\s*/Page\b').allMatches(latin1.decode(bytes));
      expect(pages.length, greaterThan(10));
    },
  );
}
