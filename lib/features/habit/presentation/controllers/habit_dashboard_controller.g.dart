// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_dashboard_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// `HabitModule.dashboardCard()` (T092, US7; DSH-01). Watches active habits
/// with the current week of entries (enough for today and the weekly
/// listing). Rebuilds at local midnight so "today" moves on without a
/// restart (feature 006 research R18).

@ProviderFor(HabitDashboardController)
final habitDashboardControllerProvider = HabitDashboardControllerProvider._();

/// `HabitModule.dashboardCard()` (T092, US7; DSH-01). Watches active habits
/// with the current week of entries (enough for today and the weekly
/// listing). Rebuilds at local midnight so "today" moves on without a
/// restart (feature 006 research R18).
final class HabitDashboardControllerProvider
    extends
        $NotifierProvider<
          HabitDashboardController,
          AsyncValue<HabitDashboardData>
        > {
  /// `HabitModule.dashboardCard()` (T092, US7; DSH-01). Watches active habits
  /// with the current week of entries (enough for today and the weekly
  /// listing). Rebuilds at local midnight so "today" moves on without a
  /// restart (feature 006 research R18).
  HabitDashboardControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitDashboardControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitDashboardControllerHash();

  @$internal
  @override
  HabitDashboardController create() => HabitDashboardController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<HabitDashboardData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<HabitDashboardData>>(
        value,
      ),
    );
  }
}

String _$habitDashboardControllerHash() =>
    r'37f63bfee003e30b03208a543cb681b3c4d6d27c';

/// `HabitModule.dashboardCard()` (T092, US7; DSH-01). Watches active habits
/// with the current week of entries (enough for today and the weekly
/// listing). Rebuilds at local midnight so "today" moves on without a
/// restart (feature 006 research R18).

abstract class _$HabitDashboardController
    extends $Notifier<AsyncValue<HabitDashboardData>> {
  AsyncValue<HabitDashboardData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<HabitDashboardData>,
              AsyncValue<HabitDashboardData>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<HabitDashboardData>,
                AsyncValue<HabitDashboardData>
              >,
              AsyncValue<HabitDashboardData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
