import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';

/// The plain-language message for a backup or restore error (§15.6): no
/// codes, and always what happened to the user's data.
String backupFailureText(AppLocalizations l10n, Object error) =>
    switch (error) {
      BackupNotRecognized() => l10n.backup_errNotRecognized,
      BackupDamaged() => l10n.backup_errDamaged,
      BackupInvalid() => l10n.backup_errInvalid,
      BackupTooNew() => l10n.backup_errTooNew,
      BackupWrongPassword() => l10n.backup_errWrongPassword,
      BackupNeedsPassword() => l10n.backup_errNeedsPassword,
      BackupTooLargeToEncrypt() => l10n.backup_errTooLarge,
      BackupBusy() => l10n.backup_errBusy,
      BackupStorageFull() => l10n.backup_errStorage,
      DriveAuthRequired() => l10n.backup_errAuth,
      DriveQuotaExceeded() => l10n.backup_errQuota,
      DriveOffline() => l10n.backup_errOffline,
      DriveUnavailable(code: 'not-configured') => l10n.backup_driveUnavailable,
      DriveUnavailable() => l10n.backup_errDrive,
      _ => l10n.backup_errGeneric,
    };
