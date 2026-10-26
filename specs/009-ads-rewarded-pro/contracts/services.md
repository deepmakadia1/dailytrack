# Service Contracts: Ads, Rewarded Unlocks, and Pro

Dart signatures are binding for names, parameters, and behavior. Doc comments and private details
are up to the implementation. "Pure" means no Flutter or plugin imports.

---

## 1. `lib/core/ads/ad_service.dart` (Flutter allowed, no plugin)

```dart
abstract interface class AdService {
  /// Starts the ads SDK after consent allows it. Idempotent. Never throws.
  Future<void> init();

  /// True while ads may be requested: SDK started, consent allows ads, not disposed.
  bool get adsEnabled;
  Stream<bool> get adsEnabledStream;

  /// For AppBannerAd and AppNativeAd only. Null = no ad (disabled, no unit ID, or failed).
  Future<AdView?> loadBanner({required double width});
  Future<AdView?> loadNative(NativePlacement placement, NativeAdLook look);

  Future<void> preloadInterstitial();

  /// Applies the trigger to the cap (domain/interstitial_cap.dart) and shows a
  /// preloaded interstitial only when everything allows it (research R10).
  /// Returns after the decision; never waits for a load.
  Future<void> maybeShowInterstitial(AdTrigger trigger);

  /// Loads the one rewarded ad PRM-02 needs. True when ready.
  Future<bool> prepareRewarded();

  /// Shows the prepared rewarded ad. [onEarned] runs from onUserEarnedReward and is
  /// awaited before the outcome completes. Never calls [onEarned] for other outcomes.
  Future<RewardedOutcome> showRewarded(
    FeatureKey key, {
    required Future<void> Function() onEarned,
  });

  /// Releases preloaded ads. Called from the provider's onDispose.
  Future<void> dispose();
}

/// Pro, consent not given, and tests. loadBanner and loadNative return null, maybeShow does
/// nothing, prepareRewarded returns false, and showRewarded returns notReady.
final class NoAdsService implements AdService { const NoAdsService(); /* … */ }
```

`lib/core/ads/ad_view.dart`:

```dart
abstract interface class AdView {
  double get height;          // logical px; banner: ad size height; native: template height
  Widget build(BuildContext context);
  void dispose();
}

/// Template colors and text styles, built from the theme by AppNativeAd.
final class NativeAdLook { /* surface, onSurface, primary, onPrimary, radius, text styles */ }
```

## 2. `lib/core/ads/ad_providers.dart`

```dart
@Riverpod(keepAlive: true) AdConfig adConfig(Ref ref);                 // AdConfig.defaults
@Riverpod(keepAlive: true) AdUnitIds adUnitIds(Ref ref);               // overridden in composition root
@Riverpod(keepAlive: true) ConsentService consentService(Ref ref);     // overridden; tests: FakeConsentService
@Riverpod(keepAlive: true) AdScreenProbe adScreenProbe(Ref ref);       // overridden
@Riverpod(keepAlive: true) class AdsSessionGate { bool build() => false; void startedWithAds(bool v); }
@Riverpod(keepAlive: true) bool adsAllowed(Ref ref);    // !removeAdsPurchased (live) && AdsSessionGate
@Riverpod(keepAlive: true) AdService adService(Ref ref); // default NoAdsService; composition root:
                                                         // adsAllowed ? AdMobAdService(...) : NoAdsService
                                                         // ref.onDispose(service.dispose)
@Riverpod(keepAlive: true) Stream<bool> privacyOptionsRequired(Ref ref); // false while Pro owned
@Riverpod(keepAlive: true) AdDebugTools adDebugTools(Ref ref);          // no-op unless dev
```

`test/helpers/test_app.dart` keeps `adServiceProvider.overrideWithValue(ads ?? const
NoAdsService())`. A new `FakeAdService` (`test/helpers/fakes.dart`) records calls and scripts
`loadBanner`/`loadNative` results, `prepareRewarded`, and `showRewarded` outcomes (calling
`onEarned` for `earned`).

## 3. Widgets (`lib/core/ads/widgets/`)

```dart
class AppBannerAd extends ConsumerStatefulWidget { const AppBannerAd({super.key}); }
class AppNativeAd extends ConsumerStatefulWidget {
  const AppNativeAd({required this.placement, super.key});
  final NativePlacement placement;
}
```

