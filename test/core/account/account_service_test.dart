import 'package:dailytrack/core/account/account_service.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/auto_backup_schedule.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';

/// The account layer (feature 010 T025, data-model §6, spec §16 "Account
/// state is local", FR-003, FR-004, FR-006, FR-024, research R2), with
/// feature 011's sign-in mode (research R3, contracts/services.md).
void main() {
  late FakeAccountAuth auth;
  late FakeSettingsRepository settings;
  late FakeBackgroundScheduler scheduler;

  const stored = AppSettings(
    locale: 'gu',
    backupAccountEmail: 'me@example.com',
    accountDisplayName: 'Asha Patel',
    autoBackupFrequency: AutoBackupFrequency.daily,
    lastKnownDriveBackupAt: 1792540800000,
    lastKnownDriveBackupDeviceId: 'this-phone',
    authMode: AuthMode.google,
  );

  AccountService service() =>
      AccountService(auth: auth, settings: settings, scheduler: scheduler);

  setUp(() {
    auth = FakeAccountAuth();
    settings = FakeSettingsRepository();
    scheduler = FakeBackgroundScheduler();
  });

  group('signIn', () {
    test('saves the account keys only: authMode, Auto backup, and the '
        'schedule are unchanged (feature 011 R3)', () async {
      final profile = await service().signIn();
      final s = settings.current;
      expect(profile?.email, 'me@example.com');
      expect(s.backupAccountEmail, 'me@example.com');
      expect(s.accountDisplayName, 'Asha Patel');
      expect(s.authMode, AuthMode.none);
      expect(s.autoBackupFrequency, AutoBackupFrequency.off);
      expect(scheduler.periodic, isEmpty);
      expect(await service().current(), isA<SignedOut>());
    });

    test('§16 cancelling sign-in changes nothing', () async {
      auth.signInResult = const DriveAuthRequired();
      expect(await service().signIn(), isNull);
      expect(settings.writeCount, 0);
      expect(scheduler.ensured, isEmpty);
    });

    test('a sign-in failure is thrown and saves nothing', () async {
      auth.signInResult = const DriveUnavailable('500');
      await expectLater(service().signIn(), throwsA(isA<DriveUnavailable>()));
      expect(settings.current.backupAccountEmail, isNull);
    });
  });

  group('commitSignIn', () {
    test('§16 sets google, turns Auto backup from Off to Daily, and syncs the '
        'schedule', () async {
      final s = service();
      await s.signIn();
      await s.commitSignIn();
      expect(settings.current.authMode, AuthMode.google);
      expect(settings.current.autoBackupFrequency, AutoBackupFrequency.daily);
      expect(scheduler.periodic.keys, contains(autoBackupTaskName));
      expect(
        await s.current(),
        isA<SignedIn>().having((x) => x.verified, 'verified', true),
      );
    });

    test('§16 leaves Weekly as it was', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(
          autoBackupFrequency: AutoBackupFrequency.weekly,
        ),
      );
      final s = service();
      await s.signIn();
      await s.commitSignIn();
      expect(settings.current.autoBackupFrequency, AutoBackupFrequency.weekly);
    });
  });

  test('stateOf is SignedIn only with authMode google and an email', () {
    final s = service();
    expect(s.stateOf(stored), isA<SignedIn>());
    for (final mode in [AuthMode.none, AuthMode.guest]) {
      expect(s.stateOf(stored.copyWith(authMode: mode)), isA<SignedOut>());
    }
    expect(
      s.stateOf(const AppSettings(authMode: AuthMode.google)),
      isA<SignedOut>(),
    );
  });

  for (final to in [AuthMode.none, AuthMode.guest]) {
    test('§16 sign-out to ${to.name} writes authMode first, then clears the '
        'account keys and the last known backup, keeps the Auto backup '
        'setting, and cancels both backup jobs', () async {
      settings = FakeSettingsRepository(initial: stored);
      final writes = <String>[];
      settings.onWrite = writes.add;
      await service().signOut(to: to);
      final s = settings.current;
      expect(writes.first, 'setAuthMode');
      expect(writes, contains('setAccount'));
      expect(s.authMode, to);
      expect(auth.signOuts, 1);
      expect(s.backupAccountEmail, isNull);
      expect(s.accountDisplayName, isNull);
      expect(s.lastKnownDriveBackupAt, isNull);
      expect(s.autoBackupFrequency, AutoBackupFrequency.daily);
      expect(s.locale, 'gu', reason: 'data stays');
      expect(
        scheduler.cancelled,
        containsAll([autoBackupTaskName, backgroundBackupTaskName]),
      );
    });
  }

  group('silent sign-in on start (restoreSession)', () {
    test('§16 the session is still there: signed in and verified, profile '
        'refreshed', () async {
      settings = FakeSettingsRepository(initial: stored);
      auth.silentResult = const AccountProfile(
        email: 'me@example.com',
        displayName: 'Asha P.',
      );
      final s = service();
      await s.restoreSession();
      final state = await s.current();
      expect(
        state,
        isA<SignedIn>().having((x) => x.verified, 'verified', true),
      );
      expect(settings.current.accountDisplayName, 'Asha P.');
    });

    test('§16 no session (token revoked, account removed from the phone): the '
        'account keys are cleared and all data is kept', () async {
      settings = FakeSettingsRepository(initial: stored);
      auth.silentResult = null;
      final s = service();
      await s.restoreSession();
      final after = settings.current;
      expect(await s.current(), isA<SignedOut>());
      expect(after.backupAccountEmail, isNull);
      expect(after.accountDisplayName, isNull);
      expect(after.authMode, AuthMode.guest);
      expect(after.locale, 'gu', reason: 'data stays');
      expect(auth.signOuts, 0, reason: 'nothing is asked of Google');
      expect(scheduler.cancelled, contains(autoBackupTaskName));
    });

    test('§16 an offline start keeps the user signed in, unverified', () async {
      settings = FakeSettingsRepository(initial: stored);
      for (final failure in const [
        DriveOffline(),
        DriveUnavailable('networkError'),
      ]) {
        auth.silentResult = failure;
        final s = service();
        await s.restoreSession();
        expect(
          await s.current(),
          isA<SignedIn>().having((x) => x.verified, 'verified', false),
        );
        expect(settings.current.backupAccountEmail, 'me@example.com');
      }
    });

    test('signed out: nothing is asked of Google', () async {
      auth.silentResult = const DriveOffline();
      await service().restoreSession();
      expect(settings.writeCount, 0);
    });

    // Feature 011 T031, research R5.
    test('google with no session: keys cleared, guest, rows kept', () async {
      settings = FakeSettingsRepository(initial: stored);
      auth.silentResult = null;
      await service().restoreSession();
      expect(settings.current.authMode, AuthMode.guest);
      expect(settings.current.backupAccountEmail, isNull);
      expect(settings.current.locale, 'gu');
    });

    test(
      'google offline (a thrown failure): stays google, unverified',
      () async {
        settings = FakeSettingsRepository(initial: stored);
        auth.silentResult = const DriveOffline();
        final s = service();
        await s.restoreSession();
        expect(settings.current.authMode, AuthMode.google);
        expect(
          await s.current(),
          isA<SignedIn>().having((x) => x.verified, 'verified', false),
        );
      },
    );

    for (final mode in [AuthMode.none, AuthMode.guest]) {
      test('${mode.name} with keys left by an interrupted sign-in: keys '
          'cleared and Google signed out once', () async {
        settings = FakeSettingsRepository(
          initial: stored.copyWith(authMode: mode),
          authModeStored: true,
        );
        await service().restoreSession();
        expect(settings.current.backupAccountEmail, isNull);
        expect(settings.current.authMode, mode);
        expect(auth.calls, ['signOut']);
      });
    }

    test('guest with no keys: no Google call at all', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(authMode: AuthMode.guest),
      );
      await service().restoreSession();
      expect(auth.calls, isEmpty);
      expect(settings.writeCount, 0);
    });

    test('google without keys (right after an Android restore) is left to '
        'the Android-restore step', () async {
      settings = FakeSettingsRepository(
        initial: const AppSettings(authMode: AuthMode.google),
      );
      await service().restoreSession();
      expect(auth.calls, isEmpty);
      expect(settings.current.authMode, AuthMode.google);
    });
  });

  test(
    'DriveAuthRequired from guardAuth makes a signed-in user a guest',
    () async {
      settings = FakeSettingsRepository(initial: stored);
      await expectLater(
        service().guardAuth<void>(() async => throw const DriveAuthRequired()),
        throwsA(isA<DriveAuthRequired>()),
      );
      expect(settings.current.authMode, AuthMode.guest);
    },
  );

  group('beginSwitch (ACC-01 Switch account)', () {
    test('signs out of Google and forgets the old backup state, keeping '
        'google and the keys until the chooser ends', () async {
      settings = FakeSettingsRepository(initial: stored);
      await service().beginSwitch();
      final s = settings.current;
      expect(auth.calls, ['signOut']);
      expect(s.authMode, AuthMode.google);
      expect(s.backupAccountEmail, 'me@example.com');
      expect(s.lastKnownDriveBackupAt, isNull);
      expect(
        scheduler.cancelled,
        containsAll([autoBackupTaskName, backgroundBackupTaskName]),
      );
    });
  });

  test('§16 when Drive says access is gone, the account is forgotten, the '
      'user becomes a guest, and data is kept', () async {
    settings = FakeSettingsRepository(initial: stored);
    final s = service();
    await s.forgetAfterAuthLoss();
    expect(await s.current(), isA<SignedOut>());
    expect(settings.current.backupAccountEmail, isNull);
    expect(settings.current.authMode, AuthMode.guest);
    expect(settings.current.locale, 'gu');
  });

  test('on AUTH-01 (keys saved, authMode none) losing access keeps none, so '
      'the user stays on AUTH-01', () async {
    settings = FakeSettingsRepository(
      initial: stored.copyWith(authMode: AuthMode.none),
      authModeStored: true,
    );
    await service().forgetAfterAuthLoss();
    expect(settings.current.authMode, AuthMode.none);
    expect(settings.current.backupAccountEmail, isNull);
  });

  test(
    'guardAuth forgets the account on DriveAuthRequired and rethrows',
    () async {
      settings = FakeSettingsRepository(initial: stored);
      final s = service();
      await expectLater(
        s.guardAuth<void>(() async => throw const DriveAuthRequired()),
        throwsA(isA<DriveAuthRequired>()),
      );
      expect(settings.current.backupAccountEmail, isNull);
    },
  );
}
