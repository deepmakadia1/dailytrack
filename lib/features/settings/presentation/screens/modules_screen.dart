import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_lookup.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/controllers/modules_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-06 Modules (spec §6, contracts/screens.md): reorder the trackers and
/// turn them on or off. Each row also offers "Move up" and "Move down"
/// accessibility actions (feature 006 R16). The order drives Home, the +
/// menu, and the tabs. No ads (§11).
class ModulesScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(modulesControllerProvider);
    final controller = ref.read(modulesControllerProvider.notifier);

    return AppScaffold(
      title: l10n.modules_title,
      body: switch (async) {
        // Keep showing the rows while a settings write reloads them.
        AsyncValue(:final value?) => _ModulesList(
          state: value,
          registry: ref.watch(moduleRegistryProvider),
          onToggle: controller.toggle,
          onReorder: controller.reorder,
        ),
        AsyncError() => ErrorState(
          message: l10n.modules_errorMessage,
          onRetry: controller.retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 2)),
      },
    );
  }
}

class _ModulesList extends StatelessWidget {
  const new({
    required this.state,
    required this.registry,
    required this.onToggle,
    required this.onReorder,
  });

  final ModulesState state;
  final ModuleRegistry registry;
  final ValueChanged<String> onToggle;
  final void Function(int oldIndex, int newIndex) onReorder;

  static const Map<String, IconData> _comingSoonIcons = {
    'water': Icons.water_drop_outlined,
    'period': Icons.event_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final message = state.messageKey == null
        ? null
        : l10nByKey(l10n, state.messageKey!);

    return ReorderableListView(
      buildDefaultDragHandles: false,
      padding: EdgeInsets.symmetric(vertical: tokens.s16),
      onReorderItem: onReorder,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            liveRegion: true,
            child: message == null
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(bottom: tokens.s12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.error,
                        ),
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
          SizedBox(height: tokens.s8),
          Text(l10n.common_comingSoon, style: theme.textTheme.titleMedium),
          SizedBox(height: tokens.s8),
          for (final soon in comingSoonModules) ...[
            Card(
              child: SwitchListTile(
                key: Key('modules_soon_${soon.id}'),
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
      ),
      children: [
        for (final (index, row) in state.rows.indexed)
          if (registry.byId(row.id) case final module?)
            Padding(
              key: ValueKey(row.id),
              padding: EdgeInsets.only(bottom: tokens.cardGap),
              // TalkBack can reorder without dragging (FR-034). Indexes
              // follow onReorderItem: the target index after removal.
              child: Semantics(
                key: Key('modules_row_${row.id}'),
                container: true,
                customSemanticsActions: {
                  if (index > 0)
                    CustomSemanticsAction(label: l10n.modules_moveUp): () =>
                        onReorder(index, index - 1),
                  if (index < state.rows.length - 1)
                    CustomSemanticsAction(label: l10n.modules_moveDown): () =>
                        onReorder(index, index + 1),
                },
                child: _ModuleCard(
                  module: module,
                  index: index,
                  enabled: row.enabled,
                  onToggle: () => onToggle(row.id),
                ),
              ),
            ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const new({
    required this.module,
    required this.index,
    required this.enabled,
    required this.onToggle,
  });

  final TrackerModule module;
  final int index;
  final bool enabled;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final name = module.displayName(context);

    return Card(
      child: Row(
        children: [
          ReorderableDragStartListener(
            key: Key('modules_handle_${module.id}'),
            index: index,
            child: SizedBox.square(
              dimension: tokens.minTouchTarget,
              child: Icon(
                Icons.drag_handle,
                semanticLabel: l10n.modules_reorderHandle(name),
              ),
            ),
          ),
          Expanded(
            child: SwitchListTile(
              key: Key('modules_toggle_${module.id}'),
              contentPadding: EdgeInsetsDirectional.only(end: tokens.s16),
              secondary: CategoryAvatar(
                icon: module.icon,
                color: theme.colorScheme.primary,
                semanticLabel: name,
              ),
              title: Text(name),
              value: enabled,
              onChanged: (_) => onToggle(),
            ),
          ),
        ],
      ),
    );
  }
}
