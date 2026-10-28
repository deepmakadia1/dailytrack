import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/mutable_clock.dart';
import 'helpers/app_harness.dart';

/// App lock journey on a device (feature 012 T021, spec FR-009, US2
/// scenario 6): SET-05 turns the lock on with a PIN set through SYS-04; a
/// restart opens SYS-03, a wrong PIN is refused, the right PIN opens Home;
/// going to the background past "Lock after" locks again. Real secure
/// storage, PIN hashing, and lock session; the clock is injected so the
/// timeout doesn't need a real wait.
/// Run with `flutter test integration_test --flavor dev` on an emulator.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(freshInstall);

  Future<void> enterPin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin_key_$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  void lifecycle(WidgetTester tester, List<AppLifecycleState> states) =>
      states.forEach(tester.binding.handleAppLifecycleStateChanged);

  testWidgets('SET-05 lock on → restart shows SYS-03 → wrong PIN refused → '
      'right PIN opens Home → background past the timeout locks again', (
    tester,
  ) async {
    final world = HarnessWorld(clock: MutableClock(DateTime.now()));
    await launch(tester, world);
    await startAsGuest(tester);

    // More → Security → App lock → SYS-04 twice.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('More'),
      ),
    );
    await tester.pumpAndSettle();
    await tapKey(tester, 'settings_app_lock');
    await tapKey(tester, 'security_app_lock');
    await enterPin(tester, '1234');
    await enterPin(tester, '1234');
    await pumpUntil(
      tester,
      () => tester
          .widget<SwitchListTile>(find.byKey(const Key('security_app_lock')))
          .value,
    );

    // A cold start opens SYS-03.
    await restart(tester, world);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await enterPin(tester, '0000');
    await pumpUntil(
      tester,
      () => shows(find.byKey(const Key('unlock_message'))),
    );
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await enterPin(tester, '1234');
    await pumpUntil(tester, () => shows(find.byType(HomeScreen)));
    expect(find.byType(UnlockScreen), findsNothing);

    // Background longer than "Lock after" (60 s by default), then resume.
    lifecycle(tester, [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]);
    world.clock!.advance(const Duration(minutes: 2));
    lifecycle(tester, [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]);
    await pumpUntil(tester, () => shows(find.byType(UnlockScreen)));
    await enterPin(tester, '1234');
    await pumpUntil(tester, () => shows(find.byType(HomeScreen)));
    expect(world.auth.calls, isEmpty);
    await closeApp(tester);
  });
}
