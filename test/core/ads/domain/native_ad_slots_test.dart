import 'package:dailytrack/core/ads/domain/native_ad_slots.dart';
import 'package:flutter_test/flutter_test.dart';

/// EXP-01 native ads: after row 8, then every 15, at most 3 per load
/// (spec §11, feature 009 T027).
void main() {
  test('after rows 8, 23, and 38', () {
    expect(nativeAdRowIndexes(40), [8, 23, 38]);
  });

  test('only between two rows, never after the last one', () {
    expect(nativeAdRowIndexes(0), isEmpty);
    expect(nativeAdRowIndexes(8), isEmpty);
    expect(nativeAdRowIndexes(9), [8]);
    expect(nativeAdRowIndexes(23), [8]);
    expect(nativeAdRowIndexes(24), [8, 23]);
  });

  test('at most 3 per screen load', () {
    expect(nativeAdRowIndexes(1000), [8, 23, 38]);
  });
}
