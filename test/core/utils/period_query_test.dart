import 'package:dailytrack/core/utils/period.dart';
import 'package:flutter_test/flutter_test.dart';

/// Period ↔ route query (feature 008 T010, contracts/routes.md).
void main() {
  Period? back(Period p, {int firstDay = 1}) =>
      periodFromQuery(periodToQuery(p), firstDayOfWeek: firstDay);

  test('round trips every kind', () {
    for (final p in <Period>[
      SingleDayPeriod(DateTime(2026, 10, 21)),
      WeekPeriod(DateTime(2026, 10, 21), firstDayOfWeek: 1),
      MonthPeriod(DateTime(2026, 9)),
      YearPeriod(DateTime(2026)),
      CustomPeriod(DateTime(2026, 9, 3), DateTime(2026, 10, 2)),
    ]) {
      final q = periodToQuery(p);
      final r = back(p)!;
      expect(r.runtimeType, p.runtimeType, reason: '$q');
      expect(r.startLocal, p.startLocal);
      expect(r.endLocalExclusive, p.endLocalExclusive);
    }
  });

  test('a month is kind=month with its first and last day', () {
    expect(periodToQuery(MonthPeriod(DateTime(2026, 9, 15))), {
      'kind': 'month',
      'start': '2026-09-01',
      'end': '2026-09-30',
    });
  });

  test(
    'a Sunday week opened with Monday weeks becomes the same custom days',
    () {
      final sundayWeek = WeekPeriod(DateTime(2026, 10, 21), firstDayOfWeek: 7);
      final r = back(sundayWeek)!;
      expect(r, isA<CustomPeriod>());
      expect(r.startLocal, sundayWeek.startLocal);
      expect(r.endLocalExclusive, sundayWeek.endLocalExclusive);
    },
  );

  test('missing or invalid parameters give null', () {
    for (final q in <Map<String, String>>[
      {},
      {'kind': 'month', 'start': '2026-09-01'},
      {'kind': 'hour', 'start': '2026-09-01', 'end': '2026-09-01'},
      {'kind': 'month', 'start': 'x', 'end': '2026-09-30'},
      {'kind': 'custom', 'start': '2026-09-30', 'end': '2026-09-01'},
    ]) {
      expect(periodFromQuery(q, firstDayOfWeek: 1), isNull, reason: '$q');
    }
  });
}
