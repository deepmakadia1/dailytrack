import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// The 16 palette swatches for categories and accounts (§15.2: each passes
/// 3:1 against both themes' surfaces). The selected swatch shows a check
/// icon, so selection never relies on color alone. Reused by HAB-02 later.
class ColorPickerRow extends StatelessWidget {
  const new({required this.selectedHex, required this.onSelected, super.key});

  /// `#RRGGBB`, compared case-insensitively.
  final String selectedHex;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final surface = Theme.of(context).colorScheme.surface;
    const palette = AppColors.palette;
    return Wrap(
      spacing: tokens.s4,
      runSpacing: tokens.s4,
      children: [
        for (final (i, color) in palette.indexed)
          () {
            final hex = AppColors.toHex(color);
            final selected = hex.toUpperCase() == selectedHex.toUpperCase();
            return Semantics(
              key: ValueKey('color_$hex'),
              button: true,
              selected: selected,
              label: l10n.common_colorLabel(i + 1, palette.length),
              onTap: () => onSelected(hex),
              excludeSemantics: true,
              child: InkWell(
                onTap: () => onSelected(hex),
                customBorder: const CircleBorder(),
                child: SizedBox.square(
                  dimension: tokens.minTouchTarget,
                  child: Center(
                    child: Container(
                      width: tokens.avatarSize,
                      height: tokens.avatarSize,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                      child: selected
                          ? Icon(
                              Icons.check,
                              color: surface,
                              size: tokens.iconSize,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            );
          }(),
      ],
    );
  }
}
