// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
/// only notifier. Defaults remember the user (research R7): last-used
/// account, payment mode from the account type, categories by usage.

@ProviderFor(TransactionFormController)
final transactionFormControllerProvider = TransactionFormControllerFamily._();

/// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
/// only notifier. Defaults remember the user (research R7): last-used
/// account, payment mode from the account type, categories by usage.
final class TransactionFormControllerProvider
    extends $NotifierProvider<TransactionFormController, TransactionFormState> {
  /// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
  /// only notifier. Defaults remember the user (research R7): last-used
  /// account, payment mode from the account type, categories by usage.
  TransactionFormControllerProvider._({
    required TransactionFormControllerFamily super.from,
    required TransactionFormArgs super.argument,
  }) : super(
         retry: null,
         name: r'transactionFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionFormControllerHash();

  @override
  String toString() {
    return r'transactionFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionFormController create() => TransactionFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionFormControllerHash() =>
    r'22a750a9a7feacd1c6fe8e1c18df681a376a596e';

/// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
/// only notifier. Defaults remember the user (research R7): last-used
/// account, payment mode from the account type, categories by usage.

final class TransactionFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionFormController,
          TransactionFormState,
          TransactionFormState,
          TransactionFormState,
          TransactionFormArgs
        > {
  TransactionFormControllerFamily._()
    : super(
        retry: null,
        name: r'transactionFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
  /// only notifier. Defaults remember the user (research R7): last-used
  /// account, payment mode from the account type, categories by usage.

  TransactionFormControllerProvider call(TransactionFormArgs args) =>
      TransactionFormControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'transactionFormControllerProvider';
}

/// EXP-02 Add / edit transaction (T053, contracts/screens.md). The screen's
/// only notifier. Defaults remember the user (research R7): last-used
/// account, payment mode from the account type, categories by usage.

abstract class _$TransactionFormController
    extends $Notifier<TransactionFormState> {
  late final _$args = ref.$arg as TransactionFormArgs;
  TransactionFormArgs get args => _$args;

  TransactionFormState build(TransactionFormArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionFormState, TransactionFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionFormState, TransactionFormState>,
              TransactionFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
