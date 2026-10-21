import 'package:dailytrack/core/utils/period.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

/// Categories store (contracts/repositories.md, data-model.md §3.2).
abstract interface class CategoryRepository {
  /// Non-deleted categories of [type] in sortOrder, with [month]'s total and
  /// the all-time usage count. Hidden ones are included (flagged). EXP-04.
  Stream<List<CategoryWithStats>> watchByType(
    CategoryType type, {
    required Period month,
  });

  /// Non-hidden categories of [type] for EXP-02: usage count DESC, then
  /// sortOrder ASC (clarification Q2).
  Stream<List<Category>> watchPickable(CategoryType type);

  /// Every non-deleted category, hidden included (row display, search).
  Stream<List<Category>> watchAll();

  Future<Category> create({
    required String name,
    required CategoryType type,
    required String iconKey,
    required String colorHex,
  });

  /// The type is fixed once created.
  Future<void> update(
    String id, {
    required String name,
    required String iconKey,
    required String colorHex,
  });

  Future<void> setHidden(String id, {required bool hidden});

  /// Rewrites sortOrder for [type] to match [orderedIds].
  Future<void> reorder(CategoryType type, List<String> orderedIds);

  /// Non-deleted transactions using the category.
  Future<int> transactionCount(String id);

  /// Soft-deletes a custom category. If it has transactions, [replacementId]
  /// is required and they are moved to it first, in one DB transaction.
  /// Throws `CategoryDeleteNotAllowed`.
  Future<void> delete(String id, {String? replacementId});

  Future<void> undelete(String id);
}
