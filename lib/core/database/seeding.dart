import 'package:dailytrack/core/database/app_database.dart';

/// One-time data seeding contributed by a tracker module (FR-025).
/// `SeedRunner` runs each seeder at most once, inside a transaction.
abstract interface class Seeder {
  /// Stable id, e.g. `expense.defaults.v1`. Bump the suffix to seed new data.
  String get id;

  Future<void> seed(AppDatabase db);
}
