// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The home screen widget host (feature 008 research R20).
/// `production_overrides.dart` binds `HomeWidgetPluginBridge`; without a
/// binding (widget tests) nothing is shown or launched.

@ProviderFor(homeWidgetBridge)
final homeWidgetBridgeProvider = HomeWidgetBridgeProvider._();

/// The home screen widget host (feature 008 research R20).
/// `production_overrides.dart` binds `HomeWidgetPluginBridge`; without a
/// binding (widget tests) nothing is shown or launched.

final class HomeWidgetBridgeProvider
    extends
        $FunctionalProvider<
          HomeWidgetBridge,
          HomeWidgetBridge,
          HomeWidgetBridge
        >
    with $Provider<HomeWidgetBridge> {
  /// The home screen widget host (feature 008 research R20).
  /// `production_overrides.dart` binds `HomeWidgetPluginBridge`; without a
  /// binding (widget tests) nothing is shown or launched.
  HomeWidgetBridgeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeWidgetBridgeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeWidgetBridgeHash();

  @$internal
  @override
  $ProviderElement<HomeWidgetBridge> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeWidgetBridge create(Ref ref) {
    return homeWidgetBridge(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeWidgetBridge value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeWidgetBridge>(value),
    );
  }
}

String _$homeWidgetBridgeHash() => r'6f0911c3504e8a59d5816c5b0fe30cdab49809f9';
