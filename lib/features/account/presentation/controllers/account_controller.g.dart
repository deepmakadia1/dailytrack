// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACC-01 Account controller (spec §16): Back up now, Switch account, and
/// Delete my backups for a signed-in account. Restore and Sign out open
/// ACC-02 and ACC-03, which have their own controllers. Signing in never
/// happens on ACC-01.

@ProviderFor(AccountController)
final accountControllerProvider = AccountControllerProvider._();

/// ACC-01 Account controller (spec §16): Back up now, Switch account, and
/// Delete my backups for a signed-in account. Restore and Sign out open
/// ACC-02 and ACC-03, which have their own controllers. Signing in never
/// happens on ACC-01.
final class AccountControllerProvider
    extends $AsyncNotifierProvider<AccountController, AccountScreenState> {
  /// ACC-01 Account controller (spec §16): Back up now, Switch account, and
  /// Delete my backups for a signed-in account. Restore and Sign out open
  /// ACC-02 and ACC-03, which have their own controllers. Signing in never
  /// happens on ACC-01.
  AccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountControllerHash();

  @$internal
  @override
  AccountController create() => AccountController();
}

String _$accountControllerHash() => r'065c4040c38090ef0e208f7b72382eaf6d259c0a';

/// ACC-01 Account controller (spec §16): Back up now, Switch account, and
/// Delete my backups for a signed-in account. Restore and Sign out open
/// ACC-02 and ACC-03, which have their own controllers. Signing in never
/// happens on ACC-01.

abstract class _$AccountController extends $AsyncNotifier<AccountScreenState> {
  FutureOr<AccountScreenState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<AccountScreenState>, AccountScreenState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountScreenState>, AccountScreenState>,
              AsyncValue<AccountScreenState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
