import 'dart:async';

import 'package:dailytrack/core/ads/interstitial_coordinator.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// One preloaded AdMob interstitial at a time (spec §11: preload the next
/// one after each shown ad).
// Device bindings; exercised on a device (quickstart §4.2), not unit tests.
// coverage:ignore-start
final class AdMobInterstitialPlayer implements InterstitialPlayer {
  new({required this.unitId, required this.canRequest});

  final String? unitId;

  /// False once ads are off (consent, Pro, or the service is disposed).
  final bool Function() canRequest;

  InterstitialAd? _ad;
  Future<void>? _loading;

  @override
  bool get isReady => _ad != null;

  @override
  Future<void> preload() =>
      _loading ??= _load().whenComplete(() => _loading = null);

  Future<void> _load() async {
    final id = unitId;
    if (id == null || _ad != null || !canRequest()) return;
    final done = Completer<void>();
    try {
      await InterstitialAd.load(
        adUnitId: id,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            if (canRequest()) {
              _ad = ad;
            } else {
              unawaited(ad.dispose());
            }
            if (!done.isCompleted) done.complete();
          },
          onAdFailedToLoad: (_) {
            if (!done.isCompleted) done.complete();
          },
        ),
      );
      await done.future;
    } on Object {
      // A later action tries again.
    }
  }

  @override
  Future<bool> show({required void Function() onShown}) async {
    final ad = _ad;
    if (ad == null) return false;
    _ad = null;
    final result = Completer<bool>();
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) => onShown(),
      onAdDismissedFullScreenContent: (ad) {
        unawaited(ad.dispose());
        if (!result.isCompleted) result.complete(true);
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        unawaited(ad.dispose());
        if (!result.isCompleted) result.complete(false);
      },
    );
    try {
      await ad.show();
    } on Object {
      if (!result.isCompleted) result.complete(false);
    }
    return await result.future;
  }

  void dispose() {
    unawaited(_ad?.dispose());
    _ad = null;
  }
}
// coverage:ignore-end
