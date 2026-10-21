// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'external_activity_guard.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(externalActivityGuard)
final externalActivityGuardProvider = ExternalActivityGuardProvider._();

final class ExternalActivityGuardProvider
    extends
        $FunctionalProvider<
          ExternalActivityGuard,
          ExternalActivityGuard,
          ExternalActivityGuard
        >
    with $Provider<ExternalActivityGuard> {
  ExternalActivityGuardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'externalActivityGuardProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$externalActivityGuardHash();

  @$internal
  @override
  $ProviderElement<ExternalActivityGuard> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExternalActivityGuard create(Ref ref) {
    return externalActivityGuard(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExternalActivityGuard value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExternalActivityGuard>(value),
    );
  }
}

String _$externalActivityGuardHash() =>
    r'049b077929b8f2c4ca0f0888286b8d9f68765733';
