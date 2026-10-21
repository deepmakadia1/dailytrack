import 'dart:math' as math;

import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// SET-04 color theme catalog (T054, feature 007 data-model §4, FR-016).
void main() {
  test(
    'the catalog has the 8 ids in order; only default and indigo are free',
    () {
      expect([for (final t in appColorThemes) t.id], colorThemeIds);
      expect(
        [
          for (final t in appColorThemes)
            if (!t.isPremium) t.id,
        ],
        ['default', 'indigo'],
      );
      expect(colorThemeById('default').seed, AppColors.seed);
    },
  );

  test('an unknown id falls back to Default teal', () {
    expect(colorThemeById('neon').id, 'default');
  });

  for (final theme in appColorThemes) {
    for (final brightness in Brightness.values) {
      test('${theme.id} meets WCAG AA in ${brightness.name} mode', () {
        final scheme =
            (brightness == Brightness.light
                    ? AppTheme.light(seed: theme.seed)
                    : AppTheme.dark(seed: theme.seed))
                .colorScheme;
        expect(
          _contrast(scheme.onPrimary, scheme.primary),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrast(scheme.onSurface, scheme.surface),
          greaterThanOrEqualTo(4.5),
        );
        // SettingsSection headers (primary) and row subtitles
        // (onSurfaceVariant) on the screen surface (§15.10, T073).
        expect(
          _contrast(scheme.primary, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'section headers',
        );
        expect(
          _contrast(scheme.onSurfaceVariant, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'row subtitles',
        );
        // The error-colored "Erase all data" row.
        expect(
          _contrast(scheme.error, scheme.surface),
          greaterThanOrEqualTo(4.5),
          reason: 'destructive row',
        );
      });
    }
  }

  test('a seed changes only the color scheme, never the semantic colors or '
      'the text theme (FR-016, §15.9)', () {
    for (final brightness in Brightness.values) {
      final base = brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark();
      final themed = brightness == Brightness.light
          ? AppTheme.light(seed: AppColors.seedSaffron)
          : AppTheme.dark(seed: AppColors.seedSaffron);
      final a = base.extension<AppTokens>()!;
      final b = themed.extension<AppTokens>()!;
      expect(b.income, a.income);
      expect(b.expense, a.expense);
      expect(b.warning, a.warning);
      expect(b.success, a.success);
      // Same type scale; only the scheme-derived text colors may differ.
      for (final (x, y) in [
        (themed.textTheme.displaySmall, base.textTheme.displaySmall),
        (themed.textTheme.titleMedium, base.textTheme.titleMedium),
        (themed.textTheme.bodyMedium, base.textTheme.bodyMedium),
        (themed.textTheme.labelSmall, base.textTheme.labelSmall),
      ]) {
        expect(x?.fontSize, y?.fontSize);
        expect(x?.fontWeight, y?.fontWeight);
        expect(x?.fontFamily, y?.fontFamily);
      }
      expect(themed.colorScheme.primary, isNot(base.colorScheme.primary));
    }
  });
}
