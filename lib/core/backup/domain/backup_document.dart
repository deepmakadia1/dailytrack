import 'dart:convert';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_meta.dart';

/// The backup document (data-model §3): `backup.json`, or the whole `.json`
/// file. Pure Dart.
final class BackupDocument {
  const new({
    required this.schemaVersion,
    required this.appVersion,
    required this.createdAt,
    required this.modules,
    required this.settings,
    this.meta,
  });

  /// Reads and checks the header (research R7: version range is checked by
  /// the migrator). Throws [BackupDamaged] for bad JSON and [BackupInvalid]
  /// for a wrong header.
  factory decode(Uint8List bytes) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    } on FormatException catch (e) {
      throw BackupDamaged('json: ${e.message}');
    }
    if (json is! Map<String, Object?>) {
      throw const BackupInvalid('the backup is not an object');
    }
    return BackupDocument.fromJson(json);
  }

  factory fromJson(Map<String, Object?> json) {
    if (json['format'] != format) {
      throw const BackupInvalid('format is not dailytrack-backup');
    }
    final version = json['schemaVersion'];
    final createdAt = json['createdAt'];
    final appVersion = json['appVersion'];
    final modules = json['modules'];
    final settings = json['settings'];
    if (version is! int || version < 1) {
      throw const BackupInvalid('schemaVersion must be a positive integer');
    }
    if (createdAt is! int) {
      throw const BackupInvalid('createdAt must be an integer');
    }
    if (modules is! Map<String, Object?>) {
      throw const BackupInvalid('modules must be an object');
    }
    for (final MapEntry(:key, :value) in modules.entries) {
      if (value is! Map<String, Object?>) {
        throw BackupInvalid('module $key is not an object');
      }
    }
    if (settings != null && settings is! Map<String, Object?>) {
      throw const BackupInvalid('settings must be an object');
    }
    final settingsMap = <String, String>{};
    for (final MapEntry(:key, :value)
        in (settings as Map<String, Object?>? ?? const {}).entries) {
      if (value is! String) {
        throw BackupInvalid('setting $key must be a JSON string');
      }
      settingsMap[key] = value;
    }
    return BackupDocument(
      schemaVersion: version,
      appVersion: appVersion is String ? appVersion : '',
      createdAt: createdAt,
      modules: modules.cast<String, Map<String, Object?>>(),
      settings: settingsMap,
      // Files from before feature 010 have none (FR-043).
      meta: BackupMeta.fromJson(json['meta']),
    );
  }

  /// The required `format` value.
  static const String format = 'dailytrack-backup';

  /// The `AppDatabase.schemaVersion` that wrote it.
  final int schemaVersion;
  final String appVersion;

  /// UTC epoch milliseconds.
  final int createdAt;

  /// One section per module id.
  final Map<String, Map<String, Object?>> modules;

  /// Restorable settings: key → the JSON text stored in `settings.value`.
  final Map<String, String> settings;

  /// Who made it and what it holds (feature 010 data-model §4). The source
  /// of truth when it disagrees with the Drive listing.
  final BackupMeta? meta;

  BackupDocument copyWith({
    int? schemaVersion,
    Map<String, Map<String, Object?>>? modules,
  }) => BackupDocument(
    schemaVersion: schemaVersion ?? this.schemaVersion,
    appVersion: appVersion,
    createdAt: createdAt,
    modules: modules ?? this.modules,
    settings: settings,
    meta: meta,
  );

  BackupDocument withMeta(BackupMeta meta) => BackupDocument(
    schemaVersion: schemaVersion,
    appVersion: appVersion,
    createdAt: createdAt,
    modules: modules,
    settings: settings,
    meta: meta,
  );

  Map<String, Object?> toJson() => {
    'format': format,
    'meta': ?meta?.toJson(),
    'schemaVersion': schemaVersion,
    'appVersion': appVersion,
    'createdAt': createdAt,
    'modules': modules,
    'settings': settings,
  };

  Uint8List encode() => utf8.encode(jsonEncode(toJson()));
}
