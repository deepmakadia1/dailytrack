import 'package:dailytrack/core/background/background_scheduler.dart';
import 'package:dailytrack/core/backup/background_backup_scheduler.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

/// A scheduler whose enqueue fails, to check leaving the app never throws.
final class _BrokenScheduler extends FakeBackgroundScheduler {
  @override
  Future<void> enqueueOnce(
    String uniqueName, {
    NetworkRequirement network = NetworkRequirement.none,
  }) async => throw StateError('WorkManager unavailable');
}

/// The backup started when the app goes to the background (feature 010
/// T077, spec §16 "Auto backup while signed in" step 1, FR-032, FR-034,
/// research R6). Fake scheduler and an injected clock.
void main() {
  late MutableClock clock;
  late FakeSettingsRepository settings;
  late FakeBackgroundScheduler scheduler;

  AppSettings signedIn({
    bool wifiOnly = true,
    AutoBackupFrequency frequency = AutoBackupFrequency.daily,
    int counter = 3,
    int backedUp = 1,
    bool onboardingDone = true,
    String? email = 'me@example.com',
  }) => AppSettings(
    onboardingDone: onboardingDone,
    backupAccountEmail: email,
    authMode: email == null ? AuthMode.guest : AuthMode.google,
    autoBackupFrequency: frequency,
    autoBackupWifiOnly: wifiOnly,
    dataChangeCounter: counter,
    backedUpChangeCounter: backedUp,
  );

  BackgroundBackupScheduler subject() => BackgroundBackupScheduler(
    settings: settings,
    scheduler: scheduler,
    clock: clock,
  );

  int nowMs() => clock.now().toUtc().millisecondsSinceEpoch;

  int enqueues() =>
      scheduler.ensured.where((n) => n == backgroundBackupTaskName).length;

  setUp(() {
    clock = MutableClock(DateTime(2026, 10, 27, 21, 30));
    settings = FakeSettingsRepository(initial: signedIn());
    scheduler = FakeBackgroundScheduler();
  });

  test('§16 going to the background with changed data starts one one-off '
      'backup task and records when it was requested', () async {
    await subject().onAppHidden();
    expect(enqueues(), 1);
    expect(scheduler.oneOff.keys, [backgroundBackupTaskName]);
    expect(settings.current.lastBackgroundBackupAt, nowMs());
  });

  test(
    '§16 with "Wi-Fi only" on the task waits for an unmetered network',
    () async {
      await subject().onAppHidden();
      expect(
        scheduler.oneOff[backgroundBackupTaskName],
        NetworkRequirement.unmetered,
      );
    },
  );

  test('§16 with "Wi-Fi only" off the task needs any connection', () async {
    settings = FakeSettingsRepository(initial: signedIn(wifiOnly: false));
    await subject().onAppHidden();
    expect(
      scheduler.oneOff[backgroundBackupTaskName],
      NetworkRequirement.connected,
    );
  });

  test('§16 going to the background again within 15 minutes does not start '
      'another; at 15 minutes it does', () async {
    await subject().onAppHidden();
    final first = settings.current.lastBackgroundBackupAt;

    clock.advance(const Duration(minutes: 14, seconds: 59));
    await subject().onAppHidden();
    expect(enqueues(), 1);
    expect(settings.current.lastBackgroundBackupAt, first);

    clock.advance(const Duration(seconds: 1));
    await subject().onAppHidden();
    expect(enqueues(), 2);
    expect(settings.current.lastBackgroundBackupAt, nowMs());
  });

  test(
    '§16 a waiting task is replaced by the next one, never queued twice',
    () async {
      await subject().onAppHidden();
      clock.advance(const Duration(minutes: 20));
      await subject().onAppHidden();
      // One unique name; the real scheduler uses ExistingWorkPolicy.replace.
      expect(scheduler.oneOff, hasLength(1));
    },
  );

  test('§16 nothing starts when no data changed', () async {
    settings = FakeSettingsRepository(
      initial: signedIn(counter: 4, backedUp: 4),
    );
    await subject().onAppHidden();
    expect(enqueues(), 0);
    expect(settings.current.lastBackgroundBackupAt, isNull);
  });

  test('§16 nothing starts while signed out, with Auto backup Off, or before '
      'onboarding is done', () async {
    for (final s in [
      signedIn(email: null),
      signedIn(frequency: AutoBackupFrequency.off),
      signedIn(onboardingDone: false),
    ]) {
      settings = FakeSettingsRepository(initial: s);
      await subject().onAppHidden();
      expect(settings.current.lastBackgroundBackupAt, isNull);
    }
    expect(enqueues(), 0);
  });

  test('a scheduler failure never makes leaving the app throw', () async {
    scheduler = _BrokenScheduler();
    await expectLater(subject().onAppHidden(), completes);
  });
}
