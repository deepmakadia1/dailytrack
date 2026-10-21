// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unlock_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SYS-03 Unlock controller (FR-028 – FR-034, clarifications Q1, Q3).

@ProviderFor(UnlockController)
final unlockControllerProvider = UnlockControllerProvider._();

/// SYS-03 Unlock controller (FR-028 – FR-034, clarifications Q1, Q3).
final class UnlockControllerProvider
    extends $NotifierProvider<UnlockController, UnlockState> {
  /// SYS-03 Unlock controller (FR-028 – FR-034, clarifications Q1, Q3).
  UnlockControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unlockControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unlockControllerHash();

  @$internal
  @override
  UnlockController create() => UnlockController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UnlockState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UnlockState>(value),
    );
  }
}

String _$unlockControllerHash() => r'61aece9b3840643553a136d6ba9a81aa2767d7b2';

/// SYS-03 Unlock controller (FR-028 – FR-034, clarifications Q1, Q3).

abstract class _$UnlockController extends $Notifier<UnlockState> {
  UnlockState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<UnlockState, UnlockState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UnlockState, UnlockState>,
              UnlockState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
