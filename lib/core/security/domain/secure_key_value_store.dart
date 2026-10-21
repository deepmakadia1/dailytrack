/// A port over the device's secure storage (Keystore-backed on Android).
/// Holds only the `lock.*` entries (feature 007 data-model §2). Methods may
/// throw when the storage cannot be read.
abstract interface class SecureKeyValueStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  /// Deletes every key for which [test] is true.
  Future<void> deleteWhere(bool Function(String key) test);
}
