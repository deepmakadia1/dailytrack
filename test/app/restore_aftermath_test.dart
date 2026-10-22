import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/daily_summary_scheduler.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

/// Logs cancelAll into the shared order.
final class _LoggingNotifications extends FakeNotificationService {
  new(this.log);

  final List<String> log;
  Error? fail;

  @override
  Future<void> cancelAll() async {
    log.add('cancelAll');
    if (fail case final e?) throw e;
    await super.cancelAll();
  }
}

/// The restore aftermath bound in production_overrides.dart (feature 008
/// T113, research R8, R18, R19).
void main() {
  late List<String> log;
  late _LoggingNotifications notifications;
  late FakeDailySummaryScheduler summary;
  late FakeGlanceRefresher refresher;
  late ProviderContainer c;
  final aftermath = Provider(bindRestoreAftermath);

  setUp(() {
    log = [];
    notifications = _LoggingNotifications(log);
    summary = FakeDailySummaryScheduler(log: log);
    refresher = FakeGlanceRefresher(log: log);
    final habit = FakeTrackerModule(id: 'habit')
      ..onAppOpenBody = () async => log.add('appOpen');
    c = ProviderContainer(
      overrides: [
        moduleRegistryProvider.overrideWithValue(ModuleRegistry([habit])),
        settingsRepositoryProvider.overrideWithValue(
          FakeSettingsRepository(
            initial: const AppSettings(
              enabledModules: ['habit'],
              moduleOrder: ['habit'],
            ),
          ),
        ),
        notificationServiceProvider.overrideWithValue(notifications),
        dailySummarySchedulerProvider.overrideWithValue(summary),
        glanceRefresherProvider.overrideWithValue(refresher),
        timeZoneSourceProvider.overrideWithValue(FakeTimeZoneSource(null)),
      ],
    );
    addTearDown(c.dispose);
  });

  test('cancels everything, reruns app open, then the summary and the '
      'widget, in that order', () async {
    await c.read(aftermath)();
    expect(log, ['cancelAll', 'appOpen', 'summary', 'refresh']);
  });

  test(
    'a failing step does not fail the restore or skip later steps',
    () async {
      notifications.fail = StateError('plugin');
      summary.fail = StateError('zone');
      await c.read(aftermath)();
      expect(log, ['cancelAll', 'appOpen', 'summary', 'refresh']);
    },
  );
}
