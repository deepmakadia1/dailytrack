import 'package:flutter/painting.dart';

/// The only file in the app that contains color literals (spec §15.2).
/// Everything else reads colors from the theme or `AppTokens`.
abstract final class AppColors {
  static const Color seed = Color(0xFF0F766E);

  // SET-04 color theme seeds (feature 007 data-model §4). Themes change only
  // the seed, never semantic colors (§15.9).
  static const Color seedIndigo = Color(0xFF4F46E5);
  static const Color seedSaffron = Color(0xFFD97706);
  static const Color seedForest = Color(0xFF15803D);
  static const Color seedRose = Color(0xFFE11D48);
  static const Color seedMidnight = Color(0xFF1E3A8A);
  static const Color seedOcean = Color(0xFF0369A1);
  static const Color seedMono = Color(0xFF525252);

  // Semantic colors, light theme.
  static const Color incomeLight = Color(0xFF15803D);
  static const Color expenseLight = Color(0xFFB91C1C);
  static const Color warningLight = Color(0xFFB45309);
  static const Color successLight = Color(0xFF15803D);

  // Semantic colors, dark theme.
  static const Color incomeDark = Color(0xFF4ADE80);
  static const Color expenseDark = Color(0xFFF87171);
  static const Color warningDark = Color(0xFFFBBF24);
  static const Color successDark = Color(0xFF4ADE80);

  /// Native splash dark background (mirrors `flutter_native_splash` config).
  static const Color splashDark = Color(0xFF191C1B);

  /// Fixed set of 16 category and habit colors. Each one has at least 3:1
  /// contrast against both themes' surfaces (checked in app_colors_test).
  static const List<Color> palette = [
    Color(0xFFD74242),
    Color(0xFFCA532B),
    Color(0xFFAD6925),
    Color(0xFF93761F),
    Color(0xFF52871D),
    Color(0xFF1D8B39),
    Color(0xFF1D8763),
    Color(0xFF1D8787),
    Color(0xFF2280A0),
    Color(0xFF2B7ACA),
    Color(0xFF4E71DA),
    Color(0xFF7B68DF),
    Color(0xFF9957DB),
    Color(0xFFBD3DD6),
    Color(0xFFD331AB),
    Color(0xFFD63D70),
  ];

  /// `#RRGGBB` form of a palette color, as stored in `colorHex` columns.
  static String toHex(Color color) {
    final rgb = color.toARGB32() & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  /// Parses a stored `#RRGGBB` color. Anything malformed falls back to the
  /// first palette color, so a bad row never breaks a screen.
  static Color fromHex(String hex) {
    final match = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(hex);
    if (match == null) return palette.first;
    return Color(0xFF000000 | int.parse(match.group(1)!, radix: 16));
  }
}
