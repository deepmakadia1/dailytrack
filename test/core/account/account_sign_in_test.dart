import 'package:dailytrack/core/account/account_service.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';

/// The shared "Sign in with Google" behind the SET-02 Drive card and ACC-01
/// Switch account (spec §16 "Guest sign-in": FR-007, FR-009), which commits
/// the sign-in at once, and AUTH-01's `login()`, which never sets
/// `authMode` (feature 011 research R9).
void main() {
  late FakeAccountAuth auth;
  late FakeSettingsRepository settings;
  late FakeDriveBackupStore drive;
  late FakeBackupService backup;
  late FakeNetworkStateSource network;

  AccountSignIn subject() => AccountSignIn(
    account: AccountService(
      auth: auth,
      settings: settings,
      scheduler: FakeBackgroundScheduler(),
    ),
    settings: settings,
    drive: drive,
    backup: backup,
    network: network,
  );

  setUp(() {
    auth = FakeAccountAuth();
    settings = FakeSettingsRepository();
    drive = FakeDriveBackupStore();
    backup = FakeBackupService();
    network = FakeNetworkStateSource();
  });

  test('§16 offline: nothing is asked of Google or Drive', () async {
    network.online = false;
    expect(await subject().run(), isA<SignInOffline>());
    expect(auth.signIns, 0);
    expect(drive.calls, isEmpty);
    expect(settings.current.backupAccountEmail, isNull);
  });

  test(
    '§16 an account without a backup: this phone is backed up right away',
    () async {
      expect(await subject().run(), isA<SignedInAndBackedUp>());
      expect(settings.current.backupAccountEmail, 'me@example.com');
      expect(settings.current.authMode, AuthMode.google);
      expect(backup.driveBackups, 1);
    },
  );

  test('§16 an account with a backup: nothing is uploaded; the caller opens '
      'ACC-02 for the newest backup', () async {
    drive
      ..seed(meta: _meta(createdAt: 1792540800000))
      ..seed(meta: _meta(createdAt: 1792540900000));
    final outcome = await subject().run();
    expect(
      outcome,
      isA<SignedInWithBackups>().having(
        (o) => o.newest.createdAt,
        'newest',
        1792540900000,
      ),
    );
    expect(backup.driveBackups, 0);
  });

  test('§16 a failed first backup keeps the sign-in', () async {
    backup.error = const DriveOffline();
    expect(await subject().run(), isA<SignedInBackupFailed>());
    expect(settings.current.backupAccountEmail, 'me@example.com');
  });

  test('§16 cancelled sign-in changes nothing', () async {
    auth.signInResult = const DriveAuthRequired();
    expect(await subject().run(), isA<SignInCancelled>());
    expect(settings.writeCount, 0);
    expect(drive.calls, isEmpty);
  });

  test('§16 a failed sign-in is thrown for the screen to explain', () async {
    auth.signInResult = const DriveUnavailable('500');
    await expectLater(subject().run(), throwsA(isA<DriveUnavailable>()));
    expect(settings.current.backupAccountEmail, isNull);
  });
  group('login (AUTH-01)', () {
    test('offline: LoginOffline with no auth or Drive call', () async {
      network.online = false;
      expect(await subject().login(), isA<LoginOffline>());
      expectNoGoogleCalls(auth, drive);
      expect(settings.writeCount, 0);
    });

    test('cancelled: LoginCancelled and no key written', () async {
      auth.signInResult = const DriveAuthRequired();
      expect(await subject().login(), isA<LoginCancelled>());
      expect(settings.writeCount, 0);
      expect(drive.calls, isEmpty);
    });

    test('an auth failure: LoginFailed and no key written', () async {
      auth.signInResult = const DriveUnavailable('500');
      expect(await subject().login(), isA<LoginFailed>());
      expect(settings.writeCount, 0);
    });

    test('an empty Drive: LoginNoBackup with the keys saved and authMode '
        'still none; nothing is uploaded', () async {
      expect(await subject().login(), isA<LoginNoBackup>());
      expect(settings.current.backupAccountEmail, 'me@example.com');
      expect(settings.current.authMode, AuthMode.none);
      expect(backup.driveBackups, 0);
    });

    test('backups: LoginHasBackups with the newest', () async {
      drive
        ..seed(meta: _meta(createdAt: 1792540800000))
        ..seed(meta: _meta(createdAt: 1792540900000));
      expect(
        await subject().login(),
        isA<LoginHasBackups>().having(
          (o) => o.newest.createdAt,
          'newest',
          1792540900000,
        ),
      );
      expect(settings.current.authMode, AuthMode.none);
    });

    test('a list failure after sign-in: LoginFailed with the keys cleared '
        'again and authMode still none', () async {
      drive.failNext = const DriveAuthRequired();
      expect(await subject().login(), isA<LoginFailed>());
      expect(settings.current.backupAccountEmail, isNull);
      expect(settings.current.authMode, AuthMode.none);
    });
  });
}

BackupMeta _meta({required int createdAt}) => BackupMeta(
  deviceId: 'other-phone',
  deviceName: 'Redmi Note 12',
  appVersion: '1.0.0+7',
  createdAt: createdAt,
  kind: BackupKind.auto,
  counts: const {'expense.transactions': 3},
  schemaVersion: 5,
  encrypted: false,
);
