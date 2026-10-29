import 'dart:io';

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// The native splash (`flutter_native_splash` in pubspec.yaml) matches the
/// app's colors, so the handover to SYS-01 shows no flash (feature 012 T050,
/// research R6, spec FR-027).
void main() {
  final pubspec = File('pubspec.yaml').readAsStringSync();
  final block = pubspec.substring(
    pubspec.indexOf('flutter_native_splash:\n'),
    pubspec.indexOf('flutter_launcher_icons:\n'),
  );
  final android12 = block.substring(block.indexOf('android_12:'));

  Color hex(String source, String key) {
    final match = RegExp(
      '^\\s*$key:\\s*"#([0-9A-Fa-f]{6})"',
      multiLine: true,
    ).firstMatch(source);
    expect(match, isNotNull, reason: '$key in flutter_native_splash');
    return Color(int.parse('FF${match!.group(1)}', radix: 16));
  }

  /// Largest channel difference, 0–255.
  int distance(Color a, Color b) {
    int ch(double v) => (v * 255).round();
    return [
      (ch(a.r) - ch(b.r)).abs(),
      (ch(a.g) - ch(b.g)).abs(),
      (ch(a.b) - ch(b.b)).abs(),
    ].reduce((x, y) => x > y ? x : y);
  }

  test('the dark splash background is AppColors.splashDark, before and '
      'from Android 12', () {
    expect(hex(block, 'color_dark'), AppColors.splashDark);
    expect(hex(android12, 'color_dark'), AppColors.splashDark);
  });

  test('the light splash background is white, before and from Android 12', () {
    expect(hex(block, 'color'), const Color(0xFFFFFFFF));
    expect(hex(android12, 'color'), const Color(0xFFFFFFFF));
  });

  test("SYS-01's surface is close to the splash background in both themes, "
      'so the handover shows no flash', () {
    final light = AppTheme.light().colorScheme.surface;
    final dark = AppTheme.dark().colorScheme.surface;
    expect(distance(light, hex(block, 'color')), lessThanOrEqualTo(24));
    expect(distance(dark, hex(block, 'color_dark')), lessThanOrEqualTo(24));
  });

  test('the Android 12 icon background is the same in light and dark', () {
    expect(
      hex(android12, 'icon_background_color'),
      hex(android12, 'icon_background_color_dark'),
    );
  });
}
