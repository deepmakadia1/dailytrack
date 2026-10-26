import 'dart:io';

import 'package:flutter/services.dart';

/// The `device_id` file in Android's no-backup folder, which Android never
/// backs up or transfers (feature 010 research R4, FR-044).
abstract interface class DeviceIdFile {
  /// The stored ID, or null when there is none or it can't be read. Never
  /// throws.
  Future<String?> read();

  /// Throws when the folder is unavailable or the write fails.
  Future<void> write(String id);
}

/// [DeviceIdFile] at `<noBackupFilesDir>/device_id`, the folder read from
/// `getNoBackupDir` on `MainActivity`'s `dailytrack/window` channel.
// Platform channel and file system: covered by the device check
// (quickstart §4); services are tested with `FakeDeviceIdFile`.
// coverage:ignore-start
final class ChannelDeviceIdFile implements DeviceIdFile {
  const new();

  static const MethodChannel _channel = MethodChannel('dailytrack/window');
  static const String fileName = 'device_id';

  Future<File?> _file() async {
    final dir = await _channel.invokeMethod<String>('getNoBackupDir');
    return dir == null || dir.isEmpty ? null : File('$dir/$fileName');
  }

  @override
  Future<String?> read() async {
    try {
      final file = await _file();
      if (file == null || !file.existsSync()) return null;
      final id = (await file.readAsString()).trim();
      return id.isEmpty ? null : id;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String id) async {
    final file = await _file();
    if (file == null) {
      throw const FileSystemException('No no-backup folder on this platform');
    }
    await file.writeAsString(id, flush: true);
  }
}

// coverage:ignore-end
