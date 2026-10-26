import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense/expense_test_app.dart';
import 'account_test_app.dart';

/// ACC-03 Sign out (spec §16, feature 010 US6, T089).
void main() {
  /// Signed in with changes not yet backed up.
  final changed = signedIn.copyWith(dataChangeCounter: 5);

  FilledButton signOutButton(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const Key('acc03_signOut')));

  testWidgets('ACC-03 with changes not yet backed up, it backs up first and '
      'enables "Sign out" only after the backup succeeds', (tester) async {
    final gate = Completer<void>();
    final world = await pumpAccountApp(
      tester,
      initial: changed,
      arrange: (w) => w.backup.gate = gate,
    );
    await tester.tap(find.byKey(const Key('acc01.signOut')));
    await tester.pump();
    await tester.pump();
    expect(find.text('Sign out of me@example.com?'), findsOneWidget);
    expect(find.text('Backing up your latest changes…'), findsOneWidget);
    expect(signOutButton(tester).onPressed, isNull);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc03_backedUp')), findsOneWidget);
    expect(world.backup.driveBackups, 1);
    expect(world.backup.conflicts, [ConflictMode.ask]);
    expect(signOutButton(tester).onPressed, isNotNull);
  });

  testWidgets('ACC-03 with nothing to back up, it says "Backed up" at once', (
    tester,
  ) async {
    final world = await pumpAccountApp(tester);
    await tapKey(tester, 'acc01.signOut');
    expect(find.byKey(const Key('acc03_backedUp')), findsOneWidget);
    expect(world.backup.driveBackups, 0);
    expect(signOutButton(tester).onPressed, isNotNull);
  });

  testWidgets('ACC-03 a failed backup offers "Try again" and "Sign out '
      'anyway"; "Sign out" waits for one of them', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: changed,
      arrange: (w) => w.backup.error = const DriveOffline(),
    );
    await tapKey(tester, 'acc01.signOut');
    expect(find.text("Couldn't back up your latest changes"), findsOneWidget);
    expect(signOutButton(tester).onPressed, isNull);

    world.backup.error = null;
    await tapKey(tester, 'acc03_tryAgain');
    expect(find.byKey(const Key('acc03_backedUp')), findsOneWidget);
    expect(signOutButton(tester).onPressed, isNotNull);
  });

  testWidgets('ACC-03 declining the conflict warning counts as a failed '
      'backup', (tester) async {
    await pumpAccountApp(
      tester,
      initial: changed,
      arrange: (w) =>
          w.backup.conflict = NewerFromOtherDevice(otherPhoneMeta()),
    );
    // The step 1 progress keeps moving behind the warning: pump frames.
    await tester.tap(find.byKey(const Key('acc01.signOut')));
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Back up anyway?'), findsOneWidget);
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('Cancel'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('acc03_failed')), findsOneWidget);
    await tapKey(tester, 'acc03_signOutAnyway');
    expect(signOutButton(tester).onPressed, isNotNull);
  });

  testWidgets('ACC-03 "Keep data on this phone" leaves every local row in '
      'place and the app fully usable', (tester) async {
    final world = await pumpAccountApp(tester);
    await tapKey(tester, 'acc01.signOut');
    await tapKey(tester, 'acc03_signOut');
    expect(world.reset.calls, 0);
    expect(world.auth.signOuts, 1);
    expect(world.settings.current.backupAccountEmail, isNull);
    // The Auto backup setting is kept for the next sign-in.
    expect(
      world.settings.current.autoBackupFrequency,
      AutoBackupFrequency.daily,
    );
    expect(
      find.text('Signed out. Your data is still on this phone.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('acc01.signIn')), findsOneWidget);
    routerOf(tester).go(Routes.home);
    await tester.pumpAndSettle();
    expect(locationOf(tester), Routes.home);
  });

  testWidgets('ACC-03 "Remove data from this phone" erases local data, keeps '
      'the Drive backups, and opens onboarding', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        w.reset.onErase = () =>
            w.settings.replace(const AppSettings(locale: 'en'));
      },
    );
    await tapKey(tester, 'acc01.signOut');
    await tapKey(tester, 'acc03_remove');
    final button = signOutButton(tester);
    expect(button.style?.backgroundColor?.resolve({}), isNotNull);
    await tapKey(tester, 'acc03_signOut');
    expect(world.auth.signOuts, 1);
    expect(world.reset.calls, 1);
    expect(world.drive.files, hasLength(1));
    expect(world.drive.calls, isNot(contains('deleteAll')));
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('ACC-03 after a failed backup, "Remove data from this phone" '
      'needs the typed DELETE confirmation', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: changed,
      arrange: (w) => w.backup.error = const DriveOffline(),
    );
    await tapKey(tester, 'acc01.signOut');
    await tapKey(tester, 'acc03_signOutAnyway');
    await tapKey(tester, 'acc03_remove');
    await tapKey(tester, 'acc03_signOut');
    expect(find.text('Type DELETE to confirm'), findsOneWidget);
    await tester.tap(find.text('Cancel').last);
    await tester.pumpAndSettle();
    expect(world.reset.calls, 0);
    expect(world.auth.signOuts, 0);

    await tapKey(tester, 'acc03_signOut');
    await tester.enterText(find.byType(TextField).last, 'DELETE');
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(FilledButton),
      ),
    );
    await tester.pumpAndSettle();
    expect(world.reset.calls, 1);
  });

  testWidgets('ACC-03 after sign-out, no Drive request is made until the '
      'user signs in again', (tester) async {
    final world = await pumpAccountApp(tester, initial: changed);
    await tapKey(tester, 'acc01.signOut');
    await tapKey(tester, 'acc03_signOut');
    world.drive.calls.clear();
    world.scheduler.ensured.clear();

    routerOf(tester).go(Routes.backup);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pumpAndSettle();
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();

    expect(world.drive.calls, isEmpty);
    expect(world.scheduler.oneOff, isEmpty);
    expect(world.scheduler.cancelled, contains('core.backgroundBackup'));
  });
}
