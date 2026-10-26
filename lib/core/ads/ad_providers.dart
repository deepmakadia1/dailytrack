import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/domain/ad_config.dart';
import 'package:dailytrack/core/ads/domain/ad_screen_probe.dart';
import 'package:dailytrack/core/ads/domain/ad_unit_ids.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/ads/interstitial_coordinator.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'
    show ProviderListenableSelect;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ad_providers.g.dart';

// Typed to interfaces only, so screens can depend on them (Constitution II).
// The defaults never touch the ads SDK: `production_overrides.dart` binds
// the AdMob and UMP implementations; tests keep the defaults or bind fakes.

/// Every tunable ad number (spec §11).
@Riverpod(keepAlive: true)
AdConfig adConfig(Ref ref) => AdConfig.defaults;

/// The ad unit IDs this build uses (feature 009 research R3).
@Riverpod(keepAlive: true)
AdUnitIds adUnitIds(Ref ref) => AdUnitIds.none;

/// Ad consent (UMP). Default: no consent SDK, so ads are never allowed.
@Riverpod(keepAlive: true)
ConsentService consentService(Ref ref) => const NoConsentService();

/// Whether this app session started with ads (feature 009 research R5).
/// Set once by SYS-01: false when Pro was owned at cold start or consent
/// does not allow ads. A Pro purchase turns ads off at once through
/// [adsAllowed]; losing Pro only takes effect from the next cold start.
@Riverpod(keepAlive: true)
class AdsSessionGate extends _$AdsSessionGate {
  @override
  bool build() => false;

  // A setter, not a field, because the notifier's state is the value.
  // ignore: avoid_setters_without_getters
  set startedWithAds(bool allowed) => state = allowed;
}

/// Ads may be requested right now: the session started with ads and Pro is
/// not owned (FR-002, FR-043). Unknown settings count as Pro, so nothing is
/// requested before they load.
@Riverpod(keepAlive: true)
bool adsAllowed(Ref ref) {
  final pro = ref.watch(
    appSettingsProvider.select((s) => s.value?.removeAdsPurchased ?? true),
  );
  return ref.watch(adsSessionGateProvider) && !pro;
}

/// The ad service screens use. Default `NoAdsService`; the composition root
/// switches between AdMob and no ads from [adsAllowed].
@Riverpod(keepAlive: true)
AdService adService(Ref ref) => const NoAdsService();

/// Whether SET-01 shows "Ad privacy choices" (FR-014): only while the
/// consent SDK requires it and Pro is not owned.
@Riverpod(keepAlive: true)
Stream<bool> privacyOptionsRequired(Ref ref) {
  final pro = ref.watch(
    appSettingsProvider.select((s) => s.value?.removeAdsPurchased ?? false),
  );
  if (pro) return Stream.value(false);
  return ref.watch(consentServiceProvider).privacyOptionsRequired;
}

/// Whether a full-screen ad may appear now (FR-023). Default: never; the
/// composition root binds the router- and lock-aware probe.
@Riverpod(keepAlive: true)
AdScreenProbe adScreenProbe(Ref ref) => const NeverShowProbe();

/// Sessions, the EXP-02 save counter, and the global interstitial cap
/// (spec §11). Kept for the whole process, so the counter survives the ad
/// service being rebuilt.
@Riverpod(keepAlive: true)
InterstitialCoordinator interstitialCoordinator(Ref ref) {
  final coordinator = InterstitialCoordinator(
    settings: ref.watch(settingsRepositoryProvider),
    clock: ref.watch(clockProvider),
    config: ref.watch(adConfigProvider),
    probe: ref.watch(adScreenProbeProvider),
  );
  ref.onDispose(coordinator.dispose);
  return coordinator;
}

/// Dev-only "Reset ad counters" (FR-048): clears the cap's counters and the
/// stored consent. The SET-01 tile exists only in dev builds.
@Riverpod(keepAlive: true)
Future<void> Function() resetAdCounters(Ref ref) => () async {
  await ref.read(interstitialCoordinatorProvider).resetForDebug();
  await ref.read(consentServiceProvider).resetForDebug();
};
