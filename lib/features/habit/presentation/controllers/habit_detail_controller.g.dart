// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id. Builds the view model once per
/// history change (research R13).

@ProviderFor(HabitDetailController)
final habitDetailControllerProvider = HabitDetailControllerFamily._();

/// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id. Builds the view model once per
/// history change (research R13).
final class HabitDetailControllerProvider
    extends $NotifierProvider<HabitDetailController, HabitDetailState> {
  /// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
  /// notifier. Family argument: the habit id. Builds the view model once per
  /// history change (research R13).
  HabitDetailControllerProvider._({
    required HabitDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'habitDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitDetailControllerHash();

  @override
  String toString() {
    return r'habitDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitDetailController create() => HabitDetailController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitDetailState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitDetailControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitDetailControllerHash() =>
    r'ac55ccb26ecc92a107712bf8a34db1be7f959c7f';

/// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id. Builds the view model once per
/// history change (research R13).

final class HabitDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitDetailController,
          HabitDetailState,
          HabitDetailState,
          HabitDetailState,
          String
        > {
  HabitDetailControllerFamily._()
    : super(
        retry: null,
        name: r'habitDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
  /// notifier. Family argument: the habit id. Builds the view model once per
  /// history change (research R13).

  HabitDetailControllerProvider call(String id) =>
      HabitDetailControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'habitDetailControllerProvider';
}

/// HAB-03 Habit detail (T082, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id. Builds the view model once per
/// history change (research R13).

abstract class _$HabitDetailController extends $Notifier<HabitDetailState> {
  late final _$args = ref.$arg as String;
  String get id => _$args;

  HabitDetailState build(String id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HabitDetailState, HabitDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HabitDetailState, HabitDetailState>,
              HabitDetailState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
