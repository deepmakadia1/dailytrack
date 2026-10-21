import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'themes_controller.freezed.dart';
part 'themes_controller.g.dart';

/// SET-04 state (feature 007 contracts/screens.md "SET-04").
@freezed
abstract class ThemesState with _$ThemesState {
  const factory({
    /// `system`, `light`, or `dark`.
    required String themeMode,

    /// The stored color theme id (may be a locked premium theme).
    required String selectedThemeId,

    /// The theme in the preview card. Equals [selectedThemeId] until the
    /// user taps a locked theme, which is previewed but never stored.
    required String previewThemeId,

    /// `default` or `large`.
    required String fontSize,
  }) = _ThemesState;
}

/// SET-04 controller (FR-015 – FR-021, research R12).
@riverpod
class ThemesController extends _$ThemesController {
  /// A locked theme the user tapped; screen-local, never persisted.
  String? _preview;

  @override
  Future<ThemesState> build() async {
    final settings = await ref.watch(appSettingsProvider.future);
    return ThemesState(
      themeMode: settings.themeMode,
      selectedThemeId: settings.selectedTheme,
      previewThemeId: _preview ?? settings.selectedTheme,
      fontSize: settings.fontSize,
    );
  }

  Future<void> setThemeMode(String mode) =>
      ref.read(settingsRepositoryProvider).setThemeMode(mode);

  Future<void> setFontSize(String size) =>
      ref.read(settingsRepositoryProvider).setFontSize(size);

  /// A free or unlocked theme is applied and stored at once. A locked one
  /// is only previewed behind the locked-feature overlay (US5-3).
  Future<void> tapTheme(String id, {required bool unlocked}) async {
    final current = state.value;
    if (unlocked) {
      _preview = null;
      await ref.read(settingsRepositoryProvider).setSelectedTheme(id);
      return;
    }
    _preview = colorThemeById(id).id;
    if (current != null) {
      state = AsyncData(current.copyWith(previewThemeId: _preview!));
    }
  }
}
