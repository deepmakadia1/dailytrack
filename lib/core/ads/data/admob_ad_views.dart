import 'dart:async';

import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Height of the medium native template (the plugin's sample size).
const double nativeTemplateHeight = 320;

/// A loaded AdMob banner or native ad behind the plugin-free [AdView].
final class AdMobAdView implements AdView {
  new(this._ad, {required this.height, this.width});

  final AdWithView _ad;

  @override
  final double height;

  /// Banner width; null fills the available width (native).
  final double? width;

  var _disposed = false;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width,
    height: height,
    child: AdWidget(ad: _ad),
  );

  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    unawaited(_ad.dispose());
  }
}
