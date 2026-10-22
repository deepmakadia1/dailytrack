/// Why a backup or restore failed (SET-02, feature 008 contracts/services.md).
/// Each case maps to one plain-language message in
/// `core/backup/presentation/backup_failure_text.dart` (§15.6).
/// Pure Dart (Constitution II).
sealed class BackupFailure implements Exception {
  const new();
}

/// The file starts with none of the known forms (research R2).
final class BackupNotRecognized extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupNotRecognized';
}

/// A known form, but the zip, JSON, or envelope is truncated or corrupt.
final class BackupDamaged extends BackupFailure {
  const new([this.detail]);

  final String? detail;

  @override
  String toString() => 'BackupDamaged($detail)';
}

/// Readable, but a header field or a row breaks a rule (data-model §3).
final class BackupInvalid extends BackupFailure {
  const new(this.detail);

  final String detail;

  @override
  String toString() => 'BackupInvalid($detail)';
}

/// Written by a newer app (research R7).
final class BackupTooNew extends BackupFailure {
  const new(this.schemaVersion);

  final int schemaVersion;

  @override
  String toString() => 'BackupTooNew($schemaVersion)';
}

/// The envelope did not authenticate: a wrong password or a tampered file;
/// AES-GCM cannot tell them apart (research R3).
final class BackupWrongPassword extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupWrongPassword';
}

/// Encryption is on, but no password is available (research R4). Never
/// leads to a plain backup.
final class BackupNeedsPassword extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupNeedsPassword';
}

/// Over the in-memory encryption limit (research R3).
final class BackupTooLargeToEncrypt extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupTooLargeToEncrypt';
}

/// Another backup or restore is running (FR-011).
final class BackupBusy extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupBusy';
}

/// Writing files failed, e.g. the device is out of storage.
final class BackupStorageFull extends BackupFailure {
  const new();

  @override
  String toString() => 'BackupStorageFull';
}

/// Google Drive needs the user to connect (or reconnect) their account
/// (feature 008 research R10).
final class DriveAuthRequired extends BackupFailure {
  const new();

  @override
  String toString() => 'DriveAuthRequired';
}

/// The user's Google Drive is out of storage.
final class DriveQuotaExceeded extends BackupFailure {
  const new();

  @override
  String toString() => 'DriveQuotaExceeded';
}

/// No connection to Google Drive.
final class DriveOffline extends BackupFailure {
  const new();

  @override
  String toString() => 'DriveOffline';
}

/// Google Drive failed for another reason, or Drive is not configured in
/// this build.
final class DriveUnavailable extends BackupFailure {
  const new([this.code]);

  final String? code;

  @override
  String toString() => 'DriveUnavailable($code)';
}
