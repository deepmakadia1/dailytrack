// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Google Play Billing for Pro. Default: no store.

@ProviderFor(proStore)
final proStoreProvider = ProStoreProvider._();

/// Google Play Billing for Pro. Default: no store.

final class ProStoreProvider
    extends $FunctionalProvider<ProStore, ProStore, ProStore>
    with $Provider<ProStore> {
  /// Google Play Billing for Pro. Default: no store.
  ProStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proStoreHash();

  @$internal
  @override
  $ProviderElement<ProStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProStore create(Ref ref) {
    return proStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProStore>(value),
    );
  }
}

String _$proStoreHash() => r'5d68b201141e1acef20390a4e608d5a868e24da7';

/// Purchase, restore, and the start-up ownership check (spec PRM-01).

@ProviderFor(proService)
final proServiceProvider = ProServiceProvider._();

/// Purchase, restore, and the start-up ownership check (spec PRM-01).

final class ProServiceProvider
    extends $FunctionalProvider<ProService, ProService, ProService>
    with $Provider<ProService> {
  /// Purchase, restore, and the start-up ownership check (spec PRM-01).
  ProServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proServiceHash();

  @$internal
  @override
  $ProviderElement<ProService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ProService create(Ref ref) {
    return proService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProService>(value),
    );
  }
}

String _$proServiceHash() => r'7e3641d0214b2f4eedcb875b91aa4655452c2b2e';

/// Whether the app acts as Pro now, live: Pro is owned
/// (`removeAdsPurchased`), or dev tools are available and "Unlock all
/// features (debug)" is on (FR-037, FR-041). False until settings load.

@ProviderFor(proOwned)
final proOwnedProvider = ProOwnedProvider._();

/// Whether the app acts as Pro now, live: Pro is owned
/// (`removeAdsPurchased`), or dev tools are available and "Unlock all
/// features (debug)" is on (FR-037, FR-041). False until settings load.

final class ProOwnedProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the app acts as Pro now, live: Pro is owned
  /// (`removeAdsPurchased`), or dev tools are available and "Unlock all
  /// features (debug)" is on (FR-037, FR-041). False until settings load.
  ProOwnedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'proOwnedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$proOwnedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return proOwned(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$proOwnedHash() => r'f0bc86234cf4a9c890bfa44cfa2ec596a89981b1';
