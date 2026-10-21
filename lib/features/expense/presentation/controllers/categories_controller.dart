import 'dart:async';

import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/errors.dart';
import 'package:dailytrack/features/expense/presentation/controllers/categories_state.dart';
import 'package:dailytrack/features/expense/presentation/expense_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:dailytrack/features/expense/presentation/controllers/categories_state.dart';

part 'categories_controller.g.dart';

/// EXP-04 Categories (T093, contracts/screens.md). The screen's only
/// notifier.
@riverpod
class CategoriesController extends _$CategoriesController {
  StreamSubscription<Object?>? _items;

  @override
  CategoriesState build() {
    ref.onDispose(() => unawaited(_items?.cancel()));
    _subscribe(CategoryType.expense);
    return const CategoriesState(
      tab: CategoryType.expense,
      items: AsyncLoading(),
    );
  }

  void _subscribe(CategoryType type) {
    unawaited(_items?.cancel());
    final month = MonthPeriod(ref.read(clockProvider).now());
    _items = ref
        .read(categoryRepositoryProvider)
        .watchByType(type, month: month)
        .listen(
          (items) => state = state.copyWith(items: AsyncData(items)),
          onError: (Object e, StackTrace st) =>
              state = state.copyWith(items: AsyncError(e, st)),
        );
  }

  void setTab(CategoryType tab) {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab, items: const AsyncLoading());
    _subscribe(tab);
  }

  void setHiddenExpanded({required bool expanded}) =>
      state = state.copyWith(hiddenExpanded: expanded);

  /// Moves a visible row; [newIndex] is the index after removal. Shown at
  /// once; a failed write reverts and flags [CategoriesState.reorderFailed].
  Future<void> reorder(int oldIndex, int newIndex) async {
    final current = state.items.value;
    final visible = state.visible;
    if (current == null || visible == null || oldIndex == newIndex) return;
    final moved = [...visible];
    moved.insert(newIndex, moved.removeAt(oldIndex));
    final order = [...moved, ...?state.hidden];
    state = state.copyWith(items: AsyncData(order), reorderFailed: false);
    try {
      await ref.read(categoryRepositoryProvider).reorder(state.tab, [
        for (final s in order) s.category.id,
      ]);
    } on ExpenseStorageFailure {
      if (ref.mounted) {
        state = state.copyWith(items: AsyncData(current), reorderFailed: true);
      }
    }
  }

  /// Hides or shows [id] and returns the undo, or null if it failed.
  Future<Future<void> Function()?> toggleHidden(String id) async {
    final item = state.items.value
        ?.where((s) => s.category.id == id)
        .firstOrNull;
    if (item == null) return null;
    final repo = ref.read(categoryRepositoryProvider);
    final hide = !item.category.isHidden;
    try {
      await repo.setHidden(id, hidden: hide);
    } on ExpenseStorageFailure {
      return null;
    }
    return () => repo.setHidden(id, hidden: !hide);
  }

  /// Deletes a custom category: at once with Undo when unused, otherwise
  /// asks for a same-type replacement (FR-026).
  Future<CategoryDeleteOutcome> delete(String id) async {
    final repo = ref.read(categoryRepositoryProvider);
    final items = state.items.value ?? const [];
    final item = items.where((s) => s.category.id == id).firstOrNull;
    if (item == null || item.category.isDefault) {
      return const CategoryDeleteFailed();
    }
    try {
      final count = await repo.transactionCount(id);
      if (count > 0) {
        return CategoryNeedsReplacement(count, [
          for (final s in items)
            if (s.category.id != id) s.category,
        ]);
      }
      await repo.delete(id);
      return CategoryDeleted(() => repo.undelete(id));
    } on CategoryDeleteNotAllowed {
      return const CategoryDeleteFailed();
    } on ExpenseStorageFailure {
      return const CategoryDeleteFailed();
    }
  }

  /// Moves [id]'s transactions to [replacementId], then deletes it. No undo
  /// (the sheet stated the consequence first, FR-037).
  Future<bool> deleteWithReplacement(String id, String replacementId) async {
    try {
      await ref
          .read(categoryRepositoryProvider)
          .delete(id, replacementId: replacementId);
      return true;
    } on CategoryDeleteNotAllowed {
      return false;
    } on ExpenseStorageFailure {
      return false;
    }
  }

  void retry() {
    state = state.copyWith(items: const AsyncLoading());
    _subscribe(state.tab);
  }
}
