/// The ACC-01 backup state line (feature 010 data-model §7). Derived, never
/// stored. Pure.
sealed class BackupStatus {
  const new();
}

/// A backup is running now.
final class BackupStatusBackingUp extends BackupStatus {
  const new();
}

/// Auto backup is paused by a newer backup from another phone.
final class BackupStatusPaused extends BackupStatus {
  const new();
}

/// Auto backups are failing.
final class BackupStatusFailed extends BackupStatus {
  const new();
}

/// The last backup is fine, or there is none yet ([lastBackupAt] null).
final class BackupStatusBackedUp extends BackupStatus {
  const new({this.lastBackupAt});

  /// UTC epoch milliseconds.
  final int? lastBackupAt;
}

abstract final class BackupStatusPolicy {
  /// Precedence: backing up > paused > failed > backed up. The offline and
  /// "Waiting for Wi-Fi" states need the network state, which comes later
  /// (task T057).
  static BackupStatus derive({
    required bool backingUp,
    required bool paused,
    required int autoBackupFailures,
    required int? lastBackupAt,
  }) {
    if (backingUp) return const BackupStatusBackingUp();
    if (paused) return const BackupStatusPaused();
    if (autoBackupFailures > 0) return const BackupStatusFailed();
    return BackupStatusBackedUp(lastBackupAt: lastBackupAt);
  }
}
