import 'package:clock/clock.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/material.dart';

/// `< Period >` switcher (§15.4, research R13) for Day, Week, Month, Year and
/// Custom periods. The arrows move to the previous or next period and are
/// hidden for a custom range; tapping the label calls [onPick] (usually
/// `PeriodPickerSheet`).
class PeriodSelector extends StatelessWidget {
  const new({
    required this.period,
    required this.onChanged,
    super.key,
    this.onPick,
    this.now,
    this.monthOnly = false,
    this.locked = false,
  });

  final Period period;
  final ValueChanged<Period> onChanged;
  final VoidCallback? onPick;

  /// "Now" for relative day labels; defaults to the `clock` global.
  final DateTime? now;

  /// Month-only screens (EXP-08): the label is plain text, never a picker,
  /// and [onPick] is ignored.
  final bool monthOnly;

  /// The shown period needs an unlock (EXP-11, Q1): a lock icon is shown
  /// next to the label.
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final tokens = AppTokens.of(context);
    final arrowStyle = IconButton.styleFrom(
      minimumSize: Size.square(tokens.minTouchTarget),
    );
    final label = period.label(
      l10n.localeName,
      RelativeDayLabels(
        today: l10n.common_today,
        yesterday: l10n.common_yesterday,
      ),
      now: now ?? clock.now(),
      fullDatePattern: FullDateFormatScope.of(context).pattern,
    );
    final (previousTip, nextTip) = switch (period) {
      SingleDayPeriod() => (l10n.common_previousDay, l10n.common_nextDay),
      WeekPeriod() => (l10n.common_previousWeek, l10n.common_nextWeek),
      MonthPeriod() => (l10n.common_previousMonth, l10n.common_nextMonth),
      YearPeriod() => (l10n.common_previousYear, l10n.common_nextYear),
      CustomPeriod() => ('', ''),
    };
    final previous = period.previous();
    final next = period.next();

    Widget arrow(IconData icon, String tip, Period? target) => target == null
        ? SizedBox.square(dimension: tokens.minTouchTarget)
        : IconButton(
            style: arrowStyle,
            icon: Icon(icon),
            tooltip: tip,
            onPressed: () => onChanged(target),
          );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        arrow(Icons.chevron_left, previousTip, previous),
        if (locked)
          Icon(
            Icons.lock,
            key: const Key('period_locked'),
            size: tokens.chipIconSize,
            semanticLabel: l10n.premium_lockedPeriod,
          ),
        Flexible(
          child: monthOnly
              ? Text(
                  label,
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                )
              : TextButton(
                  onPressed: onPick,
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
        ),
        arrow(Icons.chevron_right, nextTip, next),
      ],
    );
  }
}
