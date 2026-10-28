import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../account/account_test_app.dart';
import '../expense/expense_test_app.dart' show locationOf;
import 'login_test_app.dart';

/// AUTH-01 "Continue with Google" (feature 011 T025, spec §6 AUTH-01,
/// research R9), with fake Google sign-in and Drive.
void main() {
  void expectNothingWritten(AccountWorld world) {
    final s = world.settings.current;
    expect(s.authMode, AuthMode.none);
    expect(s.backupAccountEmail, isNull);
    expect(s.accountDisplayName, isNull);
    expect(s.autoBackupFrequency, AutoBackupFrequency.off);
    expect(s.finishSetupPending, isFalse);
    expect(world.restore.applied, isEmpty);
    expect(world.backup.driveBackups, 0);
  }

  testWidgets('AUTH-01 "Continue with Google" on an account with no backup '
      'sets authMode = google, turns Auto backup to Daily if it was Off, runs '
      'a first backup, and opens Home', (tester) async {
    final world = await pumpLogin(tester);
    await tapKey(tester, 'auth01_google');

    final s = world.settings.current;
    expect(s.authMode, AuthMode.google);
    expect(s.backupAccountEmail, 'me@example.com');
    expect(s.autoBackupFrequency, AutoBackupFrequency.daily);
    expect(world.backup.driveBackups, 1, reason: 'one manual first backup');
    expect(world.scheduler.periodic, isNotEmpty);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AUTH-01 a Weekly Auto backup stays Weekly', (tester) async {
    final world = await pumpLogin(
      tester,
      initial: onLogin.copyWith(
        autoBackupFrequency: AutoBackupFrequency.weekly,
      ),
    );
    await tapKey(tester, 'auth01_google');
    expect(
      world.settings.current.autoBackupFrequency,
      AutoBackupFrequency.weekly,
    );
  });

  testWidgets('AUTH-01 "Continue with Google" on an account with a backup and '
      'no user data on the phone restores the newest backup without a choice '
      "sheet and opens Home with the backup's data, language, currency, and "
      'modules; Restore purchase runs', (tester) async {
    final pro = FakeProStore(ownership: OwnershipCheck.owned);
    final world = await pumpLogin(
      tester,
      pro: pro,
      arrange: (w) {
        w.drive
          ..seed(meta: otherPhoneMeta(at: 1792540700000))
          ..seed(meta: otherPhoneMeta());
        restoreWritesBackup(w);
      },
    );
    await tapKey(tester, 'auth01_google');

    expect(find.byKey(const Key('acc02_sheet')), findsNothing);
    expect(world.restore.applied, [('f1', true)], reason: 'the newest');
    final s = world.settings.current;
    expect(s.authMode, AuthMode.google);
    expect(s.locale, 'hi');
    expect(s.currencyCode, 'USD');
    expect(s.enabledModules, ['habit']);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(pro.ownershipQueries, greaterThan(0), reason: 'Restore purchase');
    expect(s.removeAdsPurchased, isTrue);
    // After the "Restored …" counts snackbar.
    expect(find.byKey(const Key('acc02_restored')), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('auth01_proRestored')), findsOneWidget);
    expect(world.backup.driveBackups, 0, reason: 'nothing to back up');
  });

  testWidgets('AUTH-01 the no-data restore runs behind the full-screen '
      '"Restoring your data…" view, which back cannot close', (tester) async {
    final gate = Completer<void>();
    final world = await pumpLogin(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.restore.downloadGate = gate;
      },
    );
    await tester.tap(find.byKey(const Key('auth01_google')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byKey(const Key('auth01_restoring')), findsOneWidget);
    expect(find.text('Restoring your data…'), findsWidgets);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byKey(const Key('auth01_restoring')), findsOneWidget);
    expect(world.settings.current.authMode, AuthMode.none);
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AUTH-01 an encrypted backup asks for its password first', (
    tester,
  ) async {
    final world = await pumpLogin(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta(encrypted: true));
        w.restore.encryptedWith = 'secret';
      },
    );
    await tapKey(tester, 'auth01_google');
    expect(find.byKey(const Key('restore_password_field')), findsOneWidget);
    expect(world.restore.applied, isEmpty);
    expect(world.settings.current.authMode, AuthMode.none);

    await tester.enterText(
      find.byKey(const Key('restore_password_field')),
      'secret',
    );
    await tapKey(tester, 'restore_password_open');
    expect(world.restore.applied, hasLength(1));
    expect(world.settings.current.authMode, AuthMode.google);
    expect(world.settings.current.backupEncrypt, isTrue);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AUTH-01 "Continue with Google" with user data on the phone '
      "opens ACC-02 before Home, and the sheet can't be dismissed without a "
      'choice', (tester) async {
    final world = await pumpLogin(
      tester,
      hasData: true,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    await tapKey(tester, 'auth01_google');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
    // Still choosing: not signed in yet, so nothing backs up on its own.
    expect(world.settings.current.authMode, AuthMode.none);
    expect(world.scheduler.periodic, isEmpty);

    // Tapping outside, dragging down, and back all leave it open.
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    await tester.drag(
      find.byKey(const Key('acc02_sheet')),
      const Offset(0, 600),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
  });

  for (final choice in ['acc02_restore', 'acc02_keep']) {
    testWidgets('AUTH-01 after ACC-02 "$choice", authMode is google and Home '
        'opens', (tester) async {
      final world = await pumpLogin(
        tester,
        hasData: true,
        arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
      );
      await tapKey(tester, 'auth01_google');
      await tapKey(tester, choice);
      expect(world.settings.current.authMode, AuthMode.google);
      expect(find.byType(HomeScreen), findsOneWidget);
      if (choice == 'acc02_keep') {
        expect(world.restore.kept, ['f0']);
        expect(world.restore.applied, isEmpty);
      } else {
        expect(world.restore.applied, [('f0', false)]);
      }
    });
  }

  for (final (label, failure, text) in [
    (
      'cancelled',
      const DriveAuthRequired(),
      'Sign-in was cancelled. Try again or continue as a guest.',
    ),
    (
      'failed',
      const DriveUnavailable('500'),
      "Couldn't sign in. Check your connection and try again.",
    ),
  ]) {
    testWidgets('AUTH-01 $label sign-in stays on AUTH-01 with the inline error '
        'and "Try again"; authMode stays none and no data or account key is '
        'written', (tester) async {
      final world = await pumpLogin(
        tester,
        arrange: (w) {
          w.drive.seed(meta: otherPhoneMeta());
          w.auth.signInResult = failure;
        },
      );
      await tapKey(tester, 'auth01_google');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text(text), findsOneWidget);
      expect(find.byKey(const Key('auth01_tryAgain')), findsOneWidget);
      expect(find.byKey(const Key('auth01_guest')), findsOneWidget);
      expectNothingWritten(world);
      expect(world.drive.calls, isEmpty);

      // "Try again" reopens Google Sign-In.
      await tapKey(tester, 'auth01_tryAgain');
      expect(world.auth.signIns, 2);
      expectNothingWritten(world);
    });
  }

  testWidgets('AUTH-01 listing Drive failing after the chooser clears the '
      'saved keys again and shows the failure', (tester) async {
    final world = await pumpLogin(
      tester,
      arrange: (w) => w.drive.failNext = const DriveOffline(),
    );
    await tapKey(tester, 'auth01_google');
    expect(
      find.text("Couldn't sign in. Check your connection and try again."),
      findsOneWidget,
    );
    expectNothingWritten(world);
  });

  testWidgets('AUTH-01 Offline, "Continue with Google" shows the offline '
      'inline error and writes nothing, and "Continue as guest" still opens '
      'Home', (tester) async {
    final world = await pumpLogin(
      tester,
      network: FakeNetworkStateSource(online: false),
    );
    await tapKey(tester, 'auth01_google');
    expect(
      find.text(
        "You're offline. Connect to the internet to sign in with Google, or "
        'continue as a guest.',
      ),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auth01_tryAgain')), findsOneWidget);
    expect(world.auth.calls, isEmpty);
    expect(world.drive.calls, isEmpty);
    expectNothingWritten(world);

    await tapKey(tester, 'auth01_guest');
    expect(world.settings.current.authMode, AuthMode.guest);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AUTH-01 A failed restore after sign-in leaves this phone data '
      'unchanged and offers "Try again" and "Continue without restoring."', (
    tester,
  ) async {
    final world = await pumpLogin(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.restore.failApply = const DriveOffline();
      },
    );
    await tapKey(tester, 'auth01_google');
    // ACC-02's own failure dialog: Cancel gives up this attempt.
    expect(find.byKey(const Key('acc02_restoreFailed')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('auth01_restoreFailed')), findsOneWidget);
    expect(
      find.text("Couldn't restore. Your data on this phone wasn't changed."),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auth01_restoreTryAgain')), findsOneWidget);
    expect(
      find.byKey(const Key('auth01_continueWithoutRestoring')),
      findsOneWidget,
    );
    expect(world.restore.applied, isEmpty, reason: 'rows unchanged');
    expect(world.settings.current.authMode, AuthMode.none);

    // "Try again" runs the restore check again; this time it works.
    await tapKey(tester, 'auth01_restoreTryAgain');
    expect(world.restore.applied, hasLength(1));
    expect(world.settings.current.authMode, AuthMode.google);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('AUTH-01 "Continue without restoring" sets authMode = google '
      "with this phone's data as it is", (tester) async {
    final world = await pumpLogin(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.restore.failDownload = const DriveOffline();
      },
    );
    await tapKey(tester, 'auth01_google');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tapKey(tester, 'auth01_continueWithoutRestoring');

    final s = world.settings.current;
    expect(s.authMode, AuthMode.google);
    expect(s.backupAccountEmail, 'me@example.com');
    expect(s.autoBackupFrequency, AutoBackupFrequency.daily);
    expect(world.restore.applied, isEmpty);
    expect(world.backup.driveBackups, 0, reason: 'no upload over the backup');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(locationOf(tester), Routes.home);
  });

  testWidgets('AUTH-01 while signing in, "Continue with Google" shows progress '
      'and both buttons are disabled', (tester) async {
    final gate = Completer<void>();
    final world = await pumpLogin(
      tester,
      arrange: (w) => w.auth.signInGate = gate,
    );
    await tester.tap(find.byKey(const Key('auth01_google')));
    await tester.pump();
    final google = tester.widget<FilledButton>(
      find.byKey(const Key('auth01_google')),
    );
    final guest = tester.widget<OutlinedButton>(
      find.byKey(const Key('auth01_guest')),
    );
    expect(google.onPressed, isNull);
    expect(guest.onPressed, isNull);
    expect(
      find.descendant(
        of: find.byKey(const Key('auth01_google')),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    // A guest tap now does nothing.
    await tester.tap(find.byKey(const Key('auth01_guest')));
    await tester.pump();
    expect(world.settings.current.authMode, AuthMode.none);

    gate.complete();
    await tester.pumpAndSettle();
    expect(world.settings.current.authMode, AuthMode.google);
  });
}
