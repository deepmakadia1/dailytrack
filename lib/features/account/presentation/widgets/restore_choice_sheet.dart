import 'dart:async';
import 'dart:typed_data';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_restore.dart';
import 'package:dailytrack/core/account/account_ui.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_password_sheet.dart';
import 'package:dailytrack/core/backup/presentation/backup_summaries.dart';
import 'package:dailytrack/core/backup/presentation/restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/full_date_format_scope.dart';
import 'package:dailytrack/features/account/presentation/controllers/restore_choice_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// The account feature's [AccountUi], bound in `production_overrides.dart`
/// (research R18).
final class AccountFeatureUi implements AccountUi {
  const new();

  @override
  Future<RestoreChoiceResult> showRestoreChoice(
    BuildContext context, {
    required DriveBackupEntry newest,
    required bool afterSignIn,
  }) => showRestoreChoiceFor(context, newest: newest, afterSignIn: afterSignIn);
}

/// ACC-02 for [newest] (spec §16, contracts/screens.md). With no user data
/// on this phone, the backup is restored at once behind a progress view
/// and the sheet never shows (FR-016).
Future<RestoreChoiceResult> showRestoreChoiceFor(
  BuildContext context, {
  required DriveBackupEntry newest,
  required bool afterSignIn,
}) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final l10n = AppLocalizations.of(context);
  bool hasData;
  try {
    hasData = await container.read(accountRestoreProvider).phoneHasData();
  } on Object {
    // Unknown: ask rather than replace.
    hasData = true;
  }
  if (!context.mounted) return RestoreChoiceResult.closed;
  if (!hasData) return await restoreWithoutChoice(context, newest);
  final email =
      (await container.read(settingsRepositoryProvider).load())
          .backupAccountEmail ??
      '';
  if (!context.mounted) return RestoreChoiceResult.closed;
  final result = await AppBottomSheet.show<RestoreChoiceResult>(
    context,
    title: l10n.account_choiceTitle(email),
    dismissible: !afterSignIn,
    child: RestoreChoiceSheet(newest: newest, afterSignIn: afterSignIn),
  );
  return result ?? RestoreChoiceResult.closed;
}

/// "Restored 1,240 transactions · 8 habits".
String _restoredText(
  AppLocalizations l10n,
  ModuleRegistry registry,
  RestorePreview preview,
) {
  final summaries = backupSummaries(registry, l10n);
  final line = [
    for (final m in preview.modules)
      if (summaries[m.moduleId] case final summary?) summary(m.counts),
  ].join(' · ');
  return l10n.account_restoredCounts(line);
}

/// The plain-language reason a restore from the account failed.
String restoreFailureText(AppLocalizations l10n, Object error) =>
    error is DriveAuthRequired
    ? l10n.account_sessionExpired
    : l10n.account_restoreFailed;

/// Restores [newest] onto a phone with no user data: download, the saved
/// password or a prompt, then "Restoring your data…" (FR-016). Failures
/// say nothing changed and offer "Try again".
Future<RestoreChoiceResult> restoreWithoutChoice(
  BuildContext context,
  DriveBackupEntry newest,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final restore = container.read(accountRestoreProvider);
  final account = container.read(accountServiceProvider);
  final registry = container.read(moduleRegistryProvider);
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  while (true) {
    if (!context.mounted) return RestoreChoiceResult.closed;
    try {
      final bytes = await runWithProgress<Uint8List>(
        context,
        l10n.backup_downloading,
        () => account.guardAuth(() => restore.download(newest)),
      );
      OpenedBackup? opened;
      String? password;
      String? error;
      while (opened == null) {
        try {
          opened = await restore.open(bytes, password: password);
        } on BackupNeedsPassword {
          error = null;
        } on BackupWrongPassword {
          error = l10n.account_wrongPassword;
        }
        if (opened != null) break;
        if (!context.mounted) return RestoreChoiceResult.closed;
        password = await showBackupPasswordPrompt(context, error: error);
        if (password == null) return RestoreChoiceResult.closed;
      }
      if (!context.mounted) return RestoreChoiceResult.closed;
      final backup = opened;
      final result = await runWithProgress(
        context,
        l10n.account_restoring,
        () => restore.apply(backup, entry: newest, fromEmptyPhone: true),
      );
      switch (result) {
        case Restored(:final preview):
          messenger.showSnackBar(
            SnackBar(
              key: const Key('acc02_restored'),
              content: Text(_restoredText(l10n, registry, preview)),
            ),
          );
          return RestoreChoiceResult.restored;
        case SafetyCopyFailed():
          throw const BackupStorageFull();
      }
    } on Object catch (e) {
      if (!context.mounted) return RestoreChoiceResult.closed;
      final retry = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
          key: const Key('acc02_restoreFailed'),
          title: Text(l10n.restore_failedTitle),
          content: Text(restoreFailureText(l10n, e)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialog).pop(false),
              child: Text(l10n.common_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialog).pop(true),
              child: Text(l10n.common_tryAgain),
            ),
          ],
        ),
      );
      if (retry != true || !context.mounted) return RestoreChoiceResult.closed;
    }
  }
}

/// ACC-02 content: the backup's summary from metadata, this phone's
/// counts, the password field when needed, and the two choices. No ads.
class RestoreChoiceSheet extends ConsumerStatefulWidget {
  const new({required this.newest, required this.afterSignIn, super.key});

  final DriveBackupEntry newest;
  final bool afterSignIn;

  @override
  ConsumerState<RestoreChoiceSheet> createState() => _RestoreChoiceSheetState();
}

