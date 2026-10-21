import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/features/habit/data/mappers/habit_mapper.dart';
import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/entities/habit_schedule.dart';
import 'package:dailytrack/features/habit/domain/entities/milestone.dart';
import 'package:dailytrack/features/habit/domain/entities/reminder_time.dart';
import 'package:dailytrack/features/habit/domain/enums.dart';
import 'package:flutter_test/flutter_test.dart';

/// Row ↔ entity mapping (T042, data-model.md §3, §5).
void main() {
  const t0 = 1760000000000;

  HabitRow row({
    int weekdaysMask = 0,
    String reminderTimes = '[]',
    int celebrated = 0,
    int? archivedAt,
  }) => HabitRow(
    id: 'h1',
    name: 'Read',
    iconKey: 'book',
    colorHex: '#0F766E',
    kind: HabitKind.count,
    targetValue: 20,
    unit: 'pages',
    scheduleType: ScheduleType.specificWeekdays,
    weekdaysMask: weekdaysMask,
    reminderTimes: reminderTimes,
    remindOnlyIfNotDone: false,
    startDateKey: '2026-02-28',
    isArchived: archivedAt != null,
    archivedAt: archivedAt,
    sortOrder: 3,
    freezesAvailable: 2,
    celebratedMilestones: celebrated,
    createdAt: t0,
    updatedAt: t0 + 1,
  );

  group('reminder times JSON', () {
    test('encodes sorted, distinct HH:mm', () {
      expect(
        encodeReminderTimes(const [
          ReminderTime(21, 0),
          ReminderTime(7, 5),
          ReminderTime(21, 0),
        ]),
        '["07:05","21:00"]',
      );
      expect(encodeReminderTimes(const []), '[]');
    });

    test('decodes and round-trips', () {
      final times = decodeReminderTimes('["07:05","21:00"]');
      expect(times, const [ReminderTime(7, 5), ReminderTime(21, 0)]);
      expect(encodeReminderTimes(times), '["07:05","21:00"]');
      expect(decodeReminderTimes('[]'), isEmpty);
    });

    test('rejects a malformed time', () {
      expect(() => decodeReminderTimes('["7:5"]'), throwsFormatException);
      expect(() => decodeReminderTimes('["24:00"]'), throwsFormatException);
    });
  });

  group('HabitRow → Habit', () {
    test('maps every field', () {
      final h = row(
        weekdaysMask: 1 | 4 | 64,
        reminderTimes: '["07:00"]',
        celebrated: 1 | 4,
        archivedAt: t0 + 2,
      ).toEntity();
      expect(h.id, 'h1');
      expect(h.name, 'Read');
      expect(h.iconKey, 'book');
      expect(h.colorHex, '#0F766E');
      expect(h.kind, HabitKind.count);
      expect(
        h.schedule,
        const HabitSchedule(
          type: ScheduleType.specificWeekdays,
          target: 20,
          weekdays: {1, 3, 7},
        ),
      );
      expect(h.unit, 'pages');
      expect(h.reminderTimes, const [ReminderTime(7, 0)]);
      expect(h.remindOnlyIfNotDone, isFalse);
      expect(h.startDate, const LocalDate(2026, 2, 28));
      expect(h.isArchived, isTrue);
      expect(h.archivedAt, DateTime.utc(2025, 10, 9, 8, 53, 20, 2));
      expect(h.archivedAt!.isUtc, isTrue);
      expect(h.sortOrder, 3);
      expect(h.freezesAvailable, 2);
      expect(h.celebratedMilestones, {Milestone.d7, Milestone.d30});
      expect(h.createdAt.millisecondsSinceEpoch, t0);
      expect(h.updatedAt.millisecondsSinceEpoch, t0 + 1);
      expect(h.createdAt.isUtc, isTrue);
    });

    test('no archive moment while active', () {
      expect(row().toEntity().archivedAt, isNull);
      expect(row().toEntity().isArchived, isFalse);
    });
  });

  test('weekdays mask: Mon=1 … Sun=64 both ways', () {
    for (var day = 1; day <= 7; day++) {
      final s = HabitSchedule.fromMask(
        type: ScheduleType.specificWeekdays,
        target: 1,
        weekdaysMask: 1 << (day - 1),
      );
      expect(s.weekdays, {day});
      expect(s.weekdaysMask, 1 << (day - 1));
    }
    final all = HabitSchedule.fromMask(
      type: ScheduleType.specificWeekdays,
      target: 1,
      weekdaysMask: 127,
    );
    expect(all.weekdays, {1, 2, 3, 4, 5, 6, 7});
    expect(
      const HabitSchedule(type: ScheduleType.daily, target: 1).weekdaysMask,
      0,
    );
  });

  test('HabitScheduleRow → ScheduleVersion', () {
    const r = HabitScheduleRow(
      id: 's1',
      habitId: 'h1',
      effectiveFromKey: '2026-10-19',
      scheduleType: ScheduleType.timesPerWeek,
      weekdaysMask: 0,
      timesPerWeek: 3,
      targetValue: 5,
      createdAt: t0,
      updatedAt: t0,
    );
    final v = r.toEntity();
    expect(v.effectiveFrom, const LocalDate(2026, 10, 19));
    expect(
      v.schedule,
      const HabitSchedule(
        type: ScheduleType.timesPerWeek,
        target: 5,
        timesPerWeek: 3,
      ),
    );
  });

  test('HabitEntryRow → HabitEntry', () {
    const r = HabitEntryRow(
      id: 'e1',
      habitId: 'h1',
      dateKey: '2028-02-29',
      value: 0,
      isFreeze: true,
      note: 'Sick',
      createdAt: t0,
      updatedAt: t0,
    );
    final e = r.toEntity();
    expect(e.habitId, 'h1');
    expect(e.date, const LocalDate(2028, 2, 29));
    expect(e.value, 0);
    expect(e.isFreeze, isTrue);
    expect(e.note, 'Sick');
  });
}
