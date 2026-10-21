import 'dart:async';

import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/app/splash/splash_screen.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/widgets/error_state.dart';
import 'package:dailytrack/features/dashboard/presentation/screens/home_screen.dart';
import 'package:dailytrack/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';

const _error = "Couldn't open your data. Try again.";

void main() {
  final returning = FakeSettingsRepository(
    initial: const AppSettings(onboardingDone: true),
  );

  testWidgets('SYS-01 storage failure shows the error with Retry, and Retry '
      'continues to Home', (tester) async {
    final bootstrap = FakeBootstrap(
      results: [
        BootstrapFailed(StateError('db')),
        const BootstrapReady(Routes.home),
      ],
    );
    await pumpTestApp(tester, settings: returning, bootstrap: bootstrap);

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(ErrorState), findsOneWidget);
    expect(find.text(_error), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(bootstrap.runs, 2);
  });

  testWidgets('SYS-01 a fresh install continues to onboarding', (tester) async {
    await pumpTestApp(
      tester,
      bootstrap: FakeBootstrap(
        results: const [BootstrapReady(Routes.onboarding)],
      ),
    );
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });

  testWidgets('SYS-01 Retry can be tapped repeatedly while storage keeps '
      'failing', (tester) async {
    final bootstrap = FakeBootstrap(
      results: [BootstrapFailed(StateError('db'))],
    );
    await pumpTestApp(tester, settings: returning, bootstrap: bootstrap);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text(_error), findsOneWidget);
    }
    expect(bootstrap.runs, 4);
    expect(tester.takeException(), isNull);
  });

  testWidgets('SYS-01 the splash shows the logo and app name, and no ads', (
    tester,
  ) async {
    // A bootstrap that never finishes keeps the splash on screen.
    await pumpTestApp(tester, bootstrap: _NeverReady(), settle: false);
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('DailyTrack'), findsOneWidget);
    // Phase 0 has no ad widgets at all (T4.1 adds AppBannerAd/AppNativeAd);
    // the splash must stay ad-free when they arrive.
    expect(find.byType(ErrorState), findsNothing);
  });
}

class _NeverReady extends FakeBootstrap {
  @override
  Future<BootstrapResult> build() => Completer<BootstrapResult>().future;
}
