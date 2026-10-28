import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/features/auth/presentation/screens/login_screen.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/backup_fakes.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../account/account_test_app.dart';
import '../expense/expense_test_app.dart' show locationOf;
import 'login_test_app.dart';

/// AUTH-01 Login: layout and the guest path (feature 011 T020, spec §6
/// AUTH-01).
void main() {
  testWidgets('AUTH-01 shows the logo, title, value line, both buttons, and '
      'the guest note; no error until sign-in is tried', (tester) async {
    await pumpLogin(tester);
    expect(find.byKey(const Key('auth01_logo')), findsOneWidget);
    expect(find.text('Keep your data safe'), findsOneWidget);
    expect(
      find.text(
        'Sign in with Google to back up your expenses and habits and get '
        'them back on a new phone.',
      ),
      findsOneWidget,
    );
    expect(find.widgetWithText(FilledButton, 'Continue with Google'), findsOne);
    expect(find.widgetWithText(OutlinedButton, 'Continue as guest'), findsOne);
    expect(
      find.text('As a guest, your data stays only on this phone.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('auth01_error')), findsNothing);
    expect(find.byType(AppBar), findsNothing);
    expect(find.byType(BackButton), findsNothing);
  });

  testWidgets('AUTH-01 On a fresh install, Intro opens AUTH-01; back on '
      'AUTH-01 closes the app and never shows Intro', (tester) async {
    final system = recordSystemCalls(tester);
    final world = await pumpAccountApp(
      tester,
      initial: const AppSettings(locale: 'en'),
      location: null,
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
    await tapKey(tester, 'onboarding_skip');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(world.settings.current.authMode, AuthMode.none);

    for (var i = 0; i < 2; i++) {
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.byType(LoginScreen), findsOneWidget);
    }
    expect(system.where((m) => m == 'SystemNavigator.pop'), hasLength(2));
  });

  for (final online in [true, false]) {
    final label = online ? 'online' : 'offline';
    testWidgets('AUTH-01 "Continue as guest" sets authMode = guest and opens '
        'Home without any sign-in, Drive, or network call ($label)', (
      tester,
    ) async {
      final network = FakeNetworkStateSource(online: online);
      final world = await pumpLogin(tester, network: network);
      await tapKey(tester, 'auth01_guest');

      expect(world.settings.current.authMode, AuthMode.guest);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(locationOf(tester), Routes.home);
      expectNoGoogleCalls(world.auth, world.drive);
      expect(network.loads, 0, reason: 'not even a network check');
      expect(world.backup.driveBackups, 0);
      expect(world.restore.downloads, isEmpty);
      expect(world.scheduler.periodic, isEmpty);
      expect(world.scheduler.oneOff, isEmpty);
    });
  }

  testWidgets('AUTH-01 data already on the phone stays as the guest data; a '
      'restart opens Home, not AUTH-01 or Intro', (tester) async {
    final world = await pumpLogin(tester, hasData: true);
    await tapKey(tester, 'auth01_guest');
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(world.restore.applied, isEmpty);

    await tapKey(tester, 'finish_setup_later');
    await restartTestApp(tester, settings: world.settings);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  testWidgets('AUTH-01 No ad is requested while AUTH-01 is open', (
    tester,
  ) async {
    final ads = FakeAdService(view: FakeAdView());
    await pumpLogin(
      tester,
      ads: ads,
      arrange: (w) => w.auth.signInResult = const DriveAuthRequired(),
    );
    // Every state of the screen: default, signing in, and the error.
    await tapKey(tester, 'auth01_google');
    await tapKey(tester, 'auth01_tryAgain');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(ads.bannerLoads, 0);
    expect(ads.nativeLoads, 0);
    expect(ads.triggers, isEmpty, reason: 'no interstitial over AUTH-01');
    expect(ads.rewardedShows, 0);
  });
}
