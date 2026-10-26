import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/ad_screen_probe.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fake_webview.dart';
import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';
import '../expense/fakes.dart';

/// Dev-only "Reset ad counters" in SET-01 (feature 009 T114, FR-047,
/// FR-048, spec US5-5, US5-6).
void main() {
  setUp(FakeWebViewPlatform.install);
  const tile = Key('reset_ad_counters');

  Future<(FakeSettingsRepository, FakeConsentService)> open(
    WidgetTester tester, {
    required bool devTools,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 2600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final consent = FakeConsentService();
    final settings = FakeSettingsRepository(
      initial: AppSettings(
        onboardingDone: true,
        locale: 'en',
        adsInstallAt: fakeNow.toUtc().millisecondsSinceEpoch,
        adsLastInterstitialAt: fakeNow.toUtc().millisecondsSinceEpoch,
        adsInterstitialDay: '2026-10-14',
        adsInterstitialsToday: 4,
      ),
    );
    await pumpTestApp(
      tester,
      settings: settings,
      debugTools: devTools,
      overrides: [
        consentServiceProvider.overrideWithValue(consent),
        adScreenProbeProvider.overrideWithValue(const NeverShowProbe()),
      ],
    );
    routerOf(tester).go(Routes.more);
    await tester.pumpAndSettle();
    return (settings, consent);
  }

  testWidgets('US5-5 dev build: "Reset ad counters" clears the cap counters, '
      'meets the install-age rule, resets consent, and confirms', (
    tester,
  ) async {
    final (settings, consent) = await open(tester, devTools: true);
    await tester.ensureVisible(find.byKey(tile));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(tile));
    await tester.pumpAndSettle();
    final s = settings.current;
    expect(s.adsLastInterstitialAt, isNull);
    expect(s.adsInterstitialDay, isNull);
    expect(s.adsInterstitialsToday, 0);
    final twoDaysAgo = fakeNow.toUtc().subtract(const Duration(days: 2));
    expect(s.adsInstallAt, lessThan(twoDaysAgo.millisecondsSinceEpoch));
    expect(consent.resetCalls, 1);
    expect(find.text('Ad counters reset'), findsOneWidget);
  });

  testWidgets('US5-5 prod build: the action does not exist', (tester) async {
    await open(tester, devTools: false);
    expect(find.byKey(tile), findsNothing);
    expect(find.text('Reset ad counters'), findsNothing);
  });

  testWidgets('US5-6 the debug unlock switch is still there next to it', (
    tester,
  ) async {
    await open(tester, devTools: true);
    expect(find.byKey(const Key('debug_unlock_all')), findsOneWidget);
  });
}
