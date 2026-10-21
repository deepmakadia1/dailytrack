// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
/// notifier.

@ProviderFor(BudgetFormController)
final budgetFormControllerProvider = BudgetFormControllerFamily._();

/// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
/// notifier.
final class BudgetFormControllerProvider
    extends $NotifierProvider<BudgetFormController, BudgetFormState> {
  /// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
  /// notifier.
  BudgetFormControllerProvider._({
    required BudgetFormControllerFamily super.from,
    required BudgetFormArgs super.argument,
  }) : super(
         retry: null,
         name: r'budgetFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetFormControllerHash();

  @override
  String toString() {
    return r'budgetFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BudgetFormController create() => BudgetFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetFormControllerHash() =>
    r'c95f4812ae06fc6dd5ab7d50d208827af7c6de4a';

/// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
/// notifier.

final class BudgetFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          BudgetFormController,
          BudgetFormState,
          BudgetFormState,
          BudgetFormState,
          BudgetFormArgs
        > {
  BudgetFormControllerFamily._()
    : super(
        retry: null,
        name: r'budgetFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
  /// notifier.

  BudgetFormControllerProvider call(BudgetFormArgs args) =>
      BudgetFormControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'budgetFormControllerProvider';
}

/// EXP-09 Set budget sheet (T046, contracts/screens.md). The sheet's only
/// notifier.

abstract class _$BudgetFormController extends $Notifier<BudgetFormState> {
  late final _$args = ref.$arg as BudgetFormArgs;
  BudgetFormArgs get args => _$args;

  BudgetFormState build(BudgetFormArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BudgetFormState, BudgetFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetFormState, BudgetFormState>,
              BudgetFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
