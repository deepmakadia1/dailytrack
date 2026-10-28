import 'dart:io';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/account/account_test_app.dart';
import '../features/expense/expense_test_app.dart';

/// §16 section criteria "Every screen outside this section works the same
/// as a guest, and only the places listed at the top of this section offer
/// sign-in." and "As a guest, the app makes no Google sign-in or Drive
/// request (a fake client records zero calls across a full session)."
/// (feature 010 T101, FR-001; feature 011). Sign-in starts only from
/// AUTH-01, the SET-01 account card and the SET-02 Drive card (guest
/// sign-in, which ACC-04 will also use), SYS-03, and ACC-01 Switch account.
/// Intro no longer offers it.
void main() {
  /// Starting a Google sign-in or opening ACC-02.
  final entry = RegExp(
    r'\.signIn\(\)|accountSignInProvider\)\.run|showRestoreChoice(For)?\(',
  );

  const allowed = {
    // The account layer itself and the ACC-02 sheet's own definition.
    'lib/core/account/account_service.dart',
    'lib/core/account/account_sign_in.dart',
    'lib/core/account/account_ui.dart',
    'lib/features/account/presentation/widgets/restore_choice_sheet.dart',
    // SET-02 Drive card.
    'lib/features/settings/presentation/controllers/backup_controller.dart',
    'lib/features/settings/presentation/screens/backup_screen.dart',
    // AUTH-01 Login (feature 011); Intro no longer offers sign-in.
    'lib/features/auth/presentation/screens/login_screen.dart',
    // Guest sign-in behind the SET-01 account card, the SET-02 Drive card,
    // and ACC-04 (`AccountUi.startGuestSignIn`).
    'lib/features/account/presentation/widgets/guest_sign_in.dart',
    'lib/features/account/presentation/account_feature_ui.dart',
    // SYS-03 "Forgot PIN?".
    'lib/features/lock/presentation/screens/unlock_screen.dart',
    // ACC-01 Switch account, and Restore/Review (ACC-02 from ACC-01).
    'lib/features/account/presentation/controllers/account_controller.dart',
    'lib/features/account/presentation/screens/account_screen.dart',
  };

  test('§16 only the listed places start sign-in or open ACC-02', () {
    final callers = <String>{
      for (final f in Directory('lib').listSync(recursive: true))
        if (f is File &&
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.g.dart') &&
            entry.hasMatch(f.readAsStringSync()))
          f.path.replaceAll(r'\', '/'),
    };
    expect(callers.difference(allowed), isEmpty);
  });

  testWidgets('§16 As a guest, a full session makes no Google sign-in or '
      'Drive request', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: signedIn.copyWith(
        authMode: AuthMode.guest,
        backupAccountEmail: null,
        accountDisplayName: null,
        dataChangeCounter: 7,
      ),
      location: Routes.home,
    );
    for (final route in [
      Routes.expenses,
      Routes.expenseReports,
      Routes.habits,
      Routes.more,
      Routes.security,
      Routes.backup,
      Routes.export,
      Routes.account,
      Routes.home,
    ]) {
      routerOf(tester).go(route);
      await tester.pumpAndSettle();
    }
    // Data changed and the app goes to the background twice.
    for (var i = 0; i < 2; i++) {
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pumpAndSettle();
      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    expect(world.auth.signIns, 0);
    expect(world.auth.silentSignIns, 0);
    expect(world.drive.calls, isEmpty);
    expect(world.backup.driveBackups, 0);
    expect(world.scheduler.oneOff, isEmpty);
    expect(world.scheduler.periodic, isEmpty);
    // ACC-01 isn't reachable as a guest (rule 7).
    expect(locationOf(tester), Routes.home);
  });
}
