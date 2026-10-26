// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Every tunable ad number (spec §11).

@ProviderFor(adConfig)
final adConfigProvider = AdConfigProvider._();

/// Every tunable ad number (spec §11).

final class AdConfigProvider
    extends $FunctionalProvider<AdConfig, AdConfig, AdConfig>
    with $Provider<AdConfig> {
  /// Every tunable ad number (spec §11).
  AdConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adConfigHash();

  @$internal
  @override
  $ProviderElement<AdConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdConfig create(Ref ref) {
    return adConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdConfig>(value),
    );
  }
}

String _$adConfigHash() => r'ecfd83b3c4d31f561f8dffe3b121e36a4212b154';

/// The ad unit IDs this build uses (feature 009 research R3).

@ProviderFor(adUnitIds)
final adUnitIdsProvider = AdUnitIdsProvider._();

/// The ad unit IDs this build uses (feature 009 research R3).

final class AdUnitIdsProvider
    extends $FunctionalProvider<AdUnitIds, AdUnitIds, AdUnitIds>
    with $Provider<AdUnitIds> {
  /// The ad unit IDs this build uses (feature 009 research R3).
  AdUnitIdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adUnitIdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adUnitIdsHash();

  @$internal
  @override
  $ProviderElement<AdUnitIds> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdUnitIds create(Ref ref) {
    return adUnitIds(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdUnitIds value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdUnitIds>(value),
    );
  }
}

String _$adUnitIdsHash() => r'd644401125af4e8613767ab5c3b2a339be6fa617';

/// Ad consent (UMP). Default: no consent SDK, so ads are never allowed.

@ProviderFor(consentService)
final consentServiceProvider = ConsentServiceProvider._();

/// Ad consent (UMP). Default: no consent SDK, so ads are never allowed.

final class ConsentServiceProvider
    extends $FunctionalProvider<ConsentService, ConsentService, ConsentService>
    with $Provider<ConsentService> {
  /// Ad consent (UMP). Default: no consent SDK, so ads are never allowed.
  ConsentServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consentServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consentServiceHash();

  @$internal
  @override
  $ProviderElement<ConsentService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ConsentService create(Ref ref) {
    return consentService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ConsentService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ConsentService>(value),
    );
  }
}

String _$consentServiceHash() => r'eb51ecc69d3c44cbb69100207540fb9a4f71b05b';

/// Whether this app session started with ads (feature 009 research R5).
/// Set once by SYS-01: false when Pro was owned at cold start or consent
/// does not allow ads. A Pro purchase turns ads off at once through
/// [adsAllowed]; losing Pro only takes effect from the next cold start.

@ProviderFor(AdsSessionGate)
final adsSessionGateProvider = AdsSessionGateProvider._();

/// Whether this app session started with ads (feature 009 research R5).
/// Set once by SYS-01: false when Pro was owned at cold start or consent
/// does not allow ads. A Pro purchase turns ads off at once through
/// [adsAllowed]; losing Pro only takes effect from the next cold start.
final class AdsSessionGateProvider
    extends $NotifierProvider<AdsSessionGate, bool> {
  /// Whether this app session started with ads (feature 009 research R5).
  /// Set once by SYS-01: false when Pro was owned at cold start or consent
  /// does not allow ads. A Pro purchase turns ads off at once through
  /// [adsAllowed]; losing Pro only takes effect from the next cold start.
  AdsSessionGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsSessionGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsSessionGateHash();

  @$internal
  @override
  AdsSessionGate create() => AdsSessionGate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adsSessionGateHash() => r'2cdb9d6ae9e47721da8db50dcc51da5169750c28';

/// Whether this app session started with ads (feature 009 research R5).
/// Set once by SYS-01: false when Pro was owned at cold start or consent
/// does not allow ads. A Pro purchase turns ads off at once through
/// [adsAllowed]; losing Pro only takes effect from the next cold start.

abstract class _$AdsSessionGate extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ads may be requested right now: the session started with ads and Pro is
/// not owned (FR-002, FR-043). Unknown settings count as Pro, so nothing is
/// requested before they load.

@ProviderFor(adsAllowed)
final adsAllowedProvider = AdsAllowedProvider._();

/// Ads may be requested right now: the session started with ads and Pro is
/// not owned (FR-002, FR-043). Unknown settings count as Pro, so nothing is
/// requested before they load.

final class AdsAllowedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Ads may be requested right now: the session started with ads and Pro is
  /// not owned (FR-002, FR-043). Unknown settings count as Pro, so nothing is
  /// requested before they load.
  AdsAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adsAllowedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adsAllowedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return adsAllowed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$adsAllowedHash() => r'5a6687624aec03ade041f390b421769ebd8b8c7f';

/// The ad service screens use. Default `NoAdsService`; the composition root
/// switches between AdMob and no ads from [adsAllowed].

@ProviderFor(adService)
final adServiceProvider = AdServiceProvider._();

/// The ad service screens use. Default `NoAdsService`; the composition root
/// switches between AdMob and no ads from [adsAllowed].

final class AdServiceProvider
    extends $FunctionalProvider<AdService, AdService, AdService>
    with $Provider<AdService> {
  /// The ad service screens use. Default `NoAdsService`; the composition root
  /// switches between AdMob and no ads from [adsAllowed].
  AdServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adServiceHash();

  @$internal
  @override
  $ProviderElement<AdService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdService create(Ref ref) {
    return adService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdService>(value),
    );
  }
}

