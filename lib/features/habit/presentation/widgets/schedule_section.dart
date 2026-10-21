import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/chip_selector.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';

/// HAB-02 schedule (US1-2): Every day · Specific days with weekday chips
/// ordered from the first day of the week · X times per week with a 1–6
/// stepper. [weekdayError] and [timesError] are shown next to the field
/// (FR-025).
class ScheduleSection extends StatelessWidget {
  const new({
    required this.schedule,
    required this.firstDayOfWeek,
    required this.onType,
    required this.onWeekdays,
    required this.onTimes,
    this.weekdayError,
    this.timesError,
    super.key,
  });

  final HabitSchedule schedule;
  final int firstDayOfWeek;
  final ValueChanged<ScheduleType> onType;
  final ValueChanged<Set<int>> onWeekdays;
  final ValueChanged<int> onTimes;
  final String? weekdayError;
  final String? timesError;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final times = schedule.timesPerWeek ?? 3;
    final error = TextStyle(color: theme.colorScheme.error);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ChipSelector<ScheduleType>(
          key: const Key('schedule_type'),
          options: ScheduleType.values,
          selected: {schedule.type},
          labelBuilder: (t) => switch (t) {
            ScheduleType.daily => l10n.habit_scheduleEveryDay,
            ScheduleType.specificWeekdays => l10n.habit_scheduleSpecificDays,
            ScheduleType.timesPerWeek => l10n.habit_scheduleXTimes,
          },
          onChanged: (s) => onType(s.single),
        ),
        if (schedule.type == ScheduleType.specificWeekdays) ...[
          SizedBox(height: tokens.s8),
          ChipSelector<int>(
            key: const Key('weekday_chips'),
            multi: true,
            options: [
              for (var i = 0; i < 7; i++) (firstDayOfWeek - 1 + i) % 7 + 1,
            ],
            selected: schedule.weekdays,
            labelBuilder: (d) => weekdayShort(l10n, d),
            onChanged: onWeekdays,
          ),
          if (weekdayError case final e?)
            Padding(
              padding: EdgeInsets.only(top: tokens.s4),
              child: Text(e, key: const Key('weekday_error'), style: error),
            ),
        ],
        if (schedule.type == ScheduleType.timesPerWeek) ...[
          SizedBox(height: tokens.s8),
          Row(
            children: [
              IconButton(
                key: const Key('times_minus'),
                tooltip: l10n.habit_decrease,
                onPressed: times > 1 ? () => onTimes(times - 1) : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                l10n.habit_timesPerWeekValue(times),
                key: const Key('times_value'),
                style: theme.textTheme.titleMedium,
              ),
              IconButton(
                key: const Key('times_plus'),
                tooltip: l10n.habit_increase,
                onPressed: times < 6 ? () => onTimes(times + 1) : null,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (timesError case final e?) Text(e, style: error),
        ],
      ],
    );
  }
}
