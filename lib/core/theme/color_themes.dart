import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:flutter/painting.dart';

/// One SET-04 color theme (feature 007 data-model §4). [id] is the stored
/// `selectedTheme` value and never changes.
final class AppColorTheme {
  const new({
    required this.id,
    required this.seed,
    required this.labelKey,
    this.isPremium = false,
  });

  final String id;
  final Color seed;

  /// ARB key of the display name (`theme_<id>`).
  final String labelKey;

  /// Gated by `FeatureKey.premiumTheme(id)` until unlocked.
  final bool isPremium;

  /// The gate key, or null for a free theme.
  FeatureKey? get featureKey => isPremium ? FeatureKey.premiumTheme(id) : null;
}

/// The SET-04 grid, in display order: 2 free, then 6 premium. Ids match
/// `colorThemeIds` in `core/settings/domain/app_settings.dart`.
const List<AppColorTheme> appColorThemes = [
  AppColorTheme(id: 'default', seed: AppColors.seed, labelKey: 'theme_default'),
  AppColorTheme(
    id: 'indigo',
    seed: AppColors.seedIndigo,
    labelKey: 'theme_indigo',
  ),
  AppColorTheme(
    id: 'saffron',
    seed: AppColors.seedSaffron,
    labelKey: 'theme_saffron',
    isPremium: true,
  ),
  AppColorTheme(
    id: 'forest',
    seed: AppColors.seedForest,
    labelKey: 'theme_forest',
    isPremium: true,
  ),
  AppColorTheme(
    id: 'rose',
    seed: AppColors.seedRose,
    labelKey: 'theme_rose',
    isPremium: true,
  ),
  AppColorTheme(
    id: 'midnight',
    seed: AppColors.seedMidnight,
    labelKey: 'theme_midnight',
    isPremium: true,
  ),
  AppColorTheme(
    id: 'ocean',
    seed: AppColors.seedOcean,
    labelKey: 'theme_ocean',
    isPremium: true,
  ),
  AppColorTheme(
    id: 'mono',
    seed: AppColors.seedMono,
    labelKey: 'theme_mono',
    isPremium: true,
  ),
];

/// The theme with [id]; an unknown id gives Default teal.
AppColorTheme colorThemeById(String id) => appColorThemes.firstWhere(
  (t) => t.id == id,
  orElse: () => appColorThemes.first,
);
