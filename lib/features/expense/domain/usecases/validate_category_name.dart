import 'package:dailytrack/core/l10n/default_name_catalog.dart';
import 'package:dailytrack/features/expense/domain/entities/category.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';

enum CategoryNameError { required, tooLong, reserved, duplicate }

/// EXP-05 name rules (FR-025, clarification Q5, research R9).
final class ValidateCategoryName {
  const new(this._catalog);

  /// FR-025 (storage allows 40, data-model §3.2).
  static const int maxLength = 30;

  /// Default names are stored as these keys; users may not type one.
  static final RegExp _key = RegExp('^(expense|income)_(cat|account)_');

  final DefaultNameCatalog _catalog;

  /// Trimmed, repeated inner spaces collapsed, lower-cased.
  static String normalize(String name) =>
      name.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();

  /// Returns the first problem with [name], or null when it can be saved.
  /// [existing] are the non-deleted categories; [editingId] is the category
  /// being renamed, which may keep its own name.
  CategoryNameError? call(
    String name, {
    required CategoryType type,
    required List<Category> existing,
    String? editingId,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return CategoryNameError.required;
    if (trimmed.length > maxLength) return CategoryNameError.tooLong;
    if (_key.hasMatch(trimmed)) return CategoryNameError.reserved;

    final wanted = normalize(trimmed);
    for (final c in existing) {
      if (c.type != type || c.id == editingId) continue;
      // A default that was never renamed still holds its key: compare with
      // every translation. Anything else compares by its stored text.
      final names = c.isDefault && _key.hasMatch(c.name)
          ? _catalog.namesFor(c.name)
          : {c.name};
      if (names.map(normalize).contains(wanted)) {
        return CategoryNameError.duplicate;
      }
    }
    return null;
  }
}
