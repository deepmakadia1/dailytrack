import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';

/// [SafetyCopyStore] in `<app support>/restore_safety/`: the backup file
/// plus `safety.json` (data-model §5). The folder is outside the Android
/// backup rules (FR-045).
final class FileSafetyCopyStore implements SafetyCopyStore {
  new(this._root);

  /// The app support folder; tests pass a temporary one.
  final Future<Directory> Function() _root;

  static const String folder = 'restore_safety';
  static const String sidecar = 'safety.json';

  Future<Directory> _dir() async =>
      Directory('${(await _root()).path}/$folder');

  @override
  Future<void> save(
    BackupFile file, {
    required Map<String, int> counts,
    required int createdAt,
  }) async {
    final dir = await _dir();
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
      await dir.create(recursive: true);
      await File('${dir.path}/${file.fileName}')
          .writeAsBytes(file.bytes, flush: true);
      // The sidecar last: a copy without it doesn't count.
      await File('${dir.path}/$sidecar').writeAsString(
        jsonEncode({
          'createdAt': createdAt,
          'counts': counts,
          'fileName': file.fileName,
        }),
        flush: true,
      );
    } on FileSystemException {
      await _deleteQuietly(dir);
      throw const BackupStorageFull();
    }
  }

  @override
  Future<SafetyCopyInfo?> info() async {
    try {
      final json = jsonDecode(
        await File('${(await _dir()).path}/$sidecar').readAsString(),
      );
      if (json is! Map<String, Object?>) return null;
      final createdAt = json['createdAt'];
      final fileName = json['fileName'];
      final counts = json['counts'];
      if (createdAt is! int || fileName is! String) return null;
      return SafetyCopyInfo(
        createdAt: createdAt,
        fileName: fileName,
        counts: {
          if (counts is Map<String, Object?>)
            for (final MapEntry(:key, :value) in counts.entries)
              if (value is int) key: value,
        },
      );
    } on Object {
      return null;
    }
  }

  @override
  Future<Uint8List?> read() async {
    final copy = await info();
    if (copy == null) return null;
    try {
      return await File('${(await _dir()).path}/${copy.fileName}')
          .readAsBytes();
    } on FileSystemException {
      return null;
    }
  }

  @override
  Future<void> delete() async {
    await _deleteQuietly(await _dir());
  }

  static Future<void> _deleteQuietly(Directory dir) async {
    try {
      if (dir.existsSync()) await dir.delete(recursive: true);
    } on FileSystemException {
      // Tried again at the next start (expiry check).
    }
  }
}
