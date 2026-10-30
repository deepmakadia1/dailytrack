import 'package:clock/clock.dart';
import 'package:dailytrack/app/production_overrides.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/data/admob_ad_service.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/feature_gate/data/drift_feature_gate.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fakes.dart';

final class _NoUnlocks implements UnlockRepository {
  @override
  Stream<List<Unlock>> watchLive() => Stream.value(const []);

  @override
  Future<Unlock> grant(
    FeatureKey key, {
    required UnlockSource source,
    DateTime? expiresAt,
  }) => throw UnimplementedError();

  @override
  Future<void> revoke(String unlockId) async {}

  @override
  Future<bool> consumeOne(FeatureKey key) async => false;
}

/// Pro switches ads off and unlocks everything (feature 009 T084, T095,
/// T009a; spec PRM-01, FR-039, FR-043).
void main() {
  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('FR-039 a purchase mid-session swaps the AdMob service for '
      'NoAdsService and releases it, so no ad of any kind is requested '
      'again', () async {
    final settings = FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        consentServiceProvider.overrideWithValue(FakeConsentService()),
        adServiceProvider.overrideWith(bindAdService),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(appSettingsProvider, (_, _) {})
      ..listen(adServiceProvider, (_, _) {});
    container.read(adsSessionGateProvider.notifier).startedWithAds = true;
    await settle();
    final before = container.read(adServiceProvider);
    expect(before, isA<AdMobAdService>());

    settings.replace(settings.current.copyWith(removeAdsPurchased: true));
    await settle();
    await settle();
    expect(container.read(adServiceProvider), isA<NoAdsService>());
    expect(before.adsEnabled, isFalse);
    expect(await before.loadBanner(width: 360), isNull);
  });

  test('a cold start that began without ads never gets them back in the '
      'same session, even if Pro goes away (clarification Q1)', () async {
    final settings = FakeSettingsRepository(
      initial: const AppSettings(removeAdsPurchased: true),
    );
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        adServiceProvider.overrideWith(bindAdService),
      ],
    );
    addTearDown(container.dispose);
    container.listen(appSettingsProvider, (_, _) {});
    await settle();
    settings.replace(settings.current.copyWith(removeAdsPurchased: false));
    await settle();
    expect(container.read(adServiceProvider), isA<NoAdsService>());
  });

  group('"Unlock all features (debug)" acts as Pro (FR-037, FR-041)', () {
    Future<(ProviderContainer, FakeSettingsRepository)> start({
      required bool debugTools,
    }) async {
      final settings = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          consentServiceProvider.overrideWithValue(FakeConsentService()),
          adServiceProvider.overrideWith(bindAdService),
          debugToolsAvailableProvider.overrideWithValue(debugTools),
        ],
      );
      addTearDown(container.dispose);
      container
        ..listen(appSettingsProvider, (_, _) {})
        ..listen(adServiceProvider, (_, _) {});
      container.read(adsSessionGateProvider.notifier).startedWithAds = true;
      await settle();
      return (container, settings);
    }

    test(
      'turning it on mid-session switches ads off and reports Pro',
      () async {
        final (container, settings) = await start(debugTools: true);
        expect(container.read(adServiceProvider), isA<AdMobAdService>());
        expect(container.read(proOwnedProvider), isFalse);

        settings.replace(settings.current.copyWith(debugUnlockAll: true));
        await settle();
        await settle();
        expect(container.read(proOwnedProvider), isTrue);
        expect(container.read(adsAllowedProvider), isFalse);
        expect(container.read(adServiceProvider), isA<NoAdsService>());
      },
    );

    test('ignored without dev tools (prod)', () async {
      final (container, settings) = await start(debugTools: false);
      settings.replace(settings.current.copyWith(debugUnlockAll: true));
      await settle();
      await settle();
      expect(container.read(proOwnedProvider), isFalse);
      expect(container.read(adsAllowedProvider), isTrue);
      expect(container.read(adServiceProvider), isA<AdMobAdService>());
    });
  });

  group('permanent unlocks from Pro (FR-039)', () {
    late FakeSettingsRepository settings;
    late DriftFeatureGate gate;

    setUp(() {
      settings = FakeSettingsRepository(
        initial: const AppSettings(removeAdsPurchased: true),
      );
      gate = DriftFeatureGate(
        _NoUnlocks(),
        settings,
        const Clock(),
        debugToolsAvailable: false,
      );
    });

    test('every premium feature is open with Pro and no unlock rows', () async {
      for (final key in [
        FeatureKey.advancedReports,
        FeatureKey.exportCsv,
        FeatureKey.exportPdf,
        FeatureKey.streakFreeze,
        FeatureKey.premiumTheme('midnight'),
      ]) {
        expect(await gate.isUnlocked(key), isTrue, reason: key.storageKey);
      }
    });

    test('T009a a staged removal keeps everything open for the whole '
        'session (locks return only from the next cold start)', () async {
      settings.replace(settings.current.copyWith(proRemovalPending: true));
      final values = <bool>[];
      final sub = gate
          .watch(FeatureKey.premiumTheme('ocean'))
          .listen(values.add);
      await settle();
      await settle();
      await sub.cancel();
      expect(values, everyElement(isTrue));
    });
  });
}
