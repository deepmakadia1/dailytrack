import 'dart:async';

import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/ads/data/admob_ad_views.dart';
import 'package:dailytrack/core/ads/data/admob_interstitial_player.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/ad_unit_ids.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/ads/domain/rewarded_outcome.dart';
import 'package:dailytrack/core/ads/interstitial_coordinator.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// [AdService] over `google_mobile_ads` (spec §11, feature 009 research R5).
/// One of the only files that import the plugin.
///
/// Nothing is requested until [init] has run and consent allows ads, and
/// requests never carry keywords or app data (FR-010, FR-012).
/// Interstitials go through the [InterstitialCoordinator] (the global
/// cap). Rewarded ads load only when PRM-02 opens, and the reward is
/// granted only from the SDK's reward callback (FR-030).
// Device bindings; exercised on a device (quickstart §4.1), not unit tests.
// coverage:ignore-start
final class AdMobAdService implements AdService {
  new({
    required this.consent,
    required this.ids,
    required this.coordinator,
    this.testDeviceIds = const [],
  });

  final ConsentService consent;
  final AdUnitIds ids;
  final InterstitialCoordinator coordinator;
  final List<String> testDeviceIds;

  late final AdMobInterstitialPlayer _interstitials = AdMobInterstitialPlayer(
    unitId: ids.interstitial,
    canRequest: () => adsEnabled,
  );

  /// The rewarded ad PRM-02 prepared, if any.
  RewardedAd? _rewarded;

  /// The first interstitial loads after startup has settled (cold start is
  /// never slowed, research R10).
  static const Duration _firstPreloadDelay = Duration(seconds: 10);
  Timer? _firstPreload;

  final _enabledChanges = StreamController<bool>.broadcast();
  Future<void>? _starting;
  var _enabled = false;
  var _disposed = false;

  /// Nothing in an ad request ever describes the user or their data.
  static const AdRequest _request = AdRequest();

  @override
  Future<void> init() => _starting ??= _start();

