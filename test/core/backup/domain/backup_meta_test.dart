import 'dart:convert';

import 'package:dailytrack/core/backup/domain/backup_meta.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:flutter_test/flutter_test.dart';

/// Backup metadata in the file's `meta` and in Drive `appProperties`
/// (feature 010 T028, data-model §4, research R8, FR-041, FR-043). Pure.
void main() {
  BackupMeta meta({
    String deviceName = 'Xiaomi Redmi Note 12',
    Map<String, int> counts = const {
      'expense.transactions': 1240,
      'expense.accounts': 3,
      'habit.habits': 8,
    },
    BackupKind kind = BackupKind.auto,
    bool encrypted = true,
  }) => BackupMeta(
    deviceId: '6f1c2c8e-1d7a-4c39-9a8d-4b0f0c1e2d3a',
    deviceName: deviceName,
    appVersion: '1.4.0+23',
    createdAt: 1792540800000,
    kind: kind,
    counts: counts,
    schemaVersion: 5,
    encrypted: encrypted,
  );

  int bytes(String s) => utf8.encode(s).length;

  void expectSame(BackupMeta? actual, BackupMeta expected) {
    expect(actual, isNotNull);
    expect(actual!.toJson(), expected.toJson());
  }

  group('§16 Drive appProperties', () {
    test('round trip keeps every field', () {
      final m = meta();
      expectSame(
        BackupMetaCodec.fromProperties(BackupMetaCodec.toProperties(m)),
        m,
      );
      final manual = meta(kind: BackupKind.manual, encrypted: false);
      expectSame(
        BackupMetaCodec.fromProperties(BackupMetaCodec.toProperties(manual)),
        manual,
      );
    });

    test('keeps the feature 008 keys, so older app versions still list the '
        'file', () {
      final props = BackupMetaCodec.toProperties(meta());
      expect(props['app'], 'dailytrack');
      expect(props['kind'], 'auto');
      expect(props['schemaVersion'], '5');
      expect(props['device'], 'Xiaomi Redmi Note 12');
      expect(props['encrypted'], '1');
      expect(props['c.expense.transactions'], '1240');
    });

    test('a 200-character device name is cut so key + value fit in 124 '
        'bytes', () {
      final props = BackupMetaCodec.toProperties(meta(deviceName: 'X' * 200));
      final device = props[BackupMetaCodec.deviceKey]!;
      expect(device, isNotEmpty);
      expect(
        bytes(BackupMetaCodec.deviceKey) + bytes(device),
        lessThanOrEqualTo(BackupMetaCodec.maxEntryBytes),
      );
    });

    test('a Gujarati device name is measured in UTF-8 bytes, not characters, '
        'and never cut inside a character', () {
      final name = 'ગુજરાતી ફોન ' * 10;
      final device = BackupMetaCodec.toProperties(
        meta(deviceName: name),
      )[BackupMetaCodec.deviceKey]!;
      expect(
        bytes(BackupMetaCodec.deviceKey) + bytes(device),
        lessThanOrEqualTo(BackupMetaCodec.maxEntryBytes),
      );
      expect(device.length, lessThan(BackupMetaCodec.maxEntryBytes));
      expect(name.startsWith(device), isTrue);
    });

    test('never writes more than 30 entries; extra counts are left out', () {
      final props = BackupMetaCodec.toProperties(
        meta(counts: {for (var i = 0; i < 40; i++) 'demo.kind$i': i}),
      );
      expect(props, hasLength(BackupMetaCodec.maxEntries));
      for (final MapEntry(:key, :value) in props.entries) {
        expect(
          bytes(key) + bytes(value),
          lessThanOrEqualTo(BackupMetaCodec.maxEntryBytes),
        );
      }
    });

    test('FR-043 a backup made before this feature (no deviceId or '
        'createdAt) has no metadata', () {
      expect(
        BackupMetaCodec.fromProperties({
          'app': 'dailytrack',
          'kind': 'auto',
          'device': 'Pixel',
        }),
        isNull,
      );
      final props = BackupMetaCodec.toProperties(meta())..remove('createdAt');
      expect(BackupMetaCodec.fromProperties(props), isNull);
    });

    test('ignores unreadable counts instead of failing', () {
      final props = BackupMetaCodec.toProperties(meta())
        ..['c.expense.budgets'] = 'many'
        ..['c.habit.entries'] = '-1';
      final read = BackupMetaCodec.fromProperties(props)!;
      expect(read.counts.containsKey('expense.budgets'), isFalse);
      expect(read.counts.containsKey('habit.entries'), isFalse);
      expect(read.counts['habit.habits'], 8);
    });
  });

  group("§16 the file's meta object", () {
    test('round trip through JSON keeps every field', () {
      final m = meta();
      expectSame(BackupMeta.fromJson(jsonDecode(jsonEncode(m.toJson()))), m);
    });

    test('FR-043 a missing or damaged meta reads as none, never as an '
        'error', () {
      expect(BackupMeta.fromJson(null), isNull);
      expect(BackupMeta.fromJson('meta'), isNull);
      expect(BackupMeta.fromJson(<String, Object?>{'deviceId': 'x'}), isNull);
      expect(
        BackupMeta.fromJson(<String, Object?>{'deviceId': '', 'createdAt': 1}),
        isNull,
      );
    });

    test('totalCount adds up the counts; zero means no user rows', () {
      expect(meta().totalCount, 1251);
      expect(meta(counts: const {}).totalCount, 0);
    });
  });
}
