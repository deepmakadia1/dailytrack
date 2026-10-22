import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widget/domain/home_glance.dart';
import 'package:dailytrack/core/widget/domain/home_widget_bridge.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';
import '../../helpers/real_container.dart';

/// GlanceRefresher (feature 008 T107, T126; research R19; FR-047, FR-049).
/// Real in-memory database; a short debounce instead of 750 ms.

/// Reads a decoded JSON value at [path] (map keys and list indexes).
Object? at(Object? json, List<Object> path) {
  var v = json;
  for (final k in path) {
    v = k is int ? (v! as List<Object?>)[k] : (v! as Map<String, Object?>)[k];
  }
  return v;
}

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  setUpAll(initializeDateFormatting);

  late AppDatabase db;
  late ProviderContainer c;
  late FakeHomeWidgetBridge bridge;
  late FakeDailySummaryScheduler summary;
  late FakeTrackerModule module;
  late MutableClock clock;
  const debounce = Duration(milliseconds: 40);

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    bridge = FakeHomeWidgetBridge();
    summary = FakeDailySummaryScheduler();
    clock = MutableClock(DateTime(2026, 10, 21, 18));
    module = FakeTrackerModule(id: 'habit')
      ..glance = (b, now) => b.setHabits(
        GlanceHabits(
          scheduled: 1,
          done: 0,
          items: [
            GlanceHabit(
              id: 'h1',
              name: 'Walk ${now.day}',
              kind: GlanceHabitKind.yesNo,
              value: 0,
              target: 1,
              colorHex: '#2B7ACA',
            ),
          ],
        ),
      );
    c = makeRealContainer(
      db,
      registry: ModuleRegistry([module]),
      overrides: [
        clockProvider.overrideWithValue(clock),
        homeWidgetBridgeProvider.overrideWithValue(bridge),
        dailySummarySchedulerProvider.overrideWithValue(summary),
        glanceRefresherProvider.overrideWith((ref) {
          final r = GlanceRefresher(
            db: db,
            read: ref.read,
            clock: clock,
            debounce: debounce,
          );
          ref.onDispose(r.dispose);
          return r;
        }),
      ],
    );
    await c
        .read(settingsRepositoryProvider)
        .completeOnboarding(
          const OnboardingChoices(
            locale: 'en',
            currencyCode: 'INR',
            moduleOrder: ['habit'],
            enabledModules: ['habit'],
          ),
        );
  });

  Future<void> settle() => Future<void>.delayed(debounce * 4);

  test('refreshNow builds today and tomorrow, reschedules the summary, then '
      'saves the widget payload', () async {
    await c.read(glanceRefresherProvider).refreshNow();
    expect(module.glanceCalls, 2);
    final (today, next) = summary.calls.single;
    expect(today!.date, DateTime(2026, 10, 21));
    expect(next!.date, DateTime(2026, 10, 22));
    final p = bridge.saved.single;
    expect(at(p, ['mode']), 'data');
    expect(at(p, ['today', 'dateKey']), '2026-10-21');
    expect(at(p, ['today', 'habits', 0, 'name']), 'Walk 21');
    expect(at(p, ['next', 'habits', 0, 'name']), 'Walk 22');
  });

  test('writes to watched tables refresh once after a burst', () async {
    final r = c.read(glanceRefresherProvider)..start();
    await settle();
    final before = bridge.saved.length;
    final settings = c.read(settingsRepositoryProvider);
    await settings.setCurrency('USD');
    await settings.setFirstDayOfWeek(7);
    await settings.setLocale('hi');
    await settle();
    expect(bridge.saved.length, before + 1);
    expect(r.started, isTrue);
  });

  test('writes to other tables do not refresh', () async {
    c.read(glanceRefresherProvider).start();
    await settle();
    final before = bridge.saved.length;
    await db.customInsert(
      'INSERT INTO unlocks (id, feature_key, source, created_at, updated_at) '
      "VALUES ('u1', 'exportCsv', 0, 0, 0)",
      updates: {db.unlocks},
    );
    await settle();
    expect(bridge.saved.length, before);
  });

  group('FR-047 hidden mode', () {
    Future<String> mode() async {
      await c.read(glanceRefresherProvider).refreshNow();
      return at(bridge.saved.last, ['mode'])! as String;
    }

    test('lock off → data', () async {
      expect(await mode(), 'data');
    });

    test('lock on without "Show data on widget" → hidden', () async {
      await c.read(settingsRepositoryProvider).setLockEnabled(enabled: true);
      expect(await mode(), 'hidden');
      expect(at(bridge.saved.last, ['today']), isNull);
    });

    test('lock on with "Show data on widget" → data', () async {
      final s = c.read(settingsRepositoryProvider);
      await s.setLockEnabled(enabled: true);
      await s.setShowDataOnWidget(enabled: true);
      expect(await mode(), 'data');
    });

    test('before onboarding → hidden', () async {
      await db.customStatement(
        "DELETE FROM settings WHERE key = 'onboardingDone'",
      );
      expect(await mode(), 'hidden');
    });
  });

  test('a module that throws leaves its part empty; the payload is still '
      'saved', () async {
    module.glance = (_, _) => throw StateError('boom');
    await c.read(glanceRefresherProvider).refreshNow();
    expect(at(bridge.saved.single, ['today', 'habits']), isEmpty);
  });

  test('a host without a widget never throws', () async {
    final r = GlanceRefresher(
      db: db,
      read: <T>(p) => throw StateError('no providers'),
      clock: clock,
    );
    await r.refreshNow();
  });

  test('widgetHidden', () {
    expect(widgetHidden(const AppSettings(onboardingDone: true)), isFalse);
    expect(widgetHidden(const AppSettings()), isTrue);
    expect(
      widgetHidden(const AppSettings(onboardingDone: true, lockEnabled: true)),
      isTrue,
    );
    expect(
      widgetHidden(
        const AppSettings(
          onboardingDone: true,
          lockEnabled: true,
          showDataOnWidget: true,
        ),
      ),
      isFalse,
    );
  });

  test('the bridge URIs', () {
    expect(
      WidgetUris.isCheck(Uri.parse('dailytrack://widget/check?habit=a&day=b')),
      isTrue,
    );
    expect(WidgetUris.isOpen(Uri.parse('dailytrack://widget/open')), isTrue);
    expect(
      WidgetUris.systemTrigger(Uri.parse('dailytrack://system/timezone')),
      'timezone',
    );
    expect(
      WidgetUris.systemTrigger(Uri.parse('dailytrack://system/other')),
      isNull,
    );
    expect(
      WidgetUris.systemTrigger(Uri.parse('https://x/system/boot')),
      isNull,
    );
  });
}
