import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/habit/domain/entities/day_status.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habit_view_models.dart';
import 'package:dailytrack/features/habit/presentation/widgets/habit_labels.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Localized full date ("21 Oct 2026" by default) for a calendar or note
/// date, in the SET-01 date format.
String dayLabel(
  AppLocalizations l10n,
  DayCell cell, {
  FullDateFormat format = FullDateFormat.dMMMy,
}) => formatFullDate(
  DateTime(cell.date.year, cell.date.month, cell.date.day),
  format,
  l10n.localeName,
);

/// Screen-reader text of a day: status in words, never color only.
String daySemantics(
  AppLocalizations l10n,
  DayCell cell, {
  FullDateFormat format = FullDateFormat.dMMMy,
}) {
  final date = dayLabel(l10n, cell, format: format);
  return switch (cell.status) {
    DayStatus.done => l10n.habit_dayDone(date),
    DayStatus.freeze => l10n.habit_dayFreeze(date),
    DayStatus.missed => l10n.habit_dayMissed(date),
    DayStatus.partial => l10n.habit_dayPartial(date, cell.value, cell.target),
    _ => l10n.habit_dayOther(date),
  };
}

/// HAB-03 month calendar (US5-2, US5-3): swipe or page back to the start
/// date. Done days are filled in the habit color with a check, freeze days
/// show a snowflake, missed due days a faint outline; future days and days
/// before the start are disabled.
class HabitCalendar extends StatefulWidget {
  const new({
    required this.vm,
    required this.color,
    required this.onDay,
    super.key,
  });

  final HabitDetailViewModel vm;
  final Color color;
  final ValueChanged<DayCell> onDay;

  @override
  State<HabitCalendar> createState() => _HabitCalendarState();
}

class _HabitCalendarState extends State<HabitCalendar> {
  late final PageController _pages = PageController(
    initialPage: widget.vm.months.length - 1,
  );
  late int _page = widget.vm.months.length - 1;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Future<void> _go(int page) => _pages.animateToPage(
    page,
    duration: MediaQuery.disableAnimationsOf(context)
        ? const Duration(milliseconds: 1)
        : AppTokens.of(context).motionMedium,
    curve: Curves.easeOut,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final months = widget.vm.months;
    final page = _page.clamp(0, months.length - 1);
    final (year, month) = months[page];
    final first = widget.vm.firstDayOfWeek;
    // Six week rows of 48 dp plus the weekday header.
    final gridHeight = tokens.minTouchTarget * 6;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            IconButton(
              key: const Key('calendar_previous'),
              tooltip: l10n.habit_previousMonth,
              onPressed: page > 0 ? () => _go(page - 1) : null,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                DateFormat.yMMMM(l10n.localeName).format(DateTime(year, month)),
                key: const Key('calendar_month'),
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              key: const Key('calendar_next'),
              tooltip: l10n.habit_nextMonth,
              onPressed: page < months.length - 1 ? () => _go(page + 1) : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    weekdayNarrow(l10n, (first - 1 + i) % 7 + 1),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall,
                    maxLines: 1,
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: gridHeight,
          child: PageView.builder(
            controller: _pages,
            itemCount: months.length,
            onPageChanged: (p) => setState(() => _page = p),
            itemBuilder: (context, i) {
              final (y, m) = months[i];
              final cal = widget.vm.month(y, m);
              return Column(
                children: [
                  for (var r = 0; r * 7 < cal.cells.length; r++)
                    SizedBox(
                      height: tokens.minTouchTarget,
                      child: Row(
                        children: [
                          for (final cell in cal.cells.skip(r * 7).take(7))
                            Expanded(
                              child: cell == null
                                  ? const SizedBox.shrink()
                                  : _Day(
                                      cell: cell,
                                      color: widget.color,
                                      onTap: cell.editable
                                          ? () => widget.onDay(cell)
                                          : null,
                                    ),
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  const new({required this.cell, required this.color, required this.onTap});

  final DayCell cell;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = cell.status == DayStatus.done;
    final freeze = cell.status == DayStatus.freeze;
    final missed = cell.status == DayStatus.missed;
    final enabled = onTap != null;
    final number = Text(
      '${cell.date.day}',
      style: theme.textTheme.labelMedium?.copyWith(
        color: done
            ? scheme.surface
            : enabled
            ? scheme.onSurface
            : scheme.outline,
      ),
      maxLines: 1,
    );
    final size = tokens.iconSize + tokens.s12;
    return Semantics(
      key: ValueKey('cal_${cell.date.key}'),
      button: true,
      enabled: enabled,
      label: daySemantics(l10n, cell, format: FullDateFormatScope.of(context)),
      hint: cell.hasNote ? l10n.habit_dayHasNote : null,
      excludeSemantics: true,
      container: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: tokens.minTouchTarget / 2,
        child: Center(
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: size,
                height: size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done ? color : null,
                  border: missed
                      ? Border.all(color: scheme.outlineVariant)
                      : cell.status == DayStatus.partial
                      ? Border.all(color: color)
                      : null,
                ),
                child: freeze
                    ? Icon(
                        Icons.ac_unit,
                        size: tokens.chipIconSize,
                        color: scheme.primary,
                      )
                    : number,
              ),
              if (done)
                Positioned(
                  right: -tokens.s4,
                  bottom: -tokens.s4,
                  child: Icon(
                    Icons.check_circle,
                    size: tokens.s12,
                    color: scheme.onSurface,
                  ),
                ),
              if (cell.hasNote)
                Positioned(
                  top: -tokens.s4,
                  right: -tokens.s4,
                  child: Icon(
                    Icons.sticky_note_2,
                    size: tokens.s12,
                    color: scheme.outline,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
