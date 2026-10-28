import 'package:dailytrack/app/auto_backup_task.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

/// Auto and background backups run only once the sign-in is committed
/// (feature 011 T009, research R4): account keys alone, while the user is
/// still choosing on AUTH-01 or is a guest, never upload.
void main() {
  AppSettings withKeys(AuthMode mode) => AppSettings(
    onboardingDone: true,
    authMode: mode,
    backupAccountEmail: 'me@example.com',
    autoBackupFrequency: AutoBackupFrequency.daily,
    dataChangeCounter: 3,
    backedUpChangeCounter: 1,
  );

  for (final mode in AuthMode.values) {
    final runs = mode == AuthMode.google;
    group('account keys set, authMode ${mode.name}', () {
      test(
        'syncAutoBackupSchedule ${runs ? 'schedules' : 'schedules nothing'}',
        () async {
          final scheduler = FakeBackgroundScheduler();
          await syncAutoBackupSchedule(withKeys(mode), scheduler);
          expect(scheduler.periodic.isNotEmpty, runs);
        },
      );

      test('onAppHidden ${runs ? 'enqueues' : 'enqueues nothing'}', () async {
        final scheduler = FakeBackgroundScheduler();
        await BackgroundBackupScheduler(
          settings: FakeSettingsRepository(initial: withKeys(mode)),
          scheduler: scheduler,
          clock: MutableClock(DateTime(2026, 10, 28, 21)),
        ).onAppHidden();
        expect(scheduler.oneOff.isNotEmpty, runs);
      });

      test(
        'runAutoBackup ${runs ? 'backs up' : 'makes no Drive call'}',
        () async {
          final backup = FakeBackupService();
          final c = ProviderContainer(
            overrides: [
              settingsRepositoryProvider.overrideWithValue(
                FakeSettingsRepository(initial: withKeys(mode)),
              ),
              backupServiceProvider.overrideWithValue(backup),
              notificationServiceProvider.overrideWithValue(
                FakeNotificationService(),
              ),
              moduleRegistryProvider.overrideWithValue(
                ModuleRegistry(const []),
              ),
              backgroundSchedulerProvider.overrideWithValue(
                FakeBackgroundScheduler(),
              ),
              accountAuthProvider.overrideWithValue(FakeAccountAuth()),
            ],
          );
          addTearDown(c.dispose);
          expect(await runAutoBackup(c.read), isTrue);
          expect(backup.driveBackups, runs ? 1 : 0);
        },
      );
    });
  }
}
