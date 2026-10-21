// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Phase 0 has no ads SDK (research R8); T4.1 binds the real service.

@ProviderFor(adService)
final adServiceProvider = AdServiceProvider._();

/// Phase 0 has no ads SDK (research R8); T4.1 binds the real service.

final class AdServiceProvider
    extends $FunctionalProvider<AdService, AdService, AdService>
    with $Provider<AdService> {
  /// Phase 0 has no ads SDK (research R8); T4.1 binds the real service.
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
