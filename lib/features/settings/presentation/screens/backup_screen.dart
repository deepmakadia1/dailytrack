import 'dart:async';

import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_failure_text.dart';
import 'package:dailytrack/core/backup/presentation/backup_password_sheet.dart';
import 'package:dailytrack/core/backup/presentation/drive_backup_tile.dart';
import 'package:dailytrack/core/backup/presentation/restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:dailytrack/core/widgets/confirm_dialog.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/core/widgets/settings_section.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/settings/presentation/controllers/backup_controller.dart';
import 'package:dailytrack/features/settings/presentation/widgets/choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// SET-02 Backup and restore (spec §10, feature 008 contracts/screens.md):
/// last backup, Google Drive (connect, back up now, auto backup), the local
/// backup file, the encrypt and receipt options, and the Drive backups to
/// restore. A fixed set of controls, so it has no empty state (plan
/// Complexity Tracking); the Drive list has its own. No ads in this feature.
class BackupScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(backupControllerProvider);
    return AppScaffold(
      title: l10n.backup_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) => _BackupList(state: value),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(backupControllerProvider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 5)),
      },
    );
  }
}

/// A plain-language error dialog (§15.6).
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

String _frequencyLabel(AppLocalizations l10n, AutoBackupFrequency f) =>
    switch (f) {
      AutoBackupFrequency.off => l10n.backup_autoOff,
      AutoBackupFrequency.daily => l10n.backup_autoDaily,
      AutoBackupFrequency.weekly => l10n.backup_autoWeekly,
    };

class _BackupList extends ConsumerWidget {
  const new({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toString();
    final lastAt = state.lastBackupAt;
    final lastLine = lastAt == null
        ? l10n.backup_noBackupYet
        : l10n.backup_lastBackupDetail(
            formatFullDateTime(
              Epoch.toLocal(lastAt),
              FullDateFormatScope.of(context),
              locale,
            ),
            switch (state.lastBackupLocation) {
              BackupLocation.drive => l10n.backup_locationDrive,
              _ => l10n.backup_locationDevice,
            },
            formatBackupSize(state.lastBackupSizeBytes ?? 0, locale),
          );
    final connected = state.accountEmail != null;

    return ListView(
      children: [
        SettingsSection(
          title: l10n.backup_lastBackupTitle,
          children: [
            ListTile(
              key: const Key('backup_last'),
              leading: const Icon(Icons.history),
              title: Text(lastLine),
            ),
          ],
        ),
        _DriveCard(state: state),
        _LocalCard(state: state),
        _Options(state: state),
        if (connected) _DriveList(state: state),
      ],
    );
  }
}

/// Google Drive: connect, back up now, auto backup, disconnect (FR-014,
/// FR-015, FR-018, FR-019).
class _DriveCard extends ConsumerWidget {
  const new({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final controller = ref.read(backupControllerProvider.notifier);
    final email = state.accountEmail;
    final working = state.busy || state.uploading;

    Future<void> connect() async {
      try {
        await controller.connect();
      } on DriveAuthRequired {
        // Cancelled at the account picker: stays disconnected.
      } on Object catch (e) {
        if (context.mounted) {
          await _showError(context, l10n.backup_failedTitle, e);
        }
      }
    }

    Future<void> backUpNow() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await controller.backUpNow();
        messenger.showSnackBar(
          SnackBar(
            key: const Key('backup_drive_saved'),
            content: Text(l10n.backup_driveSaved),
          ),
        );
      } on Object catch (e) {
        if (context.mounted) {
          await _showError(context, l10n.backup_failedTitle, e);
        }
      }
    }

    Future<void> disconnect() async {
      final ok = await ConfirmDialog.show(
        context,
        title: l10n.backup_disconnectTitle,
        consequence: l10n.backup_disconnectBody,
        confirmLabel: l10n.backup_disconnect,
      );
      if (ok) await controller.disconnect();
    }

    Future<void> pickFrequency() async {
      final picked = await showChoiceSheet<AutoBackupFrequency>(
        context,
        title: l10n.backup_autoTitle,
        selected: state.autoFrequency,
        choices: [
          for (final f in AutoBackupFrequency.values)
            (
              value: f,
              label: _frequencyLabel(l10n, f),
              key: Key('backup_auto_${f.name}'),
            ),
        ],
      );
      if (picked != null) await controller.setAutoFrequency(picked.value);
    }

