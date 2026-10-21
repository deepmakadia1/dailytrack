// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feature_gate_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(featureGate)
final featureGateProvider = FeatureGateProvider._();

final class FeatureGateProvider
    extends $FunctionalProvider<FeatureGate, FeatureGate, FeatureGate>
    with $Provider<FeatureGate> {
  FeatureGateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featureGateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featureGateHash();

  @$internal
  @override
  $ProviderElement<FeatureGate> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeatureGate create(Ref ref) {
    return featureGate(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeatureGate value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeatureGate>(value),
    );
  }
}

String _$featureGateHash() => r'06fb515cc1f2fbb4783d12d8d5443c2cf02188f2';

@ProviderFor(unlockRepository)
final unlockRepositoryProvider = UnlockRepositoryProvider._();

final class UnlockRepositoryProvider
    extends
        $FunctionalProvider<
          UnlockRepository,
          UnlockRepository,
          UnlockRepository
        >
    with $Provider<UnlockRepository> {
  UnlockRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockRepositoryHash();

  @$internal
  @override
  $ProviderElement<UnlockRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UnlockRepository create(Ref ref) {
    return unlockRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnlockRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnlockRepository>(value),
    );
  }
}

String _$unlockRepositoryHash() => r'd19d7c41b2c4ce449a5a700f0c4f215b2932959f';

/// Whether developer tools (the "Unlock all features" switch) exist in this
/// build. `production_overrides.dart` sets it to
/// `!FlavorConfig.current.isProd`, so features never import `app/flavor.dart`
/// (FR-041).

@ProviderFor(debugToolsAvailable)
final debugToolsAvailableProvider = DebugToolsAvailableProvider._();

/// Whether developer tools (the "Unlock all features" switch) exist in this
/// build. `production_overrides.dart` sets it to
/// `!FlavorConfig.current.isProd`, so features never import `app/flavor.dart`
/// (FR-041).

final class DebugToolsAvailableProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether developer tools (the "Unlock all features" switch) exist in this
  /// build. `production_overrides.dart` sets it to
  /// `!FlavorConfig.current.isProd`, so features never import `app/flavor.dart`
  /// (FR-041).
  DebugToolsAvailableProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugToolsAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugToolsAvailableHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return debugToolsAvailable(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$debugToolsAvailableHash() =>
    r'5e6eab4812d9cd6f695ad2d131af3bb52cca0df8';
