import 'dart:async';

import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_icons.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_category_name.dart';
import 'package:dailytrack/features/expense/presentation/controllers/category_form_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/category_form_state.dart';

part 'category_form_controller.g.dart';

/// EXP-05 Add / edit category sheet (T091). The sheet's only notifier.
@riverpod
class CategoryFormController extends _$CategoryFormController {
  StreamSubscription<Object?>? _sub;

  @override
  CategoryFormState build(CategoryFormArgs args) {
    // Listen rather than take `.first`: the first emission fills the form,
    // later ones keep the duplicate check current while the sheet is open.
    _sub = ref
        .read(categoryRepositoryProvider)
        .watchAll()
        .listen(_onCategories, onError: (Object _) => _onLoadError());
    ref.onDispose(() => unawaited(_sub?.cancel()));
    return CategoryFormState(
      status: CategoryFormStatus.loading,
      type: args.type,
    );
  }

  void _onLoadError() {
    if (state.status == CategoryFormStatus.loading) {
      state = state.copyWith(status: CategoryFormStatus.loadError);
    }
  }

  void _onCategories(List<Category> existing) {
    if (state.status != CategoryFormStatus.loading) {
      state = state.copyWith(existing: existing);
      return;
    }
    final original = args.id == null
        ? null
        : existing.where((c) => c.id == args.id).firstOrNull;
    if (args.id != null && original == null) {
      state = state.copyWith(status: CategoryFormStatus.loadError);
      return;
    }
    state = state.copyWith(
      status: CategoryFormStatus.ready,
      existing: existing,
      original: original,
      type: original?.type ?? args.type,
      // A default holds its key here; the sheet shows (and sets) its
      // translated name.
      name: original?.name ?? '',
      iconKey: original?.iconKey ?? AppIcons.keys.first,
      colorHex: original?.colorHex ?? AppColors.toHex(AppColors.palette.first),
    );
  }

  void setName(String name) => state = state.copyWith(
    name: name,
    // Clear a shown error as soon as the user edits the name.
    nameError: null,
  );

  void setType(CategoryType type) {
    if (!state.isEdit) state = state.copyWith(type: type, nameError: null);
  }

  void setIcon(String key) => state = state.copyWith(iconKey: key);

  void setColor(String hex) => state = state.copyWith(colorHex: hex);

  /// Validates (Q5) and saves. Returns the saved category, or null when the
  /// name is invalid or saving failed (the sheet stays open).
  Future<Category?> save() async {
    final validate = ValidateCategoryName(ref.read(defaultNameCatalogProvider));
    final error = validate(
      state.name,
      type: state.type,
      existing: state.existing,
      editingId: state.original?.id,
    );
    if (error != null) {
      state = state.copyWith(nameError: error);
      return null;
    }
    state = state.copyWith(saving: true, saveFailed: false);
    final repo = ref.read(categoryRepositoryProvider);
    try {
      final original = state.original;
      final Category saved;
      if (original == null) {
        saved = await repo.create(
          name: state.name,
          type: state.type,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
      } else {
        // An unchanged default keeps its key, so it stays translated.
        final name = _unchangedDefaultName(original) ?? state.name.trim();
        await repo.update(
          original.id,
          name: name,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
        saved = original.copyWith(
          name: name,
          iconKey: state.iconKey,
          colorHex: state.colorHex,
        );
      }
      if (ref.mounted) state = state.copyWith(saving: false);
      return saved;
    } on ExpenseStorageFailure {
      if (ref.mounted) {
        state = state.copyWith(saving: false, saveFailed: true);
      }
      return null;
    }
  }

  /// The stored key, when [original] is a default whose name field still
  /// holds one of its translations (the user did not rename it).
  String? _unchangedDefaultName(Category original) {
    if (!original.isDefault) return null;
    final translations = ref
        .read(defaultNameCatalogProvider)
        .namesFor(original.name);
    final typed = ValidateCategoryName.normalize(state.name);
    return translations.map(ValidateCategoryName.normalize).contains(typed) ||
            typed == ValidateCategoryName.normalize(original.name)
        ? original.name
        : null;
  }

  void retry() => ref.invalidateSelf();
}