Contract (FR-006 to FR-008, research R6 and R7):
- Height is 0 until an `AdView` is loaded, then animates to `AdView.height`, plus the 8 dp banner
  gap or 12 dp native margins. The animation takes 200 ms, or 0 ms when animations are disabled.
- On a null load, the widget retries after `AdConfig.retryBackoff`, then gives up while mounted.
- It disposes its view on unmount, and when `adServiceProvider` changes.
- `AppNativeAd` draws the "Ad" badge (`labelSmall` on `AppTokens.adBadge`) top-left in its card
  header. Semantics: "Advertisement".
- Neither widget imports `google_mobile_ads`.

## 4. Rewarded unlock (`lib/core/ads/rewarded_unlock.dart`)

```dart
/// Opens PRM-02 for [key]. True only when the reward was earned and [grant] (or the default
/// unlock write) finished. Default grant: UnlockRepository.grant(key, source: rewardedAd,
/// expiresAt: duration == null ? null : effectiveNow + duration).
Future<bool> showRewardedUnlock(
  BuildContext context,
  FeatureKey key, {
  Duration? duration,
  Future<void> Function()? grant,
  String? subjectName, // theme or habit name for the sheet title
});

abstract interface class RewardedUnlockPresenter {
  Future<bool> present(BuildContext context, RewardedUnlockRequest request);
}
@Riverpod(keepAlive: true) RewardedUnlockPresenter rewardedUnlockPresenter(Ref ref); // throws unless overridden
```

`RewardedUnlockRequest`: `key`, `duration`, `grant` (resolved, never null), `subjectName`.
Asserts `key != FeatureKey.adFreeDay` (FR-035). The composition root binds
`PremiumRewardedUnlockPresenter` from `lib/features/premium/presentation/`. Widget tests bind a
`FakeRewardedUnlockPresenter` (scripted `true`/`false`), or the real presenter with
`FakeAdService` for PRM-02 tests.

## 5. Consent (`lib/core/ads/domain/consent_service.dart`)

```dart
abstract interface class ConsentService {
  /// Updates consent info and shows the form if required. [beforeForm] runs right before a
  /// form is shown (removes the native splash). The info update is limited to [timeout];
  /// the form is not. Never throws.
  Future<ConsentResult> gather({
    required Future<void> Function() beforeForm,
    required Duration timeout,
  });
  bool get canRequestAds;                    // from the SDK's stored state; works offline
  Stream<bool> get privacyOptionsRequired;
  Future<void> showPrivacyOptionsForm();
  Future<void> resetForDebug();              // dev only (R15)
}
```

`UmpConsentService` (in `data/`) is the only implementation. Dev builds add `ConsentDebugSettings`
from `UMP_DEBUG_GEOGRAPHY` / `UMP_TEST_DEVICE_ID`.

## 6. Interstitial cap (`lib/core/ads/domain/`, pure)

```dart
final class InterstitialCap {
  const InterstitialCap(this.config);
  CapDecision check(InterstitialCapState s,
      {required DateTime effectiveNow, required String todayKey, required AdTrigger trigger});
  InterstitialCapState afterShown(InterstitialCapState s,
      {required DateTime now, required String todayKey});
  InterstitialCapState afterExpenseSave(InterstitialCapState s);
}
final class AdSession {
  const AdSession(this.config);
  bool isNewSession({required DateTime now, DateTime? backgroundedAt});
  ({bool isFirstSessionOfDay, String lastSessionDayKey}) start(
      {required String todayKey, String? lastSessionDayKey});
}
List<int> nativeAdRowIndexes(int rowCount, {int first = 8, int every = 15, int max = 3});
// nativeAdRowIndexes(40) == [8, 23, 38]; (8) == []; (9) == [8]
```

The order of checks and the reasons are in data-model.md §3. The functions are total: they never
throw, and they don't use the clock.

## 7. Screen probe and debug tools

```dart
abstract interface class AdScreenProbe { bool get canShowFullScreenAd; }
// Composition root: lifecycle resumed && !lockSession.locked && current GoRouter location
// is not in nonReadingRoutes (research R10).

abstract interface class AdDebugTools { Future<void> resetCounters(); }
```

