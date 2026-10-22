import 'dart:ui' as ui;

import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:flutter/painting.dart';

/// Draws text with Flutter's shaping engine (HarfBuzz) and the bundled Noto
/// fonts, as a PNG at [pixelsPerPoint] for print quality (feature 008
/// research R12). Runs on the UI isolate; the export yields between items.
final class FlutterShapedTextRenderer implements ShapedTextRenderer {
  const new({this.pixelsPerPoint = 3});

  final double pixelsPerPoint;

  /// The bundled families (pubspec `fonts:`): Latin first, then the Indic
  /// scripts.
  static const String family = 'NotoSans';
  static const List<String> fallback = [
    'NotoSansDevanagari',
    'NotoSansGujarati',
  ];

  /// The text as Flutter lays it out, sized in points.
  static TextPainter layout(ShapedTextRequest request, {double scale = 1}) =>
      TextPainter(
        text: TextSpan(
          text: request.text,
          style: TextStyle(
            fontFamily: family,
            fontFamilyFallback: fallback,
            fontSize: request.fontSize * scale,
            fontWeight: request.bold ? FontWeight.w600 : FontWeight.w400,
            color: const Color(0xFF000000),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  @override
  Future<ShapedImage> render(ShapedTextRequest request) async {
    await Future<void>.delayed(Duration.zero);
    final painter = layout(request, scale: pixelsPerPoint);
    final width = painter.width.ceil().clamp(1, 1 << 14);
    final height = painter.height.ceil().clamp(1, 1 << 14);
    final recorder = ui.PictureRecorder();
    painter.paint(Canvas(recorder), Offset.zero);
    final image = await recorder.endRecording().toImage(width, height);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return ShapedImage(
        png: data!.buffer.asUint8List(),
        widthPt: width / pixelsPerPoint,
        heightPt: height / pixelsPerPoint,
      );
    } finally {
      image.dispose();
      painter.dispose();
    }
  }
}
