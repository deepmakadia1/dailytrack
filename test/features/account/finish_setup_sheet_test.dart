import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense/expense_test_app.dart';
import 'account_test_app.dart';

/// The "Finish setting up" sheet after a restore onto an empty phone
/// (spec §2 SYS-02, §16; feature 010 research R13, T044).
void main() {
  final pending = signedIn.copyWith(finishSetupPending: true);

  testWidgets('Home shows it once; "Not now" clears it for good', (
    tester,
  ) async {
    final world = await pumpAccountApp(
      tester,
      initial: pending,
      location: Routes.home,
    );
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
    expect(find.text('Finish setting up'), findsOneWidget);
    await tapKey(tester, 'finish_setup_later');
    expect(world.settings.current.finishSetupPending, isFalse);
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    routerOf(tester).go(Routes.home);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finish_setup')), findsNothing);
  });

  testWidgets('it waits for Home', (tester) async {
    final world = await pumpAccountApp(tester);
    await world.settings.setFinishSetupPending(pending: true);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finish_setup')), findsNothing);
    routerOf(tester).go(Routes.home);
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
  });

  testWidgets('"Set app lock" opens SYS-04 to set a PIN', (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: pending,
      location: Routes.home,
    );
    await tapKey(tester, 'finish_setup_lock');
    expect(find.byType(PinScreen), findsOneWidget);
    expect(world.settings.current.finishSetupPending, isFalse);
  });

  testWidgets('"Allow notifications" asks for the permission on Android 13+', (
    tester,
  ) async {
    await pumpAccountApp(tester, initial: pending, location: Routes.home);
    expect(find.byKey(const Key('finish_setup_notifications')), findsOne);
    await tapKey(tester, 'finish_setup_notifications');
    expect(find.byKey(const Key('finish_setup')), findsNothing);
  });

  testWidgets('"Allow notifications" is hidden below Android 13', (
    tester,
  ) async {
    await pumpAccountApp(
      tester,
      initial: pending,
      location: Routes.home,
      androidSdk: 32,
    );
    expect(find.byKey(const Key('finish_setup')), findsOneWidget);
    expect(find.byKey(const Key('finish_setup_notifications')), findsNothing);
  });

  testWidgets("it isn't shown when app lock is on", (tester) async {
    final world = await pumpAccountApp(
      tester,
      initial: pending.copyWith(lockEnabled: true),
      location: null,
    );
    // With the lock on, the app starts on SYS-03; the PIN is already set.
    expect(find.byKey(const Key('finish_setup')), findsNothing);
    expect(world.settings.current.finishSetupPending, isFalse);
  });
}
