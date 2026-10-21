// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habits_today_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// HAB-01 Habits today (T059, contracts/screens.md). The screen's only
/// notifier. Watches the active habits and their entries from
/// `today − 400 days` (research R7); a habit whose current run reaches that
/// window start gets its full history loaded once, cached until its
/// entries change.

@ProviderFor(HabitsTodayController)
final habitsTodayControllerProvider = HabitsTodayControllerProvider._();

/// HAB-01 Habits today (T059, contracts/screens.md). The screen's only
/// notifier. Watches the active habits and their entries from
/// `today − 400 days` (research R7); a habit whose current run reaches that
/// window start gets its full history loaded once, cached until its
/// entries change.
final class HabitsTodayControllerProvider
    extends $NotifierProvider<HabitsTodayController, HabitsTodayState> {
  /// HAB-01 Habits today (T059, contracts/screens.md). The screen's only
  /// notifier. Watches the active habits and their entries from
  /// `today − 400 days` (research R7); a habit whose current run reaches that
  /// window start gets its full history loaded once, cached until its
  /// entries change.
  HabitsTodayControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'habitsTodayControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$habitsTodayControllerHash();

  @$internal
  @override
  HabitsTodayController create() => HabitsTodayController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitsTodayState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitsTodayState>(value),
    );
  }
}

String _$habitsTodayControllerHash() =>
    r'e206f46dd52a80f2d572dd79404b16a60c9e0ba5';

/// HAB-01 Habits today (T059, contracts/screens.md). The screen's only
/// notifier. Watches the active habits and their entries from
/// `today − 400 days` (research R7); a habit whose current run reaches that
/// window start gets its full history loaded once, cached until its
/// entries change.

abstract class _$HabitsTodayController extends $Notifier<HabitsTodayState> {
  HabitsTodayState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HabitsTodayState, HabitsTodayState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HabitsTodayState, HabitsTodayState>,
              HabitsTodayState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
