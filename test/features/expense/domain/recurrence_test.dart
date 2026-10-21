import 'dart:math';

import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:dailytrack/features/expense/domain/usecases/recurrence.dart';
import 'package:flutter_test/flutter_test.dart';

/// RecurrenceSchedule (research R8): exhaustive month-end, leap-year,
/// weekday and index checks. Every occurrence is computed from the anchor.
void main() {
  int daysIn(int y, int m) => DateTime(y, m + 1, 0).day;

  RecurrenceSchedule schedule(
    DateTime anchor,
    Frequency f, {
    int interval = 1,
  }) =>
      RecurrenceSchedule(anchorLocal: anchor, frequency: f, interval: interval);

  group('EXP-10 criterion "A monthly rule on the 31st runs on the last day '
      'of shorter months"', () {
    test('from 31 Jan 2027 for 48 months: min(31, days in month), back to the '
        '31st whenever the month has it', () {
      final s = schedule(DateTime(2027, 1, 31, 9, 30), Frequency.monthly);
      for (var n = 0; n < 48; n++) {
        final y = 2027 + n ~/ 12;
        final m = n % 12 + 1;
        expect(
          s.occurrence(n),
          DateTime(y, m, min(31, daysIn(y, m)), 9, 30),
          reason: 'n=$n',
        );
      }
      expect(s.occurrence(1), DateTime(2027, 2, 28, 9, 30));
      expect(s.occurrence(2), DateTime(2027, 3, 31, 9, 30));
      expect(s.occurrence(3), DateTime(2027, 4, 30, 9, 30));
      expect(s.occurrence(4), DateTime(2027, 5, 31, 9, 30));
      expect(s.occurrence(13), DateTime(2028, 2, 29, 9, 30), reason: 'leap');
    });

    test('every anchor day 1–31, for 48 months from every starting month of '
        '2026 and 2027', () {
      for (var startYear = 2026; startYear <= 2027; startYear++) {
        for (var startMonth = 1; startMonth <= 12; startMonth++) {
          for (var day = 1; day <= daysIn(startYear, startMonth); day++) {
            final s = schedule(
              DateTime(startYear, startMonth, day, 18, 5),
              Frequency.monthly,
            );
            for (var n = 0; n < 48; n++) {
              final months = startMonth - 1 + n;
              final y = startYear + months ~/ 12;
              final m = months % 12 + 1;
              final expected = DateTime(y, m, min(day, daysIn(y, m)), 18, 5);
              expect(
                s.occurrence(n),
                expected,
                reason: 'anchor $startYear-$startMonth-$day n=$n',
              );
            }
          }
        }
      }
    });

    test('day 30 → 28 Feb, or 29 Feb in a leap year, then the 30th again', () {
      final s = schedule(DateTime(2027, 1, 30), Frequency.monthly);
      expect(s.occurrence(1), DateTime(2027, 2, 28));
      expect(s.occurrence(2), DateTime(2027, 3, 30));
      expect(s.occurrence(13), DateTime(2028, 2, 29));
      expect(s.occurrence(14), DateTime(2028, 3, 30));
    });

    test('day 29 lands on 28 Feb except in leap years', () {
      final s = schedule(DateTime(2027, 1, 29), Frequency.monthly);
      expect(s.occurrence(1), DateTime(2027, 2, 28));
      expect(s.occurrence(13), DateTime(2028, 2, 29));
      expect(s.occurrence(25), DateTime(2029, 2, 28));
    });

    test('an interval keeps the anchor day (every 2 and 3 months from the '
        '31st)', () {
      final two = schedule(
        DateTime(2027, 1, 31),
        Frequency.monthly,
        interval: 2,
      );
      expect(
        [for (var n = 0; n < 6; n++) two.occurrence(n)],
        [
          DateTime(2027, 1, 31),
          DateTime(2027, 3, 31),
          DateTime(2027, 5, 31),
          DateTime(2027, 7, 31),
          DateTime(2027, 9, 30),
          DateTime(2027, 11, 30),
        ],
      );
      final three = schedule(
        DateTime(2027, 11, 30),
        Frequency.monthly,
        interval: 3,
      );
      expect(three.occurrence(1), DateTime(2028, 2, 29));
      expect(three.occurrence(2), DateTime(2028, 5, 30));
    });
  });

  group('yearly', () {
    test('29 Feb 2028 → 28 Feb 2029, 2030, 2031, then 29 Feb 2032', () {
      final s = schedule(DateTime(2028, 2, 29, 7), Frequency.yearly);
      expect(
        [for (var n = 0; n < 5; n++) s.occurrence(n)],
        [
          DateTime(2028, 2, 29, 7),
          DateTime(2029, 2, 28, 7),
          DateTime(2030, 2, 28, 7),
          DateTime(2031, 2, 28, 7),
          DateTime(2032, 2, 29, 7),
        ],
      );
    });

    test('every day of 2028 recurs on the same date for 12 years (clamped '
        'only for 29 Feb)', () {
      for (
        var d = DateTime(2028);
        d.year == 2028;
        d = DateTime(d.year, d.month, d.day + 1)
      ) {
        final s = schedule(d, Frequency.yearly);
        for (var n = 0; n < 12; n++) {
          final y = 2028 + n;
          expect(
            s.occurrence(n),
            DateTime(y, d.month, min(d.day, daysIn(y, d.month))),
            reason: '$d n=$n',
          );
        }
      }
    });
  });

  group('weekly and daily', () {
    test('weekly keeps the weekday and time for 10 years', () {
      final anchor = DateTime(2026, 10, 5, 8, 15); // a Monday
      final s = schedule(anchor, Frequency.weekly);
      for (var n = 0; n < 520; n++) {
        final o = s.occurrence(n);
        expect(o.weekday, DateTime.monday, reason: 'n=$n');
        expect((o.hour, o.minute), (8, 15), reason: 'n=$n');
        expect(
          DateTime.utc(
            o.year,
            o.month,
            o.day,
          ).difference(DateTime.utc(2026, 10, 5)).inDays,
          7 * n,
        );
      }
    });

    test('daily keeps the wall-clock time for 10 years, in whatever time '
        'zone the test runs (local DateTime arithmetic)', () {
      final s = schedule(DateTime(2026, 1, 1, 23, 45, 10), Frequency.daily);
      var expected = DateTime(2026);
      for (var n = 0; n < 3650; n++) {
        final o = s.occurrence(n);
        expect((o.hour, o.minute, o.second), (23, 45, 10), reason: 'n=$n');
        expect(
          (o.year, o.month, o.day),
          (expected.year, expected.month, expected.day),
        );
        expected = DateTime(expected.year, expected.month, expected.day + 1);
      }
    });

    test('an interval of 3 days', () {
      final s = schedule(DateTime(2026, 2, 27), Frequency.daily, interval: 3);
      expect(s.occurrence(1), DateTime(2026, 3, 2));
    });
  });

  group('indexAtOrAfter and firstAfter', () {
    /// Linear reference: the smallest n with occurrence(n) >= t.
    int linear(RecurrenceSchedule s, DateTime t) {
      var n = 0;
      while (s.occurrence(n).isBefore(t)) {
        n++;
      }
      return n;
    }

    final schedules = {
      'daily': schedule(DateTime(2026, 10, 14, 9), Frequency.daily),
      'every 2 days': schedule(
        DateTime(2026, 10, 14, 9),
        Frequency.daily,
        interval: 2,
      ),
      'weekly': schedule(DateTime(2026, 10, 14, 9), Frequency.weekly),
      'monthly 31st': schedule(DateTime(2026, 1, 31, 9), Frequency.monthly),
      'monthly 5th': schedule(DateTime(2026, 10, 5, 9), Frequency.monthly),
      'yearly 29 Feb': schedule(DateTime(2028, 2, 29, 9), Frequency.yearly),
    };

    for (final MapEntry(key: name, value: s) in schedules.entries) {
      test(
        '$name: matches a linear scan at every 7-hour step over 3 years',
        () {
          final start = s.anchorLocal.subtract(const Duration(days: 3));
          // Linear reference, kept incremental because t only grows.
          var expected = 0;
          for (var h = 0; h < 3 * 365 * 24; h += 7) {
            final t = start.add(Duration(hours: h));
            while (s.occurrence(expected).isBefore(t)) {
              expected++;
            }
            expect(s.indexAtOrAfter(t), expected, reason: '$name at $t');
          }
        },
      );
    }

    test('stays O(1): 3,650 steps behind is found directly', () {
      final s = schedule(DateTime(2016, 10, 14, 9), Frequency.daily);
      final t = DateTime(2026, 10, 14, 9);
      expect(s.indexAtOrAfter(t), linear(s, t));
      expect(s.indexAtOrAfter(t), 3652);
      expect(s.indexAtOrAfter(DateTime(2000)), 0, reason: 'before the anchor');
    });

    test('UTC input is compared as the same moment', () {
      final s = schedule(DateTime(2026, 10, 5, 9), Frequency.monthly);
      final o = s.occurrence(3);
      expect(s.indexAtOrAfter(o.toUtc()), 3);
    });
  });

  test('describe() for every frequency', () {
    final anchor = DateTime(2026, 10, 5, 9); // Monday 5 Oct
    for (final f in Frequency.values) {
      final d = schedule(anchor, f).describe();
      expect(d.frequency, f);
      expect(d.interval, 1);
      expect(d.weekday, DateTime.monday);
      expect(d.day, 5);
      expect(d.month, 10);
    }
  });

  test('a negative index or an interval below 1 is rejected', () {
    expect(
      () => schedule(DateTime(2026), Frequency.daily).occurrence(-1),
      throwsRangeError,
    );
    expect(
      () => schedule(DateTime(2026), Frequency.daily, interval: 0),
      throwsArgumentError,
    );
  });
}
