import 'dart:convert';

import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';

/// What a backup says about itself (feature 010 data-model §4, research
/// R8): stored in the file's `meta` object and in the Drive file's
/// `appProperties`, so backups can be listed and compared without a
/// download. Pure Dart.
final class BackupMeta {
  const new({
    required this.deviceId,
    required this.deviceName,
    required this.appVersion,
    required this.createdAt,
    required this.kind,
    required this.counts,
    required this.schemaVersion,
    required this.encrypted,
  });

  /// Null when [json] is not a usable `meta` object (a damaged or foreign
  /// `meta` never makes a backup unreadable, FR-043).
  static BackupMeta? fromJson(Object? json) {
    if (json is! Map<String, Object?>) return null;
    final deviceId = json['deviceId'];
    final createdAt = json['createdAt'];
    if (deviceId is! String || deviceId.isEmpty || createdAt is! int) {
      return null;
    }
    final counts = json['counts'];
    final deviceName = json['deviceName'];
    final appVersion = json['appVersion'];
    final schemaVersion = json['schemaVersion'];
    return BackupMeta(
      deviceId: deviceId,
      deviceName: deviceName is String ? deviceName : '',
      appVersion: appVersion is String ? appVersion : '',
      createdAt: createdAt,
      kind: json['kind'] == BackupKind.auto.name
          ? BackupKind.auto
          : BackupKind.manual,
      counts: {
        if (counts is Map<String, Object?>)
          for (final MapEntry(:key, :value) in counts.entries)
            if (value is int && value >= 0) key: value,
      },
      schemaVersion: schemaVersion is int ? schemaVersion : 0,
      encrypted: json['encrypted'] == true,
    );
  }

  final String deviceId;
  final String deviceName;

  /// "1.4.0+23".
  final String appVersion;

  /// UTC epoch milliseconds, the document's `createdAt`.
  final int createdAt;
  final BackupKind kind;

  /// `"<moduleId>.<kind>"` → non-deleted rows, e.g.
  /// `"expense.transactions": 1240`.
  final Map<String, int> counts;
  final int schemaVersion;
  final bool encrypted;

  /// Sum of [counts]: zero means the backup holds no user rows.
  int get totalCount => counts.values.fold(0, (sum, c) => sum + c);

  Map<String, Object?> toJson() => {
    'deviceId': deviceId,
    'deviceName': deviceName,
    'appVersion': appVersion,
    'createdAt': createdAt,
    'kind': kind.name,
    'counts': counts,
    'schemaVersion': schemaVersion,
    'encrypted': encrypted,
  };
}

/// [BackupMeta] as Drive `appProperties` (research R8). Drive allows 30
/// entries per app, each key plus value at most 124 bytes of UTF-8.
abstract final class BackupMetaCodec {
  static const int maxEntries = 30;
  static const int maxEntryBytes = 124;

  static const String appKey = 'app';
  static const String appValue = 'dailytrack';
  static const String kindKey = 'kind';
  static const String schemaVersionKey = 'schemaVersion';
  static const String deviceKey = 'device';
  static const String deviceIdKey = 'deviceId';
  static const String appVersionKey = 'appVersion';
  static const String createdAtKey = 'createdAt';
  static const String encryptedKey = 'encrypted';
  static const String countPrefix = 'c.';

  static int _bytes(String s) => utf8.encode(s).length;

  /// [value] cut by whole characters so `key + value` fits.
  static String _fit(String key, String value) {
    final room = maxEntryBytes - _bytes(key);
    if (_bytes(value) <= room) return value;
    final out = StringBuffer();
    var used = 0;
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      final size = _bytes(char);
      if (used + size > room) break;
      out.write(char);
      used += size;
    }
    return out.toString().trim();
  }

  /// The fixed entries first, then one `c.<moduleId>.<kind>` per count
  /// while there is room. An entry that can't fit is left out; only the
  /// device name is shortened.
  static Map<String, String> toProperties(BackupMeta m) {
    final props = <String, String>{
      appKey: appValue,
      kindKey: m.kind.name,
      schemaVersionKey: '${m.schemaVersion}',
      deviceIdKey: m.deviceId,
      createdAtKey: '${m.createdAt}',
      encryptedKey: m.encrypted ? '1' : '0',
      appVersionKey: m.appVersion,
      deviceKey: _fit(deviceKey, m.deviceName),
    }..removeWhere((k, v) => _bytes(k) + _bytes(v) > maxEntryBytes);
    final keys = m.counts.keys.toList()..sort();
    for (final key in keys) {
      if (props.length >= maxEntries) break;
      final name = '$countPrefix$key';
      final value = '${m.counts[key]}';
      if (_bytes(name) + _bytes(value) <= maxEntryBytes) props[name] = value;
    }
    return props;
  }

  /// Null for backups made before feature 010 (no `deviceId` or
  /// `createdAt`), which never trigger the conflict warning (FR-043).
  static BackupMeta? fromProperties(Map<String, String?> p) {
    final deviceId = p[deviceIdKey];
    final createdAt = int.tryParse(p[createdAtKey] ?? '');
    if (deviceId == null || deviceId.isEmpty || createdAt == null) {
      return null;
    }
    return BackupMeta(
      deviceId: deviceId,
      deviceName: p[deviceKey] ?? '',
      appVersion: p[appVersionKey] ?? '',
      createdAt: createdAt,
      kind: p[kindKey] == BackupKind.auto.name
          ? BackupKind.auto
          : BackupKind.manual,
      counts: {
        for (final MapEntry(:key, :value) in p.entries)
          if (key.startsWith(countPrefix))
            if (int.tryParse(value ?? '') case final n? when n >= 0)
              key.substring(countPrefix.length): n,
      },
      schemaVersion: int.tryParse(p[schemaVersionKey] ?? '') ?? 0,
      encrypted: p[encryptedKey] == '1',
    );
  }
}
