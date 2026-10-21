import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_state.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// HAB-01 week strip (US1-7, US1-8, research R14): the 7 days of the
/// current week from the first day of the week, each with a mini
/// completion ring, plus one page back. Future and older days are disabled
/// with a hint.
class WeekStrip extends StatelessWidget {
  const new({
    required this.week,
    required this.selected,
    required this.weekOffset,
    required this.onSelect,
    required this.onPage,
    super.key,
  });

  final List<WeekDayCell> week;
  final LocalDate selected;
  final int weekOffset;
  final ValueChanged<LocalDate> onSelect;
  final ValueChanged<int> onPage;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final back = weekOffset == 0;
    // The page button sits above the days, so all 7 get the full width
    // (48 dp targets on a 360 dp screen, §15.10).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: back
              ? AlignmentDirectional.centerStart
              : AlignmentDirectional.centerEnd,
          child: TextButton.icon(
            key: Key(back ? 'week_previous' : 'week_next'),
            onPressed: () => onPage(back ? -1 : 0),
            icon: Icon(back ? Icons.chevron_left : Icons.chevron_right),
            label: Text(back ? l10n.common_previousWeek : l10n.common_nextWeek),
          ),
        ),
        Row(
          children: [
            for (final cell in week)
              Expanded(
                child: _Day(
                  cell: cell,
                  selected: cell.date == selected,
                  onTap: cell.selectable ? () => onSelect(cell.date) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const new({required this.cell, required this.selected, required this.onTap});

  final WeekDayCell cell;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final enabled = onTap != null;
    final weekday = cell.date.weekday;
    final name = weekdayLong(l10n, weekday);
    final label = cell.scheduled == 0
        ? l10n.habit_dayRingNone(name)
        : l10n.habit_dayRingLabel(name, cell.done, cell.scheduled);
    final hint = enabled
        ? null
        : cell.isFuture
        ? l10n.habit_futureDayHint
        : l10n.habit_olderEditsHint;
    final textColor = enabled ? scheme.onSurface : scheme.outline;

    return Semantics(
      key: ValueKey('day_${cell.date.key}'),
      button: true,
      enabled: enabled,
      selected: selected,
      label: label,
      hint: hint,
      excludeSemantics: true,
      // Own node with the action: the InkWell below is excluded.
      container: true,
      onTap: onTap,
      child: Tooltip(
        message: hint ?? '',
        triggerMode: enabled ? TooltipTriggerMode.manual : null,
        child: InkWell(
          borderRadius: BorderRadius.circular(tokens.radiusChip),
          onTap: onTap,
          child: Container(
            constraints: BoxConstraints(minHeight: tokens.minTouchTarget),
            padding: EdgeInsets.symmetric(vertical: tokens.s4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(tokens.radiusChip),
              color: selected ? scheme.secondaryContainer : null,
              border: cell.isToday ? Border.all(color: scheme.primary) : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weekdayNarrow(l10n, weekday),
                  style: theme.textTheme.labelSmall?.copyWith(color: textColor),
                  maxLines: 1,
                ),
                SizedBox(height: tokens.s4),
                SizedBox.square(
                  dimension: tokens.iconSize + tokens.s8,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: cell.ratio,
                        strokeWidth: tokens.s4 / 2,
                        color: tokens.success,
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                      Text(
                        '${cell.date.day}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: textColor,
                        ),
                        maxLines: 1,
                      ),
                    ],
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
