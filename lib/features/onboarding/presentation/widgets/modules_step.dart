import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:flutter/material.dart';

/// SYS-02 step 3: module toggles (at least one stays on) and the
/// "Coming soon" trackers.
class ModulesStep extends StatelessWidget {
  const new({
    required this.registry,
    required this.enabledModules,
    required this.onToggle,
    super.key,
    this.messageKey,
  });

  final ModuleRegistry registry;
  final List<String> enabledModules;
  final ValueChanged<String> onToggle;

  /// ARB key of the inline "keep one module on" message.
  final String? messageKey;

  static const Map<String, IconData> _comingSoonIcons = {
    'water': Icons.water_drop_outlined,
    'period': Icons.event_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final message = messageKey == null ? null : l10nByKey(l10n, messageKey!);

    return ListView(
      padding: EdgeInsets.symmetric(vertical: tokens.s24),
      children: [
        Text(
          l10n.onboarding_modulesTitle,
          style: theme.textTheme.headlineSmall,
        ),
        SizedBox(height: tokens.s16),
        for (final module in registry.all) ...[
          Card(
            child: SwitchListTile(
              key: Key('module_toggle_${module.id}'),
              secondary: CategoryAvatar(
                icon: module.icon,
                color: theme.colorScheme.primary,
                semanticLabel: module.displayName(context),
              ),
              title: Text(module.displayName(context)),
              value: enabledModules.contains(module.id),
              onChanged: (_) => onToggle(module.id),
            ),
          ),
          SizedBox(height: tokens.cardGap),
        ],
        Semantics(
          liveRegion: true,
          child: message == null
              ? const SizedBox.shrink()
              : Padding(
                  padding: EdgeInsets.only(bottom: tokens.s12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: theme.colorScheme.error),
                      SizedBox(width: tokens.s8),
                      Expanded(
                        child: Text(
                          message,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
        for (final soon in comingSoonModules) ...[
          Card(
            child: SwitchListTile(
              key: Key('module_soon_${soon.id}'),
              secondary: CategoryAvatar(
                icon: _comingSoonIcons[soon.id] ?? Icons.extension_outlined,
                color: theme.colorScheme.outline,
                semanticLabel: l10nByKey(l10n, soon.nameKey) ?? soon.id,
              ),
              title: Text(l10nByKey(l10n, soon.nameKey) ?? soon.id),
              subtitle: Text(l10n.common_comingSoon),
              value: false,
              onChanged: null,
            ),
          ),
          SizedBox(height: tokens.cardGap),
        ],
      ],
    );
  }
}
