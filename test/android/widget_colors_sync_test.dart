import 'dart:io';

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tool/android/widget_colors.dart';

/// The widget's Android colors match the app tokens (feature 008 T137a,
/// Constitution V, spec §15.2). `UPDATE_WIDGET_COLORS=1` rewrites them.
void main() {
  Map<String, Color> tokens({required bool dark}) {
    final scheme = (dark ? AppTheme.dark() : AppTheme.light()).colorScheme;
    return {
      'widget_surface': scheme.surface,
      'widget_on_surface': scheme.onSurface,
      'widget_on_surface_variant': scheme.onSurfaceVariant,
      'widget_success': dark ? AppColors.successDark : AppColors.successLight,
      'widget_warning': dark ? AppColors.warningDark : AppColors.warningLight,
      'widget_expense': dark ? AppColors.expenseDark : AppColors.expenseLight,
    };
  }

  const res = 'android/app/src/main/res';

  for (final dark in [false, true]) {
    final folder = dark ? 'values-night' : 'values';
    test('$folder/widget_colors.xml matches the tokens', () {
      final xml = widgetColorsXml({
        for (final MapEntry(:key, :value) in tokens(dark: dark).entries)
          key: value.toARGB32(),
      }, night: dark);
      final file = File('$res/$folder/widget_colors.xml');
      if (Platform.environment['UPDATE_WIDGET_COLORS'] == '1') {
        file.writeAsStringSync(xml);
      }
      expect(file.readAsStringSync().replaceAll('\r\n', '\n'), xml);
    });

    test('${dark ? 'dark' : 'light'}: widget text meets 4.5:1 and status '
        'colors 3:1 on the surface', () {
      final t = tokens(dark: dark);
      final surface = t['widget_surface']!;
      double ratio(Color c) {
        final a = c.computeLuminance();
        final b = surface.computeLuminance();
        return (a > b ? a + 0.05 : b + 0.05) / (a > b ? b + 0.05 : a + 0.05);
      }

      for (final text in ['widget_on_surface', 'widget_on_surface_variant']) {
        expect(ratio(t[text]!), greaterThanOrEqualTo(4.5), reason: text);
      }
      for (final status in [
        'widget_success',
        'widget_warning',
        'widget_expense',
      ]) {
        expect(ratio(t[status]!), greaterThanOrEqualTo(3), reason: status);
      }
    });
  }
}
