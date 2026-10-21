import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/lock/presentation/screens/unlock_screen.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

/// SYS-01 startup with app lock (spec §5, SYS-01 AC "Returning user with
/// lock on lands on SYS-03; without lock lands on DSH-01").
void main() {
  testWidgets('SYS-01 returning user with lock on lands on SYS-03, and back '
      'closes the app instead of leaving it', (tester) async {
    final popped = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        popped.add(call.method);
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    final settings = FakeSettingsRepository(
      initial: const AppSettings(
        onboardingDone: true,
        lockEnabled: true,
        locale: 'en',
      ),
    );
    final lock = TestLock(settings: settings);
    await lock.seedPin('1234');
    await pumpTestApp(tester, settings: settings, lock: lock);
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.text('Enter PIN'), findsOneWidget);

    final handled = await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(handled, isTrue);
    expect(popped, contains('SystemNavigator.pop'));
    expect(find.byType(UnlockScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);
  });

  testWidgets('SYS-01 returning user without lock lands on DSH-01', (
    tester,
  ) async {
    await pumpTestApp(
      tester,
      settings: FakeSettingsRepository(
        initial: const AppSettings(onboardingDone: true),
      ),
    );
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(UnlockScreen), findsNothing);
  });
}