class _RestoreChoiceSheetState extends ConsumerState<RestoreChoiceSheet> {
  final TextEditingController _password = TextEditingController();

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  RestoreChoiceControllerProvider get _provider =>
      restoreChoiceControllerProvider(widget.newest);

  Future<void> _restore() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final registry = ref.read(moduleRegistryProvider);
    final state = ref.read(_provider);
    final result = await ref
        .read(_provider.notifier)
        .restore(password: state.passwordNeeded ? _password.text : null);
    switch (result) {
      case Restored(:final preview):
        messenger.showSnackBar(
          SnackBar(
            key: const Key('acc02_restored'),
            content: Text(_restoredText(l10n, registry, preview)),
          ),
        );
        if (mounted) navigator.pop(RestoreChoiceResult.restored);
      case SafetyCopyFailed():
        // Shown in the sheet; nothing was written.
        setState(() => _safetyFailed = true);
      case null:
        break;
    }
  }

  bool _safetyFailed = false;

  Future<void> _keep() async {
    final navigator = Navigator.of(context);
    await ref.read(_provider.notifier).keep();
    if (mounted) navigator.pop(RestoreChoiceResult.kept);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(_provider);
    final registry = ref.watch(moduleRegistryProvider);
    final entry = widget.newest;
    final meta = entry.meta;
    final locale = Localizations.localeOf(context).toString();
    final date = formatFullDateTime(
      Epoch.toLocal(meta?.createdAt ?? entry.createdAt),
      FullDateFormatScope.of(context),
      locale,
    );
    final deviceName = meta?.deviceName ?? entry.device;
    final device = meta != null && meta.deviceId == state.thisDeviceId
        ? l10n.account_fromThisPhone
        : deviceName == null || deviceName.isEmpty
        ? l10n.backup_unknownDevice
        : l10n.account_fromDevice(deviceName);
    final kind = entry.kind == BackupKind.auto
        ? l10n.backup_kindAuto
        : l10n.backup_kindManual;
    final counts = meta == null
        ? ''
        : backupCountsLine(registry, l10n, meta.counts);
    final phone = switch (state.phoneCounts) {
      AsyncValue(:final value?) => backupCountsLine(registry, l10n, value),
      _ => null,
    };
    final failure = state.failure;
    final error = _safetyFailed
        ? l10n.account_safetyCopyFailed
        : failure == null
        ? null
        : restoreFailureText(l10n, failure);

    return SingleChildScrollView(
      key: const Key('acc02_sheet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            key: const Key('acc02_summary'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: EdgeInsets.all(tokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(date, style: theme.textTheme.titleMedium),
                  SizedBox(height: tokens.s4),
                  Text(device, key: const Key('acc02_device')),
                  if (counts.isNotEmpty) ...[
                    SizedBox(height: tokens.s4),
                    Text(counts, key: const Key('acc02_counts')),
                  ],
                  SizedBox(height: tokens.s4),
                  Row(
                    children: [
                      Text(kind),
                      if (meta?.encrypted ?? false) ...[
                        SizedBox(width: tokens.s12),
                        Icon(Icons.lock_outline, size: tokens.chipIconSize),
                        SizedBox(width: tokens.s4),
                        Text(
                          l10n.account_encrypted,
                          key: const Key('acc02_encrypted'),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: tokens.s12),
          if (phone == null)
            const LinearProgressIndicator()
          else
            Text(
              phone.isEmpty
                  ? l10n.account_thisPhoneEmpty
                  : l10n.account_thisPhone(phone),
              key: const Key('acc02_thisPhone'),
            ),
          SizedBox(height: tokens.s12),
          Text(l10n.account_replaceNote, style: theme.textTheme.bodySmall),
          if (state.passwordNeeded) ...[
            SizedBox(height: tokens.s12),
            TextField(
              key: const Key('acc02_password'),
              controller: _password,
              obscureText: true,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.backup_passwordField,
                errorText: state.passwordError
                    ? l10n.account_wrongPassword
                    : null,
              ),
            ),
          ],
          if (error != null) ...[
            SizedBox(height: tokens.s12),
            Text(
              error,
              key: const Key('acc02_error'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          SizedBox(height: tokens.s16),
          if (state.working) ...[
            const LinearProgressIndicator(),
            SizedBox(height: tokens.s12),
          ],
          FilledButton(
            key: const Key('acc02_restore'),
            onPressed: state.working ? null : () => unawaited(_restore()),
            child: Text(
              failure == null
                  ? l10n.account_restoreFromAccount
                  : l10n.common_tryAgain,
            ),
          ),
          SizedBox(height: tokens.s8),
          OutlinedButton(
            key: const Key('acc02_keep'),
            onPressed: state.working ? null : () => unawaited(_keep()),
            child: Text(l10n.account_keepThisPhone),
          ),
          Row(
            children: [
              TextButton(
                key: const Key('acc02_seeAll'),
                onPressed: state.working
                    ? null
                    : () {
                        final router = GoRouter.of(context);
                        Navigator.of(context).pop(RestoreChoiceResult.closed);
                        unawaited(router.push(Routes.backup));
                      },
                child: Text(l10n.account_seeAllBackups),
              ),
              const Spacer(),
              if (!widget.afterSignIn)
                TextButton(
                  key: const Key('acc02_close'),
                  onPressed: state.working
                      ? null
                      : () =>
                            Navigator.of(context)
                                .pop(RestoreChoiceResult.closed),
                  child: Text(l10n.account_close),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
