import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/category_avatar.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_state.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// One HAB-01 habit (US1-6): icon in a colored circle, name, schedule text,
/// current streak with a flame, and the check control on the right — a
/// 48 dp check button for yes/no habits, or `+` (long-press: number entry)
/// for count habits (FR-018). Done shows a check icon and "Done", a freeze
/// a snowflake: status is never color only.
class HabitCard extends StatelessWidget {
  const new({
    required this.card,
    required this.onToggle,
    required this.onIncrement,
    required this.onEnterValue,
    required this.onMenu,
    required this.onOpen,
    super.key,
  });

  final HabitCardData card;
  final VoidCallback onToggle;
  final VoidCallback onIncrement;
  final VoidCallback onEnterValue;
  final VoidCallback onMenu;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final habit = card.habit;
    final color = habitColor(habit);
    final count = habit.kind == HabitKind.count;
    final streak = streakLength(l10n, card.currentStreak, card.unit);
    final status = card.isDone
        ? l10n.habit_statusDone
        : card.isFreeze
        ? l10n.habit_statusFreeze
        : null;

    return Card(
      key: ValueKey('habit_card_${habit.id}'),
      margin: EdgeInsets.only(bottom: tokens.cardGap),
      child: InkWell(
        borderRadius: BorderRadius.circular(tokens.radiusCard),
        onTap: onOpen,
        onLongPress: onMenu,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.s12,
            vertical: tokens.s8,
          ),
          child: Row(
            children: [
              CategoryAvatar(
                icon: habitIcon(habit),
                color: color,
                semanticLabel: habit.name,
              ),
              SizedBox(width: tokens.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      habit.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      scheduleLabel(l10n, card.schedule),
                      style: theme.textTheme.bodySmall,
                    ),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: tokens.s4,
                      children: [
                        Semantics(
                          label: l10n.habit_streakLabel(streak),
                          excludeSemantics: true,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department,
                                size: tokens.chipIconSize,
                                color: card.currentStreak > 0
                                    ? tokens.warning
                                    : theme.colorScheme.outline,
                              ),
                              Text(
                                streak,
                                key: ValueKey('streak_${habit.id}'),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (count)
                          Text(
                            habit.unit == null
                                ? l10n.habit_countValueNoUnit(
                                    card.value,
                                    card.target,
                                  )
                                : l10n.habit_countValue(
                                    card.value,
                                    card.target,
                                    habit.unit!,
                                  ),
                            key: ValueKey('count_${habit.id}'),
                            style: theme.textTheme.bodySmall,
                          ),
                        if (status != null)
                          Text(
                            status,
                            key: ValueKey('status_${habit.id}'),
                            style: theme.textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (count)
                _PlusButton(
                  card: card,
                  onIncrement: onIncrement,
                  onEnterValue: onEnterValue,
                )
              else
                _CheckButton(card: card, onToggle: onToggle),
            ],
          ),
        ),
      ),
    );
  }
}

/// The check icon, animated when it changes unless animations are off
/// (FR-019).
class _CheckIcon extends StatelessWidget {
  const new({required this.card});

  final HabitCardData card;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    final noMotion = MediaQuery.disableAnimationsOf(context);
    final (icon, color) = card.isDone
        ? (Icons.check_circle, habitColor(card.habit))
        : card.isFreeze
        ? (Icons.ac_unit, scheme.primary)
        : (Icons.radio_button_unchecked, scheme.outline);
    return AnimatedSwitcher(
      duration: noMotion ? Duration.zero : tokens.motionShort,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        icon,
        key: ValueKey(icon),
        color: color,
        size: tokens.iconSize + tokens.s8,
      ),
    );
  }
}

class _CheckButton extends StatelessWidget {
  const new({required this.card, required this.onToggle});

  final HabitCardData card;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final name = card.habit.name;
    final label = card.isDone
        ? l10n.habit_markNotDoneLabel(name)
        : l10n.habit_markDoneLabel(name);
    return IconButton(
      key: ValueKey('check_${card.habit.id}'),
      tooltip: label,
      constraints: BoxConstraints.tightFor(
        width: tokens.minTouchTarget,
        height: tokens.minTouchTarget,
      ),
      onPressed: onToggle,
      icon: Semantics(
        checked: card.isDone,
        child: _CheckIcon(card: card),
      ),
    );
  }
}

class _PlusButton extends StatelessWidget {
  const new({
    required this.card,
    required this.onIncrement,
    required this.onEnterValue,
  });

  final HabitCardData card;
  final VoidCallback onIncrement;
  final VoidCallback onEnterValue;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final habit = card.habit;
    final label = habit.unit == null
        ? l10n.habit_countLabelNoUnit(habit.name, card.value, card.target)
        : l10n.habit_countLabel(
            habit.name,
            card.value,
            card.target,
            habit.unit!,
          );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (card.isDone || card.isFreeze) _CheckIcon(card: card),
        // Tap adds 1; long-press opens number entry (FR-018). No tooltip:
        // it would take the long-press.
        Semantics(
          button: true,
          label: label,
          hint: l10n.habit_addOneLabel(habit.name),
          onLongPressHint: l10n.habit_valueEntryTitle(habit.name),
          excludeSemantics: true,
          container: true,
          onTap: onIncrement,
          onLongPress: onEnterValue,
          child: InkResponse(
            key: ValueKey('plus_${habit.id}'),
            onTap: onIncrement,
            onLongPress: onEnterValue,
            radius: tokens.minTouchTarget / 2,
            child: SizedBox.square(
              dimension: tokens.minTouchTarget,
              child: const Icon(Icons.add_circle_outline),
            ),
          ),
        ),
      ],
    );
  }
}
