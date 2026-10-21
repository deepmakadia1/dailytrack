// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'module_registry.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `production_overrides.dart` with the real modules and in tests
/// with fakes.

@ProviderFor(moduleRegistry)
final moduleRegistryProvider = ModuleRegistryProvider._();

/// Overridden in `production_overrides.dart` with the real modules and in tests
/// with fakes.

final class ModuleRegistryProvider
    extends $FunctionalProvider<ModuleRegistry, ModuleRegistry, ModuleRegistry>
    with $Provider<ModuleRegistry> {
  /// Overridden in `production_overrides.dart` with the real modules and in tests
  /// with fakes.
  ModuleRegistryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moduleRegistryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moduleRegistryHash();

  @$internal
  @override
  $ProviderElement<ModuleRegistry> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ModuleRegistry create(Ref ref) {
    return moduleRegistry(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModuleRegistry value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModuleRegistry>(value),
    );
  }
}

String _$moduleRegistryHash() => r'f27be70774641e0450083ba9181bc086c056bb8e';
