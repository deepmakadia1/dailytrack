import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/settings/domain/export/csv_builder.dart';
import 'package:dailytrack/features/settings/domain/export/pdf_report_builder.dart';
import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';

/// How an export ended (data-model §9 "Export run").
sealed class ExportOutcome {
  const new();
}

/// The format is locked; no file was made.
final class ExportLocked extends ExportOutcome {
  const new();
}

/// Nothing matched the period and filters; no file was made.
final class ExportNothing extends ExportOutcome {
  const new();
}

/// Building or writing the file failed; no file was shared.
final class ExportFailed extends ExportOutcome {
  const new(this.error);

  final Object error;
}

/// The file is ready to share.
final class ExportReady extends ExportOutcome {
  const new({required this.path, required this.mimeType});

  final String path;
  final String mimeType;
}

/// SET-03 export (FR-026 – FR-032, feature 008 research R12 – R15):
/// gate check, build, write, and only then use up a one-time unlock, so a
/// failed or empty export keeps it (clarification Q2). Pro and the dev
/// debug switch are never used up.
class ExportUseCase {
  new({
    required this._gate,
    required this._unlocks,
    required this._cacheDir,
    required this._fonts,
    required this._renderer,
  });

  final FeatureGate _gate;
  final UnlockRepository _unlocks;
  final Future<Directory> Function() _cacheDir;
  final Future<PdfFonts> Function() _fonts;
  final ShapedTextRenderer _renderer;

  Future<ExportOutcome> run(
    ExportDataset dataset,
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  ) async {
    final key = request.format.featureKey;
    if (!await _gate.isUnlocked(key)) return const ExportLocked();
    try {
      final doc = await dataset.build(request, context, read);
      if (doc.isEmpty) return const ExportNothing();
      final Uint8List bytes;
      switch (request.format) {
        case ExportFormat.csv:
          bytes = const CsvBuilder().build(doc);
        case ExportFormat.pdf:
          final header = context.l10n.export_pdfHeader(
            doc.title,
            doc.periodLabel,
          );
          final shaped = <String, ShapedImage>{
            for (final r in PdfReportBuilder.shapingRequests(
              doc,
              header: header,
            ))
              r.key: await _renderer.render(r),
          };
          bytes = await PdfReportBuilder(fonts: await _fonts())
              .build(doc, header: header, shaped: shaped);
      }
      final file = await _write(
        'dailytrack_${dataset.id}_${periodSlug(request.period)}'
        '.${request.format.extension}',
        bytes,
      );
      await _unlocks.consumeOne(key);
      return ExportReady(
        path: file.path,
        mimeType: switch (request.format) {
          ExportFormat.csv => 'text/csv',
          ExportFormat.pdf => 'application/pdf',
        },
      );
    } on Object catch (e) {
      return ExportFailed(e);
    }
  }

  /// One file in `<cache>/exports/`, replacing older exports.
  Future<File> _write(String name, Uint8List bytes) async {
    final dir = Directory('${(await _cacheDir()).path}/exports');
    if (dir.existsSync()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
    return await File('${dir.path}/$name').writeAsBytes(bytes, flush: true);
  }
}

/// The period part of an export file name (data-model §8): `2026-10` for a
/// month, `2026` for a year, a day key for a day, `start_end` otherwise.
String periodSlug(Period p) {
  final q = periodToQuery(p);
  final start = q['start']!;
  return switch (p) {
    MonthPeriod() => start.substring(0, 7),
    YearPeriod() => start.substring(0, 4),
    SingleDayPeriod() => start,
    WeekPeriod() || CustomPeriod() => '${start}_${q['end']}',
  };
}
