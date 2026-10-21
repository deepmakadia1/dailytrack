// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// DSH-01 Recent transactions (feature 006 research R10): the newest five
/// rows of all time, transfers included, live.

@ProviderFor(RecentTransactionsController)
final recentTransactionsControllerProvider =
    RecentTransactionsControllerProvider._();

/// DSH-01 Recent transactions (feature 006 research R10): the newest five
/// rows of all time, transfers included, live.
final class RecentTransactionsControllerProvider
    extends
        $StreamNotifierProvider<
          RecentTransactionsController,
          List<TransactionView>
        > {
  /// DSH-01 Recent transactions (feature 006 research R10): the newest five
  /// rows of all time, transfers included, live.
  RecentTransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentTransactionsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentTransactionsControllerHash();

  @$internal
  @override
  RecentTransactionsController create() => RecentTransactionsController();
}

String _$recentTransactionsControllerHash() =>
    r'94c58c4b7c04aebd95e937fef02bd06bb5ac2c6e';

/// DSH-01 Recent transactions (feature 006 research R10): the newest five
/// rows of all time, transfers included, live.

abstract class _$RecentTransactionsController
    extends $StreamNotifier<List<TransactionView>> {
  Stream<List<TransactionView>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<TransactionView>>, List<TransactionView>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<TransactionView>>,
                List<TransactionView>
              >,
              AsyncValue<List<TransactionView>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
