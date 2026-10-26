import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Android Auto Backup and device transfer (spec §16, feature 010 T093,
/// research R14, contracts/android.md): the database only, never secure
/// storage. §16 criterion "Neither a Drive backup file nor Android Auto
/// Backup data contains the PIN hash, lockout state, or backup password",
/// rules side; test/core/backup/backup_secrets_excluded_test.dart checks the
/// backup JSON.
void main() {
  const res = 'android/app/src/main/res/xml';
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();
  final legacy = File('$res/backup_rules.xml').readAsStringSync();
  final modern = File('$res/data_extraction_rules.xml').readAsStringSync();

  const database = [
    'app_flutter/dailytrack.sqlite',
    'app_flutter/dailytrack.sqlite-wal',
    'app_flutter/dailytrack.sqlite-shm',
  ];

  /// The `domain:path` of every `<tag .../>` in [xml].
  List<String> entries(String xml, String tag) {
    String attribute(String attributes, String name) =>
        RegExp('$name="([^"]*)"').firstMatch(attributes)![1]!;
    return [
      for (final m in RegExp(
        '<$tag'
        r'\s+([^>]*)/>',
      ).allMatches(xml))
        '${attribute(m[1]!, 'domain')}:${attribute(m[1]!, 'path')}',
    ];
  }

  /// The body of `<tag>...</tag>` in [xml].
  String section(String xml, String tag) =>
      RegExp('<$tag>(.*?)</$tag>', dotAll: true).firstMatch(xml)![1]!;

  void expectDatabaseOnly(String rules, {required String reason}) {
    expect(entries(rules, 'include'), [
      for (final p in database) 'root:$p',
    ], reason: '$reason: only the database is included');
    expect(entries(rules, 'exclude'), [
      'sharedpref:FlutterSecureStorage.xml',
    ], reason: '$reason: secure storage is excluded');
  }

  test('§16 Android 11 and lower back up only the database, never secure '
      'storage', () {
    expectDatabaseOnly(
      section(legacy, 'full-backup-content'),
      reason: 'backup_rules',
    );
  });

  test('§16 Android 12+ cloud backup and device transfer back up only the '
      'database, never secure storage', () {
    expectDatabaseOnly(section(modern, 'cloud-backup'), reason: 'cloud-backup');
    expectDatabaseOnly(
      section(modern, 'device-transfer'),
      reason: 'device-transfer',
    );
  });

  test('§16 receipts, the safety copy, the no-backup folder, and caches '
      'are not included', () {
    for (final rules in [legacy, modern]) {
      for (final path in [
        'receipts',
        'restore_safety',
        'no_backup',
        'device_id',
        'cache',
        'androidx.work',
      ]) {
        expect(
          entries(rules, 'include').where((e) => e.contains(path)),
          isEmpty,
          reason: path,
        );
      }
    }
  });

  test('§16 the manifest turns backup on with both rules files', () {
    expect(manifest, contains('android:allowBackup="true"'));
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'));
    expect(
      manifest,
      contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
    );
  });
}
