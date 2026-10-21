import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/database/seeding.dart';
import 'package:dailytrack/core/settings/data/settings_codec.dart';
import 'package:dailytrack/core/utils/date_keys.dart';

/// Runs each [Seeder] at most once (FR-025). The seed data and its
/// `seed.<id>` marker are written in one transaction, so an interrupted or
/// failed run leaves nothing behind and is retried on the next launch.
class SeedRunner {
  new(this._db);

  final AppDatabase _db;

  Future<void> runAll(Iterable<Seeder> seeders) async {
    for (final seeder in seeders) {
      await _db.transaction(() async {
        final key = SettingsCodec.seedKey(seeder.id);
        final marker = await (_db.select(
          _db.settings,
        )..where((s) => s.key.equals(key))).getSingleOrNull();
        if (marker != null) return;

        await seeder.seed(_db);
        final now = Epoch.nowUtcMs();
        await _db
            .into(_db.settings)
            .insert(
              SettingsCompanion.insert(
                key: key,
                value: SettingsCodec.encode(now),
                updatedAt: now,
              ),
            );
      });
    }
  }
}
