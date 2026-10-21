import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/core/widgets/summary_card.dart';
import 'package:dailytrack/core/widgets/undo_snack_bar.dart';
import 'package:dailytrack/features/habit/domain/entities/day_write_result.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_dashboard_controller.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_dialogs.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:dailytrack/features/habit/presentation/widgets/milestone_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// What the count popup chose.
enum _CountChoice { addOne, custom }

/// `HabitModule.dashboardCard()` (US7, FR-046; DSH-01, feature 006
/// research R11): a progress ring "X of Y done today" and a horizontal row
/// of round 48 dp check buttons, one per habit scheduled today, each with
/// its name below. Yes/no tap checks it, and unchecking offers Undo; count
/// tap opens "+1" or a custom value; long-press opens HAB-03. Without
/// habits it offers "Create your first habit".
class HabitDashboardCard extends ConsumerWidget {
  const new({super.key});

  Future<void> _after(
    BuildContext context,
    WidgetRef ref,
    HabitCheckData check,
    Future<DayWriteResult?> write, {
    bool unchecking = false,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(habitDashboardControllerProvider.notifier);
    final result = await write;
    if (!context.mounted) return;
    if (result == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.habit_saveError)));
      return;
    }
    if (unchecking) {
      // Reversible, so Undo instead of a confirmation (§15.5).
      UndoSnackBar.show(
        context,
        message: l10n.habit_uncheckedSnack(check.habit.name),
        onUndo: () => unawaited(controller.undo(result)),
      );
      return;
    }
    unawaited(HapticFeedback.lightImpact());
    if (result.milestone case final milestone?) {
      await showMilestoneSheet(
        context,
        habit: check.habit,
        milestone: milestone,
        unit: result.summary.unit,
      );
    }
  }

  Future<void> _tap(
    BuildContext context,
    WidgetRef ref,
    HabitCheckData check,
  ) async {
    final controller = ref.read(habitDashboardControllerProvider.notifier);
    final id = check.habit.id;
    if (check.habit.kind == HabitKind.yesNo) {
      await _after(
        context,
        ref,
        check,
        controller.toggle(id),
        unchecking: check.isDone,
      );
      return;
    }
    final l10n = AppLocalizations.of(context);
    final choice = await AppBottomSheet.show<_CountChoice>(
      context,
      title: check.habit.name,
      child: Builder(
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              key: const Key('count_add_one'),
              leading: const Icon(Icons.add),
              title: Text(l10n.habit_addOne),
              onTap: () => Navigator.of(context).pop(_CountChoice.addOne),
            ),
            ListTile(
              key: const Key('count_custom'),
              leading: const Icon(Icons.edit_outlined),
              title: Text(l10n.habit_customValue),
              onTap: () => Navigator.of(context).pop(_CountChoice.custom),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !context.mounted) return;
    switch (choice) {
      case _CountChoice.addOne:
        await _after(context, ref, check, controller.increment(id));
      case _CountChoice.custom:
        final value = await showValueEntryDialog(
          context,
          habitName: check.habit.name,
          value: check.value,
        );
        if (value == null || !context.mounted) return;
        await _after(context, ref, check, controller.setValue(id, value));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(habitDashboardControllerProvider);

    final value = switch (async) {
      AsyncValue(:final value?) when !value.hasHabits => Align(
        alignment: AlignmentDirectional.centerStart,
        child: ActionChip(
          key: const Key('habit_card_empty'),
          avatar: Icon(Icons.add, size: tokens.chipIconSize),
          label: Text(l10n.habit_cardEmpty),
          onPressed: () => unawaited(context.push(Routes.habitAddPath())),
        ),
      ),
      AsyncValue(:final value?) when value.checks.isEmpty => Text(
        l10n.habit_cardNoneToday,
        key: const Key('habit_card_none'),
      ),
      AsyncValue(:final value?) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Ring(done: value.doneCount, total: value.scheduledCount),
          SizedBox(width: tokens.s12),
          Expanded(
            child: SizedBox(
              height: _CheckButton.heightOf(context),
              child: ListView.separated(
                key: const Key('habit_card_checks'),
                scrollDirection: Axis.horizontal,
                itemCount: value.checks.length,
                separatorBuilder: (_, _) => SizedBox(width: tokens.s4),
                itemBuilder: (context, i) {
                  final check = value.checks[i];
                  return _CheckButton(
                    check: check,
                    onTap: () => unawaited(_tap(context, ref, check)),
                    onLongPress: () => unawaited(
                      context.push(Routes.habitDetailPath(check.habit.id)),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      AsyncError() => Row(
        key: const Key('habit_card_error'),
        children: [
          Icon(Icons.error_outline, color: theme.colorScheme.error),
          SizedBox(width: tokens.s8),
          Expanded(child: Text(l10n.habit_loadDataError)),
          TextButton(
            onPressed: ref
                .read(habitDashboardControllerProvider.notifier)
                .retry,
            child: Text(l10n.common_tryAgain),
          ),
        ],
      ),
      _ => DelayedSkeleton(child: SkeletonCard(height: tokens.s48)),
    };

    return SummaryCard(
      key: const Key('habit_dashboard_card'),
      // Same header as the Expense card (§15.1 "Consistent").
      leading: CategoryAvatar(
        icon: Icons.check_circle,
        color: theme.colorScheme.primary,
        semanticLabel: l10n.modules_habit,
      ),
      title: l10n.modules_habit,
      value: value,
    );
  }
}

/// "X of Y done today" with a completion ring; the text carries the status.
class _Ring extends StatelessWidget {
  const new({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    return SizedBox(
      width: tokens.s48 * 2,
      child: Column(
        children: [
          ExcludeSemantics(
            child: SizedBox.square(
              dimension: tokens.s48,
              child: CircularProgressIndicator(
                value: total == 0 ? 0 : done / total,
                strokeWidth: tokens.s4,
                color: tokens.success,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          SizedBox(height: tokens.s4),
          Text(
            l10n.habit_doneTodayRing(done, total),
            key: const Key('habit_card_ring'),
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const new({
    required this.check,
    required this.onTap,
    required this.onLongPress,
  });

  final HabitCheckData check;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  /// Width of one item: the 48 dp button plus room for a short name.
  static double widthOf(AppTokens tokens) => tokens.s48 + tokens.s16;

  static TextStyle? _labelStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall;

  /// Row height: the 48 dp button, a 4 dp gap, and one line of the name at
  /// the current text scale (measured, so 200% never clips).
  static double heightOf(BuildContext context) {
    final tokens = AppTokens.of(context);
    final painter = TextPainter(
      text: TextSpan(text: 'Ag', style: _labelStyle(context)),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final line = painter.height;
    painter.dispose();
    return tokens.minTouchTarget + tokens.s4 + line;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final habit = check.habit;
    final color = habitColor(habit);
    final label = habit.kind == HabitKind.count
        ? (habit.unit == null
              ? l10n.habit_countLabelNoUnit(
                  habit.name,
                  check.value,
                  check.target,
                )
              : l10n.habit_countLabel(
                  habit.name,
                  check.value,
                  check.target,
                  habit.unit!,
                ))
        : check.isDone
        ? l10n.habit_markNotDoneLabel(habit.name)
        : l10n.habit_markDoneLabel(habit.name);
    return SizedBox(
      width: widthOf(tokens),
      child: Column(
        children: [
          Semantics(
            key: ValueKey('home_check_${habit.id}'),
            button: true,
            checked: check.isDone,
            label: label,
            excludeSemantics: true,
            // Own node with the actions: the InkResponse below is excluded.
            container: true,
            onTap: onTap,
            onLongPress: onLongPress,
            child: InkResponse(
              onTap: onTap,
              onLongPress: onLongPress,
              radius: tokens.minTouchTarget / 2,
              child: SizedBox.square(
                dimension: tokens.minTouchTarget,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: check.isDone ? color : null,
                    border: Border.all(color: color, width: tokens.s4 / 2),
                  ),
                  child: Icon(
                    check.isDone ? Icons.check : habitIcon(habit),
                    color: check.isDone ? scheme.surface : color,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: tokens.s4),
          // The button's label already names the habit for screen readers.
          ExcludeSemantics(
            child: Text(
              habit.name,
              style: _labelStyle(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
