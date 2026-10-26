import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/widgets.dart';

/// The manual backup warning (spec §16 "Conflict rule"): a newer backup
/// from another phone, or an empty phone over a backup with data. Shared
/// by ACC-01 and SET-02 "Back up now". True for "Back up anyway".
Future<bool> showBackupConflictDialog(
  BuildContext context,
  ConflictCheck conflict,
) {
  final l10n = AppLocalizations.of(context);
  final String body;
  switch (conflict) {
    case NewerFromOtherDevice(:final newest):
      final device = newest.deviceName.isEmpty
          ? l10n.backup_unknownDevice
          : newest.deviceName;
      final time = formatFullDateTime(
        Epoch.toLocal(newest.createdAt),
        FullDateFormatScope.of(context),
        Localizations.localeOf(context).toString(),
      );
      body = l10n.backup_conflictNewer(device, time);
    case EmptyOverData():
      body = l10n.backup_conflictEmpty;
    case NoConflict():
      return Future.value(true);
  }
  return ConfirmDialog.show(
    context,
    title: l10n.backup_conflictTitle,
    consequence: body,
    confirmLabel: l10n.backup_backUpAnyway,
  );
}
