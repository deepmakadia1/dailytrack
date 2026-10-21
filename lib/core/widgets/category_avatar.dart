import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';

/// An icon in a colored 40 dp circle, used for categories, accounts, habits
/// and modules (§15.2). Palette colors have ≥ 3:1 contrast against both theme
/// surfaces, so the surface color is used for the icon.
class CategoryAvatar extends StatelessWidget {
  const new({
    required this.icon,
    required this.color,
    required this.semanticLabel,
    super.key,
  });

  final IconData icon;
  final Color color;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Semantics(
      label: semanticLabel,
      image: true,
      excludeSemantics: true,
      child: Container(
        width: tokens.avatarSize,
        height: tokens.avatarSize,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(
          icon,
          size: tokens.iconSize,
          color: Theme.of(context).colorScheme.surface,
        ),
      ),
    );
  }
}
