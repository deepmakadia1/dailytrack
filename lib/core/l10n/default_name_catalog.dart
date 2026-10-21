/// Every translation of a default name key, e.g. `expense_cat_food` →
/// {"Food", "खाना", "ખોરાક"} (research R9). Pure Dart, so domain use cases
/// such as `ValidateCategoryName` can depend on it; the Flutter
/// implementation is `L10nDefaultNameCatalog`.
abstract interface class DefaultNameCatalog {
  /// All supported-language names of [key]; empty if the key is unknown.
  Set<String> namesFor(String key);
}
