import 'package:dailytrack/features/habit/domain/dates.dart';
import 'package:flutter_test/flutter_test.dart';

/// LocalDate (research R5): the calendar day every habit rule works on.
void main() {
  LocalDate d(String key) => LocalDate.fromKey(key);

  test('key round trip and invalid keys', () {
    expect(d('2026-10-21').key, '2026-10-21');
    expect(const LocalDate(2026, 1, 5).key, '2026-01-05');
    expect(() => d('2026-02-30'), throwsFormatException);
    expect(() => d('2026-13-01'), throwsFormatException);
    expect(() => d('21-10-2026'), throwsFormatException);
  });

  test('addDays crosses month ends, year ends, and 29 February', () {
    expect(d('2026-10-31').addDays(1), d('2026-11-01'));
    expect(d('2026-12-31').addDays(1), d('2027-01-01'));
    expect(d('2027-01-01').addDays(-1), d('2026-12-31'));
    expect(d('2028-02-28').addDays(1), d('2028-02-29'));
    expect(d('2028-02-29').addDays(1), d('2028-03-01'));
    expect(d('2027-02-28').addDays(1), d('2027-03-01'));
    expect(d('2026-01-01').addDays(365), d('2027-01-01'));
  });

  test('day arithmetic ignores daylight-saving changes', () {
    // US (8 Mar) and EU (29 Mar) clock changes in 2026, and the autumn ones.
    expect(d('2026-03-07').addDays(2), d('2026-03-09'));
    expect(d('2026-03-28').addDays(2), d('2026-03-30'));
    expect(d('2026-10-24').addDays(2), d('2026-10-26'));
    expect(d('2026-11-01').addDays(1), d('2026-11-02'));
    expect(d('2026-03-30').difference(d('2026-03-28')), 2);
    expect(d('2026-11-02').difference(d('2026-10-31')), 2);
  });

  test('difference, ordering, and equality', () {
    expect(d('2026-10-21').difference(d('2026-10-18')), 3);
    expect(d('2026-10-18').difference(d('2026-10-21')), -3);
    expect(d('2027-01-01').difference(d('2026-12-31')), 1);
    expect(d('2026-10-20').isBefore(d('2026-10-21')), isTrue);
    expect(d('2026-10-21').isAfter(d('2026-10-20')), isTrue);
    expect(d('2026-10-21'), const LocalDate(2026, 10, 21));
    expect({d('2026-10-21'), const LocalDate(2026, 10, 21)}, hasLength(1));
    expect(d('2026-09-30').compareTo(d('2026-10-01')), lessThan(0));
  });

  test('weekday: 1 = Monday … 7 = Sunday', () {
    expect(d('2026-10-19').weekday, 1);
    expect(d('2026-10-21').weekday, 3);
    expect(d('2026-10-25').weekday, 7);
  });

  test('startOfWeek honours the first day of the week', () {
    final wed = d('2026-10-21');
    expect(wed.startOfWeek(1), d('2026-10-19')); // Monday
    expect(wed.startOfWeek(7), d('2026-10-18')); // Sunday
    expect(wed.startOfWeek(6), d('2026-10-17')); // Saturday
    expect(d('2026-10-19').startOfWeek(1), d('2026-10-19'));
    expect(d('2026-10-18').startOfWeek(1), d('2026-10-12'));
    expect(d('2026-10-18').startOfWeek(7), d('2026-10-18'));
    expect(d('2027-01-01').startOfWeek(1), d('2026-12-28'));
  });

  test('fromDateTime uses the local calendar date', () {
    expect(
      LocalDate.fromDateTime(DateTime(2026, 10, 21, 23, 59, 59)),
      d('2026-10-21'),
    );
    expect(LocalDate.fromDateTime(DateTime(2026, 10, 22)), d('2026-10-22'));
    final utc = DateTime.utc(2026, 10, 21, 23, 30);
    final local = utc.toLocal();
    expect(
      LocalDate.fromDateTime(utc),
      LocalDate(local.year, local.month, local.day),
      reason: 'a UTC instant maps to the day it is in the device zone',
    );
  });
}
