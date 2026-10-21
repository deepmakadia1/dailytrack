import 'dart:math' as math;

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  final lightSurface = ColorScheme.fromSeed(seedColor: AppColors.seed).surface;
  final darkSurface = ColorScheme.fromSeed(
    seedColor: AppColors.seed,
    brightness: Brightness.dark,
  ).surface;

  test('palette has exactly 16 colors', () {
    expect(AppColors.palette, hasLength(16));
  });

  test('every palette color has >= 3:1 contrast on both theme surfaces', () {
    for (final color in AppColors.palette) {
      final hex = AppColors.toHex(color);
      expect(
        _contrast(color, lightSurface),
        greaterThanOrEqualTo(3),
        reason: '$hex on light',
      );
      expect(
        _contrast(color, darkSurface),
        greaterThanOrEqualTo(3),
        reason: '$hex on dark',
      );
    }
  });

  test('semantic text colors meet WCAG AA (4.5:1) on their surface', () {
    const light = [
      AppColors.incomeLight,
      AppColors.expenseLight,
      AppColors.warningLight,
      AppColors.successLight,
    ];
    const dark = [
      AppColors.incomeDark,
      AppColors.expenseDark,
      AppColors.warningDark,
      AppColors.successDark,
    ];
    for (final c in light) {
      expect(
        _contrast(c, lightSurface),
        greaterThanOrEqualTo(4.5),
        reason: AppColors.toHex(c),
      );
    }
    for (final c in dark) {
      expect(
        _contrast(c, darkSurface),
        greaterThanOrEqualTo(4.5),
        reason: AppColors.toHex(c),
      );
    }
  });

  test('toHex returns #RRGGBB', () {
    expect(AppColors.toHex(AppColors.seed), '#0F766E');
  });

  test('fromHex round-trips every palette color; bad input falls back', () {
    for (final c in AppColors.palette) {
      expect(AppColors.fromHex(AppColors.toHex(c)), c);
    }
    expect(AppColors.fromHex('#0f766e'), const Color(0xFF0F766E));
    expect(AppColors.fromHex('teal'), AppColors.palette.first);
  });
}
