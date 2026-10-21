// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'modules_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SET-06 Modules controller (T088, data-model.md §6 "Module"). Follows the
/// settings stream, so the screen, nav bar and Home stay in step.

@ProviderFor(ModulesController)
final modulesControllerProvider = ModulesControllerProvider._();

/// SET-06 Modules controller (T088, data-model.md §6 "Module"). Follows the
/// settings stream, so the screen, nav bar and Home stay in step.
final class ModulesControllerProvider
    extends $AsyncNotifierProvider<ModulesController, ModulesState> {
  /// SET-06 Modules controller (T088, data-model.md §6 "Module"). Follows the
  /// settings stream, so the screen, nav bar and Home stay in step.
  ModulesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'modulesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$modulesControllerHash();

  @$internal
  @override
  ModulesController create() => ModulesController();
}

String _$modulesControllerHash() => r'c992e4aeab8aa7fd8ae67368e1b42af1e8da4177';

/// SET-06 Modules controller (T088, data-model.md §6 "Module"). Follows the
/// settings stream, so the screen, nav bar and Home stay in step.

abstract class _$ModulesController extends $AsyncNotifier<ModulesState> {
  FutureOr<ModulesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ModulesState>, ModulesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ModulesState>, ModulesState>,
              AsyncValue<ModulesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
