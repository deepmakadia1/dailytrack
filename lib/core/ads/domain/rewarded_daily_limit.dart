import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';

/// At most [perKeyPerDay] earned rewards per feature key per local day
/// (FR-053). Each premium theme is its own key. Callers pass the day key of
/// the effective now (the later of the clock and the latest time ever
/// seen), so moving the clock back never starts a fresh day. Pure Dart.
final class RewardedDailyLimit {
  const new({this.perKeyPerDay = 10});

  final int perKeyPerDay;

  /// Rewards already earned for [key] on [today].
  int earnedToday(
    FeatureKey key, {
    required String today,
    required String? storedDay,
    required Map<String, int> counts,
  }) => storedDay == today ? counts[key.storageKey] ?? 0 : 0;

  bool reached(
    FeatureKey key, {
    required String today,
    required String? storedDay,
    required Map<String, int> counts,
  }) =>
      earnedToday(key, today: today, storedDay: storedDay, counts: counts) >=
      perKeyPerDay;

  /// The counts after one more reward for [key] on [today]; an older day's
  /// counts are dropped.
  Map<String, int> afterReward(
    FeatureKey key, {
    required String today,
    required String? storedDay,
    required Map<String, int> counts,
  }) {
    final next = storedDay == today ? {...counts} : <String, int>{};
    next[key.storageKey] = (next[key.storageKey] ?? 0) + 1;
    return next;
  }
}
