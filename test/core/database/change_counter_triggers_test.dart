import 'package:dailytrack/core/backup/domain/backup_settings_policy.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/real_container.dart';

/// The change-counter triggers (feature 010 research R5, data-model §2):
/// every backed-up table and restorable setting raises `dataChangeCounter`,
/// and nothing else does. Real Drift.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> counter() async {
    final row = await db
        .customSelect(
          "SELECT value FROM settings WHERE key = 'dataChangeCounter'",
        )
        .getSingleOrNull();
    return int.parse(row?.read<String>('value') ?? '0');
  }

  Future<Set<String>> triggers() async => {
    for (final r
        in await db
            .customSelect(
              "SELECT name FROM sqlite_master WHERE type = 'trigger'",
            )
            .get())
      r.read<String>('name'),
  };

  test('every table of every registered backup section has its three '
      'triggers', () async {
    final container = makeRealContainer(db);
    addTearDown(container.dispose);
    final sections = [
      for (final m in container.read(moduleRegistryProvider).all)
        ?m.backupSection(),
    ];
    expect(sections, isNotEmpty);
    final names = await triggers();
    for (final s in sections) {
      for (final table in s.tables) {
        for (final suffix in ['ins', 'upd', 'del']) {
          expect(names, contains('bk_${table}_$suffix'), reason: table);
        }
      }
    }
  });

  test('the settings triggers list exactly the restorable keys', () async {
    final rows = await db
        .customSelect(
          "SELECT name, sql FROM sqlite_master WHERE type = 'trigger' "
          "AND name LIKE 'bk_settings_%'",
        )
        .get();
    expect(rows, hasLength(3));
    for (final r in rows) {
      final sql = r.read<String>('sql');
      final list = RegExp(r'IN \(([^)]*)\)').firstMatch(sql)!.group(1)!;
      final keys = {
        for (final m in RegExp("'([^']+)'").allMatches(list)) m.group(1)!,
      };
      expect(
        keys,
        BackupSettingsPolicy.restorableKeys,
        reason: r.read<String>('name'),
      );
      expect(sql, contains("LIKE 'module.%'"));
    }
  });

  test('device state, and the counter itself, never raise it', () async {
    final container = makeRealContainer(db);
    addTearDown(container.dispose);
    final settings = container.read(settingsRepositoryProvider);
    await settings.load();
    final before = await counter();
    await settings.raiseLatestSeenAt(1792540800000);
    await settings.setBackedUpChangeCounter(5);
    await settings.setLastBackgroundBackupAt(1792540800000);
    await settings.setLockAfterSeconds(0);
    expect(await counter(), before);
  });

  test('a transaction, a restorable setting, and module state each raise '
      'it by one; writing the same setting again does not', () async {
    final container = makeRealContainer(db);
    addTearDown(container.dispose);
    final settings = container.read(settingsRepositoryProvider);
    await settings.load();

    var expected = await counter();
    await db.customStatement(
      'INSERT INTO habits (id, name, icon_key, color_hex, kind, target_value, '
      'schedule_type, weekdays_mask, start_date_key, sort_order, created_at, '
      'updated_at) '
      "VALUES ('h1', 'Walk', 'walk', '#00897B', 0, 1, 0, 127, '2026-10-26', 0, "
      '0, 0)',
    );
    expect(await counter(), ++expected);

    await settings.setLocale('hi');
    expect(await counter(), ++expected);
    await settings.setLocale('hi');
    expect(await counter(), expected, reason: 'same value');

    await settings.writeModuleState('expense.rolloverMonth', '2026-10');
    expect(await counter(), ++expected);

    await db.customStatement("DELETE FROM habits WHERE id = 'h1'");
    expect(await counter(), ++expected);
  });
}
