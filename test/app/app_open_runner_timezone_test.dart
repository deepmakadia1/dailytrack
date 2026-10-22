import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// AppOpenRunner's time zone check (feature 008 T111, FR-041, research
/// R21): covers devices that drop the time zone broadcast.
void main() {
  late FakeTrackerModule habit;
  late FakeSettingsRepository settings;
  late FakeDailySummaryScheduler summary;
  late FakeTimeZoneSource zones;
  late ProviderContainer c;

  void build(String? stored, String? device) {
    habit = FakeTrackerModule(id: 'habit');
    settings = FakeSettingsRepository(
      initial: AppSettings(
        onboardingDone: true,
        enabledModules: const ['habit'],
        moduleOrder: const ['habit'],
        deviceTimeZoneId: stored,
      ),
    );
    summary = FakeDailySummaryScheduler();
    zones = FakeTimeZoneSource(device);
    c = ProviderContainer(
      overrides: [
        moduleRegistryProvider.overrideWithValue(ModuleRegistry([habit])),
        settingsRepositoryProvider.overrideWithValue(settings),
        notificationServiceProvider.overrideWithValue(
          FakeNotificationService(),
        ),
        dailySummarySchedulerProvider.overrideWithValue(summary),
        timeZoneSourceProvider.overrideWithValue(zones),
      ],
    );
    addTearDown(c.dispose);
  }

  Future<void> open() => c.read(appOpenRunnerProvider).run();

  test('a changed zone reschedules the modules and the summary, and stores '
      'the new zone', () async {
    build('Asia/Kolkata', 'Europe/London');
    await open();
    expect(habit.appOpenCalls, 1);
    expect(habit.notificationSettingsChangedCalls, 1);
    expect(summary.calls, hasLength(1));
    expect(settings.current.deviceTimeZoneId, 'Europe/London');
  });

  test('an unchanged zone: only the usual app-open work', () async {
    build('Asia/Kolkata', 'Asia/Kolkata');
    await open();
    expect(habit.appOpenCalls, 1);
    expect(habit.notificationSettingsChangedCalls, 0);
    expect(summary.calls, isEmpty);
    expect(settings.calls['setDeviceTimeZoneId'], isNull);
  });

  test('the first open only records the zone', () async {
    build(null, 'Asia/Kolkata');
    await open();
    expect(habit.notificationSettingsChangedCalls, 0);
    expect(summary.calls, isEmpty);
    expect(settings.current.deviceTimeZoneId, 'Asia/Kolkata');
  });

  test('an unreadable zone changes nothing', () async {
    build('Asia/Kolkata', null);
    await open();
    expect(habit.notificationSettingsChangedCalls, 0);
    expect(settings.current.deviceTimeZoneId, 'Asia/Kolkata');
  });
}
