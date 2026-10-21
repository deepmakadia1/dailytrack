// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app lock, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `SecureLockService`; widget tests bind `FakeLockService`.

@ProviderFor(lockService)
final lockServiceProvider = LockServiceProvider._();

/// The app lock, typed to the domain interface so presentation code can
/// depend on it (Constitution II). `production_overrides.dart` binds
/// `SecureLockService`; widget tests bind `FakeLockService`.

final class LockServiceProvider
    extends $FunctionalProvider<LockService, LockService, LockService>
    with $Provider<LockService> {
  /// The app lock, typed to the domain interface so presentation code can
  /// depend on it (Constitution II). `production_overrides.dart` binds
  /// `SecureLockService`; widget tests bind `FakeLockService`.
  LockServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'lockServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$lockServiceHash();

  @$internal
  @override
  $ProviderElement<LockService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LockService create(Ref ref) {
    return lockService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LockService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LockService>(value),
    );
  }
}

String _$lockServiceHash() => r'5a204bba31e2fe3926abc07901ca52210a7c4c44';
