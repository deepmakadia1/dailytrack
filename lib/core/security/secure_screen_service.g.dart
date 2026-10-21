// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'secure_screen_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `production_overrides.dart` binds [ChannelSecureScreenService]; widget
/// tests bind a recording fake.

@ProviderFor(secureScreenService)
final secureScreenServiceProvider = SecureScreenServiceProvider._();

/// `production_overrides.dart` binds [ChannelSecureScreenService]; widget
/// tests bind a recording fake.

final class SecureScreenServiceProvider
    extends
        $FunctionalProvider<
          SecureScreenService,
          SecureScreenService,
          SecureScreenService
        >
    with $Provider<SecureScreenService> {
  /// `production_overrides.dart` binds [ChannelSecureScreenService]; widget
  /// tests bind a recording fake.
  SecureScreenServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureScreenServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureScreenServiceHash();

  @$internal
  @override
  $ProviderElement<SecureScreenService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SecureScreenService create(Ref ref) {
    return secureScreenService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SecureScreenService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SecureScreenService>(value),
    );
  }
}

String _$secureScreenServiceHash() =>
    r'9a5152189dbd3ec7f02473f9f9e8074f2d2f032b';

/// Keeps `FLAG_SECURE` on while SYS-03 is visible (FR-033) or app-wide
/// with "Hide app content in recents" (FR-027). The state is whether the
/// flag is on; the service is called only when that changes.

@ProviderFor(SecureScreenController)
final secureScreenControllerProvider = SecureScreenControllerProvider._();

/// Keeps `FLAG_SECURE` on while SYS-03 is visible (FR-033) or app-wide
/// with "Hide app content in recents" (FR-027). The state is whether the
/// flag is on; the service is called only when that changes.
final class SecureScreenControllerProvider
    extends $NotifierProvider<SecureScreenController, bool> {
  /// Keeps `FLAG_SECURE` on while SYS-03 is visible (FR-033) or app-wide
  /// with "Hide app content in recents" (FR-027). The state is whether the
  /// flag is on; the service is called only when that changes.
  SecureScreenControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'secureScreenControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$secureScreenControllerHash();

  @$internal
  @override
  SecureScreenController create() => SecureScreenController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$secureScreenControllerHash() =>
    r'98ac4044ba7b0b0832978c4f0d69988578ae2503';

/// Keeps `FLAG_SECURE` on while SYS-03 is visible (FR-033) or app-wide
/// with "Hide app content in recents" (FR-027). The state is whether the
/// flag is on; the service is called only when that changes.

abstract class _$SecureScreenController extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
