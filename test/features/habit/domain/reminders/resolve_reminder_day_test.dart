import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:dailytrack/features/habit/domain/reminders/resolve_reminder_day.dart';
import 'package:flutter_test/flutter_test.dart';

/// resolveReminderDay (feature 008 T103, data-model §7, research R17).
/// 2026-10-21 is a Wednesday.
void main() {
  LocalDate? day(DateTime now, String at, [int wd = 0]) =>
      resolveReminderDay(now, at, wd);

  test('a daily 08:00 reminder: at 09:00 → today; at 07:00 → yesterday', () {
    expect(
      day(DateTime(2026, 10, 21, 9), '08:00'),
      const LocalDate(2026, 10, 21),
    );
    expect(
      day(DateTime(2026, 10, 21, 7), '08:00'),
      const LocalDate(2026, 10, 20),
    );
  });

  test('exactly at the reminder time → that day', () {
    expect(
      day(DateTime(2026, 10, 21, 8), '08:00'),
      const LocalDate(2026, 10, 21),
    );
  });

  test('a tap at 00:30 on a 21:00 reminder marks the previous day', () {
    expect(
      day(DateTime(2026, 10, 22, 0, 30), '21:00'),
      const LocalDate(2026, 10, 21),
    );
  });

  test(
    'a weekly Wednesday reminder resolved on Thursday 10:00 → Wednesday',
    () {
      expect(
        day(DateTime(2026, 10, 22, 10), '08:00', 3),
        const LocalDate(2026, 10, 21),
      );
    },
  );

  test('a weekly Wednesday reminder before its time on Wednesday → the week '
      'before', () {
    expect(
      day(DateTime(2026, 10, 21, 7), '08:00', 3),
      const LocalDate(2026, 10, 14),
    );
  });

  test('across a DST change the local wall time decides', () {
    // Local times only: the day before and after a 1-hour shift resolve the
    // same way.
    expect(
      day(DateTime(2026, 11, 1, 1, 30), '01:00'),
      const LocalDate(2026, 11, 1),
    );
    expect(
      day(DateTime(2026, 3, 29, 2, 59), '03:00'),
      const LocalDate(2026, 3, 28),
    );
  });

  test('malformed input → null', () {
    final now = DateTime(2026, 10, 21, 9);
    expect(day(now, ''), isNull);
    expect(day(now, '8'), isNull);
    expect(day(now, '25:00'), isNull);
    expect(day(now, 'aa:bb'), isNull);
    expect(day(now, '08:00', 8), isNull);
    expect(day(now, '08:00', -1), isNull);
  });
}
