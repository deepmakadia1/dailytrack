// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
/// Family argument: the account id to edit, or null for a new account.

@ProviderFor(AccountFormController)
final accountFormControllerProvider = AccountFormControllerFamily._();

/// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
/// Family argument: the account id to edit, or null for a new account.
final class AccountFormControllerProvider
    extends $NotifierProvider<AccountFormController, AccountFormState> {
  /// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
  /// Family argument: the account id to edit, or null for a new account.
  AccountFormControllerProvider._({
    required AccountFormControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'accountFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$accountFormControllerHash();

  @override
  String toString() {
    return r'accountFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  AccountFormController create() => AccountFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AccountFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AccountFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AccountFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$accountFormControllerHash() =>
    r'1c16ce13404ccc75d07fd4661cc14544903dfa49';

/// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
/// Family argument: the account id to edit, or null for a new account.

final class AccountFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          AccountFormController,
          AccountFormState,
          AccountFormState,
          AccountFormState,
          String?
        > {
  AccountFormControllerFamily._()
    : super(
        retry: null,
        name: r'accountFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
  /// Family argument: the account id to edit, or null for a new account.

  AccountFormControllerProvider call(String? id) =>
      AccountFormControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'accountFormControllerProvider';
}

/// EXP-07 Add / edit account sheet (T104). The sheet's only notifier.
/// Family argument: the account id to edit, or null for a new account.

abstract class _$AccountFormController extends $Notifier<AccountFormState> {
  late final _$args = ref.$arg as String?;
  String? get id => _$args;

  AccountFormState build(String? id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AccountFormState, AccountFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AccountFormState, AccountFormState>,
              AccountFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
