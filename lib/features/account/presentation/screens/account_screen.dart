import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/backup_status_policy.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/backup/presentation/backup_conflict_dialog.dart';
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
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:dailytrack/features/account/presentation/widgets/sign_out_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// ACC-01 Account (spec §16, feature 010 contracts/screens.md): signed out
/// is the empty state; signed in shows the account, the backup status,
/// Back up now, Restore (ACC-02), Auto backup, Switch account, Sign out
/// (ACC-03), and Delete my backups. No ads (FR-049).
class AccountScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(accountControllerProvider);
    return AppScaffold(
      title: l10n.account_title,
      padBody: false,
      body: switch (async) {
        AsyncValue(:final value?) when value.profile == null => _SignedOut(
          state: value,
        ),
        AsyncValue(:final value?) => _SignedIn(state: value),
        AsyncError() => ErrorState(
          message: l10n.settings_loadError,
          onRetry: ref.read(accountControllerProvider.notifier).retry,
        ),
        _ => const DelayedSkeleton(child: SkeletonList(itemCount: 4)),
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

/// A failed Drive action: an expired sign-in says so (the account is then
/// signed out, research R2); anything else is a plain-language error.
Future<void> _showFailure(BuildContext context, Object error) async {
  final l10n = AppLocalizations.of(context);
  if (error is DriveAuthRequired) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('acc01_sessionExpired'),
        content: Text(l10n.account_sessionExpired),
      ),
    );
    return;
  }
  await showBackupError(context, l10n.backup_failedTitle, error);
}

/// What follows a sign-in, from "Sign in with Google" or "Switch account".
Future<void> _afterSignIn(BuildContext context, SignInOutcome outcome) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  switch (outcome) {
    case SignInCancelled():
      break;
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
      if (context.mounted) await _showFailure(context, error);
  }
}

/// "Sign in with Google": the outcome's next step, or "Couldn't sign in".
Future<void> _signIn(BuildContext context, WidgetRef ref) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  // Signing in swaps this part of the screen, so what follows is shown
  // from the navigator, which stays.
  final stable = Navigator.of(context).context;
  final SignInOutcome outcome;
  try {
    outcome = await ref.read(accountControllerProvider.notifier).signIn();
  } on Object {
    messenger.showSnackBar(
      SnackBar(
        key: const Key('acc01_signInFailed'),
        content: Text(l10n.account_signInFailed),
      ),
    );
    return;
  }
  if (stable.mounted) await _afterSignIn(stable, outcome);
}

/// The empty state: why to sign in, and the one primary button.
class _SignedOut extends ConsumerWidget {
  const new({required this.state});

  final AccountScreenState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final working = state.busy != AccountBusy.none;
    final expired = switch (state.account) {
      SignedOut(:final expired) => expired,
      SignedIn() => false,
    };

    Widget point(IconData icon, String text) => Padding(
      padding: EdgeInsets.only(bottom: tokens.s12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: tokens.iconSize, color: theme.colorScheme.primary),
          SizedBox(width: tokens.s12),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );

    return ListView(
      padding: EdgeInsets.all(tokens.screenPadding),
      children: [
        if (expired) ...[
          Row(
            key: const Key('acc01_expired'),
            children: [
              Icon(
                Icons.error_outline,
                size: tokens.iconSize,
                color: tokens.warning,
              ),
              SizedBox(width: tokens.s8),
              Expanded(child: Text(l10n.account_sessionExpired)),
            ],
          ),
          SizedBox(height: tokens.s16),
        ],
        SizedBox(height: tokens.s24),
        ExcludeSemantics(
          child: Icon(
            Icons.cloud_upload_outlined,
            size: tokens.s48,
            color: theme.colorScheme.primary,
          ),
        ),
        SizedBox(height: tokens.s16),
        Text(
          l10n.account_signedOutTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge,
        ),
        SizedBox(height: tokens.s24),
        point(Icons.cloud_outlined, l10n.account_pointDrive),
        point(Icons.phone_android, l10n.account_pointRestore),
        point(Icons.check_circle_outline, l10n.account_pointOptional),
        SizedBox(height: tokens.s16),
        if (!state.driveAvailable)
          Text(
            l10n.backup_driveUnavailable,
            key: const Key('acc01_driveUnavailable'),
            textAlign: TextAlign.center,
          )
        else ...[
          if (working) ...[
            const LinearProgressIndicator(),
            SizedBox(height: tokens.s16),
          ],
          FilledButton.icon(
            key: const Key('acc01.signIn'),
            onPressed: working ? null : () => unawaited(_signIn(context, ref)),
            icon: const Icon(Icons.login),
            label: Text(l10n.account_signIn),
          ),
        ],
        SizedBox(height: tokens.s16),
        Text(
          l10n.account_pinFootnote,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
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
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.account_signInFailed)),
        );
        return;
      }
      if (stable.mounted) await _afterSignIn(stable, outcome);
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

    Future<void> signOut() async {
      final messenger = ScaffoldMessenger.of(context);
      // Signing out swaps this part of the screen; the sheet's own context
      // closes it.
      final kept = await showSignOutSheet(context, email: profile.email);
      if (kept) {
        messenger.showSnackBar(
          SnackBar(
            key: const Key('acc01_signedOut'),
            content: Text(l10n.account_signedOut),
          ),
        );
      }
    }

    final autoLabel = _frequencyLabel(l10n, state.autoFrequency);
    final networkOff = working || newest == null;
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
                    onPressed: working ? null : () => unawaited(backUpNow()),
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
                onPressed: working ? null : () => unawaited(switchAccount()),
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
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final name = profile.displayName ?? profile.email;
    final initial = Container(
      key: const Key('acc01_initial'),
      width: tokens.avatarSize,
      height: tokens.avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.characters.first.toUpperCase(),
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
        ),
      ),
    );
    final url = profile.photoUrl;
    final avatar = url == null
        ? initial
        : ClipOval(
            child: Image.network(
              url,
              key: const Key('acc01_photo'),
              width: tokens.avatarSize,
              height: tokens.avatarSize,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : initial,
              errorBuilder: (_, _, _) => initial,
            ),
          );
    return ListTile(
      key: const Key('acc01_account'),
      contentPadding: EdgeInsets.all(tokens.s16),
      leading: Semantics(
        label: l10n.account_photoOf(name),
        image: true,
        excludeSemantics: true,
        child: avatar,
      ),
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
    final drive = state.drive ?? const AsyncLoading<List<DriveBackupEntry>>();
    switch (drive) {
      case AsyncValue(:final value?):
        final newest = value.firstOrNull;
        if (newest == null) {
          return Text(
            l10n.account_noBackupYet,
            key: const Key('acc01_noBackup'),
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
                  : l10n.account_lastBackupFrom(time, device),
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
