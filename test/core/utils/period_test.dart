import 'package:dailytrack/core/utils/date_formats.dart';
import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:dailytrack/core/utils/period.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Period boundaries are local midnights converted to UTC ms (research R13).
///
/// DST: Dart cannot change the process time zone, so the DST behaviour is
/// covered by invariants that hold in every zone (each boundary equals the
/// local `DateTime` constructor's midnight). To exercise a DST zone, run with
/// `TZ=America/New_York flutter test test/core/utils/period_test.dart` on
/// Linux or macOS; Windows ignores `TZ`.
void main() {
  setUpAll(() => initializeDateFormatting('en'));

  int ms(DateTime local) => local.toUtc().millisecondsSinceEpoch;
  const labels = RelativeDayLabels(today: 'Today', yesterday: 'Yesterday');

  group('SingleDayPeriod', () {
    final p = SingleDayPeriod(DateTime(2026, 10, 14, 15, 30));

    test('spans local midnight to next local midnight', () {
      expect(p.startUtcMs, ms(DateTime(2026, 10, 14)));
      expect(p.endUtcMsExclusive, ms(DateTime(2026, 10, 15)));
    });

    test('contains is start-inclusive and end-exclusive', () {
      expect(p.contains(ms(DateTime(2026, 10, 14))), isTrue);
      expect(p.contains(ms(DateTime(2026, 10, 14, 23, 59, 59))), isTrue);
      expect(p.contains(ms(DateTime(2026, 10, 15))), isFalse);
      expect(p.contains(ms(DateTime(2026, 10, 13, 23, 59))), isFalse);
    });

    test('previous and next move one day, across a month end', () {
      final first = SingleDayPeriod(DateTime(2026, 11));
      expect(first.previous(), SingleDayPeriod(DateTime(2026, 10, 31)));
      expect(SingleDayPeriod(DateTime(2026, 10, 31)).next(), first);
    });

    test('label is relative when close', () {
      final now = DateTime(2026, 10, 14, 9);
      expect(p.label('en', labels, now: now), 'Today');
      expect(p.previous().label('en', labels, now: now), 'Yesterday');
      expect(
        SingleDayPeriod(DateTime(2026, 10, 12)).label('en', labels, now: now),
        'Mon, 12 Oct',
      );
    });
  });

  group('WeekPeriod', () {
    test('starts on Monday when firstDayOfWeek is 1', () {
      // 2026-10-14 is a Wednesday.
      final p = WeekPeriod(DateTime(2026, 10, 14), firstDayOfWeek: 1);
      expect(p.startUtcMs, ms(DateTime(2026, 10, 12)));
      expect(p.endUtcMsExclusive, ms(DateTime(2026, 10, 19)));
    });

    test('starts on Sunday when firstDayOfWeek is 7', () {
      final p = WeekPeriod(DateTime(2026, 10, 14), firstDayOfWeek: 7);
      expect(p.startUtcMs, ms(DateTime(2026, 10, 11)));
      expect(p.endUtcMsExclusive, ms(DateTime(2026, 10, 18)));
    });

    test('starts on Saturday when firstDayOfWeek is 6 (SET-01, T049)', () {
      final p = WeekPeriod(DateTime(2026, 10, 14), firstDayOfWeek: 6);
      expect(p.startUtcMs, ms(DateTime(2026, 10, 10)));
      expect(p.endUtcMsExclusive, ms(DateTime(2026, 10, 17)));
      // A Saturday begins its own week.
      final sat = WeekPeriod(DateTime(2026, 10, 17, 9), firstDayOfWeek: 6);
      expect(sat.startUtcMs, ms(DateTime(2026, 10, 17)));
    });

    test('a day that is the week start begins its own week', () {
      final p = WeekPeriod(DateTime(2026, 10, 12, 8), firstDayOfWeek: 1);
      expect(p.startUtcMs, ms(DateTime(2026, 10, 12)));
    });

    test('previous and next cross month and year ends', () {
      final p = WeekPeriod(DateTime(2026, 12, 30), firstDayOfWeek: 1);
      expect(p.next().startUtcMs, ms(DateTime(2027, 1, 4)));
      expect(p.previous().startUtcMs, ms(DateTime(2026, 12, 21)));
    });

    test('label shows both ends', () {
      final p = WeekPeriod(DateTime(2026, 10, 14), firstDayOfWeek: 1);
      expect(
        p.label('en', labels, now: DateTime(2026, 10, 14)),
        '12 Oct – 18 Oct',
      );
    });
  });

  group('MonthPeriod', () {
    test('handles 31, 30, 28 and 29 day months', () {
      expect(
        MonthPeriod(DateTime(2026, 10, 14)).endUtcMsExclusive,
        ms(DateTime(2026, 11)),
      );
      expect(
        MonthPeriod(DateTime(2026, 11, 30)).endUtcMsExclusive,
        ms(DateTime(2026, 12)),
      );
      final feb = MonthPeriod(DateTime(2026, 2, 10));
      expect(feb.startUtcMs, ms(DateTime(2026, 2)));
      expect(feb.endUtcMsExclusive, ms(DateTime(2026, 3)));
      expect(feb.contains(ms(DateTime(2026, 2, 28, 23))), isTrue);
      final leap = MonthPeriod(DateTime(2028, 2, 10));
      expect(leap.contains(ms(DateTime(2028, 2, 29, 12))), isTrue);
    });

    test('previous and next cross year ends', () {
      expect(
        MonthPeriod(DateTime(2026)).previous(),
        MonthPeriod(DateTime(2025, 12)),
      );
      expect(
        MonthPeriod(DateTime(2026, 12)).next(),
        MonthPeriod(DateTime(2027)),
      );
    });

    test('any day in the month gives an equal period', () {
      expect(
        MonthPeriod(DateTime(2026, 10)),
        MonthPeriod(DateTime(2026, 10, 31, 23)),
      );
      expect(
        MonthPeriod(DateTime(2026, 10)).hashCode,
        MonthPeriod(DateTime(2026, 10, 31, 23)).hashCode,
      );
    });

    test('label is month and year', () {
      expect(
        MonthPeriod(DateTime(2026, 10))
            .label('en', labels, now: DateTime(2026)),
        'October 2026',
      );
    });
  });

  group('YearPeriod', () {
    test('spans the local calendar year', () {
      final p = YearPeriod(DateTime(2026, 6));
      expect(p.startUtcMs, ms(DateTime(2026)));
      expect(p.endUtcMsExclusive, ms(DateTime(2027)));
      expect(p.next(), YearPeriod(DateTime(2027)));
      expect(p.previous(), YearPeriod(DateTime(2025)));
      expect(p.label('en', labels, now: DateTime(2026)), '2026');
    });
  });

  group('CustomPeriod', () {
    test('includes both end days and has no previous or next', () {
      final p = CustomPeriod(DateTime(2026, 10, 3, 18), DateTime(2026, 10, 9));
      expect(p.startUtcMs, ms(DateTime(2026, 10, 3)));
      expect(p.endUtcMsExclusive, ms(DateTime(2026, 10, 10)));
      expect(p.previous(), isNull);
      expect(p.next(), isNull);
      expect(
        p.label('en', labels, now: DateTime(2026)),
        '3 Oct 2026 – 9 Oct 2026',
      );
    });

    test('the label follows the SET-01 date format (T051)', () {
      final p = CustomPeriod(DateTime(2026, 10, 3), DateTime(2026, 10, 9));
      expect(
        p.label(
          'en',
          labels,
          now: DateTime(2026),
          fullDatePattern: FullDateFormat.ddMMy.pattern,
        ),
        '03/10/2026 – 09/10/2026',
      );
      // Other periods ignore it.
      expect(
        MonthPeriod(DateTime(2026, 10, 3)).label(
          'en',
          labels,
          now: DateTime(2026),
          fullDatePattern: FullDateFormat.ddMMy.pattern,
        ),
        'October 2026',
      );
    });

    test('rejects an end before the start', () {
      expect(
        () => CustomPeriod(DateTime(2026, 10, 9), DateTime(2026, 10, 3)),
        throwsArgumentError,
      );
    });
  });

  test('boundaries equal the local DateTime midnights in any zone (DST)', () {
    // In a DST zone some days are 23 or 25 hours long; boundaries must still
    // be the local midnights, never start + 24 h.
    for (
      var d = DateTime(2026);
      d.year == 2026;
      d = DateTime(d.year, d.month, d.day + 1)
    ) {
      final p = SingleDayPeriod(d);
      expect(p.startUtcMs, ms(DateTime(d.year, d.month, d.day)));
      expect(p.endUtcMsExclusive, ms(DateTime(d.year, d.month, d.day + 1)));
    }
  });
}