## 8. Feature gate (`lib/core/feature_gate/`)

- New pure `UnlockPolicy` (data-model.md §3). `DriftFeatureGate` delegates to it and passes
  `proOwned: settings.removeAdsPurchased`. The public `FeatureGate` interface is unchanged.
- `UnlockRepository` is unchanged.

## 9. Billing (`lib/core/billing/`)

```dart
// domain/ (pure)
abstract interface class ProStore {
  Stream<List<StorePurchase>> get purchaseUpdates;
  Future<bool> isAvailable();
  Future<StoreProduct?> loadProduct();           // pro_lifetime; null = unavailable
  Future<void> buy(StoreProduct product);        // result arrives on purchaseUpdates
  Future<OwnershipCheck> queryOwnership();       // queryPastPurchases; also completes unacked
  Future<void> complete(StorePurchase purchase); // acknowledge
}
final class ProOwnershipPolicy { static ProState apply(ProState s, OwnershipCheck c); }

// root (Riverpod, no plugin)
@Riverpod(keepAlive: true) ProStore proStore(Ref ref);          // overridden; tests: FakeProStore
@Riverpod(keepAlive: true) Stream<bool> proOwned(Ref ref);      // from appSettings.removeAdsPurchased
@Riverpod(keepAlive: true) ProService proService(Ref ref);

final class ProService {
  /// Subscribes to purchaseUpdates. Called once in bootstrap before any other billing call.
  void start();
  /// Start-up ownership check (unawaited after the first frame). Applies ProOwnershipPolicy.
  Future<void> verifyOwnership();
  Future<StoreProduct?> loadProduct();
  Future<void> buy(StoreProduct product);        // calls expectExternalActivity() first
  /// "Restore purchase": owned → Pro; never counts toward the removal streak.
  Future<RestoreResult> restore();               // restored | notFound | unavailable
  Stream<PurchaseEvent> get events;              // pending | purchased | error | canceled, for PRM-01
}

// data/ (only in_app_purchase importer)
final class InAppPurchaseProStore implements ProStore { /* research R13 */ }
```

## 10. Settings repository additions

The method names are listed in data-model.md §1. `SettingsRepositoryImpl` writes each group in
one Drift transaction, and `FakeSettingsRepository` mirrors them.

## 11. Reset service

`DriftAppResetService.eraseAll` re-inserts the `adsInstallAt` row it read before deleting, inside
the same transaction. Everything else is unchanged.

## 12. Bootstrap (`lib/app/bootstrap.dart`), new step 3

```text
3a. adsInstallAt ??= effectiveNow                     (AdsSettingsStore)
3b. proService.start()                                (purchase stream first)
3b′. if proRemovalPending: setProState(owned: false, notOwnedStreak: 0, pending: false,
     removalPending: false) before consent, ads, or the gate are read (analysis I1)
3c. if removeAdsPurchased: AdsSessionGate = false; skip ads entirely
    else if consent.canRequestAds: AdsSessionGate = true; adService.init() unawaited;
         consent.gather(...) unawaited (refresh)
    else: result = await consent.gather(beforeForm: removeNativeSplash, timeout: 5 s);
          AdsSessionGate = result.canRequestAds; if so adService.init() unawaited
3d. adSession.start(...) (first session of day)
3e. after first frame: proService.verifyOwnership() unawaited;
    after 10 s: adService.preloadInterstitial() unawaited
```

Steps 3a–3d never throw out of bootstrap: failures are swallowed, and ads stay off for the
session.

## 13. Layering (enforced by `test/core/theme/no_hardcoded_style_test.dart`)

- `package:google_mobile_ads` is imported only under `lib/core/ads/data/`.
- `package:in_app_purchase` and `package:in_app_purchase_android` are imported only under
  `lib/core/billing/data/`.
- `lib/core/ads/domain/` and `lib/core/billing/domain/` are pure Dart.
- `lib/features/premium/` imports no other feature. Other features import no `features/premium/`
  file.
- Expense and habit may import `lib/core/ads/{ad_service,ad_providers,rewarded_unlock}.dart`,
  `lib/core/ads/widgets/`, and `lib/core/ads/domain/ad_trigger.dart`, never `lib/core/ads/data/`.
