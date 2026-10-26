import 'package:dailytrack/core/backup/domain/background_backup_trigger.dart';
import 'package:dailytrack/core/backup/domain/change_counter.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/mutable_clock.dart';

/// The background backup trigger rules (spec §16 "On background", FR-032,
/// research R6) and the change counter comparison (research R5). Pure.
void main() {
  late MutableClock clock;

  setUp(() => clock = MutableClock(DateTime.utc(2026, 10, 26, 18)));

  int now() => clock.now().millisecondsSinceEpoch;

  bool trigger({
    bool signedIn = true,
    AutoBackupFrequency frequency = AutoBackupFrequency.daily,
    bool onboardingDone = true,
    bool changed = true,
    int? last,
  }) => BackgroundBackupTrigger.shouldEnqueue(
    signedIn: signedIn,
    frequency: frequency,
    onboardingDone: onboardingDone,
    changed: changed,
    lastBackgroundBackupAt: last,
    nowMs: now(),
  );

  group('BackgroundBackupTrigger.shouldEnqueue', () {
    test('§16 changed data with no earlier request starts a backup', () {
      expect(trigger(), isTrue);
    });

    test('§16 going to the background again within 15 minutes does not; at '
        'exactly 15 minutes it does', () {
      final last = now();
      clock.advance(const Duration(minutes: 14, seconds: 59));
      expect(trigger(last: last), isFalse);
      clock.advance(const Duration(seconds: 1));
      expect(trigger(last: last), isTrue);
    });

    test('§16 nothing starts when no data changed', () {
      expect(trigger(changed: false), isFalse);
      clock.advance(const Duration(hours: 5));
      expect(trigger(changed: false, last: 0), isFalse);
    });

    test('nothing starts while signed out', () {
      expect(trigger(signedIn: false), isFalse);
    });

    test('nothing starts while Auto backup is Off; Daily and Weekly both '
        'run', () {
      expect(trigger(frequency: AutoBackupFrequency.off), isFalse);
      expect(trigger(), isTrue);
      expect(trigger(frequency: AutoBackupFrequency.weekly), isTrue);
    });

    test('nothing starts before onboarding is done', () {
      expect(trigger(onboardingDone: false), isFalse);
    });

    test('a last request in the future (clock moved back) never blocks', () {
      final future = now() + const Duration(hours: 2).inMilliseconds;
      expect(trigger(last: future), isTrue);
    });

    test('the minimum gap is 15 minutes', () {
      expect(BackgroundBackupTrigger.minGap, const Duration(minutes: 15));
    });
  });

  group('ChangeCounter.changed', () {
    test('changed exactly when the counters differ', () {
      expect(ChangeCounter.changed(current: 0, backedUp: 0), isFalse);
      expect(ChangeCounter.changed(current: 7, backedUp: 7), isFalse);
      expect(ChangeCounter.changed(current: 8, backedUp: 7), isTrue);
      // An erase resets the counter below the backed-up value.
      expect(ChangeCounter.changed(current: 0, backedUp: 7), isTrue);
    });
  });
}
