import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_policy.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pure unlock rules (feature 009 T008, research R12).
void main() {
  final created = DateTime.utc(2026, 10, 22, 10);
  final day = created.add(const Duration(hours: 24));

  Unlock unlock(FeatureKey key, {DateTime? expiresAt}) => Unlock(
    id: key.storageKey,
    featureKey: key,
    source: UnlockSource.rewardedAd,
    createdAt: created,
    expiresAt: expiresAt,
  );

  UnlockDecision evaluate(
    FeatureKey key,
    List<Unlock> unlocks, {
    required DateTime now,
    bool debug = false,
    bool pro = false,
  }) => UnlockPolicy.evaluate(
    key,
    unlocks,
    effectiveNowMs: now.millisecondsSinceEpoch,
    debugUnlockAll: debug,
    proOwned: pro,
  );

  test('nothing stored → locked', () {
    expect(
      evaluate(FeatureKey.advancedReports, [], now: created).unlocked,
      isFalse,
    );
  });

  test('a 24 h unlock is open until 1 ms before expiry, with that expiry as '
      'the next change; locked at exactly the expiry', () {
    final u = [unlock(FeatureKey.advancedReports, expiresAt: day)];
    final before = evaluate(
      FeatureKey.advancedReports,
      u,
      now: day.subtract(const Duration(milliseconds: 1)),
    );
    expect(before.unlocked, isTrue);
    expect(before.nextExpiryMs, day.millisecondsSinceEpoch);
    expect(evaluate(FeatureKey.advancedReports, u, now: day).unlocked, isFalse);
  });

  test('PRM-02 AC an expired unlock stays expired after a restart and when '
      'the device clock is moved backwards', () {
    final u = [unlock(FeatureKey.advancedReports, expiresAt: day)];
    // The app saw 25 h after the reward, then the clock went back to 1 h.
    final latestSeen = created.add(const Duration(hours: 25));
    final clockBack = created.add(const Duration(hours: 1));
    final now = effectiveNow(clockBack, latestSeen.millisecondsSinceEpoch);
    expect(evaluate(FeatureKey.advancedReports, u, now: now).unlocked, isFalse);
  });

  test('permanent unlocks (themes, one-time exports) stay open', () {
    final theme = FeatureKey.premiumTheme('saffron');
    expect(
      evaluate(theme, [
        unlock(theme),
      ], now: day.add(const Duration(days: 400))).unlocked,
      isTrue,
    );
    expect(
      evaluate(FeatureKey.premiumTheme('ocean'), [
        unlock(theme),
      ], now: day).unlocked,
      isFalse,
      reason: 'each theme is its own key',
    );
  });

  test('the latest of several live unlocks is the next expiry', () {
    final later = day.add(const Duration(hours: 6));
    final d = evaluate(FeatureKey.advancedReports, [
      unlock(FeatureKey.advancedReports, expiresAt: day),
      unlock(FeatureKey.advancedReports, expiresAt: later),
    ], now: created);
    expect(d.nextExpiryMs, later.millisecondsSinceEpoch);
  });

  test('Pro unlocks every key for good', () {
    for (final key in [
      FeatureKey.advancedReports,
      FeatureKey.exportCsv,
      FeatureKey.exportPdf,
      FeatureKey.streakFreeze,
      FeatureKey.premiumTheme('mono'),
    ]) {
      final d = evaluate(key, [], now: created, pro: true);
      expect(d.unlocked, isTrue, reason: key.storageKey);
      expect(d.nextExpiryMs, isNull);
    }
  });

  test('the debug switch unlocks only when passed on', () {
    expect(
      evaluate(FeatureKey.exportPdf, [], now: created, debug: true).unlocked,
      isTrue,
    );
  });

  test('FR-035 the ad-free day is never unlocked, whatever is stored', () {
    expect(
      evaluate(
        FeatureKey.adFreeDay,
        [unlock(FeatureKey.adFreeDay)],
        now: created,
        pro: true,
        debug: true,
      ).unlocked,
      isFalse,
    );
  });
}
