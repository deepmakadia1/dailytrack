// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ACC-01 Account controller (spec §16): sign in, Back up now, Switch
/// account, and Delete my backups. Restore and Sign out open ACC-02 and
/// ACC-03, which have their own controllers.

@ProviderFor(AccountController)
final accountControllerProvider = AccountControllerProvider._();

/// ACC-01 Account controller (spec §16): sign in, Back up now, Switch
/// account, and Delete my backups. Restore and Sign out open ACC-02 and
/// ACC-03, which have their own controllers.
final class AccountControllerProvider
    extends $AsyncNotifierProvider<AccountController, AccountScreenState> {
  /// ACC-01 Account controller (spec §16): sign in, Back up now, Switch
  /// account, and Delete my backups. Restore and Sign out open ACC-02 and
  /// ACC-03, which have their own controllers.
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

String _$accountControllerHash() => r'043c4dd1ad8d278c055c85bac5a12dc18bc7e284';

/// ACC-01 Account controller (spec §16): sign in, Back up now, Switch
/// account, and Delete my backups. Restore and Sign out open ACC-02 and
/// ACC-03, which have their own controllers.

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
