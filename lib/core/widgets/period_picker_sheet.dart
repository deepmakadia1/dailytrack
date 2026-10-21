import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// The period-kind picker behind `PeriodSelector` (EXP-01 "tapping the label
/// opens a picker", research R13): Day, Week, Month, Year or a custom range.
abstract final class PeriodPickerSheet {
  /// Returns the chosen period, or null if dismissed. A new kind is anchored
  /// on [now] when the current period contains it, otherwise on the current
  /// period's start, so switching Month → Week keeps you in the same place.
  ///
  /// [kinds] limits the options (EXP-11 has no Day); [lockedKinds] shows a
  /// lock icon on options that need an unlock (feature 003, Q1). Locked
  /// options stay selectable so their blurred preview can be seen.
  static Future<Period?> show(
    BuildContext context, {
    required Period current,
    required int firstDayOfWeek,
    required DateTime now,
    Set<PeriodKind> kinds = const {...PeriodKind.values},
    Set<PeriodKind> lockedKinds = const {},
  }) async {
    final l10n = AppLocalizations.of(context);
    final anchor = current.contains(now.toUtc().millisecondsSinceEpoch)
        ? now
        : current.startLocal;

    final kind = await AppBottomSheet.show<PeriodKind>(
      context,
      title: l10n.common_periodTitle,
      child: ListView(
        shrinkWrap: true,
        children: [
          for (final k in PeriodKind.values)
            if (kinds.contains(k))
              ListTile(
                key: ValueKey('period_kind_${k.name}'),
                title: Text(k.label(l10n)),
                leading: lockedKinds.contains(k)
                    ? Icon(Icons.lock, semanticLabel: l10n.premium_lockedPeriod)
                    : null,
                trailing: k.matches(current) ? const Icon(Icons.check) : null,
                selected: k.matches(current),
                onTap: () => Navigator.of(context).pop(k),
              ),
        ],
      ),
    );
    if (kind == null || !context.mounted) return null;
    if (kind == PeriodKind.custom) return await _pickRange(context, current);

    return switch (kind) {
      PeriodKind.day => SingleDayPeriod(anchor),
      PeriodKind.week => WeekPeriod(anchor, firstDayOfWeek: firstDayOfWeek),
      PeriodKind.month || PeriodKind.custom => MonthPeriod(anchor),
      PeriodKind.year => YearPeriod(anchor),
    };
  }

  static Future<Period?> _pickRange(
    BuildContext context,
    Period current,
  ) async {
    final last = current.endLocalExclusive.subtract(const Duration(days: 1));
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: current.startLocal, end: last),
    );
    return range == null ? null : CustomPeriod(range.start, range.end);
  }
}

/// The kinds of period the picker offers.
enum PeriodKind {
  day,
  week,
  month,
  year,
  custom;

  String label(AppLocalizations l10n) => switch (this) {
    day => l10n.common_periodDay,
    week => l10n.common_periodWeek,
    month => l10n.common_periodMonth,
    year => l10n.common_periodYear,
    custom => l10n.common_periodCustom,
  };

  bool matches(Period p) => switch ((this, p)) {
    (day, SingleDayPeriod()) ||
    (week, WeekPeriod()) ||
    (month, MonthPeriod()) ||
    (year, YearPeriod()) ||
    (custom, CustomPeriod()) => true,
    _ => false,
  };
}
