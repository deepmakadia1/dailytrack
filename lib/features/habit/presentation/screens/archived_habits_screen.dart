import 'dart:async';

import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/empty_state.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/habit/presentation/controllers/archived_habits_controller.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// HAB-04 Archived habits (spec US6, FR-033): name, archive date, and best
/// streak, with Restore (Undo) and Delete permanently (confirmation).
class ArchivedHabitsScreen extends ConsumerWidget {
  const new({super.key});

  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    ArchivedHabitRow row,
  ) async {
    final l10n = AppLocalizations.of(context);
    final undo = await ref
        .read(archivedHabitsControllerProvider.notifier)
        .restore(row.habit.id);
    if (!context.mounted) return;
    if (undo == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      return;
    }
    UndoSnackBar.show(
      context,
      message: l10n.habit_restored,
      onUndo: () => unawaited(undo()),
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ArchivedHabitRow row,
  ) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.habit_deleteTitle,
      consequence: l10n.habit_deleteBody(row.habit.name),
      confirmLabel: l10n.habit_deleteConfirm,
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    final ok = await ref
        .read(archivedHabitsControllerProvider.notifier)
        .deletePermanently(row.habit.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? l10n.habit_deleted : l10n.habit_saveError)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(archivedHabitsControllerProvider);
    final dateFormat = FullDateFormatScope.of(context);

    return AppScaffold(
      title: l10n.habit_archivedTitle,
      // Spec §11: the bottom banner (no space until an ad loads).
      bannerSlot: const AppBannerAd(),
      body: switch (state) {
        AsyncData(:final value) when value.isEmpty => EmptyState(
          title: l10n.habit_archivedEmpty,
        ),
        AsyncData(:final value) => ListView.separated(
          key: const Key('archived_list'),
          padding: EdgeInsets.symmetric(vertical: tokens.s8),
          itemCount: value.length,
          separatorBuilder: (_, _) => SizedBox(height: tokens.cardGap),
          itemBuilder: (context, i) {
            final row = value[i];
            final habit = row.habit;
            return Card(
              key: ValueKey('archived_${habit.id}'),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: EdgeInsets.all(tokens.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CategoryAvatar(
                          icon: habitIcon(habit),
                          color: habitColor(habit),
                          semanticLabel: habit.name,
                        ),
                        SizedBox(width: tokens.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                habit.name,
                                style: theme.textTheme.titleMedium,
                              ),
                              Text(
                                l10n.habit_archivedOn(
                                  formatFullDate(
                                    row.archivedAt.toLocal(),
                                    dateFormat,
                                    l10n.localeName,
                                  ),
                                ),
                                style: theme.textTheme.bodySmall,
                              ),
                              Text(
                                l10n.habit_bestStreakLabel(
                                  streakLength(l10n, row.bestStreak, row.unit),
                                ),
                                key: ValueKey('best_${habit.id}'),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: tokens.s8),
                    Wrap(
                      spacing: tokens.s8,
                      runSpacing: tokens.s8,
                      alignment: WrapAlignment.end,
                      children: [
                        TextButton.icon(
                          key: ValueKey('delete_${habit.id}'),
                          onPressed: () =>
                              unawaited(_delete(context, ref, row)),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(l10n.habit_deletePermanently),
                        ),
                        FilledButton.tonalIcon(
                          key: ValueKey('restore_${habit.id}'),
                          onPressed: () =>
                              unawaited(_restore(context, ref, row)),
                          icon: const Icon(Icons.unarchive_outlined),
                          label: Text(l10n.habit_restore),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        AsyncError() => ErrorState(
          message: l10n.habit_loadError,
          onRetry: ref.read(archivedHabitsControllerProvider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList()),
      },
    );
  }
}
