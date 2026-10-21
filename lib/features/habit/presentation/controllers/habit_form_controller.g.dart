// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id to edit, or null for a new one.

@ProviderFor(HabitFormController)
final habitFormControllerProvider = HabitFormControllerFamily._();

/// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id to edit, or null for a new one.
final class HabitFormControllerProvider
    extends $NotifierProvider<HabitFormController, HabitFormState> {
  /// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
  /// notifier. Family argument: the habit id to edit, or null for a new one.
  HabitFormControllerProvider._({
    required HabitFormControllerFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'habitFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$habitFormControllerHash();

  @override
  String toString() {
    return r'habitFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HabitFormController create() => HabitFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HabitFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HabitFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HabitFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$habitFormControllerHash() =>
    r'd2e6e7961e8a3214ef86cc4d4e91799e29915917';

/// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id to edit, or null for a new one.

final class HabitFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HabitFormController,
          HabitFormState,
          HabitFormState,
          HabitFormState,
          String?
        > {
  HabitFormControllerFamily._()
    : super(
        retry: null,
        name: r'habitFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
  /// notifier. Family argument: the habit id to edit, or null for a new one.

  HabitFormControllerProvider call(String? id) =>
      HabitFormControllerProvider._(argument: id, from: this);

  @override
  String toString() => r'habitFormControllerProvider';
}

/// HAB-02 Add / edit habit (T057, contracts/screens.md). The screen's only
/// notifier. Family argument: the habit id to edit, or null for a new one.

abstract class _$HabitFormController extends $Notifier<HabitFormState> {
  late final _$args = ref.$arg as String?;
  String? get id => _$args;

  HabitFormState build(String? id);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<HabitFormState, HabitFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<HabitFormState, HabitFormState>,
              HabitFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
