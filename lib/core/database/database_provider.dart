import 'package:dailytrack/core/database/app_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'database_provider.g.dart';

/// The single app database. Widget tests override this with a provider that
/// throws, so they can never touch Drift (Constitution IV, task T059).
// Production binding: opens the on-device file, so it is exercised by
// integration_test/app_smoke_test.dart rather than unit tests.
// coverage:ignore-start
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
}
// coverage:ignore-end
