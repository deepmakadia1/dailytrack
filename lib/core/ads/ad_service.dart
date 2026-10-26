import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/rewarded_outcome.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';

/// All ad code goes through this interface (spec §11, Constitution VI).
/// Screens use it only through `AppBannerAd`, `AppNativeAd`, and
/// `adServiceProvider` (feature 009 contracts/services.md §1).
abstract interface class AdService {
  /// Starts the ads SDK after consent allows it. Idempotent; never throws.
  Future<void> init();

  /// True while ads may be requested: SDK started, consent allows ads, and
  /// the service is not disposed.
  bool get adsEnabled;

  Stream<bool> get adsEnabledStream;

  /// For `AppBannerAd` only. Null means no ad: disabled, no unit ID, or the
  /// load failed.
  Future<AdView?> loadBanner({required double width});

  /// For `AppNativeAd` only. Null means no ad.
  Future<AdView?> loadNative(NativePlacement placement, NativeAdLook look);

  Future<void> preloadInterstitial();

  /// Shows a preloaded interstitial only when the global cap and the
  /// current screen allow it. Never waits for a load.
  Future<void> maybeShowInterstitial(AdTrigger trigger);

  /// Loads the one rewarded ad PRM-02 needs. True when ready.
  Future<bool> prepareRewarded();

  /// Shows the prepared rewarded ad. [onEarned] runs from the SDK's
  /// reward callback and is awaited before an `earned` outcome; it never
  /// runs for any other outcome.
  Future<RewardedOutcome> showRewarded(
    FeatureKey key, {
    required Future<void> Function() onEarned,
  });

  /// Releases preloaded ads; later loads return null.
  Future<void> dispose();
}

/// Used for Pro users, when consent does not allow ads, and in tests. Ad
/// widgets backed by this service take no space at all (spec §11 AC).
final class NoAdsService implements AdService {
  const new();

  @override
  Future<void> init() async {}

  @override
  bool get adsEnabled => false;

  @override
  Stream<bool> get adsEnabledStream => Stream.value(false);

  @override
  Future<AdView?> loadBanner({required double width}) async => null;

  @override
  Future<AdView?> loadNative(
    NativePlacement placement,
    NativeAdLook look,
  ) async => null;

  @override
  Future<void> preloadInterstitial() async {}

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {}

  @override
  Future<bool> prepareRewarded() async => false;

  @override
  Future<RewardedOutcome> showRewarded(
    FeatureKey key, {
    required Future<void> Function() onEarned,
  }) async => RewardedOutcome.notReady;

  @override
  Future<void> dispose() async {}
}
