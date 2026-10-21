import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// EXP-02 date and time (T056, §15.5 "Date entry"): Today and Yesterday
/// shortcuts first, then the full date and time pickers. Works in local
/// time; the controller stores UTC.
class OccurredAtChips extends StatelessWidget {
  const new({
    required this.value,
    required this.now,
    required this.onChanged,
    super.key,
  });

  /// Local date and time of the entry.
  final DateTime value;
  final DateTime now;
  final ValueChanged<DateTime> onChanged;

  static DateTime _onDay(DateTime day, DateTime time) =>
      DateTime(day.year, day.month, day.day, time.hour, time.minute);

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final locale = l10n.localeName;
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final isToday = _sameDay(value, now);
    final isYesterday = _sameDay(value, yesterday);

    return Wrap(
      spacing: tokens.s8,
      runSpacing: tokens.s8,
      children: [
        ChoiceChip(
          key: const Key('date_today'),
          label: Text(l10n.common_today),
          selected: isToday,
          onSelected: (_) => onChanged(_onDay(now, value)),
        ),
        ChoiceChip(
          key: const Key('date_yesterday'),
          label: Text(l10n.common_yesterday),
          selected: isYesterday,
          onSelected: (_) => onChanged(_onDay(yesterday, value)),
        ),
        ActionChip(
          key: const Key('date_pick'),
          avatar: Icon(Icons.calendar_today, size: tokens.chipIconSize),
          tooltip: l10n.expense_pickDate,
          label: Text(
            formatFullDate(value, FullDateFormatScope.of(context), locale),
          ),
          onPressed: () async {
            final day = await showDatePicker(
              context: context,
              initialDate: value,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (day != null) onChanged(_onDay(day, value));
          },
        ),
        ActionChip(
          key: const Key('time_pick'),
          avatar: Icon(Icons.schedule, size: tokens.chipIconSize),
          tooltip: l10n.expense_pickTime,
          label: Text(DateFormat.jm(locale).format(value)),
          onPressed: () async {
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(value),
            );
            if (time != null) {
              onChanged(
                DateTime(
                  value.year,
                  value.month,
                  value.day,
                  time.hour,
                  time.minute,
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
