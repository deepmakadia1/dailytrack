import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:dailytrack/core/widgets/amount_text.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:dailytrack/core/widgets/progress_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-04 live preview (FR-019): a sample dashboard card in the previewed
/// color theme and the chosen mode. A locked theme is shown blurred behind
/// [LockedFeatureOverlay] with "Get Pro" disabled and no "Watch an ad"
/// (FR-018, research R12; rewarded unlocks arrive in T4.4).
class ThemePreviewCard extends ConsumerWidget {
  const new({
    required this.theme,
    required this.themeMode,
    required this.locked,
    super.key,
  });

  final AppColorTheme theme;
  final String themeMode;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dark = switch (themeMode) {
      'dark' => true,
      'light' => false,
      _ => MediaQuery.platformBrightnessOf(context) == Brightness.dark,
    };
    final data = dark
        ? AppTheme.dark(seed: theme.seed)
        : AppTheme.light(seed: theme.seed);
    final currency =
        ref.watch(appSettingsProvider).value?.currencyCode ?? 'INR';

    final sample = Theme(
      data: data,
      child: Builder(
        builder: (context) {
          final tokens = AppTokens.of(context);
          final textTheme = Theme.of(context).textTheme;
          final scheme = Theme.of(context).colorScheme;
          return Container(
            key: const Key('theme_preview_sample'),
            padding: EdgeInsets.all(tokens.s16),
            decoration: BoxDecoration(
              color: scheme.surface,
              borderRadius: BorderRadius.circular(tokens.radiusCard),
            ),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(tokens.s16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.themes_previewSpent,
                      style: textTheme.titleMedium,
                    ),
                    SizedBox(height: tokens.s8),
                    AmountText(
                      amountMinor: 1250000,
                      currencyCode: currency,
                      style: textTheme.headlineSmall,
                    ),
                    SizedBox(height: tokens.s12),
                    ProgressBarStatus(
                      ratio: 0.62,
                      label: l10n.themes_previewSpent,
                    ),
                    SizedBox(height: tokens.s12),
                    Wrap(
                      spacing: tokens.s8,
                      runSpacing: tokens.s8,
                      children: [
                        Chip(
                          avatar: Icon(
                            Icons.shopping_basket_outlined,
                            size: tokens.chipIconSize,
                          ),
                          label: Text(l10n.themes_previewChip),
                        ),
                        FilledButton(
                          onPressed: () {},
                          child: Text(l10n.expense_cardAdd),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );

    return Semantics(
      label: l10n.themes_preview,
      container: true,
      child: locked
          ? LockedFeatureOverlay(
              key: const Key('theme_preview_locked'),
              message: l10n.themes_lockedMessage,
              child: sample,
            )
          : ExcludeSemantics(child: IgnorePointer(child: sample)),
    );
  }
}
