// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pin_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
/// "SYS-04").

@ProviderFor(PinController)
final pinControllerProvider = PinControllerFamily._();

/// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
/// "SYS-04").
final class PinControllerProvider
    extends $NotifierProvider<PinController, PinState> {
  /// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
  /// "SYS-04").
  PinControllerProvider._({
    required PinControllerFamily super.from,
    required PinFlowMode super.argument,
  }) : super(
         retry: null,
         name: r'pinControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$pinControllerHash();

  @override
  String toString() {
    return r'pinControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PinController create() => PinController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PinState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PinState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PinControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$pinControllerHash() => r'13449981bc8c61c1019da89cb60900ea62c4991b';

/// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
/// "SYS-04").

final class PinControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PinController,
          PinState,
          PinState,
          PinState,
          PinFlowMode
        > {
  PinControllerFamily._()
    : super(
        retry: null,
        name: r'pinControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
  /// "SYS-04").

  PinControllerProvider call(PinFlowMode mode) =>
      PinControllerProvider._(argument: mode, from: this);

  @override
  String toString() => r'pinControllerProvider';
}

/// SYS-04 Set / change PIN controller (FR-037 – FR-041, contracts/screens.md
/// "SYS-04").

abstract class _$PinController extends $Notifier<PinState> {
  late final _$args = ref.$arg as PinFlowMode;
  PinFlowMode get mode => _$args;

  PinState build(PinFlowMode mode);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<PinState, PinState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PinState, PinState>,
              PinState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
