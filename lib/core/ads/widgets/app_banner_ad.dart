import 'dart:async';

import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/ads/widgets/ad_slot.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The bottom banner (spec §11): a standard 320×50 banner, centered, placed
/// in `AppScaffold.bannerSlot`. It takes no space until an ad loads, then
/// animates in with an 8 dp gap above it (§15.8). With `NoAdsService` it is
/// always zero height.
class AppBannerAd extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<AppBannerAd> createState() => _AppBannerAdState();
}

class _AppBannerAdState extends ConsumerState<AppBannerAd>
    with AdSlotState<AppBannerAd> {
  double? _width;
  Timer? _resize;

  @override
  void didChangeDependencies() {
    final width = MediaQuery.sizeOf(context).width;
    final previous = _width;
    _width = width;
    super.didChangeDependencies();
    // A new width (rotation, split screen) may now fit the banner, or not.
    if (previous != null && (width - previous).abs() > 1) {
      _resize?.cancel();
      _resize = Timer(const Duration(milliseconds: 500), () {
        if (mounted) restartAd(ref.read(adServiceProvider));
      });
    }
  }

  @override
  Future<AdView?> loadAd(AdService service) =>
      service.loadBanner(width: _width ?? 0);

  @override
  void dispose() {
    _resize?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final view = adView;
    final tokens = AppTokens.of(context);
    // As the scaffold's bottom bar, the slot keeps the system inset even
    // while empty, so the screen's content never sits under the gesture bar.
    return SafeArea(
      top: false,
      child: animatedSlot(
        context,
        view == null
            ? null
            : Semantics(
                container: true,
                label: AppLocalizations.of(context).ads_bannerLabel,
                child: Padding(
                  padding: EdgeInsets.only(top: tokens.s8),
                  // Only as tall as the ad: in the scaffold's bottom bar
                  // a plain Center would fill the whole screen.
                  child: Center(heightFactor: 1, child: view.build(context)),
                ),
              ),
      ),
    );
  }
}
