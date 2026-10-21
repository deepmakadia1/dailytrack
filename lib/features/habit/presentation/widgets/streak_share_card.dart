import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// The shareable streak image (FR-045, US3-4): habit icon and color, name,
/// streak length with unit, and the app name. Nothing else: no notes,
/// counts, or dates. Fixed size so the PNG looks the same everywhere.
class StreakShareCard extends StatelessWidget {
  const new({
    required this.habit,
    required this.streak,
    required this.unit,
    super.key,
  });

  /// Logical size of the card; the PNG is rendered at 3× (research R12).
  static const Size size = Size(320, 200);

  final Habit habit;
  final int streak;
  final StreakUnit unit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final color = habitColor(habit);
    return SizedBox.fromSize(
      size: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(tokens.radiusCard),
          border: Border.all(color: color, width: tokens.s4),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryAvatar(
                    icon: habitIcon(habit),
                    color: color,
                    semanticLabel: habit.name,
                  ),
                  SizedBox(width: tokens.s12),
                  Expanded(
                    child: Text(
                      habit.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: tokens.warning,
                    size: tokens.s32,
                  ),
                  SizedBox(width: tokens.s8),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        streakLength(l10n, streak, unit),
                        style: theme.textTheme.headlineMedium,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                l10n.habit_shareCardFooter,
                style: theme.textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
