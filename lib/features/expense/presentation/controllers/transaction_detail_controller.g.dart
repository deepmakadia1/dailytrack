// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
/// or not, or null when it does not exist.

@ProviderFor(detailRule)
final detailRuleProvider = DetailRuleFamily._();

/// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
/// or not, or null when it does not exist.

final class DetailRuleProvider
    extends
        $FunctionalProvider<
          AsyncValue<RecurringRule?>,
          RecurringRule?,
          FutureOr<RecurringRule?>
        >
    with $FutureModifier<RecurringRule?>, $FutureProvider<RecurringRule?> {
  /// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
  /// or not, or null when it does not exist.
  DetailRuleProvider._({
    required DetailRuleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'detailRuleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$detailRuleHash();

  @override
  String toString() {
    return r'detailRuleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RecurringRule?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RecurringRule?> create(Ref ref) {
    final argument = this.argument as String;
    return detailRule(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DetailRuleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$detailRuleHash() => r'6699ceb7a4f15c9c3dde57f2aaf6af10089eafa1';

/// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
/// or not, or null when it does not exist.

final class DetailRuleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RecurringRule?>, String> {
  DetailRuleFamily._()
    : super(
        retry: null,
        name: r'detailRuleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-03's "Created from recurring rule" link (FR-028): the rule, deleted
  /// or not, or null when it does not exist.

  DetailRuleProvider call(String ruleId) =>
      DetailRuleProvider._(argument: ruleId, from: this);

  @override
  String toString() => r'detailRuleProvider';
}

/// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
/// only notifier. Emits null when the row is missing or was deleted
/// elsewhere.

@ProviderFor(TransactionDetailController)
final transactionDetailControllerProvider =
    TransactionDetailControllerFamily._();

/// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
/// only notifier. Emits null when the row is missing or was deleted
/// elsewhere.
final class TransactionDetailControllerProvider
    extends
        $StreamNotifierProvider<TransactionDetailController, TransactionView?> {
  /// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
  /// only notifier. Emits null when the row is missing or was deleted
  /// elsewhere.
  TransactionDetailControllerProvider._({
    required TransactionDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'transactionDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionDetailControllerHash();

  @override
  String toString() {
    return r'transactionDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TransactionDetailController create() => TransactionDetailController();

  @override
  bool operator ==(Object other) {
    return other is TransactionDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionDetailControllerHash() =>
    r'08d87e8d17fef8d18ff55fe65447d258fedec8df';

/// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
/// only notifier. Emits null when the row is missing or was deleted
/// elsewhere.

final class TransactionDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          TransactionDetailController,
          AsyncValue<TransactionView?>,
          TransactionView?,
          Stream<TransactionView?>,
          String
        > {
  TransactionDetailControllerFamily._()
    : super(
        retry: null,
        name: r'transactionDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
  /// only notifier. Emits null when the row is missing or was deleted
  /// elsewhere.

  TransactionDetailControllerProvider call(String id) =>
      TransactionDetailControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'transactionDetailControllerProvider';
}

/// EXP-03 Transaction detail (T074, contracts/screens.md). The screen's
/// only notifier. Emits null when the row is missing or was deleted
/// elsewhere.

abstract class _$TransactionDetailController
    extends $StreamNotifier<TransactionView?> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  Stream<TransactionView?> build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<TransactionView?>, TransactionView?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TransactionView?>, TransactionView?>,
              AsyncValue<TransactionView?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