String _$adServiceHash() => r'666a1e1e100d51d20a4ff47b2ab5905aff03db1b';

/// Whether SET-01 shows "Ad privacy choices" (FR-014): only while the
/// consent SDK requires it and Pro is not owned.

@ProviderFor(privacyOptionsRequired)
final privacyOptionsRequiredProvider = PrivacyOptionsRequiredProvider._();

/// Whether SET-01 shows "Ad privacy choices" (FR-014): only while the
/// consent SDK requires it and Pro is not owned.

final class PrivacyOptionsRequiredProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, Stream<bool>>
    with $FutureModifier<bool>, $StreamProvider<bool> {
  /// Whether SET-01 shows "Ad privacy choices" (FR-014): only while the
  /// consent SDK requires it and Pro is not owned.
  PrivacyOptionsRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacyOptionsRequiredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacyOptionsRequiredHash();

  @$internal
  @override
  $StreamProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<bool> create(Ref ref) {
    return privacyOptionsRequired(ref);
  }
}

String _$privacyOptionsRequiredHash() =>
    r'76ff42eadf382fb29e5b9fd9d92b7a990cf40645';

/// Whether a full-screen ad may appear now (FR-023). Default: never; the
/// composition root binds the router- and lock-aware probe.

@ProviderFor(adScreenProbe)
final adScreenProbeProvider = AdScreenProbeProvider._();

/// Whether a full-screen ad may appear now (FR-023). Default: never; the
/// composition root binds the router- and lock-aware probe.

final class AdScreenProbeProvider
    extends $FunctionalProvider<AdScreenProbe, AdScreenProbe, AdScreenProbe>
    with $Provider<AdScreenProbe> {
  /// Whether a full-screen ad may appear now (FR-023). Default: never; the
  /// composition root binds the router- and lock-aware probe.
  AdScreenProbeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adScreenProbeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adScreenProbeHash();

  @$internal
  @override
  $ProviderElement<AdScreenProbe> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AdScreenProbe create(Ref ref) {
    return adScreenProbe(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AdScreenProbe value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AdScreenProbe>(value),
    );
  }
}

String _$adScreenProbeHash() => r'7ef2a5a548f43544d963bb50ba42f71c889ea0ea';

/// Sessions, the EXP-02 save counter, and the global interstitial cap
/// (spec §11). Kept for the whole process, so the counter survives the ad
/// service being rebuilt.

@ProviderFor(interstitialCoordinator)
final interstitialCoordinatorProvider = InterstitialCoordinatorProvider._();

/// Sessions, the EXP-02 save counter, and the global interstitial cap
/// (spec §11). Kept for the whole process, so the counter survives the ad
/// service being rebuilt.

final class InterstitialCoordinatorProvider
    extends
        $FunctionalProvider<
          InterstitialCoordinator,
          InterstitialCoordinator,
          InterstitialCoordinator
        >
    with $Provider<InterstitialCoordinator> {
  /// Sessions, the EXP-02 save counter, and the global interstitial cap
  /// (spec §11). Kept for the whole process, so the counter survives the ad
  /// service being rebuilt.
  InterstitialCoordinatorProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'interstitialCoordinatorProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$interstitialCoordinatorHash();

  @$internal
  @override
  $ProviderElement<InterstitialCoordinator> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  InterstitialCoordinator create(Ref ref) {
    return interstitialCoordinator(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InterstitialCoordinator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InterstitialCoordinator>(value),
    );
  }
}

String _$interstitialCoordinatorHash() =>
    r'34a98e46cdbdb1105edc9dcb3eba016bf9566d21';

/// Dev-only "Reset ad counters" (FR-048): clears the cap's counters and the
/// stored consent. The SET-01 tile exists only in dev builds.

@ProviderFor(resetAdCounters)
final resetAdCountersProvider = ResetAdCountersProvider._();

/// Dev-only "Reset ad counters" (FR-048): clears the cap's counters and the
/// stored consent. The SET-01 tile exists only in dev builds.

final class ResetAdCountersProvider
    extends
        $FunctionalProvider<
          Future<void> Function(),
          Future<void> Function(),
          Future<void> Function()
        >
    with $Provider<Future<void> Function()> {
  /// Dev-only "Reset ad counters" (FR-048): clears the cap's counters and the
  /// stored consent. The SET-01 tile exists only in dev builds.
  ResetAdCountersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'resetAdCountersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$resetAdCountersHash();

  @$internal
  @override
  $ProviderElement<Future<void> Function()> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<void> Function() create(Ref ref) {
    return resetAdCounters(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<void> Function() value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Future<void> Function()>(value),
    );
  }
}

String _$resetAdCountersHash() => r'7ca2b091fdaa2d705c7d56ddc9e6400e3a662907';
