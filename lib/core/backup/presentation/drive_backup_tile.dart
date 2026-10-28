import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_device_name.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// "1.2 MB" style size for backup rows.
String formatBackupSize(int bytes, String locale) {
  final number = NumberFormat('#,##0.#', locale);
  if (bytes < 1024) return '${number.format(bytes)} B';
  if (bytes < 1024 * 1024) return '${number.format(bytes / 1024)} KB';
  return '${number.format(bytes / (1024 * 1024))} MB';
}

/// One Google Drive backup: date and time, size, the device, and a Manual
/// or Auto label in text (never color alone; FR-016). Shared by the SET-02
/// list and the "Forgot PIN?" picker.
class DriveBackupTile extends StatelessWidget {
  const new({required this.entry, this.onTap, this.trailing, super.key});

  final DriveBackupEntry entry;
  final VoidCallback? onTap;

  /// E.g. the SET-02 overflow menu with Delete.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = formatFullDateTime(
      Epoch.toLocal(entry.createdAt),
      FullDateFormatScope.of(context),
      locale,
    );
    final kind = entry.kind == BackupKind.auto
        ? l10n.backup_kindAuto
        : l10n.backup_kindManual;
    return ListTile(
      key: Key('drive_backup_${entry.id}'),
      leading: Icon(
        entry.kind == BackupKind.auto ? Icons.schedule : Icons.cloud_done,
        semanticLabel: kind,
      ),
      title: Text(
        l10n.backup_driveEntry(date, formatBackupSize(entry.sizeBytes, locale)),
      ),
      subtitle: Text(
        [
          kind,
          if (entry.device case final device?) backupDeviceName(l10n, device),
        ].join(' · '),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
