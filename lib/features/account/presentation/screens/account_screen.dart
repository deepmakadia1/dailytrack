import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_conflict_dialog.dart';
import 'package:dailytrack/core/backup/presentation/backup_device_name.dart';
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
import 'package:dailytrack/features/account/presentation/controllers/account_controller.dart';
import 'package:dailytrack/features/account/presentation/widgets/backup_status_line.dart';
import 'package:dailytrack/features/account/presentation/widgets/profile_avatar.dart';
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:dailytrack/features/account/presentation/widgets/sign_out_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ACC-01 Account (spec §16, feature 010 contracts/screens.md), for a
/// signed-in account only: the account, the backup status, Back up now,
/// Restore (ACC-02), Auto backup, Switch account, Sign out (ACC-03), and
/// Delete my backups. When the account stops being signed in while it is
/// open (sign-out, a revoked or expired sign-in, a cancelled Switch
/// account), the router's rule 7 closes it back to SET-01, which shows the
/// guest card (feature 011 contracts/routes.md); `app.dart` says when the
/// sign-in expired. No ads (FR-049).
class AccountScreen extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  late final AppLifecycleListener _lifecycle;
  var _leaving = false;

  @override
  void initState() {
    super.initState();
    // The network and Drive are read again on resume (data-model §7).
    _lifecycle = AppLifecycleListener(
      onResume: () =>
          unawaited(ref.read(accountControllerProvider.notifier).refresh()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  /// Still `google`, but no working session this run (the silent sign-in
  /// failed): back to SET-01. A sign-out or a lost sign-in changes
  /// `authMode`, and the router closes the screen first (rule 7).
  void _leave() {
    if (_leaving) return;
    _leaving = true;
    final router = GoRouter.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) => router.go(Routes.more));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(accountControllerProvider);
    const loading = DelayedSkeleton(child: SkeletonList(itemCount: 4));
    return AppScaffold(
      title: l10n.account_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) when value.profile != null => _SignedIn(
          state: value,
        ),
        // Switch account and ACC-03 sign out on the way; they move on.
        AsyncValue(:final value?)
            when value.busy == AccountBusy.switching ||
                value.busy == AccountBusy.signingOut =>
          loading,
        AsyncValue(value: _?) => () {
          _leave();
          return loading;
        }(),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(accountControllerProvider.notifier).retry,
        ),
        _ => loading,
      },
    );
  }
}

String _frequencyLabel(AppLocalizations l10n, AutoBackupFrequency f) =>
    switch (f) {
      AutoBackupFrequency.off => l10n.backup_autoOff,
      AutoBackupFrequency.daily => l10n.backup_autoDaily,
      AutoBackupFrequency.weekly => l10n.backup_autoWeekly,
    };

/// A failed Drive action as a plain-language error. An expired sign-in
/// signs the account out instead (research R2), and the screen closes
/// saying so.
Future<void> _showFailure(BuildContext context, Object error) async {
  if (error is DriveAuthRequired || !context.mounted) return;
  final l10n = AppLocalizations.of(context);
  await showBackupError(context, l10n.backup_failedTitle, error);
}

/// What follows the account chooser in Switch account (the guest sign-in
/// steps). A cancelled chooser leaves the user a guest with all data kept;
/// the router's rule 7 then shows SET-01 with the guest card.
Future<void> _afterSwitch(BuildContext context, SignInOutcome outcome) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  switch (outcome) {
    case SignInCancelled():
      break;
    case SignInOffline():
      messenger.showSnackBar(
        SnackBar(
          key: const Key('acc01_signInOffline'),
          content: Text(l10n.account_signInOffline),
        ),
      );
    case SignedInAndBackedUp():
      messenger.showSnackBar(
        SnackBar(
          key: const Key('acc01_signedInBackedUp'),
          content: Text(l10n.account_signedInBackedUp),
        ),
      );
    case SignedInWithBackups(:final newest):
      // ACC-02, or an immediate restore when this phone has no data.
      await showRestoreChoiceFor(context, newest: newest, afterSignIn: true);
    case SignedInBackupFailed(:final error):
      await _showFailure(context, error);
  }
}

class _SignedIn extends ConsumerWidget {
  const new({required this.state});

  final AccountScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(accountControllerProvider.notifier);
    final profile = state.profile!;
    final working = state.busy != AccountBusy.none;
    final backups = state.drive?.value;
    final newest = backups?.firstOrNull;

