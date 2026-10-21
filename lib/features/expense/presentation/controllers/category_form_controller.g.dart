// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.

@ProviderFor(CategoryFormController)
final categoryFormControllerProvider = CategoryFormControllerFamily._();

/// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.
final class CategoryFormControllerProvider
    extends $NotifierProvider<CategoryFormController, CategoryFormState> {
  /// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.
  CategoryFormControllerProvider._({
    required CategoryFormControllerFamily super.from,
    required CategoryFormArgs super.argument,
  }) : super(
         retry: null,
         name: r'categoryFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$categoryFormControllerHash();

  @override
  String toString() {
    return r'categoryFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CategoryFormController create() => CategoryFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CategoryFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CategoryFormState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CategoryFormControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$categoryFormControllerHash() =>
    r'a6f959c4113bd7ca1db79c37eae943818853fba4';

/// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.

final class CategoryFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          CategoryFormController,
          CategoryFormState,
          CategoryFormState,
          CategoryFormState,
          CategoryFormArgs
        > {
  CategoryFormControllerFamily._()
    : super(
        retry: null,
        name: r'categoryFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.

  CategoryFormControllerProvider call(CategoryFormArgs args) =>
      CategoryFormControllerProvider._(argument: args, from: this);

  @override
  String toString() => r'categoryFormControllerProvider';
}

/// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.

abstract class _$CategoryFormController extends $Notifier<CategoryFormState> {
  late final _$args = ref.$arg as CategoryFormArgs;
  CategoryFormArgs get args => _$args;

  CategoryFormState build(CategoryFormArgs args);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CategoryFormState, CategoryFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CategoryFormState, CategoryFormState>,
              CategoryFormState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
