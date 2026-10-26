import 'package:dailytrack/core/ads/ad_service.dart';
import 'package:dailytrack/core/ads/ad_view.dart';
import 'package:dailytrack/core/ads/domain/ad_placement.dart';
import 'package:dailytrack/core/ads/widgets/ad_slot.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/theme/app_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A native ad in the medium template, styled like an app card with an "Ad"
/// badge in its top-left corner (spec §11, §15.8). It takes no space until
/// an ad loads, then animates in with the 12 dp card gap. With
/// `NoAdsService` it is always zero height.
class AppNativeAd extends ConsumerStatefulWidget {
  const new({required this.placement, super.key});

  final NativePlacement placement;

  @override
  ConsumerState<AppNativeAd> createState() => _AppNativeAdState();
}

class _AppNativeAdState extends ConsumerState<AppNativeAd>
    with AdSlotState<AppNativeAd> {
  late NativeAdLook _look;

  @override
  void didChangeDependencies() {
    _look = _lookOf(context);
    super.didChangeDependencies();
  }

  static NativeAdLook _lookOf(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final tokens = AppTokens.of(context);
    return NativeAdLook(
      surface: scheme.surfaceContainerLow,
      onSurface: scheme.onSurface,
      onSurfaceVariant: scheme.onSurfaceVariant,
      primary: scheme.primary,
      onPrimary: scheme.onPrimary,
      cornerRadius: tokens.radiusCard,
      titleSize: text.titleMedium?.fontSize ?? tokens.s16,
      bodySize: text.bodySmall?.fontSize ?? tokens.s12,
    );
  }

  @override
  Future<AdView?> loadAd(AdService service) =>
      service.loadNative(widget.placement, _look);

  @override
  Widget build(BuildContext context) {
    final view = adView;
    if (view == null) return animatedSlot(context, null);
    final tokens = AppTokens.of(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return animatedSlot(
      context,
      Semantics(
        container: true,
        label: l10n.ads_bannerLabel,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: tokens.s12),
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(tokens.radiusCard),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    tokens.s12,
                    tokens.s8,
                    tokens.s12,
                    tokens.s4,
                  ),
                  child: DecoratedBox(
                    key: const Key('native_ad_badge'),
                    decoration: BoxDecoration(
                      color: tokens.adBadge,
                      borderRadius: BorderRadius.circular(tokens.s4),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: tokens.s8,
                        vertical: tokens.s4 / 2,
                      ),
                      child: ExcludeSemantics(
                        child: Text(
                          l10n.ads_badge,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
                ),
                view.build(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
