// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'categories_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-04 Categories (T093, contracts/screens.md). The screen's only
/// notifier.

@ProviderFor(CategoriesController)
final categoriesControllerProvider = CategoriesControllerProvider._();

/// EXP-04 Categories (T093, contracts/screens.md). The screen's only
/// notifier.
final class CategoriesControllerProvider
    extends $NotifierProvider<CategoriesController, CategoriesState> {
  /// EXP-04 Categories (T093, contracts/screens.md). The screen's only
  /// notifier.
  CategoriesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesControllerHash();

  @$internal
  @override
  CategoriesController create() => CategoriesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoriesState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoriesState>(value),
    );
  }
}

String _$categoriesControllerHash() =>
    r'634980c1ed11ed656914be52bd31f13bd1969d6f';

/// EXP-04 Categories (T093, contracts/screens.md). The screen's only
/// notifier.

abstract class _$CategoriesController extends $Notifier<CategoriesState> {
  CategoriesState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CategoriesState, CategoriesState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoriesState, CategoriesState>,
              CategoriesState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
