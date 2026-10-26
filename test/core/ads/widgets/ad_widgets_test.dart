import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/widgets/app_banner_ad.dart';
import 'package:dailytrack/core/ads/widgets/app_native_ad.dart';
import 'package:dailytrack/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';
import '../../../helpers/widget_wrapper.dart';

void main() {
  Future<ProviderContainer> pump(
    WidgetTester tester,
    Widget child, {
    AdService ads = const NoAdsService(),
  }) async {
    final container = ProviderContainer(
      overrides: [adServiceProvider.overrideWithValue(ads)],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: themed(child)),
    );
    await tester.pumpAndSettle();
    return container;
  }

  Widget column(Widget ad) => Column(
    children: [
      const SizedBox(key: Key('above'), height: 100),
      ad,
      const SizedBox(key: Key('below'), height: 100),
    ],
  );

  group('§11 with NoAdsService, no ad widget occupies any space', () {
    testWidgets('AppBannerAd is zero height', (tester) async {
      await pump(tester, column(const AppBannerAd()));
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
      expect(
        tester.getTopLeft(find.byKey(const Key('below'))).dy,
        tester.getBottomLeft(find.byKey(const Key('above'))).dy,
      );
    });

    testWidgets('AppNativeAd is zero height for every placement', (
      tester,
    ) async {
      await pump(
        tester,
        Column(
          children: [
            for (final p in NativePlacement.values)
              AppNativeAd(key: ValueKey(p), placement: p),
          ],
        ),
      );
      for (final p in NativePlacement.values) {
        expect(tester.getSize(find.byKey(ValueKey(p))).height, 0);
      }
      expect(find.text('Ad'), findsNothing);
    });

    testWidgets('a banner in the AppScaffold slot adds no space above the '
        'bottom edge (no empty box, §15.8)', (tester) async {
      await pump(
        tester,
        const AppScaffold(
          title: 'Expenses',
          body: SizedBox.expand(key: Key('body')),
          bannerSlot: AppBannerAd(),
        ),
      );
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
    });

    testWidgets('no pending retry timers are left behind', (tester) async {
      await pump(tester, column(const AppBannerAd()));
      await tester.pump(const Duration(minutes: 5));
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
    });
  });

  group('US1-5 a loaded ad animates in (FR-007)', () {
    testWidgets('AppBannerAd grows to the ad height plus the 8 dp gap', (
      tester,
    ) async {
      final ads = FakeAdService(view: FakeAdView(height: 50));
      await pump(tester, column(const AppBannerAd()), ads: ads);
      expect(ads.bannerLoads, 1);
      expect(tester.getSize(find.byType(AppBannerAd)).height, 58);
    });

    testWidgets('a loaded banner in the AppScaffold slot is only as tall as '
        'the ad, never the whole screen (§15.10 review finding)', (
      tester,
    ) async {
      final ads = FakeAdService(view: FakeAdView(height: 50));
      await pump(
        tester,
        const AppScaffold(
          title: 'Expenses',
          body: SizedBox.expand(key: Key('body')),
          bannerSlot: AppBannerAd(),
        ),
        ads: ads,
      );
      expect(tester.getSize(find.byType(AppBannerAd)).height, 58);
      final screen = tester.getSize(find.byType(Scaffold).first).height;
      expect(
        tester.getSize(find.byKey(const Key('body'))).height,
        greaterThan(screen / 2),
      );
    });

    testWidgets('AppNativeAd shows the "Ad" badge top-left', (tester) async {
      final ads = FakeAdService(view: FakeAdView(height: 320));
      await pump(
        tester,
        column(const AppNativeAd(placement: NativePlacement.home)),
        ads: ads,
      );
      expect(ads.nativeLoads, 1);
      final badge = tester.getRect(find.byKey(const Key('native_ad_badge')));
      final card = tester.getRect(find.byType(Card));
      expect(find.text('Ad'), findsOneWidget);
      expect(badge.left - card.left, lessThan(card.width / 4));
      expect(badge.top - card.top, lessThan(card.height / 4));
    });

    testWidgets('US1-12 a failed load leaves the slot at zero height', (
      tester,
    ) async {
      final ads = FakeAdService();
      await pump(tester, column(const AppBannerAd()), ads: ads);
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
      // Retries are scheduled while ads are enabled; drain them.
      await tester.pump(const Duration(seconds: 30));
      await tester.pump(const Duration(seconds: 60));
      await tester.pump(const Duration(seconds: 120));
      expect(ads.bannerLoads, 4);
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
    });

    testWidgets('US1-13 switching to NoAdsService releases the ad and '
        'collapses the slot', (tester) async {
      final view = FakeAdView(height: 50);
      final ads = FakeAdService(view: view);
      // Like the composition root, the service follows a switch (there:
      // adsAllowed, which a Pro purchase turns off).
      final container = ProviderContainer(
        overrides: [
          adServiceProvider.overrideWith(
            (ref) => ref.watch(_adsOnProvider) ? ads : const NoAdsService(),
          ),
        ],
      );
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: themed(column(const AppBannerAd())),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppBannerAd)).height, 58);
      container.read(_adsOnProvider.notifier).turnOff();
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(AppBannerAd)).height, 0);
      expect(view.disposeCalls, 1);
    });
  });
}

final _adsOnProvider = NotifierProvider<_AdsOn, bool>(_AdsOn.new);

class _AdsOn extends Notifier<bool> {
  @override
  bool build() => true;

  void turnOff() => state = false;
}