    final body = Padding(
      padding: EdgeInsets.symmetric(horizontal: tokens.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!state.driveAvailable)
            Text(
              l10n.backup_driveUnavailable,
              key: const Key('backup_drive_unavailable'),
            )
          else if (email == null) ...[
            Text(l10n.backup_driveBody),
            SizedBox(height: tokens.s16),
            OutlinedButton.icon(
              key: const Key('backup_connect'),
              onPressed: working ? null : () => unawaited(connect()),
              icon: const Icon(Icons.add_link),
              label: Text(l10n.backup_connect),
            ),
          ] else ...[
            Text(
              l10n.backup_connected(email),
              key: const Key('backup_account'),
            ),
            SizedBox(height: tokens.s16),
            if (state.uploading) ...[
              const LinearProgressIndicator(key: Key('backup_upload_progress')),
              SizedBox(height: tokens.s8),
              Text(l10n.backup_uploading),
              SizedBox(height: tokens.s16),
            ],
            FilledButton.icon(
              key: const Key('backup_now'),
              onPressed: working ? null : () => unawaited(backUpNow()),
              icon: const Icon(Icons.cloud_upload_outlined),
              label: Text(l10n.backup_backUpNow),
            ),
          ],
        ],
      ),
    );

    return SettingsSection(
      title: l10n.backup_driveTitle,
      children: [
        body,
        if (email != null) ...[
          ListTile(
            key: const Key('backup_auto'),
            leading: const Icon(Icons.schedule),
            title: Text(l10n.backup_autoTitle),
            subtitle: Text(_frequencyLabel(l10n, state.autoFrequency)),
            trailing: const Icon(Icons.chevron_right),
            onTap: working ? null : () => unawaited(pickFrequency()),
          ),
          SwitchListTile(
            key: const Key('backup_wifi_only'),
            secondary: const Icon(Icons.wifi),
            title: Text(l10n.backup_wifiOnly),
            subtitle: Text(l10n.backup_wifiOnlyHelp),
            value: state.wifiOnly,
            onChanged: state.autoFrequency == AutoBackupFrequency.off
                ? null
                : (on) => unawaited(controller.setWifiOnly(wifiOnly: on)),
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tokens.s8),
              child: TextButton(
                key: const Key('backup_disconnect'),
                onPressed: working ? null : () => unawaited(disconnect()),
                child: Text(l10n.backup_disconnect),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The backup file on this phone (FR-013).
class _LocalCard extends ConsumerWidget {
  const new({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final controller = ref.read(backupControllerProvider.notifier);
    final working = state.busy || state.uploading;
    // One primary action per screen (§15.1): "Back up now" when connected.
    final primary = state.accountEmail == null;

    Future<void> save() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        final saved = await controller.saveBackup();
        if (saved == null) return;
        messenger.showSnackBar(
          SnackBar(
            key: const Key('backup_saved'),
            content: Text(l10n.backup_saved),
            action: SnackBarAction(
              label: l10n.backup_share,
              onPressed: () => unawaited(controller.shareLastBackup()),
            ),
          ),
        );
      } on Object catch (e) {
        if (context.mounted) {
          await _showError(context, l10n.backup_failedTitle, e);
        }
      }
    }

    Future<void> restore() => showRestoreFromFileFlow(
      context,
      ref.read(restoreServiceProvider),
      moduleSummaries: controller.summaries(l10n),
    );

    final saveLabel = Text(l10n.backup_saveFile);
    final onSave = working ? null : () => unawaited(save());
    return SettingsSection(
      title: l10n.backup_localTitle,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.s16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.backup_localBody),
              SizedBox(height: tokens.s16),
              if (state.busy) ...[
                const LinearProgressIndicator(key: Key('backup_progress')),
                SizedBox(height: tokens.s8),
                Text(l10n.backup_working),
                SizedBox(height: tokens.s16),
              ],
              if (primary)
                FilledButton.icon(
                  key: const Key('backup_save_file'),
                  onPressed: onSave,
                  icon: const Icon(Icons.save_alt),
                  label: saveLabel,
                )
              else
                OutlinedButton.icon(
                  key: const Key('backup_save_file'),
                  onPressed: onSave,
                  icon: const Icon(Icons.save_alt),
                  label: saveLabel,
                ),
              SizedBox(height: tokens.s8),
              OutlinedButton.icon(
                key: const Key('backup_restore_file'),
                onPressed: working ? null : () => unawaited(restore()),
                icon: const Icon(Icons.restore),
                label: Text(l10n.backup_restoreFile),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Encrypt and receipt options (FR-003, FR-021).
class _Options extends ConsumerWidget {
  const new({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(backupControllerProvider.notifier);
    final working = state.busy || state.uploading;

    Future<void> toggleEncrypt({required bool on}) async {
      if (!on) {
        await controller.turnOffEncryption();
        return;
      }
      final password = await showNewBackupPasswordSheet(
        context,
        changing: false,
      );
      if (password != null) await controller.turnOnEncryption(password);
    }

    Future<void> changePassword() async {
      final password = await showNewBackupPasswordSheet(
        context,
        changing: true,
      );
      if (password != null) await controller.changePassword(password);
    }

    return SettingsSection(
      title: l10n.backup_optionsTitle,
      children: [
        SwitchListTile(
          key: const Key('backup_encrypt'),
          secondary: const Icon(Icons.lock_outline),
          title: Text(l10n.backup_encrypt),
          subtitle: Text(l10n.backup_encryptHelp),
          value: state.encrypt,
          onChanged: working ? null : (on) => unawaited(toggleEncrypt(on: on)),
        ),
        if (state.encrypt)
          ListTile(
            key: const Key('backup_change_password'),
            leading: const Icon(Icons.password),
            title: Text(l10n.backup_changePassword),
            trailing: const Icon(Icons.chevron_right),
            onTap: working ? null : () => unawaited(changePassword()),
          ),
        SwitchListTile(
          key: const Key('backup_include_receipts'),
          secondary: const Icon(Icons.receipt_long_outlined),
          title: Text(l10n.backup_includeReceipts),
          subtitle: Text(l10n.backup_includeReceiptsHelp),
          value: state.includeReceipts,
          onChanged: working
              ? null
              : (on) => unawaited(controller.setIncludeReceipts(enabled: on)),
        ),
      ],
    );
  }
}

/// "Restore from Google Drive": the account's backups, newest first, with
/// restore on tap and Delete in the overflow menu (FR-016).
class _DriveList extends ConsumerWidget {
  const new({required this.state});

  final BackupState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final controller = ref.read(backupControllerProvider.notifier);
    final drive = state.drive ?? const AsyncLoading<List<DriveBackupEntry>>();

    Future<void> restore(DriveBackupEntry entry) => showRestoreFlow(
      context,
      ref.read(restoreServiceProvider),
      source: () => ref.read(driveBackupStoreProvider).download(entry.id),
      progressLabel: l10n.backup_downloading,
      moduleSummaries: controller.summaries(l10n),
    );

    Future<void> delete(DriveBackupEntry entry) async {
      final ok = await ConfirmDialog.show(
        context,
        title: l10n.backup_deleteTitle,
        consequence: l10n.backup_deleteBody,
        confirmLabel: l10n.backup_deleteAction,
        destructive: true,
      );
      if (!ok) return;
      try {
        await controller.deleteBackup(entry.id);
      } on Object catch (e) {
        if (context.mounted) {
          await _showError(context, l10n.backup_failedTitle, e);
        }
      }
    }

    Future<void> reconnect() async {
      try {
        await controller.connect();
        await controller.refreshDrive();
      } on DriveAuthRequired {
        // Cancelled again; the error stays.
      } on Object catch (e) {
        if (context.mounted) {
          await _showError(context, l10n.backup_failedTitle, e);
        }
      }
    }

    final rows = switch (drive) {
      AsyncValue(:final value?) when value.isEmpty => [
        Padding(
          padding: EdgeInsets.all(tokens.s16),
          child: Text(
            l10n.backup_driveListEmpty,
            key: const Key('backup_drive_empty'),
          ),
        ),
      ],
      AsyncValue(:final value?) => [
        for (final entry in value)
          DriveBackupTile(
            entry: entry,
            onTap: state.busy || state.uploading
                ? null
                : () => unawaited(restore(entry)),
            trailing: PopupMenuButton<void>(
              key: Key('drive_backup_menu_${entry.id}'),
              tooltip: l10n.backup_moreActions,
              itemBuilder: (_) => [
                PopupMenuItem<void>(
                  key: Key('drive_backup_delete_${entry.id}'),
                  onTap: () => unawaited(delete(entry)),
                  child: Text(l10n.backup_delete),
                ),
              ],
            ),
          ),
      ],
      AsyncError(:final error) => [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.s16),
          child: ErrorState(
            key: const Key('backup_drive_error'),
            message: error is DriveAuthRequired
                ? l10n.backup_errAuth
                : l10n.backup_driveListError,
            retryLabel: error is DriveAuthRequired
                ? l10n.backup_reconnect
                : null,
            onRetry: error is DriveAuthRequired
                ? () => unawaited(reconnect())
                : () => unawaited(controller.refreshDrive()),
          ),
        ),
      ],
      _ => const [
        DelayedSkeleton(
          key: Key('backup_drive_loading'),
          child: SkeletonList(itemCount: 2),
        ),
      ],
    };

    return SettingsSection(title: l10n.backup_driveListTitle, children: rows);
  }
}
