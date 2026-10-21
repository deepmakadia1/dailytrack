// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archived_habits_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// HAB-04 Archived habits (T088, FR-033). The screen's only notifier. The
/// best streak comes from a one-shot full history per habit (research R7).

@ProviderFor(ArchivedHabitsController)
final archivedHabitsControllerProvider = ArchivedHabitsControllerProvider._();

/// HAB-04 Archived habits (T088, FR-033). The screen's only notifier. The
/// best streak comes from a one-shot full history per habit (research R7).
final class ArchivedHabitsControllerProvider
    extends
        $NotifierProvider<
          ArchivedHabitsController,
          AsyncValue<List<ArchivedHabitRow>>
        > {
  /// HAB-04 Archived habits (T088, FR-033). The screen's only notifier. The
  /// best streak comes from a one-shot full history per habit (research R7).
  ArchivedHabitsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'archivedHabitsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$archivedHabitsControllerHash();

  @$internal
  @override
  ArchivedHabitsController create() => ArchivedHabitsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<ArchivedHabitRow>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<ArchivedHabitRow>>>(
        value,
      ),
    );
  }
}

String _$archivedHabitsControllerHash() =>
    r'340386ba1e04e12ae094080e33b6d721ea99cbb3';

/// HAB-04 Archived habits (T088, FR-033). The screen's only notifier. The
/// best streak comes from a one-shot full history per habit (research R7).

abstract class _$ArchivedHabitsController
    extends $Notifier<AsyncValue<List<ArchivedHabitRow>>> {
  AsyncValue<List<ArchivedHabitRow>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ArchivedHabitRow>>,
              AsyncValue<List<ArchivedHabitRow>>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ArchivedHabitRow>>,
                AsyncValue<List<ArchivedHabitRow>>
              >,
              AsyncValue<List<ArchivedHabitRow>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
