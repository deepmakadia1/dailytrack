/// Receipt files in app-private storage (research R8).
abstract interface class ReceiptStore {
  /// Absolute path for display, or null if the file no longer exists.
  Future<String?> resolve(String relativePath);

  /// Deletes files not in [referencedRelativePaths] that are older than
  /// 24 hours. Returns how many were deleted.
  Future<int> pruneOrphans(Set<String> referencedRelativePaths);

  /// Deletes every receipt file (erase all data, feature 007 R16).
  Future<void> deleteAll();
}
