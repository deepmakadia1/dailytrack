import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

/// Backup settings keys (feature 008 T006, data-model §1): defaults when
/// missing, fallbacks when invalid, and values when valid.
void main() {
  AppSettings decode(Map<String, String> rows) =>
      SettingsCodec.decode(rows, knownModuleIds: const ['expense', 'habit']);

  test('defaults when missing', () {
    final s = decode(const {});
    expect(s.lastBackupLocation, isNull);
    expect(s.lastBackupSizeBytes, isNull);
    expect(s.backupEncrypt, isFalse);
    expect(s.backupIncludeReceipts, isFalse);
    expect(s.backupAccountEmail, isNull);
    expect(s.autoBackupFrequency, AutoBackupFrequency.off);
    expect(s.autoBackupWifiOnly, isTrue);
    expect(s.lastAutoBackupAt, isNull);
    expect(s.autoBackupFailures, 0);
    expect(s.autoBackupFailureNotified, isFalse);
  });

  test('valid values decode', () {
    final s = decode(const {
      'lastBackupLocation': '"drive"',
      'lastBackupSizeBytes': '2048',
      'backupEncrypt': 'true',
      'backupIncludeReceipts': 'true',
      'backupAccountEmail': '"me@example.com"',
      'autoBackupFrequency': '"weekly"',
      'autoBackupWifiOnly': 'false',
      'lastAutoBackupAt': '17',
      'autoBackupFailures': '3',
      'autoBackupFailureNotified': 'true',
    });
    expect(s.lastBackupLocation, BackupLocation.drive);
    expect(s.lastBackupSizeBytes, 2048);
    expect(s.backupEncrypt, isTrue);
    expect(s.backupIncludeReceipts, isTrue);
    expect(s.backupAccountEmail, 'me@example.com');
    expect(s.autoBackupFrequency, AutoBackupFrequency.weekly);
    expect(s.autoBackupWifiOnly, isFalse);
    expect(s.lastAutoBackupAt, 17);
    expect(s.autoBackupFailures, 3);
    expect(s.autoBackupFailureNotified, isTrue);
  });

  test('invalid values fall back to defaults', () {
    final s = decode(const {
      'lastBackupLocation': '"cloud"',
      'lastBackupSizeBytes': '-1',
      'backupEncrypt': '"yes"',
      'backupAccountEmail': '""',
      'autoBackupFrequency': '"hourly"',
      'autoBackupFailures': '-2',
      'lastAutoBackupAt': '{',
    });
    expect(s.lastBackupLocation, isNull);
    expect(s.lastBackupSizeBytes, isNull);
    expect(s.backupEncrypt, isFalse);
    expect(s.backupAccountEmail, isNull);
    expect(s.autoBackupFrequency, AutoBackupFrequency.off);
    expect(s.autoBackupFailures, 0);
    expect(s.lastAutoBackupAt, isNull);
  });
}
