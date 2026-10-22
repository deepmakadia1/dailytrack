import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/drive_backup_tile.dart';
import 'package:dailytrack/core/backup/presentation/restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

/// How a Google Drive restore ended.
enum DriveRestoreResult { restored, cancelled, noBackups }

/// Restore from Google Drive where SET-02 is not open, e.g. SYS-03 "Forgot
/// PIN?" (FR-024): connect the Google account, pick a backup, then the
/// usual password, summary, and "Replace current data?" steps. Nothing
/// changes until the user confirms. [onConnected] stores the account.
Future<DriveRestoreResult> showDriveRestoreFlow(
  BuildContext context, {
  required DriveBackupStore drive,
  required RestoreService restore,
  required Map<String, String Function(Map<String, int>)> moduleSummaries,
  required Future<void> Function(String email) onConnected,
}) async {
  final l10n = AppLocalizations.of(context);
  try {
    await onConnected(await drive.connect());
  } on DriveAuthRequired {
    return DriveRestoreResult.cancelled;
  } on Object catch (e) {
    if (context.mounted) {
      await showBackupError(context, l10n.restore_failedTitle, e);
    }
    return DriveRestoreResult.cancelled;
  }
  if (!context.mounted) return DriveRestoreResult.cancelled;

  final List<DriveBackupEntry> entries;
  try {
    entries = await runWithProgress(
      context,
      l10n.backup_listLoading,
      drive.list,
    );
  } on Object catch (e) {
    if (context.mounted) {
      await showBackupError(context, l10n.restore_failedTitle, e);
    }
    return DriveRestoreResult.cancelled;
  }
  if (entries.isEmpty) return DriveRestoreResult.noBackups;
  if (!context.mounted) return DriveRestoreResult.cancelled;

  final picked = await AppBottomSheet.show<DriveBackupEntry>(
    context,
    title: l10n.backup_driveListTitle,
    child: Column(
      key: const Key('drive_restore_picker'),
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final e in entries)
          Builder(
            builder: (sheet) => DriveBackupTile(
              entry: e,
              onTap: () => Navigator.of(sheet).pop(e),
            ),
          ),
      ],
    ),
  );
  if (picked == null || !context.mounted) return DriveRestoreResult.cancelled;

  final restored = await showRestoreFlow(
    context,
    restore,
    source: () => drive.download(picked.id),
    progressLabel: l10n.backup_downloading,
    moduleSummaries: moduleSummaries,
  );
  return restored ? DriveRestoreResult.restored : DriveRestoreResult.cancelled;
}
