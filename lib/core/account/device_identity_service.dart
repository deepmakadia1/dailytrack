import 'package:dailytrack/core/account/data/no_backup_device_id_store.dart';
import 'package:dailytrack/core/account/domain/device_identity.dart';
import 'package:dailytrack/core/settings/domain/settings_repository.dart';
import 'package:dailytrack/core/support/device_info_source.dart';

/// This install's device ID and the phone's name (feature 010 research R3,
/// R4). The ID lives in the no-backup file, with a copy in `settings`.
final class DeviceIdentityService {
  new({
    required this._file,
    required this._settings,
    required this._info,
    required this._newId,
  });

  final DeviceIdFile _file;
  final SettingsRepository _settings;
  final DeviceInfoSource _info;
  final String Function() _newId;

  String? _id;

  /// SYS-01, before routing: makes sure the file and the settings copy hold
  /// the same ID, and says where it came from (the research R4 table). The
  /// post-Android-restore steps (task T098) are not run yet. Where there is
  /// no no-backup folder, the settings copy alone keeps the ID. Never
  /// throws.
  Future<DeviceIdOrigin> ensure() async {
    try {
      final fileId = await _file.read();
      final settingsId = (await _settings.load()).deviceId;
      final origin = DeviceIdentityPolicy.resolve(
        fileId: fileId,
        settingsId: settingsId,
      );
      var id = fileId;
      if (id == null) {
        final fresh = _newId();
        try {
          await _file.write(fresh);
          id = fresh;
        } on Object {
          id = settingsId ?? fresh;
          if (id != settingsId) await _settings.setDeviceIdCopy(id);
          _id = id;
          return settingsId == null
              ? DeviceIdOrigin.created
              : DeviceIdOrigin.existing;
        }
      }
      if (id != settingsId) await _settings.setDeviceIdCopy(id);
      _id = id;
      return origin;
    } on Object {
      return DeviceIdOrigin.existing;
    }
  }

  /// The ID and the phone's current name, for backup metadata. Background
  /// isolates read the settings copy; [ensure] runs when there is none.
  Future<DeviceIdentity> current() async {
    var id = _id ?? (await _settings.load()).deviceId;
    if (id == null) {
      await ensure();
      id = _id ?? (await _settings.load()).deviceId ?? _newId();
    }
    final info = await _info.load();
    return DeviceIdentity(
      id: id,
      name: DeviceIdentityPolicy.displayName(info.manufacturer, info.model),
    );
  }
}
