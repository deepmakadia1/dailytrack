import 'package:dailytrack/core/security/domain/secure_key_value_store.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// [SecureKeyValueStore] over `flutter_secure_storage` with its default
/// Android options (Keystore-wrapped keys, feature 007 research R8).
/// Platform calls only, so it is covered by the device check.
// coverage:ignore-start
final class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const new([this._storage = const FlutterSecureStorage()]);

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> deleteWhere(bool Function(String key) test) async {
    final all = await _storage.readAll();
    for (final key in all.keys.where(test)) {
      await _storage.delete(key: key);
    }
  }
}
// coverage:ignore-end
