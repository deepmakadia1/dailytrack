import 'dart:async';

import 'package:dailytrack/core/backup/presentation/backup_conflict_dialog.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:dailytrack/core/widgets/app_bottom_sheet.dart';
import 'package:dailytrack/core/widgets/erase_all_data_flow.dart';
import 'package:dailytrack/core/widgets/typed_confirm_dialog.dart';
import 'package:dailytrack/features/account/presentation/controllers/sign_out_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ACC-03 for [email]. True when the user signed out and kept the data on
/// this phone; with "Remove data" the app goes to onboarding by itself.
Future<bool> showSignOutSheet(BuildContext context, {required String email}) =>
    AppBottomSheet.show<bool>(
      context,
      title: AppLocalizations.of(context).account_signOutSheetTitle(email),
      child: const SignOutSheet(),
    ).then((signedOut) => signedOut ?? false);

/// ACC-03 Sign out (spec §16): back up the latest changes, then keep or
/// remove this phone's data. No ads.
class SignOutSheet extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final state = ref.watch(signOutControllerProvider);
    final controller = ref.read(signOutControllerProvider.notifier);

    ref.listen(signOutControllerProvider.select((s) => s.conflict), (
      _,
      conflict,
    ) {
      if (conflict == null) return;
      unawaited(
        showBackupConflictDialog(
          context,
          conflict,
        ).then((anyway) => controller.resolveConflict(backUpAnyway: anyway)),
      );
    });

    Future<void> signOut() async {
      final navigator = Navigator.of(context);
      if (state.needsTypedConfirm) {
        final typed = await TypedConfirmDialog.show(
          context,
          title: l10n.erase_typeTitle,
          word: eraseConfirmWord,
          hint: l10n.erase_typeHint,
          confirmLabel: l10n.erase_confirm,
        );
        if (!typed) return;
      }
      final keep = state.choice == SignOutChoice.keep;
      await controller.signOut();
      if (navigator.mounted) navigator.pop(keep);
    }

    final step1 = switch (state.backup) {
      SignOutBackup.checking || SignOutBackup.backingUp => Column(
        key: const Key('acc03_backingUp'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.account_signOutBackingUp),
          SizedBox(height: tokens.s8),
          const LinearProgressIndicator(),
        ],
      ),
      SignOutBackup.backedUp => Row(
        key: const Key('acc03_backedUp'),
        children: [
          Icon(Icons.cloud_done_outlined, size: tokens.iconSize),
          SizedBox(width: tokens.s8),
          Expanded(child: Text(l10n.account_statusBackedUp)),
        ],
      ),
      SignOutBackup.failed => Column(
        key: const Key('acc03_failed'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: tokens.iconSize,
                color: tokens.warning,
              ),
              SizedBox(width: tokens.s8),
              Expanded(child: Text(l10n.account_signOutBackupFailed)),
            ],
          ),
          Wrap(
            spacing: tokens.s8,
            children: [
              TextButton(
                key: const Key('acc03_tryAgain'),
                onPressed: () => unawaited(controller.backUp()),
                child: Text(l10n.common_tryAgain),
              ),
              if (!state.signedOutAnyway)
                TextButton(
                  key: const Key('acc03_signOutAnyway'),
                  onPressed: controller.signOutAnyway,
                  child: Text(l10n.account_signOutAnyway),
                ),
            ],
          ),
        ],
      ),
    };

    final remove = state.choice == SignOutChoice.remove;
    return SingleChildScrollView(
      key: const Key('acc03_sheet'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          step1,
          SizedBox(height: tokens.s16),
          RadioGroup<SignOutChoice>(
            groupValue: state.choice,
            onChanged: (c) {
              if (c != null) controller.choose(c);
            },
            child: Column(
              children: [
                RadioListTile<SignOutChoice>(
                  key: const Key('acc03_keep'),
                  contentPadding: EdgeInsets.zero,
                  value: SignOutChoice.keep,
                  title: Text(l10n.account_keepData),
                  subtitle: Text(l10n.account_keepDataHelp),
                ),
                RadioListTile<SignOutChoice>(
                  key: const Key('acc03_remove'),
                  contentPadding: EdgeInsets.zero,
                  value: SignOutChoice.remove,
                  title: Text(l10n.account_removeData),
                  subtitle: Text(l10n.account_removeDataHelp),
                ),
              ],
            ),
          ),
          SizedBox(height: tokens.s16),
          if (state.working) ...[
            const LinearProgressIndicator(),
            SizedBox(height: tokens.s12),
          ],
          FilledButton(
            key: const Key('acc03_signOut'),
            style: remove
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: state.canSignOut ? () => unawaited(signOut()) : null,
            child: Text(l10n.account_signOut),
          ),
          SizedBox(height: tokens.s8),
          TextButton(
            key: const Key('acc03_cancel'),
            onPressed: state.working
                ? null
                : () => Navigator.of(context).pop(false),
            child: Text(l10n.common_cancel),
          ),
        ],
      ),
    );
  }
}
