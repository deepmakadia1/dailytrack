import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/real_container.dart';

/// SC-002 budget check (T105): the whole startup sequence (DB open and
/// migrations, seeding, settings load) stays well inside the 1.5 s cold
/// start budget. The on-device number is measured manually with
/// `--trace-startup` and recorded in the task summary.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('SYS-01 first-launch bootstrap finishes in under 300 ms', () async {
    // Warm up the JIT on a throwaway database first: the app ships AOT
    // compiled, so compile time is not part of the startup cost measured.
    final warmDb = AppDatabase(NativeDatabase.memory());
    addTearDown(warmDb.close);
    final warm = makeRealContainer(warmDb)
      ..listen(bootstrapProvider, (_, _) {});
    await warm.read(bootstrapProvider.future);

    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final container = makeRealContainer(db)
      ..listen(bootstrapProvider, (_, _) {});

    final watch = Stopwatch()..start();
    final result = await container.read(bootstrapProvider.future);
    watch.stop();

    expect(result, isA<BootstrapReady>());
    // First launch is the slowest path: it creates the schema and seeds.
    expect(await db.select(db.categories).get(), hasLength(17));
    expect(watch.elapsedMilliseconds, lessThan(300));
  });
}
