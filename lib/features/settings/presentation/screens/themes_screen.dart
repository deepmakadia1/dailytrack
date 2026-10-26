import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:dailytrack/core/theme/theme_providers.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/controllers/themes_controller.dart';
import 'package:dailytrack/features/settings/presentation/widgets/theme_preview_card.dart';
import 'package:dailytrack/features/settings/presentation/widgets/theme_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Smallest color tile width; the grid fits as many as the screen allows.
const double _minTileWidth = 96;

/// SET-04 Themes and appearance (spec §10, feature 007 contracts/screens.md):
/// live preview, theme mode, 8 color themes (6 gated by `FeatureGate`), and
/// font size. Every change applies at once. No ads (§11).
class ThemesScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(themesControllerProvider);
    return AppScaffold(
      title: l10n.themes_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) => _ThemesBody(state: value),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: () => ref.invalidate(appSettingsProvider),
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 4)),
      },
    );
  }
}

class _ThemesBody extends ConsumerWidget {
  const new({required this.state});

  final ThemesState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    final controller = ref.read(themesControllerProvider.notifier);
    final preview = colorThemeById(state.previewThemeId);
    final previewLocked =
        !(ref.watch(colorThemeUnlockedProvider(preview.id)).value ??
            !preview.isPremium);

    Widget heading(String text) => Padding(
      padding: EdgeInsets.only(top: tokens.s24, bottom: tokens.s8),
      child: Semantics(
        header: true,
        child: Text(text, style: textTheme.titleSmall),
      ),
    );

    return ListView(
      key: const Key('themes_list'),
      padding: EdgeInsets.all(tokens.screenPadding),
      children: [
        ThemePreviewCard(
          theme: preview,
          themeMode: state.themeMode,
          locked: previewLocked,
          onWatchAd: () => unawaited(unlockThemeWithAd(context, ref, preview)),
          onGetPro: () => unawaited(context.push(Routes.premium)),
        ),
        heading(l10n.themes_mode),
        ChipSelector<String>(
          key: const Key('themes_mode'),
          options: themeModeIds,
          selected: {state.themeMode},
          labelBuilder: (mode) => switch (mode) {
            'light' => l10n.themes_light,
            'dark' => l10n.themes_dark,
            _ => l10n.themes_system,
          },
          onChanged: (s) => unawaited(controller.setThemeMode(s.first)),
        ),
        heading(l10n.themes_colors),
        LayoutBuilder(
          builder: (context, constraints) {
            final perRow = (constraints.maxWidth / _minTileWidth).floor().clamp(
              1,
              appColorThemes.length,
            );
            final width =
                (constraints.maxWidth - tokens.s8 * (perRow - 1)) / perRow;
            return Wrap(
              spacing: tokens.s8,
              runSpacing: tokens.s8,
              children: [
                for (final theme in appColorThemes)
                  SizedBox(
                    width: width,
                    child: _Tile(
                      theme: theme,
                      selected: theme.id == state.selectedThemeId,
                    ),
                  ),
              ],
            );
          },
        ),
        heading(l10n.themes_fontSize),
        ChipSelector<String>(
          key: const Key('themes_font_size'),
          options: fontSizeIds,
          selected: {state.fontSize},
          labelBuilder: (size) =>
              size == 'large' ? l10n.themes_fontLarge : l10n.themes_fontDefault,
          onChanged: (s) => unawaited(controller.setFontSize(s.first)),
        ),
      ],
    );
  }
}

/// A tile that follows its own gate answer, so lock badges disappear live
/// when the theme is unlocked (US5-4).
class _Tile extends ConsumerWidget {
  const new({required this.theme, required this.selected});

  final AppColorTheme theme;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked =
        ref.watch(colorThemeUnlockedProvider(theme.id)).value ??
        !theme.isPremium;
    return ThemeTile(
      theme: theme,
      selected: selected,
      locked: !unlocked,
      onTap: () async {
        await ref
            .read(themesControllerProvider.notifier)
            .tapTheme(theme.id, unlocked: unlocked);
        // A locked theme is previewed, then PRM-02 offers it (spec SET-04).
        if (!unlocked && context.mounted) {
          await unlockThemeWithAd(context, ref, theme);
        }
      },
    );
  }
}

/// PRM-02 for [theme]: an earned reward unlocks it for good and applies it
/// (spec SET-04, feature 009 FR-031).
Future<void> unlockThemeWithAd(
  BuildContext context,
  WidgetRef ref,
  AppColorTheme theme,
) async {
  final key = theme.featureKey;
  if (key == null) return;
  final name =
      l10nByKey(AppLocalizations.of(context), theme.labelKey) ?? theme.id;
  final controller = ref.read(themesControllerProvider.notifier);
  final unlocked = await showRewardedUnlock(context, key, subjectName: name);
  if (unlocked) await controller.tapTheme(theme.id, unlocked: true);
}
