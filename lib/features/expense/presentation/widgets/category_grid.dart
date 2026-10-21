import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/presentation/widgets/expense_labels.dart';
import 'package:flutter/material.dart';

/// EXP-02 category grid (T054): 4 columns, in the order given (usage, then
/// the EXP-04 order), ending with "+ New" when [onNew] is set. The selected
/// tile shows a ring and a check, not color alone.
class CategoryGrid extends StatelessWidget {
  const new({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    super.key,
    this.onNew,
  });

  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  /// Opens EXP-05 (wired in T091). Hidden while null.
  final VoidCallback? onNew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final labelStyle = theme.textTheme.bodySmall;
    final scaler = MediaQuery.textScalerOf(context);
    // Avatar + gap + two lines of label, scaled so 200% text never clips.
    final extent =
        tokens.avatarSize +
        tokens.s8 * 2 +
        tokens.s4 +
        scaler.scale((labelStyle?.fontSize ?? tokens.s12) * 1.4) * 2;

    final tiles = <Widget>[
      for (final c in categories)
        _Tile(
          key: ValueKey('category_${c.id}'),
          label: l10n.categoryName(c),
          selected: c.id == selectedId,
          onTap: () => onSelected(c.id),
          avatar: CategoryAvatar(
            icon: AppIcons.byKey(c.iconKey),
            color: colorFromHex(c.colorHex),
            semanticLabel: l10n.categoryName(c),
          ),
        ),
      if (onNew case final onNew?)
        _Tile(
          key: const ValueKey('category_new'),
          label: l10n.expense_newCategory,
          selected: false,
          onTap: onNew,
          avatar: CategoryAvatar(
            icon: Icons.add,
            color: theme.colorScheme.outline,
            semanticLabel: l10n.expense_newCategory,
          ),
        ),
    ];

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisExtent: extent,
        crossAxisSpacing: tokens.s4,
      ),
      children: tiles,
    );
  }
}

class _Tile extends StatelessWidget {
  const new({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.avatar,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget avatar;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final ring = theme.colorScheme.primary;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tokens.radiusChip),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.s8),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: selected ? ring : ring.withAlpha(0),
                        width: tokens.s4 / 2,
                      ),
                    ),
                    child: avatar,
                  ),
                  if (selected)
                    Positioned(
                      right: -tokens.s4,
                      bottom: -tokens.s4,
                      child: Icon(
                        Icons.check_circle,
                        size: tokens.chipIconSize,
                        color: ring,
                      ),
                    ),
                ],
              ),
              SizedBox(height: tokens.s4),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: selected ? FontWeight.w600 : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
