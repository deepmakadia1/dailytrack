import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_conflict_policy.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/backup/domain/drive_backup_result.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';
import '../auth/login_test_app.dart' show recordSystemCalls;
import '../expense/expense_test_app.dart';
import 'account_test_app.dart';

/// ACC-03 Sign out (spec §16, feature 010 US6, T089; feature 011 T051:
/// sign-out opens AUTH-01).
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
      'place, opens AUTH-01 with the back stack cleared, and "Continue as '
      'guest" there shows the same data', (tester) async {
    final system = recordSystemCalls(tester);
    final world = await pumpAccountApp(tester);
    await tapKey(tester, 'acc01.signOut');
    await tapKey(tester, 'acc03_signOut');

    final s = world.settings.current;
    expect(world.reset.calls, 0);
    expect(world.auth.signOuts, 1);
    expect(s.authMode, AuthMode.none);
    expect(s.backupAccountEmail, isNull);
    // The Auto backup setting is kept for the next sign-in.
    expect(s.autoBackupFrequency, AutoBackupFrequency.daily);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(locationOf(tester), Routes.login);
    expect(find.byKey(const Key('auth01_signedOutKept')), findsOneWidget);
    expect(
      find.text('Signed out. Your data is still on this phone.'),
      findsOneWidget,
    );

    // Back closes the app; it never returns to ACC-01 or the More tab.
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(system, contains('SystemNavigator.pop'));
    expect(find.byType(LoginScreen), findsOneWidget);

    await tapKey(tester, 'auth01_guest');
    expect(world.settings.current.authMode, AuthMode.guest);
    expect(locationOf(tester), Routes.home);
    expect(world.restore.applied, isEmpty, reason: 'same data');
  });

  testWidgets('ACC-03 After sign-out with either choice, authMode is none and '
      'the app opens AUTH-01, never Intro; a restart also opens AUTH-01', (
    tester,
  ) async {
    for (final choice in ['keep', 'remove']) {
      final world = await pumpAccountApp(
        tester,
        arrange: (w) => w.reset.onErase = () => w.settings.replace(
          // What the erase keeps (feature 011 clarification Q1).
          AppSettings(
            locale: 'en',
            onboardingDone: true,
            authMode: w.settings.current.authMode,
          ),
        ),
      );
      await tapKey(tester, 'acc01.signOut');
      if (choice == 'remove') await tapKey(tester, 'acc03_remove');
      await tapKey(tester, 'acc03_signOut');
      expect(world.settings.current.authMode, AuthMode.none, reason: choice);
      expect(find.byType(LoginScreen), findsOneWidget, reason: choice);
      expect(find.byType(OnboardingScreen), findsNothing, reason: choice);

      await restartTestApp(tester, settings: world.settings);
      expect(find.byType(LoginScreen), findsOneWidget, reason: choice);
      expect(find.byType(OnboardingScreen), findsNothing, reason: choice);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });

  testWidgets('ACC-03 "Remove data from this phone" erases local data, keeps '
      'the Drive backups, and opens AUTH-01', (tester) async {
    final world = await pumpAccountApp(
      tester,
      arrange: (w) {
        w.drive.seed(meta: otherPhoneMeta());
        // What the erase keeps (feature 011 clarification Q1).
        w.reset.onErase = () => w.settings.replace(
          AppSettings(
            locale: 'en',
            onboardingDone: true,
            authMode: w.settings.current.authMode,
          ),
        );
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
    expect(world.settings.current.authMode, AuthMode.none);
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
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
