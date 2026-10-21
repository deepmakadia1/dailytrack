// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'themes_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// SET-04 controller (FR-015 – FR-021, research R12).

@ProviderFor(ThemesController)
final themesControllerProvider = ThemesControllerProvider._();

/// SET-04 controller (FR-015 – FR-021, research R12).
final class ThemesControllerProvider
    extends $AsyncNotifierProvider<ThemesController, ThemesState> {
  /// SET-04 controller (FR-015 – FR-021, research R12).
  ThemesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'themesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$themesControllerHash();

  @$internal
  @override
  ThemesController create() => ThemesController();
}

String _$themesControllerHash() => r'a27f338452674068b9f160a24d117c8d8008a693';

/// SET-04 controller (FR-015 – FR-021, research R12).

abstract class _$ThemesController extends $AsyncNotifier<ThemesState> {
  FutureOr<ThemesState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ThemesState>, ThemesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ThemesState>, ThemesState>,
              AsyncValue<ThemesState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
