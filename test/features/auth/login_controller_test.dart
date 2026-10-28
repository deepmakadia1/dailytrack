import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_ui.dart';
import 'package:dailytrack/core/background/background_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/support/network_state_source.dart';
import 'package:dailytrack/features/auth/presentation/controllers/login_controller.dart';
import 'package:dailytrack/features/auth/presentation/controllers/login_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../account/account_test_app.dart' show otherPhoneMeta;

/// AUTH-01 controller (feature 011 T026, research R9): `authMode` is
/// written only once every branch has settled.
void main() {
  late FakeSettingsRepository settings;
  late FakeAccountAuth auth;
  late FakeDriveBackupStore drive;
  late FakeBackupService backup;
  late FakeNetworkStateSource network;
  late FakeAccountRestore restore;
  late List<String> writes;

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        accountAuthProvider.overrideWithValue(auth),
        backgroundSchedulerProvider.overrideWithValue(
          FakeBackgroundScheduler(),
        ),
        driveBackupStoreProvider.overrideWithValue(drive),
        backupServiceProvider.overrideWithValue(backup),
        networkStateSourceProvider.overrideWithValue(network),
        accountRestoreProvider.overrideWithValue(restore),
      ],
    );
    addTearDown(c.dispose);
    // Keep the auto-dispose controller alive between calls.
    c.listen(loginControllerProvider, (_, _) {});
    return c;
  }

  setUp(() {
    settings = FakeSettingsRepository(
      initial: const AppSettings(onboardingDone: true),
      authModeStored: true,
    );
    writes = [];
    settings.onWrite = writes.add;
    auth = FakeAccountAuth();
    drive = FakeDriveBackupStore();
    backup = FakeBackupService();
    network = FakeNetworkStateSource();
    restore = FakeAccountRestore(settings: settings);
  });

  LoginController controller(ProviderContainer c) =>
      c.read(loginControllerProvider.notifier);

  test('continueAsGuest sets the sheet flag, then guest, and reads nothing '
      'else', () async {
    final c = container();
    await controller(c).continueAsGuest();
    expect(writes, ['setFinishSetupPending', 'setAuthMode']);
    expect(settings.current.authMode, AuthMode.guest);
    expect(settings.current.finishSetupPending, isTrue);
    expectNoGoogleCalls(auth, drive);
    expect(network.loads, 0);
  });

  for (final (label, arrange, error) in [
    ('offline', () => network.online = false, LoginError.offline),
    (
      'cancelled',
      () => auth.signInResult = const DriveAuthRequired(),
      LoginError.cancelled,
    ),
    (
      'failed',
      () => auth.signInResult = const DriveUnavailable('500'),
      LoginError.failed,
    ),
  ]) {
    test('$label: the inline error, and nothing written', () async {
      arrange();
      final c = container();
      expect(await controller(c).continueWithGoogle(), isA<LoginDone>());
      expect(c.read(loginControllerProvider).error, error);
      expect(c.read(loginControllerProvider).isBusy, isFalse);
      expect(settings.writeCount, 0);
    });
  }

  test('no backup: committed last, after the sheet flag, then one first '
      'backup', () async {
    final c = container();
    expect(await controller(c).continueWithGoogle(), isA<LoginDone>());
    expect(writes.first, 'setAccount');
    expect(
      writes.indexOf('setFinishSetupPending'),
      lessThan(writes.indexOf('setAuthMode')),
    );
    expect(settings.current.authMode, AuthMode.google);
    await pumpEventQueue();
    expect(backup.driveBackups, 1);
  });

  test('backups: authMode stays none while ACC-02 is open, whatever it takes '
      'to settle', () async {
    drive.seed(meta: otherPhoneMeta());
    restore.hasData = true;
    final c = container();
    final next = await controller(c).continueWithGoogle();
    expect(next, isA<LoginChooseRestore>());
    // The screen now shows ACC-02 and waits for the user.
    expect(c.read(loginControllerProvider).busy, LoginBusy.choosing);
    expect(settings.current.authMode, AuthMode.none);
    expect(settings.current.backupAccountEmail, 'me@example.com');
    await pumpEventQueue();
    expect(settings.current.authMode, AuthMode.none);

    await controller(c).onRestoreChoice(RestoreChoiceResult.kept);
    expect(settings.current.authMode, AuthMode.google);
    expect(settings.current.finishSetupPending, isTrue);
    expect(backup.driveBackups, 0, reason: 'ACC-02 made the backup itself');
  });

  test('no data on the phone: the restoring view, not the choice', () async {
    drive.seed(meta: otherPhoneMeta());
    final c = container();
    await controller(c).continueWithGoogle();
    expect(c.read(loginControllerProvider).busy, LoginBusy.restoring);
  });

  test('a closed restore: the restore error view, authMode none; "Continue '
      'without restoring" commits', () async {
    drive.seed(meta: otherPhoneMeta());
    final c = container();
    await controller(c).continueWithGoogle();
    await controller(c).onRestoreChoice(RestoreChoiceResult.closed);
    final state = c.read(loginControllerProvider);
    expect(state.restoreFailed, isTrue);
    expect(state.pendingBackup, isNotNull);
    expect(settings.current.authMode, AuthMode.none);

    expect(await controller(c).retryRestore(), isA<LoginChooseRestore>());
    await controller(c).onRestoreChoice(RestoreChoiceResult.closed);
    await controller(c).continueWithoutRestoring();
    expect(settings.current.authMode, AuthMode.google);
    expect(backup.driveBackups, 0);
  });
}
