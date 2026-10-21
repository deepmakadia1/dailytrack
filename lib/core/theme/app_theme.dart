import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Material 3 light and dark themes built from a seed (spec §15.2). The
/// seed defaults to teal; SET-04 color themes pass their own (§15.9: only
/// the seed changes).
abstract final class AppTheme {
  static const String fontFamily = 'NotoSans';
  static const List<String> fontFallback = [
    'NotoSansDevanagari',
    'NotoSansGujarati',
  ];

  static ThemeData light({Color seed = AppColors.seed}) =>
      _build(Brightness.light, seed);

  static ThemeData dark({Color seed = AppColors.seed}) =>
      _build(Brightness.dark, seed);

  static ThemeData _build(Brightness brightness, Color seed) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );
    final tokens = brightness == Brightness.light
        ? AppTokens.light(scheme)
        : AppTokens.dark(scheme);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      fontFamilyFallback: fontFallback,
      textTheme: _textTheme,
      extensions: [tokens],
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainer,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusCard),
        ),
      ),
      appBarTheme: const AppBarTheme(scrolledUnderElevation: 0),
      navigationBarTheme: NavigationBarThemeData(
        height: tokens.navBarHeight,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusChip),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusChip),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(tokens.radiusSheet),
          ),
        ),
      ),
    );
  }

  static const TextTheme _textTheme = TextTheme(
    displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.w600),
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
    bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
  );
}
