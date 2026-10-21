import 'dart:async';

import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../expense/expense_test_app.dart';
import 'lock_test_app.dart';

/// SYS-04 Set / change PIN (T024, T029; SYS-04 AC1, AC2; US1-1 – US1-3,
/// US3-1, FR-037 – FR-041).
void main() {
  /// Opens SYS-04 above the More tab. Callers follow the settings stream,
  /// not the pop result (a router refresh drops pending push results).
  Future<void> openPin(WidgetTester tester, String mode) async {
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    unawaited(routerOf(tester).push<bool>(Routes.pinPath(mode)));
    await tester.pumpAndSettle();
    expect(find.byType(PinScreen), findsOneWidget);
  }

  String title(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('pin_title'))).data!;

  group('set', () {
    testWidgets('SYS-04 AC1 "PIN cannot be set without matching '
        'confirmation."', (tester) async {
      final w = await pumpLockApp(tester);
      await openPin(tester, Routes.pinModeSet);
      expect(title(tester), 'Enter new PIN');
      await enterPin(tester, '1234');
      expect(title(tester), 'Confirm new PIN');

      await enterPin(tester, '1243');
      expect(find.text("PINs don't match. Try again."), findsOneWidget);
      expect(title(tester), 'Confirm new PIN');
      expect(w.lock.hasPin, isFalse);
      expect(w.settings.current.lockEnabled, isFalse);

      await enterPin(tester, '1234');
      expect(w.lock.hasPin, isTrue);
      expect(w.settings.current.lockEnabled, isTrue);
      expect(await w.lock.service.verifyPin('1234'), isA<UnlockSuccess>());
    });

    testWidgets('US1-3 with biometrics available, the offer shows after '
        'confirming; Done pops true with "App lock is on"', (tester) async {
      final w = await pumpLockApp(tester, biometric: true);
      await openPin(tester, Routes.pinModeSet);
      await enterPin(tester, '1234');
      await enterPin(tester, '1234');
      expect(find.byKey(const Key('pin_offer_biometric')), findsOneWidget);

      await tester.tap(find.byKey(const Key('pin_offer_biometric')));
      await tester.pumpAndSettle();
      expect(w.lock.biometrics.prompts, 1);
      expect(w.settings.current.biometricEnabled, isTrue);

      await tester.tap(find.byKey(const Key('pin_done')));
      await tester.pumpAndSettle();
      expect(find.byType(PinScreen), findsNothing);
      expect(find.byType(PinScreen), findsNothing);
      expect(find.text('App lock is on'), findsOneWidget);
    });

    testWidgets('without biometrics it pops right after confirming, and the '
        'session stays unlocked (no SYS-03 for a PIN just chosen)', (
      tester,
    ) async {
      await pumpLockApp(tester);
      await openPin(tester, Routes.pinModeSet);
      await enterPin(tester, '1234');
      await enterPin(tester, '1234');
      expect(find.byType(PinScreen), findsNothing);
      expect(find.byType(UnlockScreen), findsNothing);
      final container = containerOf(tester);
      expect(container.read(lockSessionProvider).locked, isFalse);
    });

    testWidgets('FR-041 back before finishing pops false and saves nothing', (
      tester,
    ) async {
      final w = await pumpLockApp(tester);
      await openPin(tester, Routes.pinModeSet);
      await enterPin(tester, '1234');
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PinScreen), findsNothing);
      expect(w.lock.hasPin, isFalse);
      expect(w.settings.current.lockEnabled, isFalse);
    });

    testWidgets('backgrounding clears a half-typed PIN', (tester) async {
      await pumpLockApp(tester);
      await openPin(tester, Routes.pinModeSet);
      await tester.tap(find.byKey(const Key('pin_key_1')));
      await tester.tap(find.byKey(const Key('pin_key_2')));
      await tester.pump();
      expect(find.bySemanticsLabel('2 of 4 digits entered'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      await tester.pump();
      expect(find.bySemanticsLabel('0 of 4 digits entered'), findsOneWidget);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    });
  });

  group('change', () {
    testWidgets('US3-1 current (a wrong one is refused) → new → confirm; the '
        'old PIN stops working', (tester) async {
      final w = await pumpLockApp(tester);
      await w.lock.service.setPin('1234');
      containerOf(tester).read(lockSessionProvider.notifier).unlocked();
      await tester.pumpAndSettle();
      await openPin(tester, Routes.pinModeChange);
      expect(title(tester), 'Enter current PIN');

      await enterPin(tester, '0000');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(title(tester), 'Enter current PIN');

      await enterPin(tester, '1234');
      expect(title(tester), 'Enter new PIN');
      await enterPin(tester, '5678');
      await enterPin(tester, '5678');
      expect(find.byType(PinScreen), findsNothing);
      expect(find.text('PIN changed'), findsOneWidget);
      expect(await w.lock.service.verifyPin('1234'), isA<UnlockWrong>());
      expect(await w.lock.service.verifyPin('5678'), isA<UnlockSuccess>());
    });
  });

  group('disable', () {
    testWidgets('SYS-04 AC2 "Disabling lock requires the current PIN."', (
      tester,
    ) async {
      final w = await pumpLockApp(tester);
      await w.lock.service.setPin('1234');
      containerOf(tester).read(lockSessionProvider.notifier).unlocked();
      await tester.pumpAndSettle();
      await openPin(tester, Routes.pinModeDisable);
      expect(title(tester), 'Enter current PIN');

      await enterPin(tester, '9999');
      expect(find.text('Wrong PIN'), findsOneWidget);
      expect(w.settings.current.lockEnabled, isTrue);
      expect(w.lock.hasPin, isTrue);

      await enterPin(tester, '1234');
      expect(find.byType(PinScreen), findsNothing);
      expect(find.text('App lock is off'), findsOneWidget);
      expect(w.settings.current.lockEnabled, isFalse);
      expect(
        w.lock.store.values.keys.where(
          (k) => k.startsWith(SecureLockService.keyPrefix),
        ),
        isEmpty,
      );
    });

    testWidgets('during a lockout SYS-04 shows the countdown and blocks the '
        'keypad (spec edge case)', (tester) async {
      final w = await pumpLockApp(tester);
      await w.lock.service.setPin('1234');
      containerOf(tester).read(lockSessionProvider.notifier).unlocked();
      for (var i = 0; i < 5; i++) {
        await w.lock.service.verifyPin('0000');
      }
      await openPin(tester, Routes.pinModeDisable);
      expect(find.text('Try again in 0:30'), findsOneWidget);
      await tester.tap(find.byKey(const Key('pin_key_1')));
      await tester.pump();
      expect(find.bySemanticsLabel('0 of 4 digits entered'), findsOneWidget);
      // Leave the screen so its countdown timer stops.
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('no ad widgets anywhere in the flow', (tester) async {
    await pumpLockApp(tester);
    await openPin(tester, Routes.pinModeSet);
    expect(find.byType(Image), findsNothing);
    expect(FakeTextSharer().shared, isEmpty);
  });
}
