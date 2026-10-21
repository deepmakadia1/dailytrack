import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import 'lock_test_app.dart';

/// SYS-03 Unlock (T025, T038; SYS-03 AC2, AC3; US1-8, US2-1 – US2-6;
/// FR-028 – FR-033, clarifications Q1, Q3).
void main() {
  String? message(WidgetTester tester) {
    final f = find.byKey(const Key('unlock_message'));
    return f.evaluate().isEmpty ? null : tester.widget<Text>(f).data;
  }

  Future<void> wrong(WidgetTester tester, [int times = 1]) async {
    for (var i = 0; i < times; i++) {
      await enterPin(tester, '0000');
    }
  }

  testWidgets('SYS-03 AC3 "Screenshots are blocked on this screen '
      '(FLAG_SECURE)": on while it shows, off once unlocked', (tester) async {
    final w = await pumpLockApp(tester, pin: '1234');
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(w.screen.calls, [true]);
    await enterPin(tester, '1234');
    expect(find.byType(UnlockScreen), findsNothing);
    expect(w.screen.calls, [true, false]);
  });

  testWidgets('the correct PIN opens where the user was going (Home on a '
      'cold start); no ads', (tester) async {
    await pumpLockApp(tester, pin: '1234');
    expect(find.text('Enter PIN'), findsOneWidget);
    expect(find.byKey(const Key('pin_key_biometric')), findsNothing);
    await enterPin(tester, '1234');
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('a wrong PIN shakes and says so; from the 3rd it counts the '
      'attempts left (US2-1)', (tester) async {
    await pumpLockApp(tester, pin: '1234');
    await wrong(tester);
    expect(message(tester), 'Wrong PIN');
    expect(find.bySemanticsLabel('0 of 4 digits entered'), findsOneWidget);
    await wrong(tester);
    await wrong(tester);
    expect(message(tester), 'Wrong PIN. 2 attempts left');
    await wrong(tester);
    expect(message(tester), 'Wrong PIN. 1 attempt left');
  });

  testWidgets('US2-2 the 5th wrong PIN blocks the keypad for 30 s with a '
      'countdown; then it warns the next wrong PIN locks for 1:00 (Q1)', (
    tester,
  ) async {
    final w = await pumpLockApp(tester, pin: '1234');
    await wrong(tester, 5);
    expect(message(tester), 'Try again in 0:30');
    // Keys are ignored while locked out.
    await tester.tap(find.byKey(const Key('pin_key_1')));
    await tester.pump();
    expect(find.bySemanticsLabel('0 of 4 digits entered'), findsOneWidget);

    w.expense.clock.advance(const Duration(seconds: 10));
    await tester.pump(const Duration(seconds: 1));
    expect(message(tester), 'Try again in 0:20');

    w.expense.clock.advance(const Duration(seconds: 20));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(message(tester), 'Next wrong PIN locks the app for 1:00');

    await wrong(tester);
    expect(message(tester), 'Try again in 1:00');
    w.expense.clock.advance(const Duration(minutes: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('SYS-03 AC2 "Lockout timer survives app restart": a stored '
      'lockout shows its remaining time on open', (tester) async {
    final w = await pumpLockApp(tester, pin: '1234');
    await wrong(tester, 5);
    // The app is closed; 12 s later it starts again over the same storage.
    w.expense.clock.advance(const Duration(seconds: 12));
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await pumpLockApp(tester, world: w);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(message(tester), 'Try again in 0:18');
    w.expense.clock.advance(const Duration(seconds: 18));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('US1-8 with biometrics on, the prompt opens once by itself; a '
      'success unlocks', (tester) async {
    final w = await pumpLockApp(
      tester,
      pin: '1234',
      biometric: true,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: true,
        biometricEnabled: true,
      ),
    );
    expect(w.lock.biometrics.prompts, 1);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('US1-8 a cancelled prompt leaves the keypad; the biometric key '
      'opens it again', (tester) async {
    final w = await pumpLockApp(
      tester,
      pin: '1234',
      biometric: true,
      biometricResult: false,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: true,
        biometricEnabled: true,
      ),
    );
    expect(w.lock.biometrics.prompts, 1);
    expect(find.byType(UnlockScreen), findsOneWidget);
    w.lock.biometrics.result = true;
    await tester.tap(find.byKey(const Key('pin_key_biometric')));
    await tester.pumpAndSettle();
    expect(w.lock.biometrics.prompts, 2);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('US2-6 / Q3 biometrics still work during a lockout and clear '
      'it', (tester) async {
    final w = await pumpLockApp(
      tester,
      pin: '1234',
      biometric: true,
      biometricResult: false,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: true,
        biometricEnabled: true,
      ),
    );
    await wrong(tester, 5);
    expect(message(tester), 'Try again in 0:30');
    w.lock.biometrics.result = true;
    await tester.tap(find.byKey(const Key('pin_key_biometric')));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(await w.lock.service.lockoutRemaining(), Duration.zero);
  });

  testWidgets('lock on with no readable PIN: an explanation, no keypad', (
    tester,
  ) async {
    await pumpLockApp(
      tester,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        lockEnabled: true,
      ),
    );
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(message(tester), "App lock can't be checked on this phone.");
    expect(find.byKey(const Key('pin_key_1')), findsNothing);
    // "Forgot PIN?" is the way out.
    expect(find.byKey(const Key('unlock_forgot_pin')), findsOneWidget);
  });

  testWidgets('US2-7 "Forgot PIN?" explains the PIN cannot be recovered and '
      'erases only after DELETE (T038)', (tester) async {
    final reset = FakeAppResetService();
    await pumpLockApp(tester, pin: '1234', reset: reset);
    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await tester.pumpAndSettle();
    expect(find.text('Forgot your PIN?'), findsOneWidget);
    expect(find.textContaining("can't be recovered"), findsOneWidget);
    await tester.tap(find.byKey(const Key('forgot_pin_erase')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('typed_confirm_field')),
      'DELETE',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('typed_confirm_button')));
    await tester.pumpAndSettle();
    expect(reset.calls, 1);
  });

  testWidgets('US2-8 cancelling "Forgot PIN?" keeps the lockout running', (
    tester,
  ) async {
    final reset = FakeAppResetService();
    final w = await pumpLockApp(tester, pin: '1234', reset: reset);
    await wrong(tester, 5);
    expect(message(tester), 'Try again in 0:30');
    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('forgot_pin_cancel')));
    await tester.pumpAndSettle();
    expect(reset.calls, 0);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(message(tester), startsWith('Try again in'));
    w.expense.clock.advance(const Duration(seconds: 30));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
  });

  testWidgets('"Forgot PIN?" works while SYS-03 covers the app after a '
      'resume (it has its own navigator)', (tester) async {
    final reset = FakeAppResetService();
    final w = await pumpLockApp(tester, pin: '1234', reset: reset);
    await enterPin(tester, '1234');
    const [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    w.expense.clock.advance(const Duration(minutes: 2));
    const [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ].forEach(tester.binding.handleAppLifecycleStateChanged);
    await tester.pumpAndSettle();
    expect(find.byType(UnlockScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('unlock_forgot_pin')));
    await tester.pumpAndSettle();
    expect(find.text('Forgot your PIN?'), findsOneWidget);
    await tester.tap(find.byKey(const Key('forgot_pin_cancel')));
    await tester.pumpAndSettle();
    expect(reset.calls, 0);
  });

  testWidgets('rotating clears a half-typed PIN', (tester) async {
    await pumpLockApp(tester, pin: '1234');
    await tester.tap(find.byKey(const Key('pin_key_1')));
    await tester.pump();
    expect(find.bySemanticsLabel('1 of 4 digits entered'), findsOneWidget);
    tester.view.physicalSize = const Size(915, 412);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('0 of 4 digits entered'), findsOneWidget);
  });

  test('BiometricAvailability values are the three the UI handles', () {
    expect(BiometricAvailability.values, hasLength(3));
  });
}
