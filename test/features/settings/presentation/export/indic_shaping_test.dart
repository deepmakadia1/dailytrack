import 'dart:io';
import 'dart:ui' as ui;

import 'package:dailytrack/features/settings/domain/export/shaped_text_renderer.dart';
import 'package:dailytrack/features/settings/presentation/export/flutter_shaped_text_renderer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> _loadFont(String family, String file) async {
  final bytes = File('assets/fonts/$file').readAsBytesSync();
  await (FontLoader(
    family,
  )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
}

/// SET-03 AC "Gujarati and Hindi notes render correctly in ... PDF"
/// (feature 008 T082 spike, T085, research R12): Flutter's renderer shapes
/// Devanagari and Gujarati conjuncts with the bundled Noto fonts, while the
/// `pdf` package does not, which is why the PDF builder sends Indic text
/// to the renderer.
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFont('NotoSans', 'NotoSans-Regular.ttf');
    await _loadFont('NotoSansDevanagari', 'NotoSansDevanagari-Regular.ttf');
    await _loadFont('NotoSansGujarati', 'NotoSansGujarati-Regular.ttf');
  });

  double flutterWidth(String text) =>
      FlutterShapedTextRenderer.layout(ShapedTextRequest(text, fontSize: 40))
          .width;

  // The parts of each conjunct: consonant + virama + consonant.
  const conjuncts = {
    'Gujarati ksha': ('ક્ષ', ['ક', '્', 'ષ']),
    'Hindi ksha': ('क्ष', ['क', '्', 'ष']),
    'Hindi tra': ('त्र', ['त', '्', 'र']),
  };

  for (final MapEntry(key: name, value: (word, parts)) in conjuncts.entries) {
    test('SET-03 AC Flutter shapes the $name conjunct into one cluster '
        '(narrower than its letters side by side)', () {
      final shaped = flutterWidth(word);
      final unshaped = parts.map(flutterWidth).reduce((a, b) => a + b);
      expect(shaped, greaterThan(0));
      expect(shaped, lessThan(unshaped * 0.9), reason: word);
    });
  }

  test('spike: the pdf package lays out the same conjunct letter by letter '
      '(no shaping), so it must not draw Indic text itself', () {
    final doc = PdfDocument();
    final font = pw.Font.ttf(
      ByteData.sublistView(
        File('assets/fonts/NotoSansGujarati-Regular.ttf').readAsBytesSync(),
      ),
    ).getFont(pw.Context(document: doc));
    final whole = font.stringMetrics('ક્ષ').advanceWidth;
    final letters = [
      'ક',
      '્',
      'ષ',
    ].map((c) => font.stringMetrics(c).advanceWidth).reduce((a, b) => a + b);
    expect(whole, closeTo(letters, 1e-6));
  });

  testWidgets('render returns a PNG sized in points for Gujarati and Hindi', (
    tester,
  ) async {
    await tester.runAsync(() async {
      const renderer = FlutterShapedTextRenderer();
      for (final text in ['આજે ચા ક્ષમા', 'दूध क्षमा']) {
        final image = await renderer.render(
          ShapedTextRequest(text, fontSize: 10),
        );
        expect(image.png.sublist(1, 4), 'PNG'.codeUnits, reason: text);
        expect(image.widthPt, greaterThan(10));
        expect(image.heightPt, greaterThan(5));
        final codec = await ui.instantiateImageCodec(image.png);
        final frame = await codec.getNextFrame();
        // 3 pixels per point.
        expect(frame.image.width, (image.widthPt * 3).round());
      }
    });
  });
}
