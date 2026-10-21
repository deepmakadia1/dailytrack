// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budgets_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
/// Family argument: the `yyyy-MM` month to open, or null for this month.

@ProviderFor(BudgetsController)
final budgetsControllerProvider = BudgetsControllerFamily._();

/// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
/// Family argument: the `yyyy-MM` month to open, or null for this month.
final class BudgetsControllerProvider
    extends $NotifierProvider<BudgetsController, BudgetsState> {
  /// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
  /// Family argument: the `yyyy-MM` month to open, or null for this month.
  BudgetsControllerProvider._({
    required BudgetsControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'budgetsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$budgetsControllerHash();

  @override
  String toString() {
    return r'budgetsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  BudgetsController create() => BudgetsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BudgetsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BudgetsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is BudgetsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$budgetsControllerHash() => r'58dc8e491b9978970d3843f625f8169136531b3f';

/// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
/// Family argument: the `yyyy-MM` month to open, or null for this month.

final class BudgetsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          BudgetsController,
          BudgetsState,
          BudgetsState,
          BudgetsState,
          String?
        > {
  BudgetsControllerFamily._()
    : super(
        retry: null,
        name: r'budgetsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
  /// Family argument: the `yyyy-MM` month to open, or null for this month.

  BudgetsControllerProvider call(String? month) =>
      BudgetsControllerProvider._(argument: month, from: this);

  @override
  String toString() => r'budgetsControllerProvider';
}

/// EXP-08 Budgets (T043, contracts/screens.md). The screen's only notifier.
/// Family argument: the `yyyy-MM` month to open, or null for this month.

abstract class _$BudgetsController extends $Notifier<BudgetsState> {
  late final _$args = ref.$arg as String?;
  String? get month => _$args;

  BudgetsState build(String? month);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<BudgetsState, BudgetsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<BudgetsState, BudgetsState>,
              BudgetsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
