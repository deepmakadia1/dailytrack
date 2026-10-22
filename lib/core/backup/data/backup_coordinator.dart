import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:dailytrack/core/backup/domain/backup_errors.dart';
import 'package:dailytrack/core/database/app_database.dart';

/// Lets only one backup or restore run at a time (FR-011, feature 008
/// research R8): an in-isolate flag, plus a lease in the `settings` table so
/// a background backup in another isolate also waits. A lease older than
/// [leaseLength] is taken over, so a crashed run never blocks for good.
final class BackupCoordinator {
  new(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;
  bool _running = false;

  /// Settings key of the lease (UTC ms it expires). Device state; never in a
  /// backup.
  static const String leaseKey = 'backupLeaseUntil';
  static const Duration leaseLength = Duration(minutes: 10);

  /// Runs [body] while holding the lease. Throws [BackupBusy] if another
  /// run holds it.
  Future<T> run<T>(Future<T> Function() body) async {
    if (_running) throw const BackupBusy();
    _running = true;
    try {
      await _acquire();
      try {
        return await body();
      } finally {
        await _release();
      }
    } finally {
      _running = false;
    }
  }

  int get _nowMs => _clock.now().toUtc().millisecondsSinceEpoch;

  Future<void> _acquire() => _db.transaction(() async {
    final row = await (_db.select(
      _db.settings,
    )..where((t) => t.key.equals(leaseKey))).getSingleOrNull();
    final until = row == null ? null : jsonDecode(row.value);
    if (until is int && until > _nowMs) throw const BackupBusy();
    await _db
        .into(_db.settings)
        .insertOnConflictUpdate(
          SettingsCompanion.insert(
            key: leaseKey,
            value: jsonEncode(_nowMs + leaseLength.inMilliseconds),
            updatedAt: _nowMs,
          ),
        );
  });

  Future<void> _release() async {
    try {
      await (_db.delete(
        _db.settings,
      )..where((t) => t.key.equals(leaseKey))).go();
    } on Object {
      // The lease expires on its own.
    }
  }
}
