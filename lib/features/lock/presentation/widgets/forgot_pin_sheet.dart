import 'package:dailytrack/core/backup/presentation/drive_restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/reset/domain/app_reset_service.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/erase_all_data_flow.dart';
import 'package:flutter/material.dart';

enum _ForgotChoice { restore, erase }

/// SYS-03 "Forgot PIN?" (FR-024, FR-035, US2-7, US8): the PIN can't be
/// recovered; the user can restore from a Google Drive backup
/// ([restoreFromDrive], null when Drive isn't available in this build) or
/// erase all data (typed DELETE). With no Drive backups, erasing is offered
/// instead. Cancel leaves SYS-03, and any lockout, as it was.
Future<void> showForgotPinSheet(
  BuildContext context,
  AppResetService service, {
  Future<DriveRestoreResult> Function()? restoreFromDrive,
}) async {
  final l10n = AppLocalizations.of(context);
  final choice = await AppBottomSheet.show<_ForgotChoice>(
    context,
    title: l10n.lock_forgotTitle,
    child: _ForgotPin(canRestore: restoreFromDrive != null),
  );
  if (choice == null || !context.mounted) return;
  if (choice == _ForgotChoice.restore) {
    final result = await restoreFromDrive!();
    if (result != DriveRestoreResult.noBackups || !context.mounted) return;
    final erase = await ConfirmDialog.show(
      context,
      title: l10n.backup_driveListEmpty,
      consequence: l10n.lock_forgotBody,
      confirmLabel: l10n.settings_eraseAll,
      destructive: true,
    );
    if (!erase || !context.mounted) return;
  }
  await showEraseAllDataFlow(context, service);
}

class _ForgotPin extends StatelessWidget {
  const new({required this.canRestore});

  final bool canRestore;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          canRestore ? l10n.lock_forgotBodyRestore : l10n.lock_forgotBody,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: tokens.s24),
        if (canRestore) ...[
          FilledButton.icon(
            key: const Key('forgot_pin_restore'),
            onPressed: () => Navigator.of(context).pop(_ForgotChoice.restore),
            icon: const Icon(Icons.cloud_download_outlined),
            label: Text(l10n.lock_restoreFromDrive),
          ),
          SizedBox(height: tokens.s8),
        ],
        // The only primary button when there is no Drive restore.
        if (canRestore)
          OutlinedButton(
            key: const Key('forgot_pin_erase'),
            style: OutlinedButton.styleFrom(foregroundColor: scheme.error),
            onPressed: () => Navigator.of(context).pop(_ForgotChoice.erase),
            child: Text(l10n.settings_eraseAll),
          )
        else
          FilledButton(
            key: const Key('forgot_pin_erase'),
            style: FilledButton.styleFrom(
              backgroundColor: scheme.error,
              foregroundColor: scheme.onError,
            ),
            onPressed: () => Navigator.of(context).pop(_ForgotChoice.erase),
            child: Text(l10n.settings_eraseAll),
          ),
        SizedBox(height: tokens.s8),
        TextButton(
          key: const Key('forgot_pin_cancel'),
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}
