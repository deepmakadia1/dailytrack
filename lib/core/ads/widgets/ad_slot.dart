import 'dart:async';

import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The load, retry, and dispose loop shared by `AppBannerAd` and
/// `AppNativeAd` (FR-007, feature 009 research R6, R7):
///  - no space until an ad has loaded, then the height animates in;
///  - a failed load is retried after each `AdConfig.retryBackoff` wait,
///    then the slot gives up until it is mounted again;
///  - the ad is released on unmount and whenever the ad service changes
///    (e.g. to `NoAdsService` after a Pro purchase).
mixin AdSlotState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  AdView? _view;
  AdService? _service;
  Timer? _retry;
  StreamSubscription<bool>? _enabledSub;
  var _attempt = 0;
  var _generation = 0;
  var _loading = false;

  /// The loaded ad, or null while the slot takes no space.
  AdView? get adView => _view;

  /// Loads one ad from [service]; null when there is none.
  Future<AdView?> loadAd(AdService service);

  @override
  void initState() {
    super.initState();
    ref.listenManual(adServiceProvider, (_, next) => restartAd(next));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The first load needs inherited data (width, theme), so it starts here.
    if (_service == null) restartAd(ref.read(adServiceProvider));
  }

  /// Drops the current ad and starts loading again from [service].
  void restartAd(AdService service) {
    _generation++;
    _retry?.cancel();
    _retry = null;
    unawaited(_enabledSub?.cancel());
    _attempt = 0;
    _loading = false;
    _service = service;
    final old = _view;
    if (old != null) {
      // Take the ad out of the tree first, then release it after the frame.
      if (mounted) {
        setState(() => _view = null);
      } else {
        _view = null;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    }
    // An SDK that finishes starting later still fills the slot.
    _enabledSub = service.adsEnabledStream.listen((enabled) {
      if (enabled && _view == null && _retry == null) unawaited(_load());
    });
  }

  Future<void> _load() async {
    final service = _service;
    if (service == null || _loading) return;
    final generation = _generation;
    _loading = true;
    final view = await loadAd(service);
    if (generation != _generation) {
      view?.dispose();
      return;
    }
    _loading = false;
    if (!mounted) {
      view?.dispose();
      return;
    }
    if (view != null) {
      setState(() => _view = view);
      return;
    }
    final backoff = ref.read(adConfigProvider).retryBackoff;
    // Retry only while ads may be requested; otherwise wait for the
    // enabled stream (or stay empty for good with NoAdsService).
    if (!service.adsEnabled || _attempt >= backoff.length) return;
    _retry = Timer(backoff[_attempt++], () {
      _retry = null;
      unawaited(_load());
    });
  }

  @override
  void dispose() {
    _generation++;
    _retry?.cancel();
    unawaited(_enabledSub?.cancel());
    _view?.dispose();
    _view = null;
    super.dispose();
  }

  /// Animates from no space to [child]'s height when an ad loads (§15.6:
  /// no layout shift; instant when animations are off).
  Widget animatedSlot(BuildContext context, Widget? child) {
    final tokens = AppTokens.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return AnimatedSize(
      duration: reduce ? Duration.zero : tokens.motionSize,
      curve: Easing.standard,
      alignment: Alignment.topCenter,
      child: child ?? const SizedBox(width: double.infinity),
    );
  }
}
