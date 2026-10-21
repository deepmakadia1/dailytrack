import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (name, theme) in [
    ('light', AppTheme.light()),
    ('dark', AppTheme.dark()),
  ]) {
    group('$name theme', () {
      test('uses Material 3 with AppTokens attached', () {
        expect(theme.useMaterial3, isTrue);
        expect(theme.extension<AppTokens>(), isNotNull);
      });

      test('type scale matches spec §15.2', () {
        final t = theme.textTheme;
        void check(TextStyle? s, double size, FontWeight weight) {
          expect(s?.fontSize, size);
          expect(s?.fontWeight, weight);
        }

        check(t.displaySmall, 36, FontWeight.w600);
        check(t.headlineSmall, 24, FontWeight.w600);
        check(t.titleMedium, 16, FontWeight.w600);
        check(t.bodyMedium, 14, FontWeight.w400);
        check(t.bodySmall, 12, FontWeight.w400);
        check(t.labelLarge, 14, FontWeight.w600);
        check(t.labelSmall, 11, FontWeight.w600);
      });

      test('navigation bar is 80 dp with labels always shown', () {
        expect(theme.navigationBarTheme.height, 80);
        expect(
          theme.navigationBarTheme.labelBehavior,
          NavigationDestinationLabelBehavior.alwaysShow,
        );
      });

      test('cards are flat', () {
        expect(theme.cardTheme.elevation, 0);
      });
    });
  }

  test('dark tokens dim habit fills to 85%', () {
    expect(AppTheme.dark().extension<AppTokens>()!.habitDoneDarkOpacity, 0.85);
    expect(AppTheme.light().extension<AppTokens>()!.habitDoneDarkOpacity, 1);
  });
}
