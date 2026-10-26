import 'dart:math';

import 'package:dailytrack/core/ads/domain/ad_config.dart';
import 'package:dailytrack/core/ads/domain/ad_session.dart';
import 'package:dailytrack/core/ads/domain/ad_trigger.dart';
import 'package:dailytrack/core/ads/domain/interstitial_cap.dart';
import 'package:dailytrack/core/utils/effective_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cap = InterstitialCap(AdConfig.defaults);
  const habit = HabitCreated();
  const closingSave = ExpenseSaved(screenClosing: true);
  final installAt = DateTime.utc(2026, 10, 1, 9);
  // Comfortably past the 2-day install age, on local day 2026-10-05.
  final now = DateTime.utc(2026, 10, 5, 12);
  const today = '2026-10-05';

  InterstitialCapState ready({
    DateTime? lastShownAt,
    String? dayKey,
    int shownToday = 0,
    bool isFirstSessionOfDay = false,
    int expenseSaves = 0,
  }) => InterstitialCapState(
    installAt: installAt,
    lastShownAt: lastShownAt,
    dayKey: dayKey,
    shownToday: shownToday,
    isFirstSessionOfDay: isFirstSessionOfDay,
    expenseSaves: expenseSaves,
  );

  CapDecision check(
    InterstitialCapState s, {
    DateTime? at,
    String day = today,
    AdTrigger trigger = habit,
  }) => cap.check(s, effectiveNow: at ?? now, todayKey: day, trigger: trigger);

  const block = CapBlock.new;

  test('a state that meets every rule is allowed', () {
    expect(check(ready()), isA<CapAllow>());
  });

  group('§11 install-age rule: no interstitial in the first 2 days', () {
    test('blocks 1 ms before 2 days', () {
      final at = installAt.add(const Duration(days: 2, milliseconds: -1));
      expect(check(ready(), at: at), block(CapBlockReason.installAge));
    });

    test('allows at exactly 2 days', () {
      final at = installAt.add(const Duration(days: 2));
      expect(check(ready(), at: at), isA<CapAllow>());
    });

    test('a clock moved back cannot make the install look newer than the '
        'latest time ever seen', () {
      final seen = installAt.add(const Duration(days: 3));
      final clockBack = installAt.add(const Duration(hours: 1));
      final at = effectiveNow(clockBack, seen.millisecondsSinceEpoch);
      expect(check(ready(), at: at), isA<CapAllow>());
    });
  });

  group('§11 never in the first session of the day', () {
    test('the first session of the day is blocked', () {
      expect(
        check(ready(isFirstSessionOfDay: true)),
        block(CapBlockReason.firstSession),
      );
    });

    const session = AdSession(AdConfig.defaults);

    test('the first session that starts on a local day is the first of the '
        'day; a later one that day is not', () {
      final first = session.start(
        todayKey: today,
        lastSessionDayKey: '2026-10-04',
      );
      expect(first.isFirstSessionOfDay, isTrue);
      expect(first.lastSessionDayKey, today);
      final second = session.start(
        todayKey: today,
        lastSessionDayKey: first.lastSessionDayKey,
      );
      expect(second.isFirstSessionOfDay, isFalse);
    });

    test('a fresh install has no earlier session, so its first session is '
        'the first of the day', () {
      expect(session.start(todayKey: today).isFirstSessionOfDay, isTrue);
    });

    test('clarification Q3: a return after 30 minutes or more starts a new '
        'session; a shorter one (e.g. a full-screen ad) does not', () {
      final back = now.subtract(const Duration(minutes: 30));
      expect(session.isNewSession(now: now, backgroundedAt: back), isTrue);
      expect(
        session.isNewSession(
          now: now,
          backgroundedAt: back.add(const Duration(seconds: 1)),
        ),
        isFalse,
      );
      expect(session.isNewSession(now: now), isFalse);
    });
  });

  group('§11 minimum 3 minutes between interstitials', () {
    test('blocks at 2:59', () {
      final s = ready(
        lastShownAt: now.subtract(const Duration(minutes: 2, seconds: 59)),
        dayKey: today,
        shownToday: 1,
      );
      expect(check(s), block(CapBlockReason.gap));
    });

    test('allows at exactly 3:00', () {
      final s = ready(
        lastShownAt: now.subtract(const Duration(minutes: 3)),
        dayKey: today,
        shownToday: 1,
      );
      expect(check(s), isA<CapAllow>());
    });

    test('a clock moved back still sees the gap', () {
      final last = now;
      final clockBack = now.subtract(const Duration(hours: 1));
      final at = effectiveNow(clockBack, now.millisecondsSinceEpoch);
      final s = ready(lastShownAt: last, dayKey: today, shownToday: 1);
      expect(check(s, at: at), block(CapBlockReason.gap));
    });
  });

  group('§11 maximum 4 per day', () {
    final old = now.subtract(const Duration(hours: 1));

    test('the 5th on the same local day is blocked', () {
      final s = ready(lastShownAt: old, dayKey: today, shownToday: 4);
      expect(check(s), block(CapBlockReason.dailyMax));
    });

    test('the 4th is still allowed', () {
      final s = ready(lastShownAt: old, dayKey: today, shownToday: 3);
      expect(check(s), isA<CapAllow>());
    });

    test('a new local day starts the count again', () {
      final s = ready(lastShownAt: old, dayKey: '2026-10-04', shownToday: 4);
      expect(check(s), isA<CapAllow>());
      final after = cap.afterShown(s, now: now, todayKey: today);
      expect(after.dayKey, today);
      expect(after.shownToday, 1);
    });
  });

  group('§11 counter of qualifying saves resets after each shown '
      'interstitial', () {
    test(
      'EXP-02: fewer than 4 new entries are blocked; the 4th is allowed',
      () {
        var s = ready();
        for (var i = 0; i < 3; i++) {
          s = cap.afterExpenseSave(s);
        }
        expect(
          check(s, trigger: closingSave),
          block(CapBlockReason.notEnoughSaves),
        );
        s = cap.afterExpenseSave(s);
        expect(check(s, trigger: closingSave), isA<CapAllow>());
      },
    );

    test('showing an interstitial resets the counter and counts the day', () {
      final s = ready(expenseSaves: 4, dayKey: today, shownToday: 2);
      final after = cap.afterShown(s, now: now, todayKey: today);
      expect(after.expenseSaves, 0);
      expect(after.shownToday, 3);
      expect(after.lastShownAt, now);
    });

    test('FR-022: a blocked check never resets the counter, so the next '
        'save tries again', () {
      var s = ready(
        expenseSaves: 4,
        lastShownAt: now.subtract(const Duration(minutes: 1)),
        dayKey: today,
        shownToday: 1,
      );
      expect(check(s, trigger: closingSave), block(CapBlockReason.gap));
      expect(s.expenseSaves, 4);
      s = cap.afterExpenseSave(s);
      final later = now.add(const Duration(minutes: 3));
      expect(check(s, trigger: closingSave, at: later), isA<CapAllow>());
    });

    test('new habits and manual backups do not need saves', () {
      expect(check(ready()), isA<CapAllow>());
      expect(
        check(ready(), trigger: const ManualBackupSucceeded()),
        isA<CapAllow>(),
      );
    });
  });

  test('SC-004 a simulated week of triggers never breaks the cap', () {
    final random = Random(9);
    var s = ready();
    final shown = <DateTime>[];
    var t = now;
    for (var step = 0; step < 7 * 24 * 120; step++) {
      t = t.add(const Duration(seconds: 30));
      final day = '${t.year}-${t.month}-${t.day}';
      final trigger = switch (random.nextInt(3)) {
        0 => closingSave,
        1 => habit,
        _ => const ManualBackupSucceeded(),
      };
      if (trigger is ExpenseSaved) s = cap.afterExpenseSave(s);
      if (cap.check(s, effectiveNow: t, todayKey: day, trigger: trigger)
          is CapAllow) {
        s = cap.afterShown(s, now: t, todayKey: day);
        shown.add(t);
      }
    }
    expect(shown, isNotEmpty);
    for (var i = 1; i < shown.length; i++) {
      expect(
        shown[i].difference(shown[i - 1]),
        greaterThanOrEqualTo(const Duration(minutes: 3)),
      );
    }
    final perDay = <String, int>{};
    for (final t in shown) {
      final key = '${t.year}-${t.month}-${t.day}';
      perDay[key] = (perDay[key] ?? 0) + 1;
    }
    expect(perDay.values.every((n) => n <= 4), isTrue);
  });
}
