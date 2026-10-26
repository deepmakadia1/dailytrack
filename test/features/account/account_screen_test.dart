import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_store.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import 'account_test_app.dart';

/// ACC-01 Account (spec §16, feature 010 US2, T052). The offline criterion
/// waits for the network state source (task T057).
void main() {
  final signedOut = signedIn.copyWith(
    backupAccountEmail: null,
    accountDisplayName: null,
    autoBackupFrequency: AutoBackupFrequency.off,
  );

  testWidgets('ACC-01 signed out shows only the sign-in content', (
    tester,
  ) async {
    await pumpAccountApp(tester, initial: signedOut);
    expect(find.text('Back up with your Google account'), findsOneWidget);
    expect(find.text('Your app lock PIN is never backed up.'), findsOneWidget);
    expect(find.byKey(const Key('acc01.signIn')), findsOneWidget);
    for (final key in [
      'acc01.backUpNow',
      'acc01.restore',
      'acc01.switch',
      'acc01.signOut',
      'acc01.deleteBackups',
    ]) {
      expect(find.byKey(Key(key)), findsNothing, reason: key);
    }
  });

  testWidgets('ACC-01 signed in shows name, email, photo or initial, last '
      'backup time and device, and all actions', (tester) async {
    await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    expect(find.text('Asha Patel'), findsOneWidget);
    expect(find.text('me@example.com'), findsOneWidget);
    expect(find.byKey(const Key('acc01_initial')), findsOneWidget);
    expect(find.textContaining('Last backup: '), findsOneWidget);
    expect(find.textContaining('· Redmi Note 12'), findsOneWidget);
    for (final key in [
      'acc01.backUpNow',
      'acc01.restore',
      'acc01.switch',
      'acc01.signOut',
      'acc01.deleteBackups',
    ]) {
      expect(find.byKey(Key(key)), findsOneWidget, reason: key);
    }
    expect(find.byKey(const Key('acc01.signIn')), findsNothing);
  });

  testWidgets('ACC-01 a Drive read error shows in the status area with "Try '
      'again"; the rest of the screen stays usable', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) => w.drive.failNext = const DriveUnavailable('500'),
    );
    expect(find.byKey(const Key('acc01_statusError')), findsOneWidget);
    expect(find.text("Couldn't read your backups."), findsOneWidget);
    expect(
      tester
          .widget<ButtonStyleButton>(find.byKey(const Key('acc01.backUpNow')))
          .onPressed,
      isNotNull,
    );
    world.drive.seed(meta: otherPhoneMeta());
    await tapKey(tester, 'acc01_statusError');
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc01_statusError')), findsNothing);
    expect(find.byKey(const Key('acc01_lastBackup')), findsOneWidget);
  });

  testWidgets('ACC-01 signing in to an account without a backup makes a '
      'first backup, and Auto backup becomes Daily if it was Off', (
    tester,
  ) async {
    final world = await pumpAccountApp(tester, initial: signedOut);
    await tapKey(tester, 'acc01.signIn');
    expect(world.auth.signIns, 1);
    expect(world.backup.driveBackups, 1);
    expect(
      world.settings.current.autoBackupFrequency,
      AutoBackupFrequency.daily,
    );
    expect(find.text('Signed in. Your data is backed up.'), findsOneWidget);
    expect(find.byKey(const Key('acc01.backUpNow')), findsOneWidget);
  });

  testWidgets('ACC-01 signing in keeps Weekly as it was', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut.copyWith(
        autoBackupFrequency: AutoBackupFrequency.weekly,
      ),
    );
    await tapKey(tester, 'acc01.signIn');
    expect(
      world.settings.current.autoBackupFrequency,
      AutoBackupFrequency.weekly,
    );
  });

  testWidgets('ACC-01 signing in to an account with a backup opens ACC-02', (
    tester,
  ) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut,
      arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
    );
    await tapKey(tester, 'acc01.signIn');
    expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
    expect(world.backup.driveBackups, 0);
  });

  testWidgets('ACC-01 cancelling sign-in changes nothing', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedOut,
      arrange: (w) => w.auth.signInResult = const DriveAuthRequired(),
    );
    final writes = world.settings.writeCount;
    await tapKey(tester, 'acc01.signIn');
    expect(world.settings.writeCount, writes);
    expect(world.backup.driveBackups, 0);
    expect(find.byKey(const Key('acc01.signIn')), findsOneWidget);
    expect(find.byKey(const Key('acc01_signInFailed')), findsNothing);
  });

  testWidgets('ACC-01 a failed sign-in says "Couldn\'t sign in"', (
    tester,
  ) async {
    await pumpAccountApp(
      tester,
      initial: signedOut,
      arrange: (w) => w.auth.signInResult = const DriveOffline(),
    );
    await tapKey(tester, 'acc01.signIn');
    expect(
      find.text("Couldn't sign in. Check your connection and try again."),
      findsOneWidget,
    );
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

  testWidgets('ACC-01 "Back up now" shows no interstitial afterwards', (
    tester,
  ) async {
    final ads = FakeAdService();
    final world = await pumpAccountApp(tester, ads: ads);
    await tapKey(tester, 'acc01.backUpNow');
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(world.backup.driveBackups, 1);
    expect(ads.triggers, isEmpty);
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
      expect(world.settings.current.backupAccountEmail, 'new@example.com');
      expect(find.text('new@example.com'), findsOneWidget);
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

    testWidgets('ACC-01 cancelling the chooser after switching leaves the '
        'user signed out with data kept', (tester) async {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.auth.signInResult = const DriveAuthRequired(),
      );
      await tapKey(tester, 'acc01.switch');
      expect(world.auth.signOuts, 1);
      expect(world.settings.current.backupAccountEmail, isNull);
      expect(world.reset.calls, 0);
      expect(find.byKey(const Key('acc01.signIn')), findsOneWidget);
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
  });

  testWidgets('token expiry: when Drive refuses the sign-in, ACC-01 signs out '
      'and says to sign in again', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) => w.backup.error = const DriveAuthRequired(),
    );
    await tapKey(tester, 'acc01.backUpNow');
    expect(world.settings.current.backupAccountEmail, isNull);
    expect(find.byKey(const Key('acc01_expired')), findsOneWidget);
    expect(find.byKey(const Key('acc01.signIn')), findsOneWidget);
    // Data stays; signing in again clears the message.
    expect(world.reset.calls, 0);
    world.backup.error = null;
    await tapKey(tester, 'acc01.signIn');
    expect(find.byKey(const Key('acc01_expired')), findsNothing);
  });
}
