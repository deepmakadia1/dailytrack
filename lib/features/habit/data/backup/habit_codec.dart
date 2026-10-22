import 'dart:convert';

import 'package:dailytrack/core/backup/domain/backup_fields.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';

final RegExp _timeOfDay = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

/// Count targets: 1–9,999 (yes/no habits always 1).
const int maxHabitTarget = 9999;

/// `habits` rows in a backup (feature 008 data-model §3).
abstract final class HabitCodec {
  static const String table = 'habits';

  static Map<String, Object?> encode(HabitRow r) => {
    'id': r.id,
    'name': r.name,
    'iconKey': r.iconKey,
    'colorHex': r.colorHex,
    'kind': r.kind.name,
    'targetValue': r.targetValue,
    'unit': r.unit,
    'scheduleType': r.scheduleType.name,
    'weekdaysMask': r.weekdaysMask,
    'timesPerWeek': r.timesPerWeek,
    'reminderTimes': r.reminderTimes,
    'remindOnlyIfNotDone': r.remindOnlyIfNotDone,
    'startDateKey': r.startDateKey,
    'isArchived': r.isArchived,
    'archivedAt': r.archivedAt,
    'sortOrder': r.sortOrder,
    'freezesAvailable': r.freezesAvailable,
    'celebratedMilestones': r.celebratedMilestones,
    'createdAt': r.createdAt,
    'updatedAt': r.updatedAt,
    'deletedAt': r.deletedAt,
  };

  /// Mirrors the table: trimmed name 1–40, target 1 for yes/no and
  /// 1–9,999 for count, unit ≤ 20, weekdays 0..127, times per week 1..6,
  /// 0–3 `HH:mm` reminders, `yyyy-MM-dd` start, freezes 0..2, milestones
  /// 0..63.
  static HabitRow decode(BackupFields f) {
    final kind = f.enumByName('kind', HabitKind.values);
    final target = f.integer('targetValue', min: 1, max: maxHabitTarget);
    if (kind == HabitKind.yesNo && target != 1) {
      f.invalid('targetValue', 'must be 1 for a yes/no habit');
    }
    final reminders = f.string('reminderTimes');
    final Object? times;
    try {
      times = jsonDecode(reminders);
    } on FormatException {
      f.invalid('reminderTimes', 'is not a JSON list');
    }
    if (times is! List<Object?> ||
        times.length > 3 ||
        times.any((t) => t is! String || !_timeOfDay.hasMatch(t))) {
      f.invalid('reminderTimes', 'must list 0–3 HH:mm times');
    }
    return HabitRow(
      id: f.string('id', min: 1),
      name: f.string('name', min: 1, max: 40, trim: true),
      iconKey: f.string('iconKey'),
      colorHex: f.string('colorHex'),
      kind: kind,
      targetValue: target,
      unit: f.nullableString('unit', max: 20),
      scheduleType: f.enumByName('scheduleType', ScheduleType.values),
      weekdaysMask: f.integer('weekdaysMask', min: 0, max: 127),
      timesPerWeek: f.nullableInt('timesPerWeek', min: 1, max: 6),
      reminderTimes: reminders,
      remindOnlyIfNotDone: f.boolean('remindOnlyIfNotDone'),
      startDateKey: f.matching('startDateKey', dateKeyPattern, 'yyyy-MM-dd'),
      isArchived: f.boolean('isArchived'),
      archivedAt: f.nullableInt('archivedAt'),
      sortOrder: f.integer('sortOrder'),
      freezesAvailable: f.integer('freezesAvailable', min: 0, max: 2),
      celebratedMilestones: f.integer('celebratedMilestones', min: 0, max: 63),
      createdAt: f.integer('createdAt'),
      updatedAt: f.integer('updatedAt'),
      deletedAt: f.nullableInt('deletedAt'),
    );
  }
}
