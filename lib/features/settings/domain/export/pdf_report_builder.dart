import 'dart:isolate';
import 'dart:typed_data';

import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// The bundled Noto Sans faces used for Latin text, digits, and amounts.
final class PdfFonts {
  const new({required this.regular, required this.bold});

  final Uint8List regular;
  final Uint8List bold;
}

/// Text roles and their sizes (PDF points).
abstract final class _Size {
  static const double title = 18;
  static const double body = 10;
  static const double small = 9;
  static const double table = 8;
}

/// Builds the SET-03 PDF (FR-028, feature 008 research R12): a summary page
/// (title, period, filters, totals, and a category donut when there is
/// one), then the table, with headers repeated on every page. Pure Dart:
/// Indic strings arrive as shaped images from a [ShapedTextRenderer]; every
/// other string is vector text in Noto Sans.
final class PdfReportBuilder {
  const new({required this.fonts});

  final PdfFonts fonts;

  /// Every string the PDF draws that needs shaping, with its style. Render
  /// these first, then pass the images to [build].
  static Set<ShapedTextRequest> shapingRequests(
    ExportDocument doc, {
    required String header,
  }) {
    final requests = <ShapedTextRequest>{};
    void add(String text, double size, {bool bold = false}) {
      if (needsShaping(text)) {
        requests.add(ShapedTextRequest(text, fontSize: size, bold: bold));
      }
    }

    add(header, _Size.table);
    add(doc.title, _Size.title, bold: true);
    add(doc.periodLabel, _Size.body);
    for (final line in doc.filterLines) {
      add(line, _Size.small);
    }
    for (final (label, value) in doc.summary) {
      add(label, _Size.body);
      add(value, _Size.body, bold: true);
    }
    for (final slice in doc.chart ?? const <ExportSlice>[]) {
      add(slice.label, _Size.small);
    }
    for (final c in doc.columns) {
      add(c.header, _Size.table, bold: true);
    }
    for (final row in doc.rows) {
      for (final cell in row) {
        switch (cell) {
          case TextCell(:final text):
            add(text, _Size.table);
          case MoneyCell(:final display):
            add(display, _Size.table);
        }
      }
    }
    return requests;
  }

  /// The PDF bytes, built in a background isolate. [shaped] holds an image
  /// for every request from [shapingRequests], by its key.
  Future<Uint8List> build(
    ExportDocument doc, {
    required String header,
    required Map<String, ShapedImage> shaped,
  }) {
    final fonts = this.fonts;
    return Isolate.run(() => _build(doc, header, shaped, fonts));
  }

  static Future<Uint8List> _build(
    ExportDocument doc,
    String header,
    Map<String, ShapedImage> shaped,
    PdfFonts fonts,
  ) {
    final regular = pw.Font.ttf(ByteData.sublistView(fonts.regular));
    final bold = pw.Font.ttf(ByteData.sublistView(fonts.bold));
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    pw.Widget text(
      String s,
      double size, {
      bool isBold = false,
      pw.TextAlign align = pw.TextAlign.left,
    }) {
      final image =
          shaped[ShapedTextRequest(s, fontSize: size, bold: isBold).key];
      if (image != null) {
        return pw.Image(
          pw.MemoryImage(image.png),
          width: image.widthPt,
          height: image.heightPt,
        );
      }
      return pw.Text(
        s,
        textAlign: align,
        style: pw.TextStyle(
          fontSize: size,
          fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      );
    }

    final chart = doc.chart;
    final total = chart?.fold<int>(0, (sum, s) => sum + s.valueMinor) ?? 0;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        // Large exports run to many pages (10,000 rows ≈ 250).
        maxPages: 100000,
        header: (_) => pw.Container(
          alignment: pw.Alignment.centerLeft,
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: text(header, _Size.table),
        ),
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            '${context.pageNumber} / ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: _Size.table),
          ),
        ),
        build: (_) => [
          text(doc.title, _Size.title, isBold: true),
          pw.SizedBox(height: 4),
          text(doc.periodLabel, _Size.body),
          for (final line in doc.filterLines) text(line, _Size.small),
          pw.SizedBox(height: 16),
          pw.Table(
            columnWidths: const {
              0: pw.FlexColumnWidth(2),
              1: pw.FlexColumnWidth(),
            },
            children: [
              for (final (label, value) in doc.summary)
                pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: text(label, _Size.body),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(vertical: 2),
                      child: text(value, _Size.body, isBold: true),
                    ),
                  ],
                ),
            ],
          ),
          if (chart != null && total > 0) ...[
            pw.SizedBox(height: 16),
            pw.Row(
              children: [
                pw.SizedBox(
                  width: 160,
                  height: 160,
                  child: pw.Chart(
                    grid: pw.PieGrid(),
                    datasets: [
                      for (final s in chart)
                        pw.PieDataSet(
                          value: s.valueMinor,
                          color: PdfColor.fromHex(s.colorHex),
                          innerRadius: 45,
                          legendPosition: pw.PieLegendPosition.none,
                        ),
                    ],
                  ),
                ),
                pw.SizedBox(width: 24),
                pw.Expanded(
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      for (final s in chart)
                        pw.Padding(
                          padding: const pw.EdgeInsets.symmetric(vertical: 2),
                          child: pw.Row(
                            children: [
                              pw.Container(
                                width: 8,
                                height: 8,
                                color: PdfColor.fromHex(s.colorHex),
                              ),
                              pw.SizedBox(width: 6),
                              pw.Expanded(child: text(s.label, _Size.small)),
                              pw.Text(
                                '${(s.valueMinor * 100 / total).round()}%',
                                style: const pw.TextStyle(
                                  fontSize: _Size.small,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Table(
            border: const pw.TableBorder(
              horizontalInside: pw.BorderSide(
                color: PdfColors.grey300,
                width: 0.5,
              ),
            ),
            columnWidths: {
              for (final (i, c) in doc.columns.indexed)
                i: pw.FlexColumnWidth(c.flex),
            },
            children: [
              pw.TableRow(
                repeat: true,
                decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                children: [
                  for (final c in doc.columns)
                    _cell(text(c.header, _Size.table, isBold: true), c.align),
                ],
              ),
              for (final row in doc.rows)
                pw.TableRow(
                  children: [
                    for (final (i, cell) in row.indexed)
                      _cell(
                        text(switch (cell) {
                          TextCell(:final text) => text,
                          MoneyCell(:final display) => display,
                        }, _Size.table),
                        doc.columns[i].align,
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
    return pdf.save();
  }

  static pw.Widget _cell(pw.Widget child, ExportAlign align) => pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 3),
    alignment: align == ExportAlign.end
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    child: child,
  );
}
