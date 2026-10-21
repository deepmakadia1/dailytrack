import 'package:clock/clock.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

/// Drift implementation of [UnlockRepository] over the core `unlocks`
/// table (data-model.md §3.3).
final class DriftUnlockRepository implements UnlockRepository {
  new(this._db, this._clock);

  final AppDatabase _db;
  final Clock _clock;
  static const Uuid _uuid = Uuid();

  static DateTime _utc(int ms) =>
      DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);

  static Unlock _toEntity(UnlockRow r) => Unlock(
    id: r.id,
    featureKey: FeatureKey.fromStorage(r.featureKey),
    expiresAt: r.expiresAt == null ? null : _utc(r.expiresAt!),
    source: r.source,
    createdAt: _utc(r.createdAt),
  );

  @override
  Stream<List<Unlock>> watchLive() =>
      (_db.select(_db.unlocks)..where((t) => t.deletedAt.isNull())).watch().map(
        (rows) => [for (final r in rows) _toEntity(r)],
      );

  @override
  Future<Unlock> grant(
    FeatureKey key, {
    required UnlockSource source,
    DateTime? expiresAt,
  }) async {
    final id = _uuid.v4();
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    await _db
        .into(_db.unlocks)
        .insert(
          UnlocksCompanion.insert(
            id: id,
            featureKey: key.storageKey,
            expiresAt: Value(expiresAt?.toUtc().millisecondsSinceEpoch),
            source: source,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return _toEntity(
      await (_db.select(
        _db.unlocks,
      )..where((t) => t.id.equals(id))).getSingle(),
    );
  }

  @override
  Future<void> revoke(String unlockId) {
    final now = _clock.now().toUtc().millisecondsSinceEpoch;
    return (_db.update(_db.unlocks)..where((t) => t.id.equals(unlockId))).write(
      UnlocksCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  }
}
