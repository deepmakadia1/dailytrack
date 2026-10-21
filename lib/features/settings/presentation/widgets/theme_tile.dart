import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:flutter/material.dart';

/// One SET-04 color theme: a seed swatch and its name, a check when
/// selected, and a lock icon plus a "Pro" chip while locked (never color
/// alone, FR-018).
class ThemeTile extends StatelessWidget {
  const new({
    required this.theme,
    required this.selected,
    required this.locked,
    required this.onTap,
    super.key,
  });

  final AppColorTheme theme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final name = l10nByKey(l10n, theme.labelKey) ?? theme.id;
    // The swatch is the theme's own primary color, with its matching
    // on-color for the icon, in the current brightness.
    final swatch = ColorScheme.fromSeed(
      seedColor: theme.seed,
      brightness: Theme.of(context).brightness,
    );
    final label = locked
        ? l10n.themes_tileLocked(name)
        : selected
        ? l10n.themes_tileSelected(name)
        : name;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        key: Key('theme_${theme.id}'),
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minHeight: tokens.minTouchTarget),
          padding: EdgeInsets.all(tokens.s8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(tokens.radiusCard),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              // Thicker when selected, alongside the check icon.
              width: selected ? tokens.s4 / 2 : tokens.s4 / 4,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: tokens.avatarSize / 2,
                backgroundColor: swatch.primary,
                child: selected
                    ? Icon(Icons.check, color: swatch.onPrimary)
                    : locked
                    ? Icon(Icons.lock, color: swatch.onPrimary)
                    : null,
              ),
              SizedBox(height: tokens.s8),
              Text(
                name,
                textAlign: TextAlign.center,
                style: textTheme.labelLarge,
              ),
              if (locked) ...[
                SizedBox(height: tokens.s4),
                Container(
                  key: Key('theme_${theme.id}_pro'),
                  padding: EdgeInsets.symmetric(horizontal: tokens.s8),
                  decoration: BoxDecoration(
                    color: scheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(tokens.radiusChip),
                  ),
                  child: Text(
                    l10n.themes_pro,
                    style: textTheme.labelSmall?.copyWith(
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
