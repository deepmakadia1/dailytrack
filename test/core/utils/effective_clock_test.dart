import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime.utc(2026, 10, 22, 10);

  test('no latest-seen time → the clock, in UTC', () {
    final result = effectiveNow(now.toLocal(), null);
    expect(result, now);
    expect(result.isUtc, isTrue);
  });

  test('a clock moved back 2 days → the latest time ever seen', () {
    final back = now.subtract(const Duration(days: 2));
    expect(effectiveNow(back, now.millisecondsSinceEpoch), now);
  });

  test('a clock ahead of the latest-seen time → the clock', () {
    final ahead = now.add(const Duration(minutes: 5));
    expect(effectiveNow(ahead, now.millisecondsSinceEpoch), ahead);
  });
}
