import 'package:dailytrack/core/utils/date_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  // The app gets this from GlobalMaterialLocalizations; unit tests load it
  // directly.
  setUpAll(() => initializeDateFormatting('en'));

  group('DateKeys', () {
    test('fromLocal uses the local calendar date', () {
      expect(DateKeys.fromLocal(DateTime(2026, 10, 13, 23, 59)), '2026-10-13');
      expect(DateKeys.fromLocal(DateTime(2026, 1, 5)), '2026-01-05');
    });

    test('parse round-trips', () {
      final d = DateKeys.parse('2026-10-13');
      expect(d, DateTime(2026, 10, 13));
      expect(DateKeys.fromLocal(d), '2026-10-13');
    });

    test('parse rejects malformed keys', () {
      expect(() => DateKeys.parse('2026-1-5'), throwsFormatException);
      expect(() => DateKeys.parse('2026-13-01'), throwsFormatException);
    });
  });

  group('Epoch', () {
    test('nowUtcMs is close to the current UTC time', () {
      final before = DateTime.now().toUtc().millisecondsSinceEpoch;
      final now = Epoch.nowUtcMs();
      final after = DateTime.now().toUtc().millisecondsSinceEpoch;
      expect(now, inInclusiveRange(before, after));
    });

    test('toLocal returns a local DateTime for the instant', () {
      final ms = DateTime.utc(2026, 10, 13, 12).millisecondsSinceEpoch;
      final local = Epoch.toLocal(ms);
      expect(local.isUtc, isFalse);
      expect(local.toUtc(), DateTime.utc(2026, 10, 13, 12));
    });
  });

  group('relativeDayLabel', () {
    const labels = RelativeDayLabels(today: 'Today', yesterday: 'Yesterday');
    final now = DateTime(2026, 10, 13, 9);

    test('today and yesterday use the passed labels', () {
      expect(
        relativeDayLabel(
          DateTime(2026, 10, 13, 23),
          now: now,
          labels: labels,
          locale: 'en',
        ),
        'Today',
      );
      expect(
        relativeDayLabel(
          DateTime(2026, 10, 12, 1),
          now: now,
          labels: labels,
          locale: 'en',
        ),
        'Yesterday',
      );
    });

    test('older dates use EEE, d MMM', () {
      expect(
        relativeDayLabel(
          DateTime(2026, 10, 10),
          now: now,
          labels: labels,
          locale: 'en',
        ),
        'Sat, 10 Oct',
      );
    });
  });
}
