import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/fakes.dart';

/// What a lock test works with.
typedef LockWorld = ({
  FakeSettingsRepository settings,
  TestLock lock,
  FakeSecureScreenService screen,
  ExpenseFakes expense,
});

/// Pumps the app past onboarding with the real lock service on in-memory
/// storage (feature 007). With [pin], the lock is on and that PIN stored,
/// so the app starts on SYS-03. Pass [world] to start the app again over
/// the same settings and secure storage (an app restart).
Future<LockWorld> pumpLockApp(
  WidgetTester tester, {
  String? pin,
  AppSettings? initial,
  bool biometric = false,
  bool biometricResult = true,
  LockWorld? world,
  ExpenseFakes? expense,
  FakeAppResetService? reset,
  List<Override> overrides = const [],
}) async {
  tester.view
    ..physicalSize = const Size(412, 915)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final settings =
      world?.settings ??
      FakeSettingsRepository(
        initial:
            initial ??
            AppSettings(
              onboardingDone: true,
              locale: 'en',
              lockEnabled: pin != null,
            ),
      );
  final f = world?.expense ?? expense ?? ExpenseFakes.withDefaults();
  final lock = world?.lock ?? TestLock(settings: settings, clock: f.clock);
  if (biometric) lock.biometrics.available = BiometricAvailability.available;
  lock.biometrics.result = biometricResult;
  if (pin != null) await lock.seedPin(pin);
  final screen = FakeSecureScreenService();
  await pumpTestApp(
    tester,
    settings: settings,
    lock: lock,
    secureScreen: screen,
    expense: f,
    reset: reset,
    overrides: overrides,
  );
  return (settings: settings, lock: lock, screen: screen, expense: f);
}

/// Taps the four digits of [pin] on the PIN keypad.
Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin_key_$d')));
    await tester.pump();
  }
  await tester.pumpAndSettle();
}
