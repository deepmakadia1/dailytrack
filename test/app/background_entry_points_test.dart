import 'package:dailytrack/app/background_entry_points.dart';
import 'package:dailytrack/core/module/app_action.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// Background entry points (feature 008 T108, T110, T127; research R16,
/// R17, R20, R21). The plugin entry points themselves run on a device; their
/// testable cores are exercised here with fakes.
void main() {
  late FakeTrackerModule habit;
  late FakeTrackerModule expense;
  late FakeSettingsRepository settings;
  late FakeNotificationService notifications;
  late FakeGlanceRefresher refresher;
  late FakeDailySummaryScheduler summary;
  late List<String> log;
  late ProviderContainer c;

  void build({AppSettings initial = const AppSettings(onboardingDone: true)}) {
    log = [];
    habit = FakeTrackerModule(id: 'habit');
    expense = FakeTrackerModule(id: 'expense');
    settings = FakeSettingsRepository(initial: initial);
    notifications = FakeNotificationService();
    refresher = FakeGlanceRefresher(log: log);
    summary = FakeDailySummaryScheduler(log: log);
    c = ProviderContainer(
      overrides: [
        moduleRegistryProvider.overrideWithValue(
          ModuleRegistry([expense, habit]),
        ),
        settingsRepositoryProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(notifications),
        glanceRefresherProvider.overrideWithValue(refresher),
        dailySummarySchedulerProvider.overrideWithValue(summary),
        timeZoneSourceProvider.overrideWithValue(FakeTimeZoneSource()),
      ],
    );
    addTearDown(c.dispose);
  }

  setUp(build);

  group('notification actions (T108)', () {
    test('parses the action and payload, dispatches an AppAction, then '
        'refreshes', () async {
      habit.handles = true;
      await handleNotificationAction(
        'habit.markDone',
        '/habits?habit=h1&at=08:00&wd=3',
        c.read,
      );
      final a = habit.actions.single;
      expect(a.source, AppActionSource.notification);
      expect(a.name, 'habit.markDone');
      expect(a.params, {'habit': 'h1', 'at': '08:00', 'wd': '3'});
      expect(refresher.refreshCalls, 1);
    });

    test(
      'a throwing dispatch does not throw out; the refresh still runs',
      () async {
        habit.handleError = StateError('boom');
        await handleNotificationAction(
          'habit.snooze',
          '/habits?habit=h1',
          c.read,
        );
        expect(refresher.refreshCalls, 1);
      },
    );

    test('a failing refresh does not throw out', () async {
      refresher.fail = StateError('db');
      await handleNotificationAction('habit.snooze', 'not a uri %%', c.read);
    });

    test('payloadParams', () {
      expect(payloadParams('/habits?habit=a&at=21:00&wd=0'), {
        'habit': 'a',
        'at': '21:00',
        'wd': '0',
      });
      expect(payloadParams('/home'), isEmpty);
    });
  });

  group('widget checks (T127)', () {
    final check = Uri.parse(
      'dailytrack://widget/check?habit=h1&day=2026-10-21',
    );

    test(
      'dispatches habit.widgetCheck from the widget, then refreshes',
      () async {
        habit.handles = true;
        await handleWidgetUri(check, c);
        final a = habit.actions.single;
        expect(a.source, AppActionSource.widget);
        expect(a.name, 'habit.widgetCheck');
        expect(a.params, {'habit': 'h1', 'day': '2026-10-21'});
        expect(refresher.refreshCalls, 1);
      },
    );

    test('FR-047 hidden mode (lock on, no "Show data on widget"): no '
        'dispatch, but the widget is redrawn', () async {
      build(
        initial: const AppSettings(onboardingDone: true, lockEnabled: true),
      );
      await handleWidgetUri(check, c);
      expect(habit.actions, isEmpty);
      expect(refresher.refreshCalls, 1);
    });

    test('lock on with "Show data on widget": dispatched', () async {
      build(
        initial: const AppSettings(
          onboardingDone: true,
          lockEnabled: true,
          showDataOnWidget: true,
        ),
      );
      await handleWidgetUri(check, c);
      expect(habit.actions, hasLength(1));
    });

    test('an unknown or missing URI only refreshes', () async {
      await handleWidgetUri(null, c);
      await handleWidgetUri(Uri.parse('dailytrack://widget/open'), c);
      expect(habit.actions, isEmpty);
      expect(refresher.refreshCalls, 2);
    });
  });

  group('system triggers (T110, research R21)', () {
    for (final trigger in ['boot', 'timezone']) {
      test('$trigger: re-reads the zone, each visible module reschedules, '
          'the summary, then the refresh; the zone is recorded', () async {
        await handleWidgetUri(Uri.parse('dailytrack://system/$trigger'), c);
        expect(notifications.refreshTimeZoneCalls, 1);
        expect(habit.notificationSettingsChangedCalls, 1);
        expect(expense.notificationSettingsChangedCalls, 1);
        expect(log, ['summary', 'refresh']);
        expect(settings.current.deviceTimeZoneId, 'Asia/Kolkata');
      });
    }

    test(
      'midnight: the summary and the refresh, no module reschedule',
      () async {
        await handleWidgetUri(Uri.parse('dailytrack://system/midnight'), c);
        expect(habit.notificationSettingsChangedCalls, 0);
        expect(log, ['summary', 'refresh']);
      },
    );

    test('disabled modules are skipped', () async {
      build(
        initial: const AppSettings(
          onboardingDone: true,
          enabledModules: ['habit'],
        ),
      );
      await handleSystemTrigger('boot', c);
      expect(expense.notificationSettingsChangedCalls, 0);
      expect(habit.notificationSettingsChangedCalls, 1);
    });

    test('a failing summary still records the zone', () async {
      summary.fail = StateError('x');
      await handleSystemTrigger('timezone', c);
      expect(settings.current.deviceTimeZoneId, 'Asia/Kolkata');
    });
  });

  test('registerWidgetHost registers the callback and arms midnight', () async {
    final bridge = FakeHomeWidgetBridge();
    await registerWidgetHost(bridge);
    expect(bridge.callbacks.single, widgetBackgroundEntryPoint);
    expect(bridge.armMidnightCalls, 1);
  });
}
