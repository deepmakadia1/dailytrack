// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'premium_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// PRM-01 Premium (spec §10, feature 009 contracts/screens.md). Pro itself
/// lives in settings (`removeAdsPurchased`), written by `ProService`; this
/// screen follows it live.

@ProviderFor(PremiumController)
final premiumControllerProvider = PremiumControllerProvider._();

/// PRM-01 Premium (spec §10, feature 009 contracts/screens.md). Pro itself
/// lives in settings (`removeAdsPurchased`), written by `ProService`; this
/// screen follows it live.
final class PremiumControllerProvider
    extends $NotifierProvider<PremiumController, PremiumState> {
  /// PRM-01 Premium (spec §10, feature 009 contracts/screens.md). Pro itself
  /// lives in settings (`removeAdsPurchased`), written by `ProService`; this
  /// screen follows it live.
  PremiumControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'premiumControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$premiumControllerHash();

  @$internal
  @override
  PremiumController create() => PremiumController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PremiumState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PremiumState>(value),
    );
  }
}

String _$premiumControllerHash() => r'0b6acbc1eb887d400e4518cc87df8cdc92290859';

/// PRM-01 Premium (spec §10, feature 009 contracts/screens.md). Pro itself
/// lives in settings (`removeAdsPurchased`), written by `ProService`; this
/// screen follows it live.

abstract class _$PremiumController extends $Notifier<PremiumState> {
  PremiumState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PremiumState, PremiumState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PremiumState, PremiumState>,
              PremiumState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
