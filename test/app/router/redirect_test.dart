import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Redirect rules from contracts/routes.md (features 001, 007, 011),
/// tested as a pure function.
void main() {
  const ready = AsyncData<BootstrapResult>(BootstrapReady(Routes.home));
  const fresh = AppSettings();
  const done = AppSettings(onboardingDone: true, authMode: AuthMode.guest);
  const locked = AppSettings(
    onboardingDone: true,
    lockEnabled: true,
    authMode: AuthMode.guest,
  );
  const noLogin = AppSettings(onboardingDone: true);

  final registry = ModuleRegistry(registeredModules);

  String? go(
    String location, {
    AsyncValue<BootstrapResult> bootstrap = ready,
    AppSettings? settings = done,
  }) => redirectFor(
    location: location,
    bootstrap: bootstrap,
    settings: settings,
    registry: registry,
  );

  test('rule 1: stay on the splash while startup runs', () {
    const loading = AsyncLoading<BootstrapResult>();
    expect(go(Routes.splash, bootstrap: loading), isNull);
    expect(go(Routes.home, bootstrap: loading), Routes.splash);
    expect(go(Routes.home, settings: null), Routes.splash);
  });

  test('rule 1: a ready app leaves the splash for its first screen', () {
    final toLock = AsyncData<BootstrapResult>(
      BootstrapReady(Routes.lockPath(from: Routes.home)),
    );
    expect(go(Routes.splash), Routes.home);
    expect(
      go(Routes.splash, bootstrap: toLock, settings: locked),
      Routes.lockPath(from: Routes.home),
    );
  });

  test('rule 2: a failed startup stays on the splash', () {
    final failed = AsyncData<BootstrapResult>(BootstrapFailed(StateError('x')));
    expect(go(Routes.splash, bootstrap: failed), isNull);
    expect(go(Routes.home, bootstrap: failed), Routes.splash);
  });

  test('rule 3: onboarding comes first', () {
    expect(go(Routes.home, settings: fresh), Routes.onboarding);
    expect(go(Routes.more, settings: fresh), Routes.onboarding);
    expect(go(Routes.onboarding, settings: fresh), isNull);
  });

  // --- Lock rules (feature 007 T026, contracts/routes.md) ---

  String? lockGo(
    String location, {
    AppSettings settings = locked,
    bool sessionLocked = true,
    LockMode mode = LockMode.route,
    String? covered,
    String? query,
  }) => redirectFor(
    location: location,
    uri: Uri.parse(query == null ? location : '$location?$query'),
    bootstrap: ready,
    settings: settings,
    registry: registry,
    sessionLocked: sessionLocked,
    sessionMode: mode,
    coveredLocation: covered,
  );

  test('rule 4: while locked every location goes through /lock with where it '
      'was going', () {
    expect(lockGo(Routes.home), Routes.lockPath(from: Routes.home));
    expect(lockGo('/expenses/123'), '/lock?from=%2Fexpenses%2F123');
    expect(lockGo(Routes.lock, query: 'from=%2Fhome'), isNull);
  });

  test('rule 4: an unlocked session goes anywhere', () {
    expect(lockGo(Routes.home, sessionLocked: false), isNull);
    expect(lockGo(Routes.home, settings: done), isNull);
  });

  test('rule 4: the location the resume overlay covers stays; any other one '
      '(a deep link) goes through /lock', () {
    expect(
      lockGo('/expenses/123', mode: LockMode.overlay, covered: '/expenses/123'),
      isNull,
    );
    expect(
      lockGo(Routes.habits, mode: LockMode.overlay, covered: '/expenses/123'),
      Routes.lockPath(from: Routes.habits),
    );
  });

  test('rule 4b: /lock leaves for "from" once unlocked or once the lock is '
      'off', () {
    expect(
      lockGo(Routes.lock, query: 'from=%2Fhabits', sessionLocked: false),
      Routes.habits,
    );
    expect(lockGo(Routes.lock, sessionLocked: false), Routes.home);
    expect(lockGo(Routes.lock, settings: done), Routes.home);
  });

  test('rule 3: Intro no longer opens SYS-04, so every PIN mode goes to '
      'onboarding (the settingPin exception is removed)', () {
    String? pin(String mode) => redirectFor(
      location: Routes.pin,
      uri: Uri.parse(Routes.pinPath(mode)),
      bootstrap: ready,
      settings: fresh,
      registry: registry,
    );
    for (final mode in [
      Routes.pinModeSet,
      Routes.pinModeChange,
      Routes.pinModeDisable,
    ]) {
      expect(pin(mode), Routes.onboarding, reason: mode);
    }
  });

  test('rule 5: a disabled module route goes to Home', () {
    const habitOnly = AppSettings(
      onboardingDone: true,
      enabledModules: ['habit'],
      authMode: AuthMode.guest,
    );
    expect(go(Routes.expenses, settings: habitOnly), Routes.home);
    expect(go('${Routes.expenses}/anything', settings: habitOnly), Routes.home);
    expect(go(Routes.habits, settings: habitOnly), isNull);
    expect(go(Routes.more, settings: habitOnly), isNull);
  });

  test('rule 6: finished onboarding goes to Home, or to AUTH-01 with no '
      'login chosen', () {
    expect(go(Routes.onboarding), Routes.home);
    expect(go(Routes.onboarding, settings: noLogin), Routes.login);
    expect(go(Routes.home), isNull);
    expect(go(Routes.modules), isNull);
  });

  // --- Login rules (feature 011 contracts/routes.md) ---

  test('rule 3b: with authMode none every location opens AUTH-01, a '
      'notification or deep link included', () {
    for (final location in [
      Routes.home,
      Routes.more,
      Routes.account,
      '/expenses/123',
      Routes.lock,
      Routes.pin,
      Routes.premium,
    ]) {
      expect(go(location, settings: noLogin), Routes.login, reason: location);
    }
    expect(go(Routes.login, settings: noLogin), isNull);
  });

  test('rule 3b: before onboarding, Intro still comes first', () {
    expect(go(Routes.login, settings: fresh), Routes.onboarding);
  });

  test('rule 3c: once logged in, AUTH-01 leaves for Home', () {
    for (final mode in [AuthMode.guest, AuthMode.google]) {
      expect(
        go(Routes.login, settings: noLogin.copyWith(authMode: mode)),
        Routes.home,
      );
    }
  });

  test('rule 3c + 4: with app lock on, leaving AUTH-01 goes through SYS-03 '
      'first', () {
    expect(lockGo(Routes.login), Routes.home);
    expect(lockGo(Routes.home), Routes.lockPath(from: Routes.home));
  });

  test('rules 4/4b: with authMode none the lock rules do not apply; AUTH-01 '
      'shows even with app lock on', () {
    final lockedNoLogin = locked.copyWith(authMode: AuthMode.none);
    expect(lockGo(Routes.login, settings: lockedNoLogin), isNull);
    expect(lockGo(Routes.home, settings: lockedNoLogin), Routes.login);
    expect(lockGo(Routes.lock, settings: lockedNoLogin), Routes.login);
  });

  test('rule 7: ACC-01 only while signed in with Google; otherwise SET-01', () {
    final google = done.copyWith(
      authMode: AuthMode.google,
      backupAccountEmail: 'me@example.com',
    );
    expect(go(Routes.account, settings: google), isNull);
    expect(go(Routes.account), Routes.more);
    expect(go('${Routes.account}/x'), Routes.more);
    expect(go(Routes.more), isNull);
  });

  test('the authMode argument wins over settings (the router passes '
      'authModeProvider)', () {
    expect(
      redirectFor(
        location: Routes.home,
        bootstrap: ready,
        settings: done,
        registry: registry,
        authMode: AuthMode.none,
      ),
      Routes.login,
    );
  });

  group('SYS-01 first screen: onboarding × authMode × lock', () {
    for (final onboarded in [false, true]) {
      for (final mode in AuthMode.values) {
        for (final lock in [false, true]) {
          final s = AppSettings(
            onboardingDone: onboarded,
            authMode: mode,
            lockEnabled: lock,
          );
          final expected = !onboarded
              ? Routes.onboarding
              : mode == AuthMode.none
              ? Routes.login
              : lock
              ? Routes.lockPath(from: Routes.home)
              : Routes.home;
          test('onboarding ${onboarded ? 'done' : 'not done'}, '
              '${mode.name}, lock ${lock ? 'on' : 'off'} → $expected', () {
            expect(initialLocationFor(s), expected);
            expect(lockAtStart(s), onboarded && lock && mode != AuthMode.none);
            // The router agrees: the splash leaves for that screen, which
            // then stays put (the session is locked exactly when expected).
            final start = AsyncData<BootstrapResult>(BootstrapReady(expected));
            expect(
              redirectFor(
                location: Routes.splash,
                bootstrap: start,
                settings: s,
                registry: registry,
              ),
              expected,
            );
            final uri = Uri.parse(expected);
            expect(
              redirectFor(
                location: uri.path,
                uri: uri,
                bootstrap: start,
                settings: s,
                registry: registry,
                sessionLocked: lockAtStart(s),
              ),
              isNull,
            );
          });
        }
      }
    }
  });

  test(
    'initialLocationFor drops a notification payload with authMode none',
    () {
      expect(
        initialLocationFor(noLogin, launchPayload: '/habits'),
        Routes.login,
      );
      expect(initialLocationFor(done, launchPayload: '/habits'), '/habits');
    },
  );
}
