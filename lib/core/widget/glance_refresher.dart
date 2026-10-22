import 'dart:async';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/l10n/l10n_for.dart';
import 'package:dailytrack/core/module/provider_reader.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/core/widget/domain/widget_payload.dart';
import 'package:dailytrack/core/widget/glance_source.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'glance_refresher.g.dart';

/// Tables whose writes change the widget or the daily summary (FR-049):
/// spending, budgets, habits, and settings (currency, language, lock,
/// widget switch, summary time).
const List<String> glanceTables = [
  'transactions',
  'budgets',
  'habits',
  'habit_schedules',
  'habit_entries',
  'settings',
];

/// Whether the widget shows only "Open DailyTrack" (FR-047): before
/// onboarding, and while the app lock is on unless "Show data on widget"
/// is.
bool widgetHidden(AppSettings s) =>
    !s.onboardingDone || (s.lockEnabled && !s.showDataOnWidget);

/// Keeps the home screen widget and the daily summary current (feature 008
/// research R19). [start] listens for writes to [glanceTables], including
/// those from background isolates, and refreshes 750 ms after the last one
/// of a burst. Background entry points call [refreshNow] before they exit.
class GlanceRefresher {
  new({
    required this.db,
    required this.read,
    required this.clock,
    this.debounce = const Duration(milliseconds: 750),
  });

  final AppDatabase db;
  final ProviderReader read;
  final Clock clock;
  final Duration debounce;

  StreamSubscription<void>? _sub;
  Timer? _timer;
  Future<void>? _running;
  var _again = false;

  bool get started => _sub != null;

  /// Starts listening, once, and refreshes right away.
  void start() {
    if (_sub != null) return;
    _sub = db
        .tableUpdates(
          TableUpdateQuery.allOf([
            for (final t in glanceTables) TableUpdateQuery.onTableName(t),
          ]),
        )
        .listen((_) => _schedule(), onError: (Object _) {});
    unawaited(refreshNow());
  }

  void _schedule() {
    _timer?.cancel();
    _timer = Timer(debounce, () => unawaited(refreshNow()));
  }

  /// Builds today's and tomorrow's glances, reschedules the daily summary,
  /// and saves the widget payload. A call during a refresh runs once more
  /// after it, so the last write always shows. Never throws.
  Future<void> refreshNow() {
    if (_running != null) {
      _again = true;
      return _running!;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _refresh();
    } while (_again);
  }

  Future<void> _refresh() async {
    try {
      final now = clock.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final today = await buildHomeGlance(read, now);
      final next = await buildHomeGlance(read, tomorrow);
      final settings = await read(settingsRepositoryProvider).load();
      await read(dailySummarySchedulerProvider)
          .reschedule(today: today, next: next);
      await _save(settings, today, next);
    } on Object {
      // Best effort; the next write or trigger refreshes again.
    }
  }

  Future<void> _save(AppSettings s, HomeGlance today, HomeGlance next) async {
    try {
      final l10n = l10nFor(s.locale);
      await read(homeWidgetBridgeProvider).save(
        encodeWidgetPayload(
          today,
          next,
          hidden: widgetHidden(s),
          l10n: l10n,
          locale: l10n.localeName,
        ),
      );
    } on Object {
      // No widget host (tests, other platforms).
    }
  }

  void dispose() {
    _timer?.cancel();
    unawaited(_sub?.cancel());
    _sub = null;
  }
}

@Riverpod(keepAlive: true)
GlanceRefresher glanceRefresher(Ref ref) {
  final refresher = GlanceRefresher(
    db: ref.watch(appDatabaseProvider),
    read: ref.read,
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(refresher.dispose);
  return refresher;
}
