// Step-by-step state changes read better as separate calls.
// ignore_for_file: cascade_invocations

import 'package:dailytrack/core/security/domain/lock_rules.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// Lock on resume (T015, FR-043, data-model §3, research R7, R15).
void main() {
  final t0 = DateTime(2026, 10, 21, 10);

  group('shouldLockOnResume', () {
    bool lock({
      bool enabled = true,
      Duration? away = const Duration(seconds: 61),
      int after = 60,
      bool external = false,
    }) => shouldLockOnResume(
      lockEnabled: enabled,
      backgroundedAt: away == null ? null : t0,
      now: away == null ? t0 : t0.add(away),
      lockAfterSeconds: after,
      externalActivity: external,
    );

    test('never without app lock or without a trip to the background', () {
      expect(lock(enabled: false), isFalse);
      expect(lock(away: null), isFalse);
    });

    test('Immediately locks after any time away', () {
      expect(lock(after: 0, away: const Duration(milliseconds: 1)), isTrue);
    });

    test('1 min: 59 s no, 60 s and 61 s yes', () {
      expect(lock(away: const Duration(seconds: 59)), isFalse);
      expect(lock(away: const Duration(seconds: 60)), isTrue);
      expect(lock(), isTrue);
    });

    test('5 min: 4 min no, 5 min yes', () {
      expect(lock(after: 300, away: const Duration(minutes: 4)), isFalse);
      expect(lock(after: 300, away: const Duration(minutes: 5)), isTrue);
    });

    test('a clock moved back locks (fail safe)', () {
      expect(lock(away: const Duration(seconds: -5)), isTrue);
    });

    test('an app-started trip locks only after 5 minutes', () {
      expect(lock(external: true, away: const Duration(minutes: 4)), isFalse);
      expect(
        lock(external: true, after: 0, away: const Duration(seconds: 30)),
        isFalse,
      );
      expect(
        lock(external: true, away: const Duration(minutes: 5, seconds: 1)),
        isTrue,
      );
    });
  });

  group('LockSession', () {
    late FakeSettingsRepository settings;
    late ProviderContainer container;

    Future<LockSession> session({
      bool lockEnabled = true,
      int lockAfterSeconds = 60,
    }) {
      settings = FakeSettingsRepository(
        initial: AppSettings(
          onboardingDone: true,
          lockEnabled: lockEnabled,
          lockAfterSeconds: lockAfterSeconds,
        ),
      );
      container = ProviderContainer(
        overrides: [settingsRepositoryProvider.overrideWithValue(settings)],
      );
      addTearDown(container.dispose);
      container.listen(appSettingsProvider, (_, _) {});
      return container
          .read(appSettingsProvider.future)
          .then((_) => container.read(lockSessionProvider.notifier));
    }

    LockSessionState state() => container.read(lockSessionProvider);

    test(
      'start: locked as a route when the lock is on, else unlocked',
      () async {
        final s = await session();
        s.start(lockEnabled: true);
        expect(state().locked, isTrue);
        expect(state().mode, LockMode.route);
        s.start(lockEnabled: false);
        expect(state().locked, isFalse);
      },
    );

    test(
      'resume past "Lock after" locks as an overlay; before it, not',
      () async {
        final s = await session()
          ..start(lockEnabled: false);
        s
          ..markBackgrounded(t0)
          ..onResumed(t0.add(const Duration(seconds: 30)));
        expect(state().locked, isFalse);
        s
          ..markBackgrounded(t0)
          ..onResumed(t0.add(const Duration(seconds: 61)));
        expect(state().locked, isTrue);
        expect(state().mode, LockMode.overlay);
        expect(state().backgroundedAt, isNull);
      },
    );

    test(
      'Immediately locks already when the app is hidden (no flash)',
      () async {
        final s = await session(lockAfterSeconds: 0)
          ..start(lockEnabled: false);
        s.markBackgrounded(t0);
        expect(state().locked, isTrue);
        expect(state().mode, LockMode.overlay);
      },
    );

    test('an expected external trip does not lock with Immediately, and the '
        'flag clears on resume', () async {
      final s = await session(lockAfterSeconds: 0)
        ..start(lockEnabled: false);
      s
        ..expectExternalActivity()
        ..markBackgrounded(t0);
      expect(state().locked, isFalse);
      s.onResumed(t0.add(const Duration(seconds: 30)));
      expect(state().locked, isFalse);
      expect(state().externalActivity, isFalse);
    });

    test('a deferred location comes back once on unlock', () async {
      final s = await session()
        ..start(lockEnabled: true);
      s.deferLocation('/habits');
      expect(s.unlocked(), '/habits');
      expect(state().locked, isFalse);
      expect(state().pendingLocation, isNull);
      expect(s.unlocked(), isNull);
    });

    test('showAsRoute switches an overlay lock to the route', () async {
      final s = await session(lockAfterSeconds: 0)
        ..start(lockEnabled: false);
      s.markBackgrounded(t0);
      s.showAsRoute();
      expect(state().mode, LockMode.route);
      expect(state().locked, isTrue);
    });

    test('reset gives a fresh unlocked session', () async {
      final s = await session()
        ..start(lockEnabled: true);
      s
        ..deferLocation('/home')
        ..reset();
      expect(state(), const LockSessionState());
    });
  });
}
