import 'dart:async';
import 'dart:typed_data';

import 'package:dailytrack/core/backup/backup_service.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/presentation/backup_failure_text.dart';
import 'package:dailytrack/core/backup/presentation/backup_password_sheet.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:flutter/material.dart';

/// Restore from a backup file (SET-02, feature 008 contracts/screens.md
/// "Restore flow"):
///  1. the system picker,
///  2. the password, if the file is encrypted (a wrong one is asked again),
///  3. a summary of what the backup holds,
///  4. "Replace current data?" (§15.5: a restore can't be undone),
///  5. a progress dialog, then a snackbar or a plain-language error.
/// Nothing changes until step 4 is confirmed. Returns true when restored.
Future<bool> showRestoreFromFileFlow(
  BuildContext context,
  RestoreService service, {
  required Map<String, String Function(Map<String, int>)> moduleSummaries,
}) => showRestoreFlow(
  context,
  service,
  source: service.pickFile,
  moduleSummaries: moduleSummaries,
);

/// The restore steps for any [source] of backup bytes: the file picker, or
/// a Google Drive download (with [progressLabel] shown while it runs).
/// [source] returning null means the user cancelled.
Future<bool> showRestoreFlow(
  BuildContext context,
  RestoreService service, {
  required Future<Uint8List?> Function() source,
  required Map<String, String Function(Map<String, int>)> moduleSummaries,
  String? progressLabel,
}) async {
  final l10n = AppLocalizations.of(context);
  final Uint8List? bytes;
  try {
    bytes = progressLabel == null
        ? await source()
        : await runWithProgress(context, progressLabel, source);
  } on Object catch (e) {
    if (context.mounted) await _showError(context, l10n.restore_failedTitle, e);
    return false;
  }
  if (bytes == null || !context.mounted) return false;

  RestoreCandidate? candidate;
  String? password;
  String? passwordError;
  while (candidate == null) {
    try {
      candidate = await service.open(bytes, password: password);
    } on BackupNeedsPassword {
      if (!context.mounted) return false;
      password = await showBackupPasswordPrompt(context, error: passwordError);
      if (password == null) return false;
    } on BackupWrongPassword {
      if (!context.mounted) return false;
      passwordError = l10n.backup_errWrongPassword;
      password = await showBackupPasswordPrompt(context, error: passwordError);
      if (password == null) return false;
    } on Object catch (e) {
      if (context.mounted) {
        await _showError(context, l10n.restore_failedTitle, e);
      }
      return false;
    }
  }
  if (!context.mounted) return false;

  final proceed = await AppBottomSheet.show<bool>(
    context,
    title: l10n.restore_previewTitle,
    child: _Preview(
      preview: candidate.preview,
      moduleSummaries: moduleSummaries,
    ),
  );
  if (proceed != true || !context.mounted) return false;

  final confirmed = await ConfirmDialog.show(
    context,
    title: l10n.restore_confirmTitle,
    consequence: l10n.restore_confirmBody,
    confirmLabel: l10n.restore_confirmAction,
    destructive: true,
  );
  if (!confirmed || !context.mounted) return false;

  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  // Restored settings can rebuild the screens, so the dialog is removed by
  // its route, never by popping whatever is on top.
  final progress = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _RestoringDialog(),
  );
  navigator.push(progress);
  Object? error;
  var outcome = RestoreOutcome.done;
  try {
    outcome = await service.apply(candidate);
  } on Object catch (e) {
    error = e;
  }
  if (progress.isActive) navigator.removeRoute(progress);
  if (error != null) {
    if (context.mounted) {
      await _showError(context, l10n.restore_failedTitle, error);
    }
    return false;
  }
  messenger.showSnackBar(
    SnackBar(
      key: const Key('restore_done'),
      content: Text(
        outcome == RestoreOutcome.done
            ? l10n.restore_done
            : l10n.restore_doneMissingReceipts,
      ),
    ),
  );
  return true;
}

/// Runs [body] under a non-dismissible progress dialog showing [label].
Future<T> runWithProgress<T>(
  BuildContext context,
  String label,
  Future<T> Function() body,
) async {
  final navigator = Navigator.of(context);
  final progress = DialogRoute<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _ProgressDialog(label: label),
  );
  navigator.push(progress);
  try {
    return await body();
  } finally {
    if (progress.isActive) navigator.removeRoute(progress);
  }
}

/// A plain-language error with its next step (§15.6).
Future<void> showBackupError(
  BuildContext context,
  String title,
  Object error,
) => _showError(context, title, error);

/// A plain-language error with its next step (§15.6).
Future<void> _showError(BuildContext context, String title, Object error) {
  final l10n = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    builder: (dialog) => AlertDialog(
      key: const Key('backup_error'),
      title: Text(title),
      content: Text(backupFailureText(l10n, error)),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: Text(l10n.common_cancel),
        ),
      ],
    ),
  );
}

class _Preview extends StatelessWidget {
  const new({required this.preview, required this.moduleSummaries});

  final RestorePreview preview;
  final Map<String, String Function(Map<String, int>)> moduleSummaries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final locale = Localizations.localeOf(context).toString();
    final created = formatFullDateTime(
      Epoch.toLocal(preview.createdAt),
      FullDateFormatScope.of(context),
      locale,
    );
    return Column(
      key: const Key('restore_preview'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.restore_previewCreated(created)),
        if (preview.appVersion.isNotEmpty)
          Text(
            l10n.restore_previewVersion(preview.appVersion),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        SizedBox(height: tokens.s12),
        for (final m in preview.modules)
          if (moduleSummaries[m.moduleId] case final summary?)
            Padding(
              padding: EdgeInsets.symmetric(vertical: tokens.s4),
              child: Text(
                summary(m.counts),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
        if (preview.receiptCount > 0)
          Text(l10n.restore_previewReceipts(preview.receiptCount)),
        if (preview.skippedModuleIds.isNotEmpty) ...[
          SizedBox(height: tokens.s8),
          Text(l10n.restore_previewSkipped),
        ],
        SizedBox(height: tokens.s24),
        FilledButton(
          key: const Key('restore_continue'),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.restore_continue),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.common_cancel),
        ),
      ],
    );
  }
}

class _RestoringDialog extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => _ProgressDialog(
    label: AppLocalizations.of(context).restore_inProgress,
    dialogKey: const Key('restore_progress'),
  );
}

class _ProgressDialog extends StatelessWidget {
  const new({required this.label, this.dialogKey});

  final String label;
  final Key? dialogKey;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        key: dialogKey ?? const Key('backup_progress_dialog'),
        content: Row(
          children: [
            const CircularProgressIndicator(),
            SizedBox(width: tokens.s16),
            Expanded(child: Text(label)),
          ],
        ),
      ),
    );
  }
}
