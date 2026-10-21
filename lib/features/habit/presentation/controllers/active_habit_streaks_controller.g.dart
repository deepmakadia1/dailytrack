// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_habit_streaks_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Active habits (in sort order) with the same 400-day history window as
/// HAB-01 and their streak summaries, live, rebuilt at local midnight.
/// Shared by the DSH-01 streak flame and the habit insight source, so Home
/// loads that window once (feature 006 research R5, R15).

@ProviderFor(ActiveHabitStreaksController)
final activeHabitStreaksControllerProvider =
    ActiveHabitStreaksControllerProvider._();

/// Active habits (in sort order) with the same 400-day history window as
/// HAB-01 and their streak summaries, live, rebuilt at local midnight.
/// Shared by the DSH-01 streak flame and the habit insight source, so Home
/// loads that window once (feature 006 research R5, R15).
final class ActiveHabitStreaksControllerProvider
    extends
        $NotifierProvider<
          ActiveHabitStreaksController,
          AsyncValue<List<HabitStreakRow>>
        > {
  /// Active habits (in sort order) with the same 400-day history window as
  /// HAB-01 and their streak summaries, live, rebuilt at local midnight.
  /// Shared by the DSH-01 streak flame and the habit insight source, so Home
  /// loads that window once (feature 006 research R5, R15).
  ActiveHabitStreaksControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeHabitStreaksControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeHabitStreaksControllerHash();

  @$internal
  @override
  ActiveHabitStreaksController create() => ActiveHabitStreaksController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<HabitStreakRow>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<HabitStreakRow>>>(
        value,
      ),
    );
  }
}

String _$activeHabitStreaksControllerHash() =>
    r'30d99430636136c616b7c6d2c47b979ef8acb33b';

/// Active habits (in sort order) with the same 400-day history window as
/// HAB-01 and their streak summaries, live, rebuilt at local midnight.
/// Shared by the DSH-01 streak flame and the habit insight source, so Home
/// loads that window once (feature 006 research R5, R15).

abstract class _$ActiveHabitStreaksController
    extends $Notifier<AsyncValue<List<HabitStreakRow>>> {
  AsyncValue<List<HabitStreakRow>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<HabitStreakRow>>,
              AsyncValue<List<HabitStreakRow>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<HabitStreakRow>>,
                AsyncValue<List<HabitStreakRow>>
              >,
              AsyncValue<List<HabitStreakRow>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
