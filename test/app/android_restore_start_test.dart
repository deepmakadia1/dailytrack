import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:dailytrack/core/security/security_providers.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/backup_fakes.dart';
import '../helpers/fakes.dart';
import '../helpers/real_container.dart';

/// The first start after Android Auto Backup or device transfer restored
/// the database (spec §16, feature 010 US7, T095, research R4, R13). §16
/// criteria "Two installs never share a deviceId, including after a Drive
/// restore or an Android Auto Backup restore." and "On the first start
/// after an Android Auto Backup restore with app lock on and no PIN hash,
/// the lock is turned off and the "Finish setting up" sheet is shown instead
/// of locking the user out."
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late FakeDeviceIdFile file;
  late FakeAccountAuth auth;
  late InMemorySecureStore secure;
  late FakeProStore pro;
  late int aftermaths;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    file = FakeDeviceIdFile();
    auth = FakeAccountAuth()..silentResult = null;
    secure = InMemorySecureStore();
    pro = FakeProStore();
    aftermaths = 0;
  });
  tearDown(() => db.close());

  ProviderContainer container() => makeRealContainer(
    db,
    overrides: [
      consentServiceProvider.overrideWithValue(
        FakeConsentService(stored: true),
      ),
      deviceIdFileProvider.overrideWithValue(file),
      accountAuthProvider.overrideWithValue(auth),
      proStoreProvider.overrideWithValue(pro),
      restoreAftermathProvider.overrideWithValue(() async => aftermaths++),
      lockServiceProvider.overrideWith(
        (ref) => SecureLockService(
          store: secure,
          biometrics: FakeBiometricAuthenticator(),
          settings: ref.watch(settingsRepositoryProvider),
          clock: const Clock(),
        ),
      ),
    ],
  );

  /// The database as Android restored it: a past user with app lock on,
  /// an account, and a known backup, but no secure storage.
  Future<SettingsRepository> restoredDatabase(ProviderContainer c) async {
    final s = c.read(settingsRepositoryProvider);
    await db.customStatement(
      "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
    );
    await db.customStatement(
      "INSERT INTO settings VALUES ('lockEnabled', 'true', 0)",
    );
    await db.customStatement(
      "INSERT INTO settings VALUES ('biometricEnabled', 'true', 0)",
    );
    await s.setAccount(const AccountProfile(email: 'old@example.com'));
    await s.setLastKnownDriveBackup(at: 1792540800000, deviceId: 'old-phone');
    await s.setDeviceIdCopy('old-phone');
    return s;
  }

  Future<BootstrapResult> boot(ProviderContainer c) async {
    c.listen(bootstrapProvider, (_, _) {});
    final r = await c.read(bootstrapProvider.future);
    await pumpEventQueue();
    return r;
  }

  test('§16 after an Android restore with app lock on and no PIN: a new '
      'device ID, the lock off, the account cleared, no known backup, '
      '"Finish setting up", notifications rescheduled, Restore purchase, '
      'and no onboarding', () async {
    final c = container();
    addTearDown(c.dispose);
    final repo = await restoredDatabase(c);

    final r = await boot(c);
    expect((r as BootstrapReady).initialLocation, Routes.home);
    final s = await repo.load();
    expect(s.deviceId, isNot('old-phone'));
    expect(file.value, s.deviceId);
    expect(s.lockEnabled, isFalse);
    expect(s.biometricEnabled, isFalse);
    expect(s.backupAccountEmail, isNull);
    expect(s.lastKnownDriveBackupAt, isNull);
    expect(s.finishSetupPending, isTrue);
    expect(aftermaths, 1);
    expect(pro.ownershipQueries, greaterThan(0));
  });

  test(
    '§16 a Google session still on the phone is taken over silently',
    () async {
      auth.silentResult = const AccountProfile(
        email: 'me@example.com',
        displayName: 'Asha',
      );
      final c = container();
      addTearDown(c.dispose);
      final repo = await restoredDatabase(c);
      await boot(c);
      expect((await repo.load()).backupAccountEmail, 'me@example.com');
    },
  );

  test('§16 a readable PIN keeps the lock on (e.g. the file was replaced on '
      'the same phone)', () async {
    final c = container();
    addTearDown(c.dispose);
    final repo = await restoredDatabase(c);
    final record = await PinHasher(
      iterations: 1000,
      runner: (f) async => await f(),
    ).hash('1234');
    secure.values[SecureLockService.pinKey] = jsonEncode(record.toJson());
    final r = await boot(c);
    expect(
      (r as BootstrapReady).initialLocation,
      Routes.lockPath(from: Routes.home),
    );
    expect((await repo.load()).lockEnabled, isTrue);
  });

  test('§16 an update from before feature 010 (no file, no copy) does none '
      'of this', () async {
    final c = container();
    addTearDown(c.dispose);
    final repo = c.read(settingsRepositoryProvider);
    await db.customStatement(
      "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
    );
    await repo.setAccount(const AccountProfile(email: 'me@example.com'));
    await boot(c);
    final s = await repo.load();
    expect(s.deviceId, isNotNull);
    expect(file.value, s.deviceId);
    expect(s.backupAccountEmail, 'me@example.com');
    expect(s.finishSetupPending, isFalse);
    expect(aftermaths, 0);
  });

  test("§16 a Drive restore keeps this phone's device ID", () async {
    file.value = 'this-phone';
    final c = container();
    addTearDown(c.dispose);
    final repo = c.read(settingsRepositoryProvider);
    await db.customStatement(
      "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
    );
    // A Drive restore never writes deviceId (not restorable), so the copy
    // still matches the file.
    await repo.setDeviceIdCopy('this-phone');
    await boot(c);
    final s = await repo.load();
    expect(s.deviceId, 'this-phone');
    expect(s.finishSetupPending, isFalse);
    expect(aftermaths, 0);
  });
}
