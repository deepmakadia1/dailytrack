import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/streak_summary.dart';
import 'package:dailytrack/features/habit/domain/insights/habit_insight_rules.dart';
import 'package:dailytrack/features/habit/domain/streaks/streak_engine.dart';
import 'package:dailytrack/features/habit/presentation/controllers/active_habit_streaks_controller.dart';
import 'package:dailytrack/features/habit/presentation/controllers/habits_today_controller.dart';
import 'package:dailytrack/features/habit/presentation/habit_providers.dart';

/// `HabitModule.insights()` (DSH-01, feature 006 research R4, R8): loads
/// active habits with the HAB-01 400-day window, summarizes streaks and this
/// week's completions, runs [HabitInsightRules], and localizes each fact.
/// A habit or fact that fails is skipped; the rest still return.
final class HabitInsightSource implements InsightSource {
  const new();

  @override
  List<String> get ruleIds => HabitInsightRules.ruleIds;

  @override
  Future<List<Insight>> evaluate(ProviderReader read) async {
    final settings = read(appSettingsProvider).value ?? const AppSettings();
    final l10n = l10nFor(settings.locale);
    final clock = read(clockProvider);
    final today = LocalDate.fromDateTime(clock.now());
    final weekStart = today.startOfWeek(settings.firstDayOfWeek);
    final engine = read(streakEngineProvider);
    // Home's streak flame usually has the window loaded already; reuse it
    // instead of a second 400-day load (R15). Otherwise load it here.
    final rows =
        read(activeHabitStreaksControllerProvider).value ??
        await _load(read, today, engine);

    final inputs = <HabitInsightHabit>[];
    for (final row in rows) {
      try {
        inputs.add(
          HabitInsightHabit(
            habit: row.habit,
            summary: row.summary,
            completedDays: {
              for (var d = weekStart; !d.isAfter(today); d = d.addDays(1))
                if (engine.isDone(row.history, d)) d,
            },
            scheduledToday: engine.isScheduledOn(row.history, today),
          ),
        );
      } on Object {
        // This habit's rules are skipped; the others still run.
      }
    }

    final facts = HabitInsightRules(clock).evaluate(
      HabitInsightInputs(
        habits: inputs,
        firstDayOfWeek: settings.firstDayOfWeek,
      ),
    );
    return [for (final fact in facts) ?_localize(fact, l10n)];
  }

  static Future<List<HabitStreakRow>> _load(
    ProviderReader read,
    LocalDate today,
    StreakEngine engine,
  ) async {
    final habits = await read(habitRepositoryProvider).watchActive().first;
    final histories = {
      for (final h
          in await read(habitEntryRepositoryProvider)
              .watchActiveHistories(
                from: today.addDays(-HabitsTodayController.windowDays),
              )
              .first)
        h.habitId: h,
    };
    final rows = <HabitStreakRow>[];
    for (final habit in habits) {
      final history = histories[habit.id];
      if (history == null) continue;
      try {
        rows.add((
          habit: habit,
          history: history,
          summary: engine.summarize(history),
        ));
      } on Object {
        // Skipped, like a failing rule.
      }
    }
    return rows;
  }

  static Insight? _localize(HabitInsightFact fact, AppLocalizations l10n) {
    try {
      final weeks = switch (fact) {
        NextMilestone(:final unit) ||
        Comeback(:final unit) => unit == StreakUnit.weeks,
        BestThisWeek() => false,
      };
      final text = switch (fact) {
        NextMilestone(:final daysLeft, :final milestone, :final name) =>
          weeks
              ? l10n.habit_insightNextMilestoneWeeks(
                  daysLeft,
                  milestone.value,
                  name,
                )
              : l10n.habit_insightNextMilestoneDays(
                  daysLeft,
                  milestone.value,
                  name,
                ),
        BestThisWeek(:final name, :final count) =>
          l10n.habit_insightBestThisWeek(name, count),
        Comeback(:final name, :final best) =>
          weeks
              ? l10n.habit_insightComebackWeeks(name, best)
              : l10n.habit_insightComebackDays(name, best),
      };
      return Insight(
        ruleId: fact.ruleId,
        text: text,
        location: Routes.habitDetailPath(fact.habitId),
        semanticLabel: l10n.habit_insightOpensHabit(text, fact.name),
      );
    } on Object {
      return null;
    }
  }
}
