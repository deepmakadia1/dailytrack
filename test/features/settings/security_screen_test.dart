import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/lock/presentation/screens/pin_screen.dart';
import 'package:dailytrack/features/settings/presentation/screens/security_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../expense/expense_test_app.dart';
import '../lock/lock_test_app.dart';

/// SET-05 Security (T029, T045; US1-1, US3-1 – US3-7; FR-022 – FR-027).
void main() {
  Future<LockWorld> open(
    WidgetTester tester, {
    bool lockOn = false,
    bool biometric = false,
    bool biometricResult = true,
  }) async {
    final w = await pumpLockApp(
      tester,
      biometric: biometric,
      biometricResult: biometricResult,
    );
    if (lockOn) {
      await w.lock.service.setPin('1234');
      containerOf(tester).read(lockSessionProvider.notifier).unlocked();
    }
    routerOf(tester).go(Routes.security);
    await tester.pumpAndSettle();
    expect(find.byType(SecurityScreen), findsOneWidget);
    return w;
  }

  SwitchListTile switchOf(WidgetTester tester, String key) =>
      tester.widget<SwitchListTile>(find.byKey(Key(key)));

  ListTile tileOf(WidgetTester tester, String key) =>
      tester.widget<ListTile>(find.byKey(Key(key)));

  testWidgets('SET-01 shows "App lock: Off" and opens SET-05', (tester) async {
    await pumpLockApp(tester);
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    final row = find.byKey(const Key('settings_app_lock'));
    await tester.scrollUntilVisible(
      row,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(of: row, matching: find.text('Off')),
      findsOneWidget,
    );
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(find.byType(SecurityScreen), findsOneWidget);
  });

  testWidgets('US1-1 turning the lock on opens SYS-04 in set mode; the '
      'switch turns on only once a PIN is saved', (tester) async {
    final w = await open(tester);
    await tester.tap(find.byKey(const Key('security_app_lock')));
    await tester.pumpAndSettle();
    expect(find.byType(PinScreen), findsOneWidget);
    expect(find.text('Enter new PIN'), findsWidgets);
    expect(w.settings.current.lockEnabled, isFalse);

    await enterPin(tester, '1234');
    await enterPin(tester, '1234');
    expect(find.byType(SecurityScreen), findsOneWidget);
    expect(w.settings.current.lockEnabled, isTrue);
    expect(switchOf(tester, 'security_app_lock').value, isTrue);
  });

  testWidgets('turning the lock off opens SYS-04 asking for the current PIN', (
    tester,
  ) async {
    final w = await open(tester, lockOn: true);
    await tester.tap(find.byKey(const Key('security_app_lock')));
    await tester.pumpAndSettle();
    expect(find.text('Enter current PIN'), findsWidgets);
    await enterPin(tester, '1234');
    expect(find.byType(SecurityScreen), findsOneWidget);
    expect(w.settings.current.lockEnabled, isFalse);
    expect(switchOf(tester, 'security_app_lock').value, isFalse);
  });

  testWidgets('US3-4 with the lock off, Change PIN, biometric, Lock after, '
      'and Show data on widget are disabled with "Turn on app lock first"', (
    tester,
  ) async {
    await open(tester, biometric: true);
    expect(tileOf(tester, 'security_change_pin').enabled, isFalse);
    expect(switchOf(tester, 'security_biometric').onChanged, isNull);
    expect(tileOf(tester, 'security_lock_after').enabled, isFalse);
    expect(switchOf(tester, 'security_show_widget_data').onChanged, isNull);
    expect(find.text('Turn on app lock first'), findsNWidgets(4));
  });

  testWidgets('feature 008 T129 FR-047 "Show data on widget" with its helper; '
      'with the lock on it toggles the setting', (tester) async {
    final w = await open(tester, lockOn: true);
    final row = find.byKey(const Key('security_show_widget_data'));
    await tester.ensureVisible(row);
    expect(
      find.descendant(of: row, matching: find.text('Show data on widget')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: row,
        matching: find.text(
          'Shows amounts and habit names on your home screen',
        ),
      ),
      findsOneWidget,
    );
    expect(switchOf(tester, 'security_show_widget_data').value, isFalse);
    await tester.tap(row);
    await tester.pumpAndSettle();
    expect(w.settings.current.showDataOnWidget, isTrue);
    expect(switchOf(tester, 'security_show_widget_data').value, isTrue);
  });

  testWidgets('US3-1 Change PIN opens SYS-04 in change mode', (tester) async {
    await open(tester, lockOn: true);
    await tester.tap(find.byKey(const Key('security_change_pin')));
    await tester.pumpAndSettle();
    expect(find.byType(PinScreen), findsOneWidget);
    expect(find.text('Enter current PIN'), findsWidgets);
  });

  testWidgets('US3-5 without enrolled biometrics the switch is disabled with '
      'the reason', (tester) async {
    final w = await pumpLockApp(tester);
    w.lock.biometrics.available = BiometricAvailability.notEnrolled;
    await w.lock.service.setPin('1234');
    containerOf(tester).read(lockSessionProvider.notifier).unlocked();
    routerOf(tester).go(Routes.security);
    await tester.pumpAndSettle();
    expect(switchOf(tester, 'security_biometric').onChanged, isNull);
    expect(
      find.text("Set up fingerprint or face unlock in your phone's settings"),
      findsOneWidget,
    );
  });

  testWidgets('US3-6 turning biometrics on needs the prompt; a cancel leaves '
      'it off', (tester) async {
    final w = await open(
      tester,
      lockOn: true,
      biometric: true,
      biometricResult: false,
    );
    await tester.tap(find.byKey(const Key('security_biometric')));
    await tester.pumpAndSettle();
    expect(w.lock.biometrics.prompts, 1);
    expect(w.settings.current.biometricEnabled, isFalse);

    w.lock.biometrics.result = true;
    await tester.tap(find.byKey(const Key('security_biometric')));
    await tester.pumpAndSettle();
    expect(w.settings.current.biometricEnabled, isTrue);
    expect(switchOf(tester, 'security_biometric').value, isTrue);
  });

  testWidgets('Lock after offers Immediately, 1 and 5 minutes; 5 minutes is '
      'stored as 300', (tester) async {
    final w = await open(tester, lockOn: true);
    expect(
      find.descendant(
        of: find.byKey(const Key('security_lock_after')),
        matching: find.text('After 1 minute'),
      ),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('security_lock_after')));
    await tester.pumpAndSettle();
    for (final s in [0, 60, 300]) {
      expect(find.byKey(Key('lock_after_$s')), findsOneWidget);
    }
    await tester.tap(find.byKey(const Key('lock_after_300')));
    await tester.pumpAndSettle();
    expect(w.settings.current.lockAfterSeconds, 300);
  });

  testWidgets('US3-7 Hide app content in recents turns FLAG_SECURE on '
      'app-wide', (tester) async {
    final w = await open(tester);
    await tester.tap(find.byKey(const Key('security_hide_in_recents')));
    await tester.pumpAndSettle();
    expect(w.settings.current.hideInRecents, isTrue);
    expect(w.screen.secure, isTrue);
    await tester.tap(find.byKey(const Key('security_hide_in_recents')));
    await tester.pumpAndSettle();
    expect(w.screen.secure, isFalse);
    expect(const AppSettings().hideInRecents, isFalse);
  });
}
