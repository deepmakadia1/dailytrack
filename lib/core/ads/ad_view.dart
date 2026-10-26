import 'package:flutter/widgets.dart';

/// A loaded banner or native ad, without the plugin types (feature 009
/// research R5), so `AppBannerAd` and `AppNativeAd` never import
/// `google_mobile_ads`.
abstract interface class AdView {
  /// Logical pixels the ad needs.
  double get height;

  Widget build(BuildContext context);

  /// Releases the ad. Safe to call more than once.
  void dispose();
}

/// Native template colors and text styles, taken from the app theme by
/// `AppNativeAd` (spec §15.8: styled like app cards).
final class NativeAdLook {
  const new({
    required this.surface,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.primary,
    required this.onPrimary,
    required this.cornerRadius,
    required this.titleSize,
    required this.bodySize,
  });

  final Color surface;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color primary;
  final Color onPrimary;
  final double cornerRadius;
  final double titleSize;
  final double bodySize;
}
