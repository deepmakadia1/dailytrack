import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads the bundled Noto fonts and the SDK's Material Icons font before any
/// test runs, so text and icons render with real glyphs and goldens are
/// deterministic (research R11). Every family the theme names
/// (`AppTheme.fontFamily` and `AppTheme.fontFallback`) must be loaded here:
/// goldens must never fall back to the machine's system fonts (feature 012
/// research R7).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await _loadFamily('NotoSans', [
    'assets/fonts/NotoSans-Regular.ttf',
    'assets/fonts/NotoSans-SemiBold.ttf',
  ]);
  await _loadFamily('NotoSansDevanagari', [
    'assets/fonts/NotoSansDevanagari-Regular.ttf',
    'assets/fonts/NotoSansDevanagari-SemiBold.ttf',
  ]);
  await _loadFamily('NotoSansGujarati', [
    'assets/fonts/NotoSansGujarati-Regular.ttf',
    'assets/fonts/NotoSansGujarati-SemiBold.ttf',
  ]);
  // Icons too, so goldens show real glyphs instead of empty boxes.
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  if (flutterRoot != null) {
    await _loadFamily('MaterialIcons', [
      '$flutterRoot/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ]);
  }
  await testMain();
}

Future<void> _loadFamily(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}
