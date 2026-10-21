import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// Grouped icon picker for categories and accounts (§15.4, research R14),
/// reused by HAB-02 later. 48 dp cells; the selected icon shows a ring AND a
/// check, never color alone, and every icon has a spoken label.
class IconPickerGrid extends StatelessWidget {
  const new({required this.selectedKey, required this.onSelected, super.key});

  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final MapEntry(key: group, value: keys)
            in AppIcons.groups.entries) ...[
          Padding(
            padding: EdgeInsets.only(top: tokens.s8, bottom: tokens.s4),
            child: Semantics(
              header: true,
              child: Text(
                l10nByKey(l10n, 'common_iconGroup_$group') ?? group,
                style: theme.textTheme.labelLarge,
              ),
            ),
          ),
          Wrap(
            spacing: tokens.s4,
            runSpacing: tokens.s4,
            children: [
              for (final key in keys)
                _IconCell(
                  key: ValueKey('icon_$key'),
                  icon: AppIcons.byKey(key),
                  label: l10nByKey(l10n, 'icon_$key') ?? key,
                  selected: key == selectedKey,
                  onTap: () => onSelected(key),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  const new({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    // The tooltip is visual only; the cell itself carries the label and the
    // tap action, so screen readers can select it.
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: tokens.minTouchTarget,
            height: tokens.minTouchTarget,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected ? scheme.primaryContainer : null,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
                width: selected ? tokens.s4 / 2 : tokens.s4 / 4,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  icon,
                  size: tokens.iconSize,
                  color: selected
                      ? scheme.onPrimaryContainer
                      : scheme.onSurfaceVariant,
                ),
                if (selected)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle,
                      size: tokens.s12 + tokens.s4,
                      color: scheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
