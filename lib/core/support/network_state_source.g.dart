// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network_state_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(networkStateSource)
final networkStateSourceProvider = NetworkStateSourceProvider._();

final class NetworkStateSourceProvider
    extends
        $FunctionalProvider<
          NetworkStateSource,
          NetworkStateSource,
          NetworkStateSource
        >
    with $Provider<NetworkStateSource> {
  NetworkStateSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'networkStateSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$networkStateSourceHash();

  @$internal
  @override
  $ProviderElement<NetworkStateSource> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NetworkStateSource create(Ref ref) {
    return networkStateSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NetworkStateSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NetworkStateSource>(value),
    );
  }
}

String _$networkStateSourceHash() =>
    r'a5db05b9d21781deb9e6e7105464066a1ed631f1';
