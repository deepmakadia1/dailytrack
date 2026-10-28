import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/database/database_provider.dart';
import 'package:dailytrack/core/module/dev_action.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/expense/data/dev/large_data_seeder.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/app_harness.dart';

/// Adds 10,000 transactions with the dev seed action's seeder, as the
/// Developer section does (feature 012 T045, T046).
Future<void> seed10k(WidgetTester tester) async {
  final container = containerOf(tester);
  final result = await LargeDataSeeder(
    container.read(appDatabaseProvider),
    container.read(clockProvider),
    container.read(backupCoordinatorProvider),
  ).seed(onProgress: (_) {});
  expect(result, isA<DevActionDone>());
  expect((result as DevActionDone).count, 10000);
  await tester.pumpAndSettle();
}

/// The `p`th percentile (0–100) of [values], nearest rank.
double percentile(List<num> values, double p) {
  final sorted = [...values]..sort();
  final rank = ((p / 100) * sorted.length).ceil().clamp(1, sorted.length);
  return sorted[rank - 1].toDouble();
}
