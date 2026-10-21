// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'accounts_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-06 Accounts (T105). The screen's only notifier.

@ProviderFor(AccountsController)
final accountsControllerProvider = AccountsControllerProvider._();

/// EXP-06 Accounts (T105). The screen's only notifier.
final class AccountsControllerProvider
    extends $StreamNotifierProvider<AccountsController, AccountsData> {
  /// EXP-06 Accounts (T105). The screen's only notifier.
  AccountsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'accountsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$accountsControllerHash();

  @$internal
  @override
  AccountsController create() => AccountsController();
}

String _$accountsControllerHash() =>
    r'35f157d420048c1ce75fb4e48a46135f03e43f3e';

/// EXP-06 Accounts (T105). The screen's only notifier.

abstract class _$AccountsController extends $StreamNotifier<AccountsData> {
  Stream<AccountsData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<AccountsData>, AccountsData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AccountsData>, AccountsData>,
              AsyncValue<AccountsData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
