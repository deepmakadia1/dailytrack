import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../account/account_test_app.dart';
import 'login_test_app.dart';

/// "Finish setting up" after every login, and app lock after login
/// (feature 011 T037, T033; spec §6 AUTH-01 "After login", research R7,
/// R10).
void main() {
  const paths = {'guest': 'auth01_guest', 'Google': 'auth01_google'};

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin_key_$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  for (final MapEntry(key: path, value: button) in paths.entries) {
    testWidgets('AUTH-01 After login on either path with app lock off, the '
        '"Finish setting up" sheet appears once on Home and not again after a '
        'restart ($path)', (tester) async {
      final world = await pumpLogin(tester);
      await tapKey(tester, button);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('finish_setup')), findsOneWidget);
      expect(find.byKey(const Key('finish_setup_lock')), findsOneWidget);

      await tapKey(tester, 'finish_setup_later');
      expect(find.byKey(const Key('finish_setup')), findsNothing);
      expect(world.settings.current.finishSetupPending, isFalse);

      await restartTestApp(tester, settings: world.settings);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byKey(const Key('finish_setup')), findsNothing);
    });

    testWidgets('AUTH-01 With app lock on (data kept after sign-out), leaving '
        'AUTH-01 on either path shows SYS-03 before Home ($path)', (
      tester,
    ) async {
      final world = await pumpLogin(
        tester,
        initial: onLogin.copyWith(lockEnabled: true),
        hasData: true,
        pin: '1234',
      );
      // AUTH-01 first, even with app lock on (SYS-01 criterion).
      expect(find.byType(UnlockScreen), findsNothing);
      await tapKey(tester, button);

      expect(find.byType(UnlockScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);
      expect(world.settings.current.authMode, isNot(AuthMode.none));
      await enterPin(tester, '1234');
      expect(find.byType(HomeScreen), findsOneWidget);
      // That user already has a PIN: no sheet.
      expect(find.byKey(const Key('finish_setup')), findsNothing);
      expect(world.settings.current.finishSetupPending, isFalse);
    });
  }

  testWidgets('AUTH-01 "Allow notifications" is offered only on Android 13+ '
      'when the permission is not granted', (tester) async {
    for (final (sdk, granted, offered) in [
      (34, false, true),
      (34, true, false),
      (32, false, false),
    ]) {
      await pumpLogin(
        tester,
        androidSdk: sdk,
        notif: FakeNotificationPermission(granted: granted),
      );
      await tapKey(tester, 'auth01_guest');
      expect(find.byKey(const Key('finish_setup')), findsOneWidget);
      expect(
        find.byKey(const Key('finish_setup_notifications')),
        offered ? findsOneWidget : findsNothing,
        reason: 'SDK $sdk, granted $granted',
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
    }
  });

  testWidgets('AUTH-01 a later login (after a sign-out or log-out set '
      'authMode none) offers the sheet again', (tester) async {
    final world = await pumpLogin(tester);
    await tapKey(tester, 'auth01_guest');
    await tapKey(tester, 'finish_setup_later');

    await world.settings.setAuthMode(AuthMode.none);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    await tapKey(tester, 'auth01_guest');
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
  });

  testWidgets('SYS-01 with authMode none, returning from the background does '
      'not re-lock: AUTH-01 stays', (tester) async {
    await pumpLogin(
      tester,
      initial: onLogin.copyWith(lockEnabled: true, lockAfterSeconds: 0),
      pin: '1234',
    );
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    await tester.pumpAndSettle();
    tester.binding
      ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
      ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(UnlockScreen), findsNothing);
  });
}
