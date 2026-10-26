/// This install's ID and the phone's name at backup time (feature 010
/// data-model §3). Pure Dart.
final class DeviceIdentity {
  const new({required this.id, required this.name});

  /// UUID v4, kept in Android's no-backup folder (research R4).
  final String id;

  /// "Manufacturer model", or "Android phone" when unknown.
  final String name;
}

/// Where this start's device ID came from (research R4).
enum DeviceIdOrigin { existing, created, restoredFromAndroidBackup }

/// The research R4 table. Pure.
abstract final class DeviceIdentityPolicy {
  /// Longest device name kept (Drive `appProperties` limit).
  static const int maxNameLength = 60;

  /// Shown when the phone reports neither manufacturer nor model.
  static const String fallbackName = 'Android phone';

  /// [fileId] is the no-backup file; [settingsId] is the copy in the
  /// database, which travels with an Android restore while the file does
  /// not.
  static DeviceIdOrigin resolve({
    required String? fileId,
    required String? settingsId,
  }) {
    if (fileId != null) {
      return fileId == settingsId
          ? DeviceIdOrigin.existing
          : DeviceIdOrigin.restoredFromAndroidBackup;
    }
    return settingsId == null
        ? DeviceIdOrigin.created
        : DeviceIdOrigin.restoredFromAndroidBackup;
  }

  /// "Manufacturer model", with the manufacturer dropped when the model
  /// already starts with it ("Google Pixel 7", not "Google Google Pixel 7").
  static String displayName(String manufacturer, String model) {
    final maker = manufacturer.trim();
    final name = model.trim();
    final repeats = name.toLowerCase().startsWith(maker.toLowerCase());
    final full = maker.isEmpty || repeats ? name : '$maker $name'.trim();
    if (full.isEmpty) return fallbackName;
    final runes = full.runes.toList();
    return runes.length <= maxNameLength
        ? full
        : String.fromCharCodes(runes.take(maxNameLength)).trim();
  }
}
