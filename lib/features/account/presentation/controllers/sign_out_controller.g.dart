// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACC-03 Sign out controller (spec §16).

@ProviderFor(SignOutController)
final signOutControllerProvider = SignOutControllerProvider._();

/// ACC-03 Sign out controller (spec §16).
final class SignOutControllerProvider
    extends $NotifierProvider<SignOutController, SignOutState> {
  /// ACC-03 Sign out controller (spec §16).
  SignOutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutControllerHash();

  @$internal
  @override
  SignOutController create() => SignOutController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SignOutState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SignOutState>(value),
    );
  }
}

String _$signOutControllerHash() => r'bb9f41c8b7651518844ab18d763abe4d9519c47d';

/// ACC-03 Sign out controller (spec §16).

abstract class _$SignOutController extends $Notifier<SignOutState> {
  SignOutState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<SignOutState, SignOutState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SignOutState, SignOutState>,
              SignOutState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
