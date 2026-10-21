// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_flame_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The best active streak across active habits (feature 006 research R5),
/// live, from [ActiveHabitStreaksController] (the HAB-01 window, so the
/// flame and HAB-01 always agree). Shows 0 with no habits.

@ProviderFor(StreakFlameController)
final streakFlameControllerProvider = StreakFlameControllerProvider._();

/// The best active streak across active habits (feature 006 research R5),
/// live, from [ActiveHabitStreaksController] (the HAB-01 window, so the
/// flame and HAB-01 always agree). Shows 0 with no habits.
final class StreakFlameControllerProvider
    extends
        $NotifierProvider<StreakFlameController, AsyncValue<StreakFlameData>> {
  /// The best active streak across active habits (feature 006 research R5),
  /// live, from [ActiveHabitStreaksController] (the HAB-01 window, so the
  /// flame and HAB-01 always agree). Shows 0 with no habits.
  StreakFlameControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'streakFlameControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$streakFlameControllerHash();

  @$internal
  @override
  StreakFlameController create() => StreakFlameController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<StreakFlameData> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<StreakFlameData>>(value),
    );
  }
}

String _$streakFlameControllerHash() =>
    r'acbf078238081bcad7f2421959a51399be394f39';

/// The best active streak across active habits (feature 006 research R5),
/// live, from [ActiveHabitStreaksController] (the HAB-01 window, so the
/// flame and HAB-01 always agree). Shows 0 with no habits.

abstract class _$StreakFlameController
    extends $Notifier<AsyncValue<StreakFlameData>> {
  AsyncValue<StreakFlameData> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<StreakFlameData>, AsyncValue<StreakFlameData>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<StreakFlameData>,
                AsyncValue<StreakFlameData>
              >,
              AsyncValue<StreakFlameData>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
