import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_archive.dart';
import 'package:dailytrack/core/backup/domain/backup_document.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/backup_migrator.dart';
import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// A section that renames a field between v4 and v5 (synthetic step).
final class _RenamingSection implements SectionUpgrader {
  const new();

  @override
  String get moduleId => 'demo';

  @override
  int get sinceSchemaVersion => 2;

  @override
  Map<String, Object?> upgrade(
    Map<String, Object?> section, {
    required int from,
  }) => from < 5 ? {'renamed': section['old']} : section;
}

/// Pure backup domain (feature 008 T023–T026, research R2, R6, R7).
void main() {
  group('detectForm and the zip container (research R2)', () {
    test('recognizes each form by its first bytes', () {
      expect(detectForm(utf8.encode('  {"a":1}')), ContainerForm.plain);
      expect(
        detectForm(Uint8List.fromList([0xEF, 0xBB, 0xBF, 0x7B])),
        ContainerForm.plain,
      );
      expect(
        detectForm(packZip(utf8.encode('{}'), const {})),
        ContainerForm.zip,
      );
      expect(detectForm(utf8.encode('DTBK....')), ContainerForm.encrypted);
      expect(detectForm(utf8.encode('hello')), ContainerForm.unknown);
      expect(detectForm(Uint8List(0)), ContainerForm.unknown);
    });

    test('packZip and unpackZip round trip the document and receipts', () {
      final json = utf8.encode('{"x":1}');
      final receipt = Uint8List.fromList([1, 2, 3]);
      final (doc, files) = unpackZip(
        packZip(json, {'receipts/a.jpg': receipt}),
      );
      expect(doc, json);
      expect(files, {'receipts/a.jpg': receipt});
    });

    test('a truncated zip is damaged; a zip without backup.json too', () {
      final zip = packZip(utf8.encode('{}'), const {});
      expect(
        () => unpackZip(Uint8List.sublistView(zip, 0, zip.length - 10)),
        throwsA(isA<BackupDamaged>()),
      );
      expect(() => unpackZip(packZipWithout()), throwsA(isA<BackupDamaged>()));
    });

    test('attachment paths cannot escape the receipts folder', () {
      expect(isSafeAttachmentPath('receipts/a1.jpg'), isTrue);
      expect(isSafeAttachmentPath('receipts/../db.sqlite'), isFalse);
      expect(isSafeAttachmentPath('../receipts/a.jpg'), isFalse);
      expect(isSafeAttachmentPath('other/a.jpg'), isFalse);
      expect(isSafeAttachmentPath('receipts/sub/a.jpg'), isFalse);
    });
  });

  group('BackupDocument header (data-model §3)', () {
    Map<String, Object?> header() => {
      'format': 'dailytrack-backup',
      'schemaVersion': 4,
      'appVersion': '1.0.0',
      'createdAt': 5,
      'modules': <String, Object?>{},
    };

    test('round trips; missing settings read as empty', () {
      final doc = BackupDocument.fromJson(header());
      expect(doc.settings, isEmpty);
      expect(BackupDocument.decode(doc.encode()).toJson(), doc.toJson());
    });

    test('rejects a wrong format, version, time, or modules', () {
      for (final bad in [
        {...header(), 'format': 'other'},
        {...header(), 'schemaVersion': '4'},
        {...header(), 'schemaVersion': 0},
        {...header(), 'createdAt': null},
        {...header(), 'modules': <Object?>[]},
        {
          ...header(),
          'modules': {'expense': 1},
        },
        {
          ...header(),
          'settings': {'locale': 1},
        },
      ]) {
        expect(
          () => BackupDocument.fromJson(bad),
          throwsA(isA<BackupInvalid>()),
          reason: '$bad',
        );
      }
    });

    test('FR-043 a file from before feature 010 has no meta and still '
        'decodes; writing it back adds none', () {
      final doc = BackupDocument.decode(
        BackupDocument.fromJson(header()).encode(),
      );
      expect(doc.meta, isNull);
      expect(doc.toJson().containsKey('meta'), isFalse);
    });

    test('§16 meta is written next to format, read back, and kept by '
        'copyWith (schema upgrades)', () {
      const meta = BackupMeta(
        deviceId: 'dev-1',
        deviceName: 'Google Pixel 7',
        appVersion: '1.4.0+23',
        createdAt: 5,
        kind: BackupKind.auto,
        counts: {'expense.transactions': 2},
        schemaVersion: 4,
        encrypted: false,
      );
      final doc = BackupDocument.fromJson(header()).withMeta(meta);
      final json = doc.toJson();
      expect(json.keys.take(2), ['format', 'meta']);

      final read = BackupDocument.decode(doc.encode());
      expect(read.meta?.toJson(), meta.toJson());
      expect(read.copyWith(schemaVersion: 5).meta?.toJson(), meta.toJson());
    });

    test('FR-043 a damaged meta object never makes the file unreadable', () {
      final doc = BackupDocument.fromJson({...header(), 'meta': 'oops'});
      expect(doc.meta, isNull);
      expect(doc.schemaVersion, 4);
    });

    test('bad JSON is damaged, a JSON list is invalid', () {
      expect(
        () => BackupDocument.decode(utf8.encode('{"format":')),
        throwsA(isA<BackupDamaged>()),
      );
      expect(
        () => BackupDocument.decode(utf8.encode('[1]')),
        throwsA(isA<BackupInvalid>()),
      );
    });
  });

  group('BackupMigrator (research R7)', () {
    BackupDocument doc(int version, Map<String, Map<String, Object?>> m) =>
        BackupDocument(
          schemaVersion: version,
          appVersion: '',
          createdAt: 0,
          modules: m,
          settings: const {},
        );

    test('a current document is unchanged', () {
      final result = const BackupMigrator([_RenamingSection()], current: 5)
          .upgrade(
            doc(5, {
              'demo': {'renamed': 1},
            }),
          );
      expect(result.document.modules['demo'], {'renamed': 1});
      expect(result.skippedModuleIds, isEmpty);
    });

    test('an older document runs each section upgrade step to current', () {
      final result = const BackupMigrator([_RenamingSection()], current: 5)
          .upgrade(
            doc(4, {
              'demo': {'old': 7},
            }),
          );
      expect(result.document.schemaVersion, 5);
      expect(result.document.modules['demo'], {'renamed': 7});
    });

    test('a missing section becomes empty; unknown modules are skipped', () {
      final result = const BackupMigrator([
        _RenamingSection(),
      ], current: 5).upgrade(doc(3, {'water': {}}));
      expect(result.document.modules['demo'], {'tables': <String, Object?>{}});
      expect(result.skippedModuleIds, ['water']);
    });

    test('newer is BackupTooNew; below the minimum is invalid', () {
      const migrator = BackupMigrator([], current: 4);
      expect(
        () => migrator.upgrade(doc(99, const {})),
        throwsA(isA<BackupTooNew>()),
      );
      expect(
        () => migrator.upgrade(doc(minRestorableSchema - 1, const {})),
        throwsA(isA<BackupInvalid>()),
      );
    });
  });

  group('BackupSettingsPolicy (research R6, FR-009)', () {
    test('only user preferences and module state travel', () {
      for (final key in [
        'locale',
        'currencyCode',
        'firstDayOfWeek',
        'dateFormat',
        'themeMode',
        'selectedTheme',
        'fontSize',
        'enabledModules',
        'moduleOrder',
        'notificationsEnabled',
        'budgetAlertsEnabled',
        'habitRemindersEnabled',
        'dailySummaryTime',
        'homeComingSoonDismissed',
        'module.expense.x',
      ]) {
        expect(BackupSettingsPolicy.isRestorable(key), isTrue, reason: key);
      }
      for (final key in [
        'lockEnabled',
        'biometricEnabled',
        'lockAfterSeconds',
        'hideInRecents',
        'onboardingDone',
        'adConsentStatus',
        'removeAdsPurchased',
        'latestSeenAt',
        'debugUnlockAll',
        'dailyInsightDate',
        'dailyInsightId',
        'lastBackupAt',
        'lastBackupLocation',
        'lastBackupSizeBytes',
        'backupEncrypt',
        'backupIncludeReceipts',
        'backupLeaseUntil',
        'seed.expense.defaults',
      ]) {
        expect(BackupSettingsPolicy.isRestorable(key), isFalse, reason: key);
      }
    });

    test('exportable keeps only restorable keys', () {
      expect(
        BackupSettingsPolicy.exportable({
          'locale': '"gu"',
          'lockEnabled': 'true',
          'module.habit.x': '"1"',
        }),
        {'locale': '"gu"', 'module.habit.x': '"1"'},
      );
    });
  });
}

/// A zip with an entry, but no `backup.json`.
Uint8List packZipWithout() {
  final zip = packZip(utf8.encode('{}'), {
    'receipts/a.jpg': Uint8List.fromList([1]),
  });
  // Rename the document entry in place: same length, now a receipt.
  final s = latin1.decode(zip).replaceAll('backup.json', 'receipts/ab');
  return latin1.encode(s);
}
