// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The Home Expense card (T111, FR-030; DSH-01 budget bar, research R9):
/// spent today and this month (expenses only) plus the Overall budget,
/// live. Rebuilds itself at the next local midnight so "today" moves on
/// without a restart.

@ProviderFor(ExpenseDashboardController)
final expenseDashboardControllerProvider =
    ExpenseDashboardControllerProvider._();

/// The Home Expense card (T111, FR-030; DSH-01 budget bar, research R9):
/// spent today and this month (expenses only) plus the Overall budget,
/// live. Rebuilds itself at the next local midnight so "today" moves on
/// without a restart.
final class ExpenseDashboardControllerProvider
    extends
        $NotifierProvider<
          ExpenseDashboardController,
          AsyncValue<ExpenseDashboardData>
        > {
  /// The Home Expense card (T111, FR-030; DSH-01 budget bar, research R9):
  /// spent today and this month (expenses only) plus the Overall budget,
  /// live. Rebuilds itself at the next local midnight so "today" moves on
  /// without a restart.
  ExpenseDashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseDashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseDashboardControllerHash();

  @$internal
  @override
  ExpenseDashboardController create() => ExpenseDashboardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ExpenseDashboardData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ExpenseDashboardData>>(
        value,
      ),
    );
  }
}

String _$expenseDashboardControllerHash() =>
    r'da9c3e51dd003798ca1ec421b626b07661f518b5';

/// The Home Expense card (T111, FR-030; DSH-01 budget bar, research R9):
/// spent today and this month (expenses only) plus the Overall budget,
/// live. Rebuilds itself at the next local midnight so "today" moves on
/// without a restart.

abstract class _$ExpenseDashboardController
    extends $Notifier<AsyncValue<ExpenseDashboardData>> {
  AsyncValue<ExpenseDashboardData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<ExpenseDashboardData>,
              AsyncValue<ExpenseDashboardData>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<ExpenseDashboardData>,
                AsyncValue<ExpenseDashboardData>
              >,
              AsyncValue<ExpenseDashboardData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
