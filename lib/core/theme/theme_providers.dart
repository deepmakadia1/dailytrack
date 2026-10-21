import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_providers.g.dart';

/// The color theme the app shows (FR-017, FR-020): the stored theme when it
/// is free or unlocked, otherwise Default teal. The stored choice is never
/// overwritten, so the premium theme comes back as soon as the gate says so
/// (e.g. the dev "Unlock all features" switch).
@Riverpod(keepAlive: true)
Stream<AppColorTheme> effectiveColorTheme(Ref ref) {
  final id = ref.watch(
    appSettingsProvider.select((s) => s.value?.selectedTheme ?? 'default'),
  );
  final theme = colorThemeById(id);
  final key = theme.featureKey;
  if (key == null) return Stream.value(theme);
  return ref
      .watch(featureGateProvider)
      .watch(key)
      .map((unlocked) => unlocked ? theme : appColorThemes.first);
}

/// Whether the theme [id] can be applied: always for a free theme,
/// otherwise live from the feature gate.
@riverpod
Stream<bool> colorThemeUnlocked(Ref ref, String id) {
  final key = colorThemeById(id).featureKey;
  if (key == null) return Stream.value(true);
  return ref.watch(featureGateProvider).watch(key);
}
