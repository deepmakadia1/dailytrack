import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';

/// `habit_entries` rows in a backup (feature 008 data-model §3).
abstract final class HabitEntryCodec {
  static const String table = 'habitEntries';

  static Map<String, Object?> encode(HabitEntryRow r) => {
    'id': r.id,
    'habitId': r.habitId,
    'dateKey': r.dateKey,
    'value': r.value,
    'isFreeze': r.isFreeze,
    'note': r.note,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: `yyyy-MM-dd` day, value 0..9,999, note ≤ 200.
  static HabitEntryRow decode(BackupFields f) => HabitEntryRow(
    id: f.string('id', min: 1),
    habitId: f.string('habitId', min: 1),
    dateKey: f.matching('dateKey', dateKeyPattern, 'yyyy-MM-dd'),
    value: f.integer('value', min: 0, max: 9999),
    isFreeze: f.boolean('isFreeze'),
    note: f.nullableString('note', max: 200),
    createdAt: f.integer('createdAt'),
    updatedAt: f.integer('updatedAt'),
    deletedAt: f.nullableInt('deletedAt'),
  );
}
