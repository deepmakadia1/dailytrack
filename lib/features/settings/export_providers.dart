import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/features/settings/domain/export/export_use_case.dart';
import 'package:dailytrack/features/settings/domain/export/pdf_report_builder.dart';
import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:dailytrack/features/settings/presentation/export/flutter_shaped_text_renderer.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'export_providers.g.dart';

/// The bundled Noto Sans faces for PDF text (spec §12 fonts).
Future<PdfFonts> loadPdfFonts() async {
  Future<Uint8List> load(String name) async =>
      (await rootBundle.load('assets/fonts/$name')).buffer.asUint8List();
  return PdfFonts(
    regular: await load('NotoSans-Regular.ttf'),
    bold: await load('NotoSans-SemiBold.ttf'),
  );
}

/// Draws Hindi and Gujarati strings for the PDF. Tests override it.
@Riverpod(keepAlive: true)
ShapedTextRenderer shapedTextRenderer(Ref ref) =>
    const FlutterShapedTextRenderer();

/// SET-03 export (feature 008 research R12 – R15).
@riverpod
ExportUseCase exportUseCase(Ref ref) => ExportUseCase(
  gate: ref.watch(featureGateProvider),
  unlocks: ref.watch(unlockRepositoryProvider),
  cacheDir: getTemporaryDirectory,
  fonts: loadPdfFonts,
  renderer: ref.watch(shapedTextRendererProvider),
);
