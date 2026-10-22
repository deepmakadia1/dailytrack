import 'package:dailytrack/core/backup/backup_section.dart';
import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/features/habit/data/backup/habit_codec.dart';
import 'package:dailytrack/features/habit/data/backup/habit_entry_codec.dart';
import 'package:dailytrack/features/habit/data/backup/habit_schedule_codec.dart';

/// The Habit module's backup section (SET-02, feature 008 research R5):
/// habits, schedule history, and entries, soft-deleted rows included.
final class HabitBackupSection extends BackupSection {
  const new();

  @override
  String get moduleId => 'habit';

  /// The habit tables arrived in schema v4; older backups have none.
  @override
  int get sinceSchemaVersion => 4;

  @override
  Future<Map<String, Object?>> export(AppDatabase db) async => {
    'tables': {
      HabitCodec.table: [
        for (final r in await db.select(db.habits).get()) HabitCodec.encode(r),
      ],
      HabitScheduleCodec.table: [
        for (final r in await db.select(db.habitSchedules).get())
          HabitScheduleCodec.encode(r),
      ],
      HabitEntryCodec.table: [
        for (final r in await db.select(db.habitEntries).get())
          HabitEntryCodec.encode(r),
      ],
    },
  };

  static List<T> _decode<T>(
    Map<String, Object?> section,
    String table,
    T Function(BackupFields) decode,
  ) {
    final rows = tableRows(section, table);
    return [
      for (var i = 0; i < rows.length; i++)
        decode(BackupFields.of(rows[i], table: table, index: i)),
    ];
  }

  ({
    List<HabitRow> habits,
    List<HabitScheduleRow> schedules,
    List<HabitEntryRow> entries,
  })
  _read(Map<String, Object?> section) => (
    habits: _decode(section, HabitCodec.table, HabitCodec.decode),
    schedules: _decode(
      section,
      HabitScheduleCodec.table,
      HabitScheduleCodec.decode,
    ),
    entries: _decode(section, HabitEntryCodec.table, HabitEntryCodec.decode),
  );

  @override
  void validate(Map<String, Object?> section) {
    final d = _read(section);
    checkUnique(HabitCodec.table, 'id', d.habits.map((r) => r.id));
    checkUnique(HabitScheduleCodec.table, 'id', d.schedules.map((r) => r.id));
    checkUnique(HabitEntryCodec.table, 'id', d.entries.map((r) => r.id));
    // The entries index is full (deleted rows too); schedules only live.
    checkUnique(HabitEntryCodec.table, 'habit and day', [
      for (final e in d.entries) '${e.habitId}|${e.dateKey}',
    ]);
    checkUnique(HabitScheduleCodec.table, 'habit and start day', [
      for (final s in d.schedules)
        if (s.deletedAt == null) '${s.habitId}|${s.effectiveFromKey}',
    ]);
    final habits = {for (final h in d.habits) h.id};
    for (final (i, s) in d.schedules.indexed) {
      checkReference(HabitScheduleCodec.table, i, 'habitId', s.habitId, habits);
    }
    for (final (i, e) in d.entries.indexed) {
      checkReference(HabitEntryCodec.table, i, 'habitId', e.habitId, habits);
    }
  }

  @override
  Future<void> restore(AppDatabase db, Map<String, Object?> section) async {
    final d = _read(section);
    await db.delete(db.habitEntries).go();
    await db.delete(db.habitSchedules).go();
    await db.delete(db.habits).go();
    await db.batch((b) {
      b
        ..insertAll(db.habits, d.habits)
        ..insertAll(db.habitSchedules, d.schedules)
        ..insertAll(db.habitEntries, d.entries);
    });
  }

  @override
  Map<String, int> counts(Map<String, Object?> section) {
    int live(String table) => tableRows(
      section,
      table,
    ).where((r) => r is Map<String, Object?> && r['deletedAt'] == null).length;
    return {
      'habits': live(HabitCodec.table),
      'entries': live(HabitEntryCodec.table),
    };
  }

  @override
  String summary(AppLocalizations l10n, Map<String, int> counts) =>
      l10n.backup_countHabits(counts['habits'] ?? 0);
}
