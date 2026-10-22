import 'package:dailytrack/core/export/export_dataset.dart';
import 'package:dailytrack/core/export/export_document.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_entry.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_history.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';
import 'package:intl/intl.dart';

/// "Habits" in SET-03 (FR-027, FR-028, feature 008 research R14): one row
/// per habit per day with an entry in the period, archived habits
/// included; the summary gives each habit's completion rate over its
/// scheduled days, freeze days left out (same rules as HAB-03).
final class HabitsExportDataset implements ExportDataset {
  const new();

  static const String datasetId = 'habits';

  @override
  String get id => datasetId;

  @override
  String label(AppLocalizations l10n) => l10n.export_habits;

  @override
  List<ExportFilterSpec> get filters => const [];

  @override
  Future<ExportDocument> build(
    ExportRequest request,
    ExportContext context,
    ProviderReader read,
  ) async {
    final l10n = context.l10n;
    final habitsRepo = read(habitRepositoryProvider);
    final entriesRepo = read(habitEntryRepositoryProvider);
    final engine = read(streakEngineProvider);
    final habits = [
      ...await habitsRepo.activeHabits(),
      ...await habitsRepo.watchArchived().first,
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final first = LocalDate.fromDateTime(request.period.startLocal);
    final endExclusive = LocalDate.fromDateTime(
      request.period.endLocalExclusive,
    );
    final today = LocalDate.fromDateTime(context.clock.now());
    final percent = NumberFormat.decimalPattern(context.locale);

    final rows = <(LocalDate, int, List<ExportCell>)>[];
    final summary = <(String, String)>[];
    for (final habit in habits) {
      final history = await entriesRepo.history(habit.id);
      if (history == null) continue;
      for (final entry in history.entries.values) {
        if (entry.date.isBefore(first) || !entry.date.isBefore(endExclusive)) {
          continue;
        }
        if (!entry.isFreeze && entry.value == 0 && (entry.note ?? '').isEmpty) {
          continue;
        }
        rows.add((
          entry.date,
          habit.sortOrder,
          _row(habit, history, entry, l10n, context, engine),
        ));
      }
      final rate = _completionRate(
        history,
        engine,
        from: first.isBefore(habit.startDate) ? habit.startDate : first,
        toExclusive: endExclusive.isBefore(today.addDays(1))
            ? endExclusive
            : today.addDays(1),
      );
      if (rate != null) {
        summary.add((habit.name, l10n.export_percent(rate)));
      }
    }
    rows.sort((a, b) {
      final byDate = a.$1.compareTo(b.$1);
      return byDate != 0 ? byDate : a.$2.compareTo(b.$2);
    });

    return ExportDocument(
      title: l10n.export_habits,
      periodLabel: request.period.label(
        context.locale,
        RelativeDayLabels(
          today: l10n.common_today,
          yesterday: l10n.common_yesterday,
        ),
        now: context.clock.now(),
        fullDatePattern: context.dateFormat.pattern,
      ),
      summary: [(l10n.export_count, percent.format(rows.length)), ...summary],
      columns: [
        ExportColumn(l10n.export_colDate, flex: 1.4),
        ExportColumn(l10n.export_colHabit, flex: 1.8),
        ExportColumn(l10n.export_colValue, align: ExportAlign.end, flex: 0.8),
        ExportColumn(l10n.export_colTarget, align: ExportAlign.end, flex: 0.8),
        ExportColumn(l10n.export_colUnit),
        ExportColumn(l10n.export_colStatus),
        ExportColumn(l10n.export_colNote, flex: 2.4),
      ],
      rows: [for (final r in rows) r.$3],
    );
  }

  static List<ExportCell> _row(
    Habit habit,
    HabitHistory history,
    HabitEntry entry,
    AppLocalizations l10n,
    ExportContext context,
    StreakEngine engine,
  ) {
    final target = engine.scheduleOn(history, entry.date).target;
    final status = entry.isFreeze
        ? l10n.export_statusFreeze
        : entry.value >= target
        ? l10n.export_statusDone
        : l10n.export_statusPartial;
    return [
      TextCell(
        formatFullDate(
          DateTime(entry.date.year, entry.date.month, entry.date.day),
          context.dateFormat,
          context.locale,
        ),
      ),
      TextCell(habit.name),
      TextCell('${entry.value}'),
      TextCell('$target'),
      TextCell(habit.unit ?? ''),
      TextCell(status),
      TextCell(entry.note ?? ''),
    ];
  }

  /// Done scheduled days over scheduled days without a freeze, as a whole
  /// percent; null when no day was scheduled.
  static int? _completionRate(
    HabitHistory history,
    StreakEngine engine, {
    required LocalDate from,
    required LocalDate toExclusive,
  }) {
    var scheduled = 0;
    var done = 0;
    for (var d = from; d.isBefore(toExclusive); d = d.addDays(1)) {
      if (!engine.isScheduledOn(history, d)) continue;
      if (history.entries[d]?.isFreeze ?? false) continue;
      scheduled++;
      if (engine.isDone(history, d)) done++;
    }
    if (scheduled == 0) return null;
    return (done * 100 / scheduled).round();
  }
}
