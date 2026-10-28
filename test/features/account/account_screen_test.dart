import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/skeleton.dart';
import 'package:dailytrack/features/account/presentation/widgets/backup_status_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../expense/expense_test_app.dart';
import 'account_test_app.dart';

/// ACC-01 Account (spec §16, feature 010 US2, T052; feature 011 T042).
/// ACC-01 is for an account signed in with Google only: the router's rule 7
/// closes it back to SET-01 otherwise. Guest sign-in is in
/// guest_sign_in_test.dart.
void main() {
  const networkActions = [
    'acc01.backUpNow',
    'acc01.restore',
    'acc01.switch',
    'acc01.deleteBackups',
  ];

  VoidCallback? onPressed(WidgetTester tester, String key) =>
      tester.widget<ButtonStyleButton>(find.byKey(Key(key))).onPressed;

  testWidgets('ACC-01 shows name, email, photo or initial, "Backed up to '
      'Google" with the last backup time and device, and all actions', (
    tester,
  ) async {
    await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
    expect(find.byKey(const Key('acc01_initial')), findsOneWidget);
    expect(find.textContaining('Last backup: '), findsOneWidget);
    expect(find.textContaining('· Redmi Note 12'), findsOneWidget);
    expect(find.text('Backed up to Google'), findsOneWidget);
    expect(find.text('Your app lock PIN is never backed up.'), findsOneWidget);
    for (final key in [...networkActions, 'acc01.signOut']) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
      expect(onPressed(tester, key), isNotNull, reason: key);
    }
    expect(find.text('Sign in with Google'), findsNothing);
  });

  testWidgets('ACC-01 the state line has an icon as well as text, never '
      'color alone', (tester) async {
    await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    expect(
      find.descendant(
        of: find.byType(BackupStatusLine),
        matching: find.byIcon(Icons.cloud_done_outlined),
      ),
      findsOneWidget,
    );
  });

  testWidgets("ACC-01 can't be opened as a guest; the SET-01 guest card "
      'starts guest sign-in instead (rule 7)', (tester) async {
    final world = await pumpAccountApp(tester, initial: guest);
    expect(locationOf(tester), Routes.more);
    expect(find.byKey(const Key('acc01.backUpNow')), findsNothing);
    expect(find.byKey(const Key('set01_accountGuest')), findsOneWidget);
    expect(world.auth.signIns, 0);
    expect(world.drive.calls, isEmpty);
  });

  testWidgets('ACC-01 opens from the SET-01 account card', (tester) async {
    await pumpAccountApp(tester, location: Routes.more);
    // Pushed above SET-01 (the router's location stays /more).
    await tapKey(tester, 'set01_accountGoogle');
    expect(find.byKey(const Key('acc01.backUpNow')), findsOneWidget);
  });

  testWidgets('ACC-01 closes to SET-01 when the account stops being signed '
      'in while it is open', (tester) async {
    final world = await pumpAccountApp(tester);
    expect(find.byKey(const Key('acc01.backUpNow')), findsOneWidget);
    world.settings.replace(guest);
    await tester.pumpAndSettle();
    expect(locationOf(tester), Routes.more);
    expect(world.reset.calls, 0);
  });

  testWidgets('ACC-01 while Drive is read, the account shows at once and '
      'the status area is a skeleton', (tester) async {
    final gate = Completer<void>();
    await pumpAccountApp(
      tester,
      location: null,
      arrange: (w) {
        w.drive
          ..seed(meta: otherPhoneMeta())
          ..listGate = gate;
      },
    );
    routerOf(tester).go(Routes.account);
    await tester.pump();
    // The page builds, then the skeleton shows after 300 ms (§15.6).
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('acc01.status')),
        matching: find.byType(SkeletonCard),
      ),
      findsOneWidget,
    );
    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(SkeletonCard), findsNothing);
    expect(find.byKey(const Key('acc01_lastBackup')), findsOneWidget);
  });

  testWidgets('ACC-01 a Drive read error shows in the status area with "Try '
      'again"; the rest of the screen stays usable', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.failNext = const DriveUnavailable('500'),
    );
    expect(find.byKey(const Key('acc01_statusError')), findsOneWidget);
    expect(find.text("Couldn't read your backups."), findsOneWidget);
    expect(onPressed(tester, 'acc01.backUpNow'), isNotNull);
    expect(onPressed(tester, 'acc01.signOut'), isNotNull);
    world.drive.seed(meta: otherPhoneMeta());
    await tapKey(tester, 'acc01_statusError');
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc01_statusError')), findsNothing);
    expect(find.byKey(const Key('acc01_lastBackup')), findsOneWidget);
  });

  testWidgets('ACC-01 "Back up now" with a newer backup from another device '
      'shows the warning, and "Cancel" uploads nothing', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) =>
          w.backup.conflict = NewerFromOtherDevice(otherPhoneMeta()),
    );
    await tapKey(tester, 'acc01.backUpNow');
    expect(find.textContaining('A newer backup from Redmi Note 12'), findsOne);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(world.backup.driveBackups, 0);

    await tapKey(tester, 'acc01.backUpNow');
    await tester.tap(find.text('Back up anyway'));
    await tester.pumpAndSettle();
    expect(world.backup.driveBackups, 1);
    expect(find.text('Backed up to Google Drive'), findsOneWidget);
  });

  testWidgets('ACC-01 "Back up now" is a manual backup that ignores Wi-Fi '
      'only, and no interstitial follows', (tester) async {
    final ads = FakeAdService();
    final world = await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(autoBackupWifiOnly: true),
      network: FakeNetworkStateSource(metered: true),
      ads: ads,
    );
    await tapKey(tester, 'acc01.backUpNow');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(world.backup.driveBackups, 1);
    expect(world.backup.conflicts, [ConflictMode.ask]);
    expect(ads.triggers, isEmpty);
  });

  testWidgets('ACC-01 a failed "Back up now" shows "Backup failed" with the '
      'error message', (tester) async {
    await pumpAccountApp(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.backup.error = const DriveQuotaExceeded();
      },
    );
    await tapKey(tester, 'acc01.backUpNow');
    // The error dialog, then the state line keeps the reason.
    await tester.tap(
      find.descendant(
        of: find.byKey(const Key('backup_error')),
        matching: find.byType(TextButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Backup failed'), findsOneWidget);
    expect(find.byKey(const Key('acc01_failureDetail')), findsOneWidget);
  });

  testWidgets('ACC-01 with "Encrypt backup" on and no password, the state '
      'says "Backup failed: set your backup password in Backup and restore"', (
    tester,
  ) async {
    await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(backupEncrypt: true),
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
      overrides: [
        backupPasswordStoreProvider.overrideWithValue(
          FakeBackupPasswordStore(),
        ),
      ],
    );
    expect(
      find.text(
        'Backup failed: set your backup password in Backup and restore',
      ),
      findsOneWidget,
    );
  });

  testWidgets('ACC-01 a background backup waiting on a metered network says '
      '"Waiting for Wi-Fi"', (tester) async {
    await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(
        autoBackupWifiOnly: true,
        lastBackupAt: 1792540800000,
        lastBackgroundBackupAt: 1792540900000,
      ),
      network: FakeNetworkStateSource(metered: true),
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    expect(find.text('Waiting for Wi-Fi'), findsOneWidget);
  });

  testWidgets('ACC-01 "Delete my backups" removes every backup file in the '
      'app folder and leaves local data and the sign-in in place', (
    tester,
  ) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) {
        w.drive
          ..seed(meta: otherPhoneMeta())
          ..seed(kind: BackupKind.auto)
          ..seed();
      },
    );
    await world.settings.setLastKnownDriveBackup(at: 1, deviceId: 'x');
    await tapKey(tester, 'acc01.deleteBackups');
    expect(
      find.text(
        'Delete all 3 DailyTrack backups from me@example.com? Data on this '
        "phone stays. This can't be undone.",
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Delete backups'));
    await tester.pumpAndSettle();
    expect(world.drive.files, isEmpty);
    expect(world.reset.calls, 0);
    expect(world.settings.current.backupAccountEmail, 'me@example.com');
    expect(world.settings.current.lastKnownDriveBackupAt, isNull);
    expect(find.text('Your backups were deleted'), findsOneWidget);
    expect(find.text('No backup in this account yet'), findsOneWidget);
  });

  testWidgets('ACC-01 cancelling "Delete my backups" deletes nothing', (
    tester,
  ) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    await tapKey(tester, 'acc01.deleteBackups');
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(world.drive.files, hasLength(1));
    expect(world.drive.calls, isNot(contains('deleteAll')));
  });

  group('Switch account', () {
    testWidgets('ACC-01 Switch account backs up to the old account before '
        'signing out and never removes local data', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInResult = const AccountProfile(
          email: 'new@example.com',
          displayName: 'Ravi',
        ),
      );
      await tapKey(tester, 'acc01.switch');
      // One backup to the old account, then the first one for the new.
      expect(world.backup.conflicts.first, ConflictMode.ask);
      expect(world.auth.signOuts, 1);
      expect(world.auth.signIns, 1);
      expect(world.backup.driveBackups, 2);
      expect(world.reset.calls, 0);
      expect(world.restore.applied, isEmpty);
      expect(world.settings.current.backupAccountEmail, 'new@example.com');
      expect(locationOf(tester), Routes.account);
      expect(find.text('new@example.com'), findsOneWidget);
      expect(find.text('Signed in. Your data is backed up.'), findsOneWidget);
    });

    testWidgets('ACC-01 switching to an account with a backup opens ACC-02, '
        "which can't be dismissed", (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInResult = const AccountProfile(
          email: 'new@example.com',
        ),
      );
      world.drive.seed(meta: otherPhoneMeta());
      await tapKey(tester, 'acc01.switch');
      expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
      expect(find.byKey(const Key('acc02_close')), findsNothing);
      expect(world.reset.calls, 0);
    });

    testWidgets('ACC-01 when that backup fails, "Switch anyway" still keeps '
        'the data; cancelling it changes nothing', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.backup.error = const DriveOffline(),
      );
      await tapKey(tester, 'acc01.switch');
      expect(find.text("Couldn't back up first"), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(world.auth.signOuts, 0);
      expect(world.settings.current.backupAccountEmail, 'me@example.com');

      await tapKey(tester, 'acc01.switch');
      world.backup.error = null;
      await tester.tap(find.text('Switch anyway'));
      await tester.pumpAndSettle();
      expect(world.auth.signOuts, 1);
      expect(world.auth.signIns, 1);
      expect(world.reset.calls, 0);
    });

    testWidgets('ACC-01 declining the conflict warning before switching '
        'counts as a failed backup and offers "Switch anyway"', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) =>
            w.backup.conflict = NewerFromOtherDevice(otherPhoneMeta()),
      );
      await tapKey(tester, 'acc01.switch');
      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Cancel'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text("Couldn't back up first"), findsOneWidget);
      expect(world.backup.driveBackups, 0);
      expect(world.auth.signOuts, 0);
    });

    testWidgets('FR-012 Switch account with a cancelled chooser: authMode '
        'becomes guest, every local row is kept, and ACC-01 closes back to '
        'SET-01 with the guest card', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInResult = const DriveAuthRequired(),
      );
      await tapKey(tester, 'acc01.switch');
      expect(world.auth.signOuts, greaterThan(0));
      expect(world.settings.current.authMode, AuthMode.guest);
      expect(world.settings.current.backupAccountEmail, isNull);
      expect(world.reset.calls, 0);
      expect(world.restore.applied, isEmpty);
      expect(locationOf(tester), Routes.more);
      expect(find.byKey(const Key('acc01.backUpNow')), findsNothing);
      expect(find.byKey(const Key('set01_accountGuest')), findsOneWidget);
    });

    testWidgets('ACC-01 while the chooser is open, ACC-01 stays open and the '
        'mode stays google', (tester) async {
      final gate = Completer<void>();
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInGate = gate,
      );
      final finder = find.byKey(const Key('acc01.switch'));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(world.settings.current.authMode, AuthMode.google);
      expect(locationOf(tester), Routes.account);
      gate.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('ACC-01 a failed sign-in after switching says "Couldn\'t sign '
        'in" on the More tab, with data kept', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInResult = const DriveUnavailable('500'),
      );
      await tapKey(tester, 'acc01.switch');
      expect(world.settings.current.backupAccountEmail, isNull);
      expect(world.reset.calls, 0);
      expect(locationOf(tester), Routes.more);
      expect(
        find.text("Couldn't sign in. Check your connection and try again."),
        findsOneWidget,
      );
    });
  });

  group('Offline', () {
    testWidgets('ACC-01 offline, the network actions are disabled with an '
        'explanation and Sign out still works', (tester) async {
      final world = await pumpAccountApp(
        tester,
        initial: signedIn.copyWith(
          lastBackupAt: 1792540800000,
          dataChangeCounter: 3,
        ),
        network: FakeNetworkStateSource(online: false),
      );
      expect(find.text('Asha Patel'), findsOneWidget);
      expect(find.text('me@example.com'), findsOneWidget);
      expect(
        find.text("You're offline. Backups resume when you're back online."),
        findsOneWidget,
      );
      expect(find.byKey(const Key('acc01_lastBackup')), findsOneWidget);
      for (final key in networkActions) {
        expect(onPressed(tester, key), isNull, reason: key);
      }
      expect(world.drive.calls, isEmpty, reason: 'Drive is not read offline');

      // Sign out opens ACC-03, which goes straight to the failed state.
      await tapKey(tester, 'acc01.signOut');
      expect(find.byKey(const Key('acc03_failed')), findsOneWidget);
      expect(world.backup.driveBackups, 0);
      expect(world.backup.conflicts, isEmpty);
      await tapKey(tester, 'acc03_signOutAnyway');
      await tapKey(tester, 'acc03_signOut');
      expect(world.auth.signOuts, 1);
      expect(world.settings.current.backupAccountEmail, isNull);
      expect(world.reset.calls, 0);
      // Signing out sets authMode none, so the redirect opens AUTH-01
      // (feature 011 rule 3b).
      expect(world.settings.current.authMode, AuthMode.none);
      expect(locationOf(tester), Routes.login);
    });

    testWidgets('ACC-01 reading Drive failing with "offline" shows the '
        'offline state, not an error', (tester) async {
      await pumpAccountApp(
        tester,
        arrange: (w) => w.drive.failNext = const DriveOffline(),
      );
      expect(
        find.text("You're offline. Backups resume when you're back online."),
        findsOneWidget,
      );
      expect(find.byKey(const Key('acc01_statusError')), findsNothing);
      expect(onPressed(tester, 'acc01.backUpNow'), isNull);
      expect(onPressed(tester, 'acc01.signOut'), isNotNull);
    });

    testWidgets('ACC-01 back online on resume, the actions come back', (
      tester,
    ) async {
      final network = FakeNetworkStateSource(online: false);
      final world = await pumpAccountApp(
        tester,
        network: network,
        arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
      );
      expect(onPressed(tester, 'acc01.backUpNow'), isNull);
      network.online = true;
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(onPressed(tester, 'acc01.backUpNow'), isNotNull);
      expect(onPressed(tester, 'acc01.restore'), isNotNull);
      expect(world.drive.calls, contains('list'));
      expect(find.text('Backed up to Google'), findsOneWidget);
    });
  });

  testWidgets('ACC-01 "Backup paused" offers Review, which opens ACC-02 for '
      'the newest backup', (tester) async {
    await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(autoBackupPausedByConflict: true),
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    expect(
      find.text('Backup paused: a newer backup from another phone exists'),
      findsOneWidget,
    );
    await tapKey(tester, 'acc01_review');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(find.byKey(const Key('acc02_close')), findsOneWidget);
  });

  testWidgets('token expiry: when Drive refuses the sign-in, the account is '
      'signed out with data kept and ACC-01 closes to the More tab, saying '
      'to sign in again', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) => w.backup.error = const DriveAuthRequired(),
    );
    await tapKey(tester, 'acc01.backUpNow');
    expect(world.settings.current.backupAccountEmail, isNull);
    expect(world.reset.calls, 0);
    expect(locationOf(tester), Routes.more);
    expect(find.byKey(const Key('acc01_sessionExpired')), findsOneWidget);
  });
}
