import 'package:dailytrack/core/security/data/secure_lock_service.dart';
import 'package:dailytrack/core/security/domain/lock_types.dart';
import 'package:dailytrack/core/security/domain/lockout_policy.dart';
import 'package:dailytrack/core/security/domain/pin_hasher.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/mutable_clock.dart';

/// SecureLockService (T011, T037, research R5, R6; SYS-03 AC2, FR-039).
void main() {
  late InMemorySecureStore store;
  late FakeBiometricAuthenticator bio;
  late FakeSettingsRepository settings;
  late MutableClock clock;
  late int hashRuns;
  final order = <String>[];

  SecureLockService service() => SecureLockService(
    store: store,
    biometrics: bio,
    settings: settings,
    clock: clock,
    hasher: PinHasher(
      iterations: 1000,
      runner: (f) async {
        hashRuns++;
        return await f();
      },
    ),
  );

  setUp(() {
    order.clear();
    store = InMemorySecureStore(onWrite: (k) => order.add('store:$k'));
    bio = FakeBiometricAuthenticator();
    settings = FakeSettingsRepository(
      initial: const AppSettings(onboardingDone: true),
    );
    clock = MutableClock(DateTime.utc(2026, 10, 21, 10));
    hashRuns = 0;
  });

  group('PIN', () {
    test('status is disabled until a PIN is set; the credential is written '
        'before lockEnabled', () async {
      final lock = service();
      expect(await lock.status(), LockStatus.disabled);
      settings.onWrite = (name) => order.add('settings:$name');
      await lock.setPin('1234');
      expect(await lock.status(), LockStatus.enabled);
      expect(settings.current.lockEnabled, isTrue);
      expect(store.values.containsKey(SecureLockService.pinKey), isTrue);
      expect(
        order.indexOf('store:${SecureLockService.pinKey}'),
        lessThan(order.indexOf('settings:setLockEnabled')),
      );
    });

    test('setPin rejects anything but 4 digits', () {
      final lock = service();
      for (final bad in ['12a4', '123', '12345', '']) {
        expect(() => lock.setPin(bad), throwsArgumentError, reason: bad);
      }
    });

    test('verify accepts the PIN and rejects others', () async {
      final lock = service();
      await lock.setPin('1234');
      expect(await lock.verifyPin('1234'), isA<UnlockSuccess>());
      expect(await lock.verifyPin('9999'), isA<UnlockWrong>());
    });

    test('changePin: a wrong current PIN changes nothing; the right one '
        'replaces the PIN', () async {
      final lock = service();
      await lock.setPin('1234');
      expect(
        await lock.changePin(current: '0000', newPin: '5678'),
        isA<UnlockWrong>(),
      );
      expect(await lock.verifyPin('1234'), isA<UnlockSuccess>());
      expect(
        await lock.changePin(current: '1234', newPin: '5678'),
        isA<UnlockSuccess>(),
      );
      expect(await lock.verifyPin('1234'), isA<UnlockWrong>());
      expect(await lock.verifyPin('5678'), isA<UnlockSuccess>());
    });

    test('disable needs the current PIN, then turns everything off', () async {
      final lock = service();
      await lock.setPin('1234');
      await settings.setBiometricEnabled(enabled: true);
      expect(await lock.disable('9999'), isA<UnlockWrong>());
      expect(settings.current.lockEnabled, isTrue);

      expect(await lock.disable('1234'), isA<UnlockSuccess>());
      expect(settings.current.lockEnabled, isFalse);
      expect(settings.current.biometricEnabled, isFalse);
      expect(store.values.keys.where((k) => k.startsWith('lock.')), isEmpty);
      expect(await lock.status(), LockStatus.disabled);
    });

    test('lock on without a readable PIN is credentialUnavailable', () async {
      await settings.setLockEnabled(enabled: true);
      final lock = service();
      expect(await lock.status(), LockStatus.credentialUnavailable);
      expect(await lock.verifyPin('1234'), isA<UnlockUnavailable>());
      expect(await lock.unlockWithBiometrics(reason: 'r'), isFalse);

      store.values[SecureLockService.pinKey] = '{"v":9}';
      expect(await lock.status(), LockStatus.credentialUnavailable);

      store.failReads = true;
      expect(await lock.status(), LockStatus.credentialUnavailable);
    });

    test('reset removes every lock.* key and nothing else', () async {
      final lock = service();
      await lock.setPin('1234');
      store.values['other'] = 'keep';
      await lock.reset();
      expect(store.values.keys, ['other']);
    });
  });

  group('biometrics', () {
    test(
      'turning on needs a successful prompt; a cancel leaves it off',
      () async {
        final lock = service();
        await lock.setPin('1234');
        bio.result = false;
        expect(
          await lock.setBiometricEnabled(enabled: true, reason: 'r'),
          isFalse,
        );
        expect(settings.current.biometricEnabled, isFalse);
        bio.result = true;
        expect(
          await lock.setBiometricEnabled(enabled: true, reason: 'r'),
          isTrue,
        );
        expect(settings.current.biometricEnabled, isTrue);
        expect(
          await lock.setBiometricEnabled(enabled: false, reason: 'r'),
          isTrue,
        );
        expect(settings.current.biometricEnabled, isFalse);
      },
    );

    test('turning on is refused when biometrics are unavailable', () async {
      final lock = service();
      await lock.setPin('1234');
      bio.available = BiometricAvailability.notEnrolled;
      expect(
        await lock.setBiometricEnabled(enabled: true, reason: 'r'),
        isFalse,
      );
      expect(bio.prompts, 0);
    });
  });

  group('lockout', () {
    Future<SecureLockService> lockedOut() async {
      final lock = service();
      await lock.setPin('1234');
      for (var i = 0; i < 4; i++) {
        await lock.verifyPin('0000');
      }
      expect(await lock.verifyPin('0000'), isA<UnlockLockedOut>());
      return lock;
    }

    test('the 3rd and 4th wrong PINs report attempts left', () async {
      final lock = service();
      await lock.setPin('1234');
      final results = [
        for (var i = 0; i < 4; i++) await lock.verifyPin('0000'),
      ];
      expect(
        [for (final r in results) (r as UnlockWrong).attemptsLeft],
        [null, null, 2, 1],
      );
    });

    test('the 5th wrong PIN locks for 30 s; during it even the right PIN is '
        'refused without hashing', () async {
      final lock = await lockedOut();
      final runs = hashRuns;
      final r = await lock.verifyPin('1234');
      expect(r, isA<UnlockLockedOut>());
      expect((r as UnlockLockedOut).remaining, const Duration(seconds: 30));
      expect(hashRuns, runs);
    });

    test('SYS-03 AC2: the lockout timer survives an app restart', () async {
      await lockedOut();
      clock.advance(const Duration(seconds: 10));
      final restarted = service();
      expect(await restarted.lockoutRemaining(), const Duration(seconds: 20));
      expect(await restarted.verifyPin('1234'), isA<UnlockLockedOut>());
    });

    test('the new state is stored before verifyPin returns', () async {
      final lock = service();
      await lock.setPin('1234');
      await lock.verifyPin('0000');
      final stored = LockoutState.tryParse(
        store.values[SecureLockService.lockoutKey]!,
      );
      expect(stored!.failedAttempts, 1);
    });

    test('after the lockout ends, one wrong PIN locks for 60 s, and the '
        'warning says so first (Q1)', () async {
      final lock = await lockedOut();
      clock.advance(const Duration(seconds: 30));
      expect(await lock.nextLockoutLength(), const Duration(seconds: 60));
      final r = await lock.verifyPin('0000');
      expect((r as UnlockLockedOut).remaining, const Duration(seconds: 60));
    });

    test('a success resets the count', () async {
      final lock = service();
      await lock.setPin('1234');
      await lock.verifyPin('0000');
      await lock.verifyPin('0000');
      await lock.verifyPin('0000');
      expect(await lock.verifyPin('1234'), isA<UnlockSuccess>());
      expect((await lock.verifyPin('0000') as UnlockWrong).attemptsLeft, null);
    });

    test('Q3: a biometric success during a lockout clears it', () async {
      final lock = await lockedOut();
      bio.result = true;
      expect(await lock.unlockWithBiometrics(reason: 'r'), isTrue);
      expect(await lock.lockoutRemaining(), Duration.zero);
      expect(await lock.verifyPin('1234'), isA<UnlockSuccess>());
    });

    test('FR-039: wrong current PINs in change and disable count toward the '
        'same lockout', () async {
      final lock = service();
      await lock.setPin('1234');
      await lock.changePin(current: '0000', newPin: '5678');
      await lock.disable('0000');
      await lock.verifyPin('0000');
      await lock.changePin(current: '0000', newPin: '5678');
      expect(await lock.disable('0000'), isA<UnlockLockedOut>());
    });

    test(
      'a lockout read error with a PIN set fails safe: locked for 15 min',
      () async {
        final lock = service();
        await lock.setPin('1234');
        store.failReadsOf = SecureLockService.lockoutKey;
        final r = await lock.verifyPin('1234');
        expect(r, isA<UnlockLockedOut>());
        expect((r as UnlockLockedOut).remaining, const Duration(minutes: 15));
      },
    );

    test('moving the clock back does not extend the lockout', () async {
      final lock = await lockedOut();
      clock.value = clock.now().subtract(const Duration(hours: 2));
      expect(await lock.lockoutRemaining(), const Duration(seconds: 30));
      clock.advance(const Duration(seconds: 30));
      expect(await lock.lockoutRemaining(), Duration.zero);
    });
  });
}
