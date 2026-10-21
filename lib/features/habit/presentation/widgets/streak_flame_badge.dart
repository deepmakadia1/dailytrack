import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/controllers/streak_flame_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// `HabitModule.appBarBadge()` (DSH-01, feature 006 contracts/screens.md
/// "Streak flame badge"): a flame and the best active streak ("2 wk" for a
/// weekly habit) in a 48 dp target that opens HAB-01.
class StreakFlameBadge extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final async = ref.watch(streakFlameControllerProvider);
    final data = async.value;
    if (data == null) {
      // Loading keeps the space so the app bar never shifts; an error hides
      // the badge (the Habit card shows the error).
      return async.hasError
          ? const SizedBox.shrink()
          : SizedBox.square(dimension: tokens.minTouchTarget);
    }
    final weeks = data.unit == StreakUnit.weeks;
    final count = weeks
        ? l10n.habit_streakBadgeWeeksShort(data.current)
        : '${data.current}';
    final label = weeks
        ? l10n.habit_streakBadgeLabelWeeks(data.current)
        : l10n.habit_streakBadgeLabelDays(data.current);
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: () => context.go(Routes.habits),
      child: InkResponse(
        onTap: () => context.go(Routes.habits),
        radius: tokens.minTouchTarget / 2,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: tokens.minTouchTarget,
            minHeight: tokens.minTouchTarget,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: tokens.s8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: data.current > 0
                      ? tokens.warning
                      : theme.colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: tokens.s4),
                Text(
                  count,
                  key: const Key('streak_flame_count'),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
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
