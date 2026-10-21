// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info_source.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceInfoSource)
final deviceInfoSourceProvider = DeviceInfoSourceProvider._();

final class DeviceInfoSourceProvider
    extends
        $FunctionalProvider<
          DeviceInfoSource,
          DeviceInfoSource,
          DeviceInfoSource
        >
    with $Provider<DeviceInfoSource> {
  DeviceInfoSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceInfoSourceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceInfoSourceHash();

  @$internal
  @override
  $ProviderElement<DeviceInfoSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DeviceInfoSource create(Ref ref) {
    return deviceInfoSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeviceInfoSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeviceInfoSource>(value),
    );
  }
}

String _$deviceInfoSourceHash() => r'e3867664e0075a4c531af3998b87db34a7c92780';
