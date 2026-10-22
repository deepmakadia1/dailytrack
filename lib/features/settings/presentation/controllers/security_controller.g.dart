// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'security_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SET-05 Security controller (FR-022 – FR-027). The lock itself is turned
/// on and off through SYS-04, which owns the PIN.

@ProviderFor(SecurityController)
final securityControllerProvider = SecurityControllerProvider._();

/// SET-05 Security controller (FR-022 – FR-027). The lock itself is turned
/// on and off through SYS-04, which owns the PIN.
final class SecurityControllerProvider
    extends $AsyncNotifierProvider<SecurityController, SecurityState> {
  /// SET-05 Security controller (FR-022 – FR-027). The lock itself is turned
  /// on and off through SYS-04, which owns the PIN.
  SecurityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'securityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$securityControllerHash();

  @$internal
  @override
  SecurityController create() => SecurityController();
}

String _$securityControllerHash() =>
    r'43cc3b0285d846f14459a282069a75e8b1e5ffb6';

/// SET-05 Security controller (FR-022 – FR-027). The lock itself is turned
/// on and off through SYS-04, which owns the PIN.

abstract class _$SecurityController extends $AsyncNotifier<SecurityState> {
  FutureOr<SecurityState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SecurityState>, SecurityState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SecurityState>, SecurityState>,
              AsyncValue<SecurityState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
