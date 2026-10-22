import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/backup/habit_codec.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';

/// `habit_schedules` rows in a backup (feature 008 data-model §3).
abstract final class HabitScheduleCodec {
  static const String table = 'habitSchedules';

  static Map<String, Object?> encode(HabitScheduleRow r) => {
    'id': r.id,
    'habitId': r.habitId,
    'effectiveFromKey': r.effectiveFromKey,
    'scheduleType': r.scheduleType.name,
    'weekdaysMask': r.weekdaysMask,
    'timesPerWeek': r.timesPerWeek,
    'targetValue': r.targetValue,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: `yyyy-MM-dd` start, weekdays 0..127, times per week
  /// 1..6, target 1..9,999.
  static HabitScheduleRow decode(BackupFields f) => HabitScheduleRow(
    id: f.string('id', min: 1),
    habitId: f.string('habitId', min: 1),
    effectiveFromKey: f.matching(
      'effectiveFromKey',
      dateKeyPattern,
      'yyyy-MM-dd',
    ),
    scheduleType: f.enumByName('scheduleType', ScheduleType.values),
    weekdaysMask: f.integer('weekdaysMask', min: 0, max: 127),
    timesPerWeek: f.nullableInt('timesPerWeek', min: 1, max: 6),
    targetValue: f.integer('targetValue', min: 1, max: maxHabitTarget),
    createdAt: f.integer('createdAt'),
    updatedAt: f.integer('updatedAt'),
    deletedAt: f.nullableInt('deletedAt'),
  );
}
