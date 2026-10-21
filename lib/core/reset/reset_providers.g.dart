// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reset_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Erase all data, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `DriftAppResetService`; widget tests bind a fake or a real one over an
/// in-memory database.

@ProviderFor(appResetService)
final appResetServiceProvider = AppResetServiceProvider._();

/// Erase all data, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `DriftAppResetService`; widget tests bind a fake or a real one over an
/// in-memory database.

final class AppResetServiceProvider
    extends
        $FunctionalProvider<AppResetService, AppResetService, AppResetService>
    with $Provider<AppResetService> {
  /// Erase all data, typed to the domain interface so presentation code can
  /// depend on it (Constitution II). `production_overrides.dart` binds
  /// `DriftAppResetService`; widget tests bind a fake or a real one over an
  /// in-memory database.
  AppResetServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appResetServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appResetServiceHash();

  @$internal
  @override
  $ProviderElement<AppResetService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppResetService create(Ref ref) {
    return appResetService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppResetService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppResetService>(value),
    );
  }
}

String _$appResetServiceHash() => r'9f54d8326484ff08d734f236eb77187c3d6c5c53';
