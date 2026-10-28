import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../expense/expense_test_app.dart' show routerOf;
import 'account_test_app.dart';

/// §16 "Guest sign-in" (feature 011 T041), from the SET-01 account card and
/// the SET-02 Drive card, both through `AccountUi.startGuestSignIn` (the
/// call ACC-04 "Sign in with Google instead" makes).
void main() {
  final guest = signedIn.copyWith(
    authMode: AuthMode.guest,
    backupAccountEmail: null,
    accountDisplayName: null,
    autoBackupFrequency: AutoBackupFrequency.off,
  );

  const entryPoints = {
    'SET-01 card': (Routes.more, 'set01_accountSignIn'),
    'SET-02 Drive card': (Routes.backup, 'backup_signIn'),
  };

  for (final MapEntry(key: from, value: (location, button))
      in entryPoints.entries) {
    Future<AccountWorld> start(
      WidgetTester tester, {
      bool hasData = true,
      FakeNetworkStateSource? network,
      void Function(AccountWorld w)? arrange,
    }) => pumpAccountApp(
      tester,
      initial: guest,
      location: location,
      hasData: hasData,
      network: network,
      arrange: arrange,
    );

    testWidgets('§16 Guest sign-in Signing in to an account without a backup '
        'backs up the data on this phone, sets authMode = google, turns Auto '
        'backup to Daily if it was Off, and the SET-01 card switches to the '
        'Google state ($from)', (tester) async {
      final world = await start(tester);
      await tapKey(tester, button);

      final s = world.settings.current;
      expect(world.backup.driveBackups, 1);
      expect(s.authMode, AuthMode.google);
      expect(s.backupAccountEmail, 'me@example.com');
      expect(s.autoBackupFrequency, AutoBackupFrequency.daily);
      expect(find.text('Signed in. Your data is backed up.'), findsOneWidget);
      expect(world.restore.applied, isEmpty);
      expect(world.restore.kept, isEmpty);

      routerOf(tester).go(Routes.more);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('set01_accountGoogle')), findsOneWidget);
      expect(find.byKey(const Key('set01_accountGuest')), findsNothing);
    });

    for (final choice in ['acc02_restore', 'acc02_keep']) {
      testWidgets('§16 Guest sign-in Signing in to an account with a backup '
          'opens ACC-02; "$choice" gives either the account data or this '
          'phone data, and no rows from the two are combined ($from)', (
        tester,
      ) async {
        final world = await start(
          tester,
          arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
        );
        await tapKey(tester, button);
        expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
        // Can't be dismissed without a choice.
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('acc02_sheet')), findsOneWidget);
        expect(world.backup.driveBackups, 0, reason: 'nothing uploaded yet');

        await tapKey(tester, choice);
        expect(world.settings.current.authMode, AuthMode.google);
        if (choice == 'acc02_restore') {
          // Replaces this phone's data, in one transaction.
          expect(world.restore.applied, [('f0', false)]);
          expect(world.restore.kept, isEmpty);
        } else {
          // This phone's data becomes the account's latest backup.
          expect(world.restore.kept, ['f0']);
          expect(world.restore.applied, isEmpty);
        }
      });
    }

    testWidgets('§16 Guest sign-in with no user data on this phone, the newest '
        'backup is restored without the sheet ($from)', (tester) async {
      final world = await start(
        tester,
        hasData: false,
        arrange: (w) => w.drive.seed(meta: otherPhoneMeta()),
      );
      await tapKey(tester, button);
      expect(find.byKey(const Key('acc02_sheet')), findsNothing);
      expect(world.restore.applied, [('f0', true)]);
    });

    for (final (label, failure) in [
      ('Cancelling', const DriveAuthRequired()),
      ('failing', const DriveUnavailable('500')),
    ]) {
      testWidgets('§16 Guest sign-in $label sign-in leaves authMode = guest '
          'and every local row unchanged ($from)', (tester) async {
        final world = await start(
          tester,
          arrange: (w) {
            w.drive.seed(meta: otherPhoneMeta());
            w.auth.signInResult = failure;
          },
        );
        final before = world.settings.current;
        await tapKey(tester, button);

        expect(world.settings.current, before);
        expect(world.settings.current.authMode, AuthMode.guest);
        expect(world.restore.applied, isEmpty);
        expect(world.restore.kept, isEmpty);
        expect(world.restore.downloads, isEmpty);
        expect(world.backup.driveBackups, 0);
        expect(world.reset.calls, 0);
        expect(
          find.text("Couldn't sign in. Check your connection and try again."),
          failure is DriveAuthRequired ? findsNothing : findsOneWidget,
        );
      });
    }

    testWidgets('§16 Guest sign-in offline says "Connect to the internet to '
        'sign in with Google" and makes no request ($from)', (tester) async {
      final world = await start(
        tester,
        network: FakeNetworkStateSource(online: false),
      );
      await tapKey(tester, button);
      expect(
        find.text('Connect to the internet to sign in with Google'),
        findsWidgets,
      );
      expect(world.auth.calls, isEmpty);
      expect(world.drive.calls, isEmpty);
      expect(world.settings.current.authMode, AuthMode.guest);
    });

    testWidgets('§16 Guest sign-in a failed first backup keeps the user signed '
        'in; auto backup tries again ($from)', (tester) async {
      final world = await start(
        tester,
        arrange: (w) => w.backup.error = const DriveOffline(),
      );
      await tapKey(tester, button);
      expect(world.settings.current.authMode, AuthMode.google);
      expect(world.settings.current.backupAccountEmail, 'me@example.com');
      expect(world.scheduler.periodic, isNotEmpty);
    });
  }
}
