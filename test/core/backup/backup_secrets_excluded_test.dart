import 'dart:convert';
import 'dart:io';

import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/settings/data/settings_repository_impl.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/mutable_clock.dart';
import 'backup_test_support.dart';

/// §16 criterion "Neither a Drive backup file nor Android Auto Backup data
/// contains the PIN hash, lockout state, or backup password", backup JSON
/// side (feature 010 T094, FR-047); test/android/backup_rules_test.dart
/// checks the Android rules. The PIN hash, lockout state, and backup
/// password live in secure storage, which the engine never reads; the
/// account and device keys are in `settings` but are not restorable.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;
  late Directory docs;

  const secrets = [
    'secret@example.com',
    'Secret Name',
    'device-secret-id',
    'pw-secret',
  ];

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    docs = await Directory.systemTemp.createTemp('secrets_docs');
    await seedRichData(db, docs);
    final settings = SettingsRepositoryImpl(
      db,
      knownModuleIds: const ['expense', 'habit'],
    );
    await settings.setAccount(
      const AccountProfile(
        email: 'secret@example.com',
        displayName: 'Secret Name',
      ),
    );
    await settings.setDeviceIdCopy('device-secret-id');
    await settings.setLockEnabled(enabled: true);
    await settings.setBiometricEnabled(enabled: true);
    await settings.setLastKnownDriveBackup(at: 1, deviceId: 'other');
  });
  tearDown(() async {
    await db.close();
    await docs.delete(recursive: true);
  });

  for (final (name, receipts, password) in [
    ('plain JSON', false, null),
    ('zip with receipts', true, null),
    ('encrypted, once decrypted', true, 'pw-secret'),
  ]) {
    test('§16 a $name backup holds no PIN, lock, password, or account '
        'state', () async {
      final engine = engineFor(db, MutableClock(DateTime(2026, 10, 26)), docs);
      final file = await engine.create(
        includeReceipts: receipts,
        password: password,
        device: const DeviceIdentity(id: 'meta-device', name: 'Pixel 7'),
      );
      final doc = (await engine.open(file.bytes, password: password)).document;
      final json = jsonEncode(doc.toJson());
      for (final secret in secrets) {
        expect(json, isNot(contains(secret)), reason: secret);
      }
      for (final key in doc.settings.keys) {
        expect(BackupSettingsPolicy.isRestorable(key), isTrue, reason: key);
      }
      for (final key in [
        'lockEnabled',
        'biometricEnabled',
        'backupAccountEmail',
        'accountDisplayName',
        'deviceId',
        'lastKnownDriveBackupAt',
        'dataChangeCounter',
      ]) {
        expect(doc.settings.containsKey(key), isFalse, reason: key);
      }
      if (password != null) {
        // The password never appears in the sealed bytes either.
        expect(
          latin1.decode(file.bytes, allowInvalid: true),
          isNot(contains('pw-secret')),
        );
      }
    });
  }
}
