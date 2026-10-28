import 'package:dailytrack/core/account/domain/account_card_view.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';

/// The ACC-01 backup state line (feature 010 data-model §7). Derived, never
/// stored. Pure.
sealed class BackupStatus {
  const new();
}

/// No network, or reading Drive failed with `DriveOffline`.
final class BackupStatusOffline extends BackupStatus {
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

/// Auto backups are failing, or the last manual backup failed this session.
final class BackupStatusFailed extends BackupStatus {
  const new({this.error});

  /// The last failure seen this session, for its message; null when only
  /// the auto backup failure count is known.
  final Object? error;
}

/// A background backup is waiting for an unmetered network.
final class BackupStatusWaitingForWifi extends BackupStatus {
  const new();
}

/// The last backup is fine, or there is none yet ([lastBackupAt] null).
final class BackupStatusBackedUp extends BackupStatus {
  const new({this.lastBackupAt});

  /// UTC epoch milliseconds.
  final int? lastBackupAt;
}

abstract final class BackupStatusPolicy {
  /// Precedence: offline > backing up > paused > failed > waiting for
  /// Wi-Fi > backed up (data-model §7).
  static BackupStatus derive({
    required bool online,
    required bool backingUp,
    required bool paused,
    required int autoBackupFailures,
    required int? lastBackupAt,
    Object? failure,
    int? lastBackgroundBackupAt,
    bool wifiOnly = false,
    bool metered = false,
  }) {
    if (!online) return const BackupStatusOffline();
    if (backingUp) return const BackupStatusBackingUp();
    if (paused) return const BackupStatusPaused();
    if (failure != null || autoBackupFailures > 0) {
      return BackupStatusFailed(error: failure);
    }
    final pending =
        lastBackgroundBackupAt != null &&
        lastBackgroundBackupAt > (lastBackupAt ?? 0);
    if (pending && wifiOnly && metered) {
      return const BackupStatusWaitingForWifi();
    }
    return BackupStatusBackedUp(lastBackupAt: lastBackupAt);
  }
}

/// The SET-01 account card's status line (feature 011 data-model §5,
/// research R11): [BackupStatusPolicy.derive] over the same settings ACC-01
/// reads, with "Backing up…" from the backup lease (any isolate), and the
/// last successful state kept while offline or waiting for Wi-Fi
/// (clarification Q3).
abstract final class AccountCardPolicy {
  static CardStatus derive({
    required AppSettings s,
    required bool online,
    required DateTime now,
    bool metered = false,
  }) {
    final status = BackupStatusPolicy.derive(
      online: online,
      backingUp: (s.backupLeaseUntil ?? 0) > now.toUtc().millisecondsSinceEpoch,
      paused: s.autoBackupPausedByConflict,
      autoBackupFailures: s.autoBackupFailures,
      lastBackupAt: s.lastBackupAt,
      lastBackgroundBackupAt: s.lastBackgroundBackupAt,
      wifiOnly:
          s.autoBackupWifiOnly &&
          s.autoBackupFrequency != AutoBackupFrequency.off,
      metered: metered,
    );
    CardStatus last() {
      final at = s.lastBackupAt;
      return at == null ? const CardNotBackedUpYet() : CardBackedUp(at);
    }

    return switch (status) {
      BackupStatusBackingUp() => const CardBackingUp(),
      BackupStatusPaused() => const CardPaused(),
      BackupStatusFailed() => const CardFailed(),
      BackupStatusOffline() ||
      BackupStatusWaitingForWifi() ||
      BackupStatusBackedUp() => last(),
    };
  }
}
