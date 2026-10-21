import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:flutter/material.dart';

/// DSH-01 Coming soon card (clarification Q3, research R13): names the
/// upcoming trackers and offers a 48 dp "Dismiss" button.
class ComingSoonCard extends StatelessWidget {
  const new({required this.modules, required this.onDismiss, super.key});

  final List<ComingSoonModule> modules;
  final VoidCallback onDismiss;

  /// "Water and Period": names joined through the ARB list pattern, never
  /// by concatenation.
  static String namesOf(AppLocalizations l10n, List<ComingSoonModule> list) {
    final names = [for (final m in list) l10nByKey(l10n, m.nameKey) ?? m.id];
    if (names.isEmpty) return '';
    return names.reduce((a, b) => l10n.home_listPair(a, b));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return SummaryCard(
      key: const Key('home_coming_soon'),
      leading: CategoryAvatar(
        icon: Icons.upcoming_outlined,
        color: theme.colorScheme.secondary,
        semanticLabel: l10n.home_comingSoonTitle,
      ),
      title: l10n.home_comingSoonTitle,
      actionChip: IconButton(
        key: const Key('home_coming_soon_dismiss'),
        tooltip: l10n.home_comingSoonDismiss,
        constraints: BoxConstraints.tightFor(
          width: tokens.minTouchTarget,
          height: tokens.minTouchTarget,
        ),
        onPressed: onDismiss,
        icon: const Icon(Icons.close),
      ),
      value: Text(l10n.home_comingSoonBody(namesOf(l10n, modules))),
    );
  }
}
