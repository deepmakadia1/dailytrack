import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart' show immutable;

/// Text that must be drawn by a shaping engine before it goes into a PDF
/// (feature 008 research R12): the `pdf` package maps code points straight
/// to glyphs and has no OpenType GSUB/GPOS support, so Devanagari and
/// Gujarati conjuncts and vowel signs would come out wrong.
@immutable
final class ShapedTextRequest {
  const new(this.text, {required this.fontSize, this.bold = false});

  final String text;

  /// PDF points.
  final double fontSize;
  final bool bold;

  String get key => '$fontSize|${bold ? 1 : 0}|$text';

  @override
  bool operator ==(Object other) =>
      other is ShapedTextRequest && other.key == key;

  @override
  int get hashCode => key.hashCode;
}

/// A shaped string as an image, sized in PDF points.
final class ShapedImage {
  const new({required this.png, required this.widthPt, required this.heightPt});

  final Uint8List png;
  final double widthPt;
  final double heightPt;
}

/// Draws text with a full shaping engine (the Flutter implementation uses
/// `TextPainter` with the bundled Noto fonts). Tests use a recording fake.
abstract interface class ShapedTextRenderer {
  Future<ShapedImage> render(ShapedTextRequest request);
}

/// True when [text] has an Indic code point (U+0900–U+0DFF: Devanagari
/// through Sinhala, which covers Hindi and Gujarati).
bool needsShaping(String text) =>
    text.runes.any((c) => c >= 0x0900 && c <= 0x0DFF);
