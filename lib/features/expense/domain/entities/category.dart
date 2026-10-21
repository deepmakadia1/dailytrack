import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

/// Expense or income category (data-model.md §3.2).
@freezed
abstract class Category with _$Category {
  const factory({
    required String id,

    /// An ARB key (e.g. `expense_cat_food`) for a default that has not been
    /// renamed, otherwise the user's text.
    required String name,
    required CategoryType type,
    required String iconKey,
    required String colorHex,
    required bool isDefault,

    /// Stored in the `isArchived` column.
    required bool isHidden,
    required int sortOrder,
  }) = _Category;
}

/// EXP-04 row and EXP-02 ordering input.
@freezed
abstract class CategoryWithStats with _$CategoryWithStats {
  const factory({
    required Category category,
    required int monthTotalMinor,
    required int usageCount,
  }) = _CategoryWithStats;
}