    Future<void> backUpNow() async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        var result = await controller.backUpNow();
        if (result case NeedsConfirmation(:final conflict)) {
          if (!context.mounted) return;
          if (!await showBackupConflictDialog(context, conflict)) return;
          result = await controller.backUpNow(overwrite: true);
        }
        // No interstitial here: the SET-02 one applies to SET-02 only.
        if (result is Uploaded) {
          messenger.showSnackBar(
            SnackBar(
              key: const Key('acc01_backedUp'),
              content: Text(l10n.backup_driveSaved),
            ),
          );
        }
      } on Object catch (e) {
        if (context.mounted) await _showFailure(context, e);
      }
    }

    Future<void> restore(DriveBackupEntry entry) async {
      await showRestoreChoiceFor(context, newest: entry, afterSignIn: false);
      await controller.refreshDrive();
    }

    /// Step 1 backs up to the current account; a failure or a declined
    /// warning offers "Switch anyway" (spec §16 ACC-01).
    Future<void> switchAccount() async {
      // Signing out swaps this part of the screen; the navigator stays.
      final stable = Navigator.of(context).context;
      final messenger = ScaffoldMessenger.of(context);
      var backedUp = false;
      try {
        var result = await controller.backUpBeforeSwitch();
        if (result case NeedsConfirmation(:final conflict)) {
          if (!context.mounted) return;
          if (await showBackupConflictDialog(context, conflict)) {
            result = await controller.backUpBeforeSwitch(overwrite: true);
          }
        }
        backedUp = result is Uploaded;
      } on Object {
        backedUp = false;
      }
      if (!context.mounted) return;
      if (!backedUp) {
        final anyway = await ConfirmDialog.show(
          context,
          title: l10n.account_switchFailedTitle,
          consequence: l10n.account_switchFailedBody(profile.email),
          confirmLabel: l10n.account_switchAnyway,
        );
        if (!anyway || !context.mounted) return;
      }
      final SignInOutcome outcome;
      try {
        outcome = await controller.switchAccount();
      } on Object {
        // Signed out by then, with data kept.
        if (stable.mounted) GoRouter.of(stable).go(Routes.more);
        messenger.showSnackBar(
          SnackBar(
            key: const Key('acc01_signInFailed'),
            content: Text(l10n.account_signInFailed),
          ),
        );
        return;
      }
      if (stable.mounted) await _afterSwitch(stable, outcome);
    }

    Future<void> deleteBackups() async {
      final count = backups?.length ?? 0;
      final messenger = ScaffoldMessenger.of(context);
      final ok = await ConfirmDialog.show(
        context,
        title: l10n.account_deleteTitle,
        consequence: l10n.account_deleteBody(count, profile.email),
        confirmLabel: l10n.account_deleteAction,
        destructive: true,
      );
      if (!ok) return;
      try {
        await controller.deleteMyBackups();
        messenger.showSnackBar(SnackBar(content: Text(l10n.account_deleted)));
      } on Object catch (e) {
        if (context.mounted) await _showFailure(context, e);
      }
    }

    /// ACC-03: "Keep" opens the More tab and "Remove" onboarding.
    Future<void> signOut() => controller.holdForSignOut(
      () => showSignOutSheet(context, email: profile.email),
    );

    final autoLabel = _frequencyLabel(l10n, state.autoFrequency);
    final offline = state.offline;
    final backUpOff = working || offline;
    final networkOff = backUpOff || newest == null;
    return ListView(
      children: [
        _AccountCard(profile: profile),
        SettingsSection(
          title: l10n.backup_driveTitle,
          children: [
            Padding(
              key: const Key('acc01.status'),
              padding: EdgeInsets.symmetric(horizontal: tokens.s16),
              child: _Status(
                state: state,
                onReview: newest == null
                    ? null
                    : () => unawaited(restore(newest)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(tokens.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    key: const Key('acc01.backUpNow'),
                    onPressed: backUpOff ? null : () => unawaited(backUpNow()),
                    icon: state.busy == AccountBusy.backingUp
                        ? SizedBox.square(
                            dimension: tokens.chipIconSize,
                            child: const CircularProgressIndicator(),
                          )
                        : const Icon(Icons.cloud_upload_outlined),
                    label: Text(l10n.backup_backUpNow),
                  ),
                  SizedBox(height: tokens.s8),
                  OutlinedButton.icon(
                    key: const Key('acc01.restore'),
                    onPressed: networkOff
                        ? null
                        : () => unawaited(restore(newest)),
                    icon: const Icon(Icons.restore),
                    label: Text(l10n.account_restore),
                  ),
                ],
              ),
            ),
            ListTile(
              key: const Key('acc01_autoBackup'),
              leading: const Icon(Icons.schedule),
              title: Text(l10n.backup_autoTitle),
              subtitle: Text(
                state.wifiOnly && state.autoFrequency != AutoBackupFrequency.off
                    ? l10n.account_autoSummaryWifi(autoLabel)
                    : autoLabel,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => unawaited(context.push(Routes.backup)),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.s8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                key: const Key('acc01.switch'),
                onPressed: backUpOff ? null : () => unawaited(switchAccount()),
                child: Text(l10n.account_switch),
              ),
              TextButton(
                key: const Key('acc01.signOut'),
                onPressed: working ? null : () => unawaited(signOut()),
                child: Text(l10n.account_signOut),
              ),
              TextButton(
                key: const Key('acc01.deleteBackups'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: networkOff ? null : () => unawaited(deleteBackups()),
                child: Text(l10n.account_deleteBackups),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(tokens.screenPadding),
          child: Text(
            l10n.account_pinFootnote,
            key: const Key('acc01_footnote'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall,
          ),
        ),
        SizedBox(height: tokens.s24),
      ],
    );
  }
}

/// Photo (or initial), name, and email. The screen never waits for the
/// photo (research R17).
class _AccountCard extends StatelessWidget {
  const new({required this.profile});

  final AccountProfile profile;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final name = profile.displayName ?? profile.email;
    return ListTile(
      key: const Key('acc01_account'),
      contentPadding: EdgeInsets.all(tokens.s16),
      leading: ProfileAvatar(profile: profile, keyPrefix: 'acc01'),
      title: Text(name, style: theme.textTheme.titleMedium),
      subtitle: profile.displayName == null ? null : Text(profile.email),
    );
  }
}

/// Last backup and the state line, with "Review" while paused. A skeleton
/// while Drive is read; an error here leaves the rest of the screen usable
/// (spec §16 ACC-01).
class _Status extends ConsumerWidget {
  const new({required this.state, required this.onReview});

  final AccountScreenState state;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    if (state.offline) {
      final at = state.lastBackupAt;
      return Column(
        key: const Key('acc01_offline'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (at != null) ...[
            Text(
              l10n.account_lastBackup(
                formatFullDateTime(
                  Epoch.toLocal(at),
                  FullDateFormatScope.of(context),
                  Localizations.localeOf(context).toString(),
                ),
              ),
              key: const Key('acc01_lastBackup'),
            ),
            SizedBox(height: tokens.s8),
          ],
          BackupStatusLine(status: state.status),
        ],
      );
    }
    final drive = state.drive ?? const AsyncLoading<List<DriveBackupEntry>>();
    switch (drive) {
      case AsyncValue(:final value?):
        final newest = value.firstOrNull;
        if (newest == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.account_noBackupYet, key: const Key('acc01_noBackup')),
              if (state.status is! BackupStatusBackedUp) ...[
                SizedBox(height: tokens.s8),
                BackupStatusLine(status: state.status),
              ],
            ],
          );
        }
        final time = formatFullDateTime(
          Epoch.toLocal(newest.meta?.createdAt ?? newest.createdAt),
          FullDateFormatScope.of(context),
          Localizations.localeOf(context).toString(),
        );
        final device = newest.meta?.deviceName ?? newest.device;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              device == null || device.isEmpty
                  ? l10n.account_lastBackup(time)
                  : l10n.account_lastBackupFrom(
                      time,
                      backupDeviceName(l10n, device),
                    ),
              key: const Key('acc01_lastBackup'),
            ),
            SizedBox(height: tokens.s8),
            BackupStatusLine(status: state.status),
            if (state.status is BackupStatusPaused && onReview != null)
              TextButton(
                key: const Key('acc01_review'),
                onPressed: onReview,
                child: Text(l10n.account_review),
              ),
          ],
        );
      case AsyncError():
        return ErrorState(
          key: const Key('acc01_statusError'),
          message: l10n.account_statusError,
          onRetry: () => unawaited(
            ref.read(accountControllerProvider.notifier).refreshDrive(),
          ),
        );
      default:
        return const DelayedSkeleton(child: SkeletonCard());
    }
  }
}
