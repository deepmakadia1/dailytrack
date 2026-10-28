// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AUTH-01 Login controller (spec §6 AUTH-01, feature 011 research R9).
/// `authMode` is written only once every branch has settled, so the user
/// stays on AUTH-01 (and nothing backs up on its own) until then. Setting
/// it makes the router leave AUTH-01; this controller never navigates.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// AUTH-01 Login controller (spec §6 AUTH-01, feature 011 research R9).
/// `authMode` is written only once every branch has settled, so the user
/// stays on AUTH-01 (and nothing backs up on its own) until then. Setting
/// it makes the router leave AUTH-01; this controller never navigates.
final class LoginControllerProvider
    extends $NotifierProvider<LoginController, LoginState> {
  /// AUTH-01 Login controller (spec §6 AUTH-01, feature 011 research R9).
  /// `authMode` is written only once every branch has settled, so the user
  /// stays on AUTH-01 (and nothing backs up on its own) until then. Setting
  /// it makes the router leave AUTH-01; this controller never navigates.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LoginState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LoginState>(value),
    );
  }
}

String _$loginControllerHash() => r'3e5bdf20acd009dd7dd41167526928d661c37bb8';

/// AUTH-01 Login controller (spec §6 AUTH-01, feature 011 research R9).
/// `authMode` is written only once every branch has settled, so the user
/// stays on AUTH-01 (and nothing backs up on its own) until then. Setting
/// it makes the router leave AUTH-01; this controller never navigates.

abstract class _$LoginController extends $Notifier<LoginState> {
  LoginState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LoginState, LoginState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LoginState, LoginState>,
              LoginState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
