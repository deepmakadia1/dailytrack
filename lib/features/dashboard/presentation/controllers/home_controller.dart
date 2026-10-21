import 'dart:async';

import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/module/tracker_module.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/features/dashboard/domain/greeting.dart';
import 'package:dailytrack/features/dashboard/domain/insight_rotation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_controller.freezed.dart';
part 'home_controller.g.dart';

/// Everything DSH-01 shows besides the module-owned cards, sections, and
/// badges (feature 006 data-model.md §5).
@freezed
abstract class HomeState with _$HomeState {
  const factory({
    required Greeting greeting,

    /// Local midnight of today.
    required DateTime today,

    /// Visible modules, in the user's order (SET-06).
    required List<TrackerModule> modules,

    /// The + menu: every visible module's quick adds, in module order.
    required List<QuickAddAction> quickAdds,

    /// Empty once the Coming soon card is dismissed.
    required List<ComingSoonModule> comingSoon,

    /// Today's insight. Replaced alone by refreshes; keeps its previous value
    /// while a new pick is computed.
    required AsyncValue<InsightPick> insight,
  }) = _HomeState;
}

/// The one DSH-01 notifier (Constitution II, research R7, R14, R18).
///
/// `build()` watches only the registry and the settings that change what
/// Home lists (`locale`, `enabledModules`, `moduleOrder`). Writing the
/// insight pick or the Coming soon flag never re-runs it, and it never
/// watches data streams: cards and sections watch their own modules.
@riverpod
class HomeController extends _$HomeController {
  Timer? _timer;

  /// Bumped per evaluation, so a stale one never overwrites a newer pick.
  var _generation = 0;

  /// Counts builds, so only the latest one starts an evaluation.
  var _builds = 0;

  /// Kept across rebuilds so a module or language change keeps the card's
  /// content and height until the new pick is ready (§15.6).
  AsyncValue<InsightPick>? _lastInsight;

  AppSettings get _settings =>
      ref.read(appSettingsProvider).value ?? const AppSettings();

  @override
  HomeState build() {
    final registry = ref.watch(moduleRegistryProvider);
    // Lists are compared by content, so an unrelated settings write that
    // decodes fresh lists does not rebuild Home.
    ref.watch(
      appSettingsProvider.select((a) {
        final s = a.value;
        return s == null
            ? null
            : (s.locale, s.enabledModules.join(','), s.moduleOrder.join(','));
      }),
    );
    ref.listen(
      appSettingsProvider.select(
        (a) => a.value?.homeComingSoonDismissed ?? false,
      ),
      (_, dismissed) =>
          state = state.copyWith(comingSoon: _comingSoonFor(dismissed)),
    );
    // The notifier instance survives rebuilds; each build owns one listener.
    final lifecycle = AppLifecycleListener(onResume: _onTimeChange);
    ref.onDispose(() {
      _timer?.cancel();
      lifecycle.dispose();
      _generation++;
    });
    _schedule();

    final settings = _settings;
    final modules = registry.visible(settings);
    final now = ref.read(clockProvider).now();
    final insight = _lastInsight ?? const AsyncLoading<InsightPick>();
    // Only the latest build evaluates: a quick rebuild (settings arriving)
    // must not run every source twice.
    final build = ++_builds;
    // After the first frame, so the cards' own queries go first (R15).
    unawaited(
      SchedulerBinding.instance.endOfFrame.then((_) => _evaluate(build: build)),
    );
    return HomeState(
      greeting: greetingFor(now),
      today: DateTime(now.year, now.month, now.day),
      modules: modules,
      quickAdds: [for (final m in modules) ...m.quickAddActions()],
      comingSoon: _comingSoonFor(settings.homeComingSoonDismissed),
      insight: insight,
    );
  }

  static List<ComingSoonModule> _comingSoonFor(bool dismissed) =>
      dismissed ? const [] : comingSoonModules;

  /// Re-evaluates the insight only (pull-to-refresh, FR-028). The previous
  /// insight stays visible until the new pick replaces it.
  Future<void> refreshInsights() => _evaluate();

  /// Hides the Coming soon card; [undoDismissComingSoon] brings it back.
  Future<void> dismissComingSoon() => ref
      .read(settingsRepositoryProvider)
      .setHomeComingSoonDismissed(dismissed: true);

  Future<void> undoDismissComingSoon() => ref
      .read(settingsRepositoryProvider)
      .setHomeComingSoonDismissed(dismissed: false);

  /// Fires at the next greeting boundary or local midnight, whichever comes
  /// first.
  void _schedule() {
    _timer?.cancel();
    final now = ref.read(clockProvider).now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final boundary = nextGreetingBoundary(now);
    final next = boundary.isBefore(midnight) ? boundary : midnight;
    _timer = Timer(next.difference(now), _onTimeChange);
  }

  /// Timer or resume: updates the greeting and date, and re-evaluates the
  /// insight when the local date changed (research R18).
  void _onTimeChange() {
    if (!ref.mounted) return;
    final now = ref.read(clockProvider).now();
    final today = DateTime(now.year, now.month, now.day);
    final dayChanged = today != state.today;
    state = state.copyWith(greeting: greetingFor(now), today: today);
    _schedule();
    if (dayChanged) unawaited(_evaluate());
  }

  /// Evaluates the visible modules' sources and picks today's insight.
  /// [build] is set when a build started it: reading [state] first applies
  /// any pending rebuild, and only the latest build's evaluation runs.
  Future<void> _evaluate({int? build}) async {
    if (!ref.mounted) return;
    final modules = state.modules;
    if (build != null && build != _builds) return;
    final generation = ++_generation;
    final sources = [for (final m in modules) ?m.insights()];
    final order = [for (final s in sources) ...s.ruleIds];
    final results = await Future.wait([
      for (final s in sources)
        Future.sync(() => s.evaluate(ref.read))
            .catchError((Object _) => const <Insight>[]),
    ]);
    if (!ref.mounted || generation != _generation) return;

    final applicable = <String, Insight>{};
    for (final list in results) {
      for (final insight in list) {
        if (order.contains(insight.ruleId)) {
          applicable.putIfAbsent(insight.ruleId, () => insight);
        }
      }
    }
    final settings = _settings;
    final now = ref.read(clockProvider).now();
    final stored = switch ((
      settings.dailyInsightDate,
      settings.dailyInsightId,
    )) {
      (final date?, final id?) => StoredInsightPick(date: date, ruleId: id),
      _ => null,
    };
    final pick = pickDailyInsight(
      today: DateKeys.fromLocal(now),
      order: order,
      applicable: applicable,
      stored: stored,
    );
    final insight = AsyncData<InsightPick>(pick);
    _lastInsight = insight;
    state = state.copyWith(insight: insight);
    if (pick case Picked(:final insight, persist: true)) {
      try {
        await ref
            .read(settingsRepositoryProvider)
            .setDailyInsight(
              dateKey: DateKeys.fromLocal(now),
              ruleId: insight.ruleId,
            );
      } on Object {
        // Best effort: tomorrow's pick may then repeat today's.
      }
    }
  }
}
