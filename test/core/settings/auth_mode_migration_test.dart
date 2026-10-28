import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/data/backup_coordinator.dart';
import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// SYS-01 `authMode` migration (feature 011 T005, research R2), one test
/// per case, over a real in-memory database.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late SettingsRepositoryImpl repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
  });
  tearDown(() => db.close());

  Future<String?> rawAuthMode() async =>
      (await (db.select(db.settings)
                ..where((t) => t.key.equals(SettingsCodec.authMode)))
              .getSingleOrNull())
          ?.value;

  Future<void> putRaw(String key, String json) => db
      .into(db.settings)
      .insertOnConflictUpdate(
        SettingsCompanion.insert(key: key, value: json, updatedAt: 0),
      );

  Future<void> onboard() => repo.completeOnboarding(
    const OnboardingChoices(
      locale: 'en',
      currencyCode: 'INR',
      moduleOrder: ['expense', 'habit'],
      enabledModules: ['expense', 'habit'],
    ),
  );

  const account = AccountProfile(email: 'me@example.com');

  test(
    '1. a fresh install (no rows) gets none, written on the first start',
    () async {
      await repo.migrateAuthMode();
      expect(await rawAuthMode(), '"none"');
      expect((await repo.load()).authMode, AuthMode.none);
    },
  );

  test('2. onboarding not done, no email: none', () async {
    await repo.setLocale('gu');
    await repo.migrateAuthMode();
    expect((await repo.load()).authMode, AuthMode.none);
  });

  test('3. onboarding not done, email set: none (the start check clears the '
      'keys)', () async {
    await repo.setAccount(account);
    await repo.migrateAuthMode();
    expect((await repo.load()).authMode, AuthMode.none);
  });

  test('4. onboarding done, no email: guest', () async {
    await onboard();
    await repo.migrateAuthMode();
    expect((await repo.load()).authMode, AuthMode.guest);
  });

  test('5. onboarding done, email set: google', () async {
    await onboard();
    await repo.setAccount(account);
    await repo.migrateAuthMode();
    expect((await repo.load()).authMode, AuthMode.google);
  });

  group('6. an existing row is unchanged', () {
    for (final mode in AuthMode.values) {
      test(mode.name, () async {
        await onboard();
        await repo.setAccount(account);
        await repo.setAuthMode(mode);
        await repo.migrateAuthMode();
        expect((await repo.load()).authMode, mode);
        expect(await rawAuthMode(), '"${mode.name}"');
      });
    }
  });

  test('7. a corrupt value is kept, decodes to none, and is not migrated '
      'again', () async {
    await onboard();
    await putRaw(SettingsCodec.authMode, '"x"');
    await repo.migrateAuthMode();
    expect(await rawAuthMode(), '"x"');
    expect((await repo.load()).authMode, AuthMode.none);
  });

  test('8. a second call writes nothing', () async {
    await onboard();
    await repo.migrateAuthMode();
    final before = await (db.select(
      db.settings,
    )..where((t) => t.key.equals(SettingsCodec.authMode))).getSingle();
    // Even after the inputs change, the stored mode stays.
    await repo.setAccount(account);
    await repo.migrateAuthMode();
    final after = await (db.select(
      db.settings,
    )..where((t) => t.key.equals(SettingsCodec.authMode))).getSingle();
    expect(after, before);
    expect((await repo.load()).authMode, AuthMode.guest);
  });

  test('9. authMode is never in a backup and never written by a restore', () {
    expect(BackupSettingsPolicy.isRestorable(SettingsCodec.authMode), isFalse);
    expect(
      BackupSettingsPolicy.exportable({
        SettingsCodec.authMode: '"google"',
        SettingsCodec.locale: '"gu"',
      }),
      {SettingsCodec.locale: '"gu"'},
    );
  });

  group('codec (T004)', () {
    AuthMode decode(Map<String, String> rows) =>
        SettingsCodec.decode(rows, knownModuleIds: const ['expense']).authMode;

    test('decodes none, guest, and google', () {
      for (final mode in AuthMode.values) {
        expect(decode({SettingsCodec.authMode: '"${mode.name}"'}), mode);
      }
    });

    test('backupLeaseUntil decodes an int (UTC ms) and null otherwise; it is '
        'the coordinator lease row and never restorable', () {
      AppSettings read(Map<String, String> rows) =>
          SettingsCodec.decode(rows, knownModuleIds: const ['expense']);
      expect(
        read({SettingsCodec.backupLeaseUntil: '1792540800000'})
            .backupLeaseUntil,
        1792540800000,
      );
      expect(read({}).backupLeaseUntil, isNull);
      expect(
        read({SettingsCodec.backupLeaseUntil: '"x"'}).backupLeaseUntil,
        isNull,
      );
      expect(SettingsCodec.backupLeaseUntil, BackupCoordinator.leaseKey);
      expect(
        BackupSettingsPolicy.isRestorable(SettingsCodec.backupLeaseUntil),
        isFalse,
      );
    });

    test('a missing or unknown value decodes to none', () {
      expect(decode({}), AuthMode.none);
      expect(decode({SettingsCodec.authMode: '"x"'}), AuthMode.none);
      expect(decode({SettingsCodec.authMode: '1'}), AuthMode.none);
      expect(decode({SettingsCodec.authMode: 'not json'}), AuthMode.none);
    });
  });
}