  Future<void> _start() async {
    try {
      if (!await consent.canRequestAds()) return;
      // Child-directed and under-age tags stay unspecified (spec §11).
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: testDeviceIds),
      );
      await MobileAds.instance.initialize();
      _setEnabled(enabled: true);
      _firstPreload = Timer(
        _firstPreloadDelay,
        () => unawaited(preloadInterstitial()),
      );
    } on Object {
      // Ads never block or break the app.
      _setEnabled(enabled: false);
    }
  }

  void _setEnabled({required bool enabled}) {
    final next = enabled && !_disposed;
    if (next == _enabled) return;
    _enabled = next;
    if (!_enabledChanges.isClosed) _enabledChanges.add(next);
  }

  @override
  bool get adsEnabled => _enabled && !_disposed;

  @override
  Stream<bool> get adsEnabledStream async* {
    yield adsEnabled;
    yield* _enabledChanges.stream;
  }

  /// Waits for a running [init]; false when ads may not be requested.
  Future<bool> _ready() async {
    final starting = _starting;
    if (starting == null) return false;
    await starting;
    return adsEnabled;
  }

  @override
  Future<AdView?> loadBanner({required double width}) async {
    final unitId = ids.banner;
    if (unitId == null || !await _ready()) return null;
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
        width.truncate(),
      );
      if (size == null || !adsEnabled) return null;
      final loaded = Completer<AdView?>();
      final ad = BannerAd(
        size: size,
        adUnitId: unitId,
        request: _request,
        listener: BannerAdListener(
          onAdLoaded: (ad) => loaded.complete(
            AdMobAdView(
              ad as AdWithView,
              height: size.height.toDouble(),
              width: size.width.toDouble(),
            ),
          ),
          onAdFailedToLoad: (ad, _) {
            unawaited(ad.dispose());
            loaded.complete(null);
          },
        ),
      );
      await ad.load();
      return _keepIfEnabled(await loaded.future);
    } on Object {
      return null;
    }
  }

  @override
  Future<AdView?> loadNative(
    NativePlacement placement,
    NativeAdLook look,
  ) async {
    final unitId = ids.native;
    if (unitId == null || !await _ready()) return null;
    try {
      final loaded = Completer<AdView?>();
      final ad = NativeAd(
        adUnitId: unitId,
        request: _request,
        nativeTemplateStyle: _templateStyle(look),
        listener: NativeAdListener(
          onAdLoaded: (ad) => loaded.complete(
            AdMobAdView(ad as AdWithView, height: nativeTemplateHeight),
          ),
          onAdFailedToLoad: (ad, _) {
            unawaited(ad.dispose());
            loaded.complete(null);
          },
        ),
      );
      await ad.load();
      return _keepIfEnabled(await loaded.future);
    } on Object {
      return null;
    }
  }

  /// An ad that finished loading after [dispose] (e.g. a Pro purchase) is
  /// released instead of shown.
  AdView? _keepIfEnabled(AdView? view) {
    if (view != null && !adsEnabled) {
      view.dispose();
      return null;
    }
    return view;
  }

  static NativeTemplateStyle _templateStyle(NativeAdLook look) =>
      NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: look.surface,
        cornerRadius: look.cornerRadius,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: look.onPrimary,
          backgroundColor: look.primary,
          style: NativeTemplateFontStyle.bold,
          size: look.bodySize,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: look.onSurface,
          style: NativeTemplateFontStyle.bold,
          size: look.titleSize,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: look.onSurfaceVariant,
          size: look.bodySize,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: look.onSurfaceVariant,
          size: look.bodySize,
        ),
      );

  @override
  Future<void> preloadInterstitial() async {
    if (adsEnabled) await _interstitials.preload();
  }

  @override
  Future<void> maybeShowInterstitial(AdTrigger trigger) async {
    if (!adsEnabled) return;
    await coordinator.handle(trigger, _interstitials);
  }

  @override
  Future<bool> prepareRewarded() async {
    final unitId = ids.rewarded;
    if (unitId == null || !await _ready()) return false;
    if (_rewarded != null) return true;
    try {
      final loaded = Completer<bool>();
      await RewardedAd.load(
        adUnitId: unitId,
        request: _request,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            if (adsEnabled) {
              _rewarded = ad;
            } else {
              unawaited(ad.dispose());
            }
            if (!loaded.isCompleted) loaded.complete(adsEnabled);
          },
          onAdFailedToLoad: (_) {
            if (!loaded.isCompleted) loaded.complete(false);
          },
        ),
      );
      return await loaded.future;
    } on Object {
      return false;
    }
  }

  @override
  Future<RewardedOutcome> showRewarded(
    FeatureKey key, {
    required Future<void> Function() onEarned,
  }) async {
    final ad = _rewarded;
    if (ad == null || !adsEnabled) return RewardedOutcome.notReady;
    _rewarded = null;
    Future<void>? granting;
    final ended = Completer<RewardedOutcome>();
    ad.fullScreenContentCallback = FullScreenContentCallback<RewardedAd>(
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        if (ended.isCompleted) return;
        final grant = granting;
        if (grant == null) {
          ended.complete(RewardedOutcome.closedEarly);
        } else {
          // The grant finishes before the caller hears "earned".
          unawaited(
            grant.then(
              (_) => ended.complete(RewardedOutcome.earned),
              onError: (Object _) => ended.complete(RewardedOutcome.failed),
            ),
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        if (!ended.isCompleted) ended.complete(RewardedOutcome.failed);
      },
    );
    try {
      await ad.show(
        // The only place a reward is granted (FR-030).
        onUserEarnedReward: (_, _) {
          granting ??= onEarned();
        },
      );
    } on Object {
      if (!ended.isCompleted) ended.complete(RewardedOutcome.failed);
    }
    return await ended.future;
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _firstPreload?.cancel();
    _interstitials.dispose();
    unawaited(_rewarded?.dispose());
    _rewarded = null;
    _setEnabled(enabled: false);
    await _enabledChanges.close();
  }
}
// coverage:ignore-end
