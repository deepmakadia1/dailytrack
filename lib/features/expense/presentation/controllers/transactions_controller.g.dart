// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-01 Transactions list (T071, contracts/screens.md). The screen's only
/// notifier. Kept alive so the session filter survives tab switches and
/// navigation, and resets when the app restarts (FR-020).

@ProviderFor(TransactionsController)
final transactionsControllerProvider = TransactionsControllerProvider._();

/// EXP-01 Transactions list (T071, contracts/screens.md). The screen's only
/// notifier. Kept alive so the session filter survives tab switches and
/// navigation, and resets when the app restarts (FR-020).
final class TransactionsControllerProvider
    extends $NotifierProvider<TransactionsController, TransactionsState> {
  /// EXP-01 Transactions list (T071, contracts/screens.md). The screen's only
  /// notifier. Kept alive so the session filter survives tab switches and
  /// navigation, and resets when the app restarts (FR-020).
  TransactionsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'transactionsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$transactionsControllerHash();

  @$internal
  @override
  TransactionsController create() => TransactionsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TransactionsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TransactionsState>(value),
    );
  }
}

String _$transactionsControllerHash() =>
    r'84683a6e7b7aaa610b265f2bb851d95125bb31ac';

/// EXP-01 Transactions list (T071, contracts/screens.md). The screen's only
/// notifier. Kept alive so the session filter survives tab switches and
/// navigation, and resets when the app restarts (FR-020).

abstract class _$TransactionsController extends $Notifier<TransactionsState> {
  TransactionsState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TransactionsState, TransactionsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TransactionsState, TransactionsState>,
              TransactionsState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
