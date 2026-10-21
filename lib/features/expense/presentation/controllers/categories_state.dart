import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'categories_state.freezed.dart';

/// EXP-04 state (contracts/screens.md).
@freezed
abstract class CategoriesState with _$CategoriesState {
  const factory({
    required CategoryType tab,

    /// Every non-deleted category of [tab] in its order, with this month's
    /// total; hidden ones included (flagged).
    required AsyncValue<List<CategoryWithStats>> items,
    @Default(false) bool hiddenExpanded,
    @Default(false) bool reorderFailed,
  }) = _CategoriesState;

  const new _();

  List<CategoryWithStats>? get visible =>
      items.value?.where((s) => !s.category.isHidden).toList();

  List<CategoryWithStats>? get hidden =>
      items.value?.where((s) => s.category.isHidden).toList();
}

/// What deleting a category needs (FR-026).
sealed class CategoryDeleteOutcome {
  const new();
}

/// Deleted at once; [undo] restores it.
final class CategoryDeleted extends CategoryDeleteOutcome {
  const new(this.undo);

  final Future<void> Function() undo;
}

/// It has transactions: the user must pick one of [options] first.
final class CategoryNeedsReplacement extends CategoryDeleteOutcome {
  const new(this.transactionCount, this.options);

  final int transactionCount;
  final List<Category> options;
}

/// Default categories cannot be deleted, or the write failed.
final class CategoryDeleteFailed extends CategoryDeleteOutcome {
  const new();
}
