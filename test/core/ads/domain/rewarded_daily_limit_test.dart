import 'package:dailytrack/core/ads/domain/rewarded_daily_limit.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:flutter_test/flutter_test.dart';

/// FR-053: at most 10 earned rewards per feature key per local day
/// (feature 009 T127).
void main() {
  const limit = RewardedDailyLimit();
  const today = '2026-10-22';

  bool reached(FeatureKey key, Map<String, int> counts, {String? day}) =>
      limit.reached(key, today: today, storedDay: day ?? today, counts: counts);

  test('9 → allowed; 10 → reached', () {
    expect(
      reached(FeatureKey.advancedReports, {'advancedReports': 9}),
      isFalse,
    );
    expect(
      reached(FeatureKey.advancedReports, {'advancedReports': 10}),
      isTrue,
    );
  });

  test('each feature key counts on its own, each theme included', () {
    final counts = {'advancedReports': 10, 'premiumTheme_saffron': 10};
    expect(reached(FeatureKey.exportCsv, counts), isFalse);
    expect(reached(FeatureKey.premiumTheme('saffron'), counts), isTrue);
    expect(reached(FeatureKey.premiumTheme('ocean'), counts), isFalse);
  });

  test("a new local day starts again; yesterday's counts are dropped", () {
    final counts = {'advancedReports': 10, 'exportPdf': 4};
    expect(
      reached(FeatureKey.advancedReports, counts, day: '2026-10-21'),
      isFalse,
    );
    expect(
      limit.afterReward(
        FeatureKey.advancedReports,
        today: today,
        storedDay: '2026-10-21',
        counts: counts,
      ),
      {'advancedReports': 1},
    );
  });

  test('a reward adds one for its key only', () {
    expect(
      limit.afterReward(
        FeatureKey.exportPdf,
        today: today,
        storedDay: today,
        counts: const {'exportPdf': 2, 'advancedReports': 5},
      ),
      {'exportPdf': 3, 'advancedReports': 5},
    );
  });

  test('ten rewards in a row reach the limit', () {
    var counts = <String, int>{};
    for (var i = 0; i < 10; i++) {
      expect(reached(FeatureKey.streakFreeze, counts), isFalse);
      counts = limit.afterReward(
        FeatureKey.streakFreeze,
        today: today,
        storedDay: today,
        counts: counts,
      );
    }
    expect(reached(FeatureKey.streakFreeze, counts), isTrue);
  });
}
