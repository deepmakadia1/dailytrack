import 'package:dailytrack/core/backup/domain/backup_ports.dart';
import 'package:dailytrack/core/security/domain/secure_key_value_store.dart';

/// Keeps the backup password in secure storage only (feature 008 research
/// R4), so auto backups can encrypt without asking. Never logged, never in
/// a backup.
final class SecureBackupPasswordStore implements BackupPasswordStore {
  const new(this._store);

  final SecureKeyValueStore _store;

  /// Erase all data removes every key with [keyPrefix].
  static const String keyPrefix = 'backup.';
  static const String passwordKey = 'backup.password';

  @override
  Future<String?> read() => _store.read(passwordKey);

  @override
  Future<void> write(String password) => _store.write(passwordKey, password);

  @override
  Future<void> delete() => _store.delete(passwordKey);
}
