import 'dart:async';

import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/account_sign_in.dart';
import 'package:dailytrack/core/backup/presentation/restore_flow.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/account/presentation/widgets/restore_choice_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The app scopes where a guest sign-in is running; a second tap there does
/// nothing.
final Expando<bool> _running = Expando<bool>('guestSignInRunning');

/// Guest sign-in (spec §16 "Guest sign-in"), the one flow behind the SET-01
/// account card, the SET-02 Drive card, and ACC-04 "Sign in with Google
/// instead" (feature 011 research R11). Signing in sets `authMode = google`
/// at once and Auto backup Daily if it was Off. Then: no backup on the
/// account → this phone is backed up ("Signed in. Your data is backed
/// up."); a backup → ACC-02, which can't be dismissed (or, with no user data
/// here, the newest backup restored without the sheet). Cancelled: nothing
/// changed. Failed: "Couldn't sign in…". Offline: "Connect to the internet
/// to sign in with Google" and no request.
Future<void> runGuestSignIn(BuildContext context) async {
  final container = ProviderScope.containerOf(context, listen: false);
  if (_running[container] ?? false) return;
  _running[container] = true;
  try {
    await _signIn(context, container.read(accountSignInProvider));
  } finally {
    _running[container] = false;
  }
}

Future<void> _signIn(BuildContext context, AccountSignIn signIn) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final SignInOutcome outcome;
  try {
    outcome = await signIn.run();
  } on Object {
    messenger.showSnackBar(
      SnackBar(
        key: const Key('backup_signInFailed'),
        content: Text(l10n.account_signInFailed),
      ),
    );
    return;
  }
  switch (outcome) {
    case SignInCancelled():
      break;
    case SignInOffline():
      messenger.showSnackBar(
        SnackBar(
          key: const Key('backup_signInOffline'),
          content: Text(l10n.account_signInOffline),
        ),
      );
    case SignedInAndBackedUp():
      messenger.showSnackBar(
        SnackBar(
          key: const Key('account_signedInBackedUp'),
          content: Text(l10n.account_signedInBackedUp),
        ),
      );
    case SignedInWithBackups(:final newest):
      if (context.mounted) {
        await showRestoreChoiceFor(context, newest: newest, afterSignIn: true);
      }
    case SignedInBackupFailed(:final error):
      // Still signed in; auto backup tries again (spec §16).
      if (context.mounted) {
        await showBackupError(context, l10n.backup_failedTitle, error);
      }
  }
}
