import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/validate_category_name.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category_form_state.freezed.dart';

/// Which EXP-05 sheet to open: a new category of [type], or [id] to edit.
@freezed
abstract class CategoryFormArgs with _$CategoryFormArgs {
  const factory({required CategoryType type, String? id}) = _CategoryFormArgs;
}

enum CategoryFormStatus { loading, ready, loadError }

/// EXP-05 state (contracts/screens.md).
@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const factory({
    required CategoryFormStatus status,
    required CategoryType type,
    @Default('') String name,
    @Default('') String iconKey,
    @Default('') String colorHex,
    CategoryNameError? nameError,
    @Default(false) bool saving,
    @Default(false) bool saveFailed,

    /// Non-deleted categories, for the duplicate check.
    @Default(<Category>[]) List<Category> existing,

    /// The category being edited; null for a new one.
    Category? original,
  }) = _CategoryFormState;

  const new _();

  bool get isEdit => original != null;
}
