import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/module_registry.dart';
import 'package:dailytrack/app/router/app_router.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Redirect rules from contracts/routes.md, tested as a pure function.
void main() {
  const ready = AsyncData<BootstrapResult>(BootstrapReady(Routes.home));
  const fresh = AppSettings();
  const done = AppSettings(onboardingDone: true);
  const locked = AppSettings(onboardingDone: true, lockEnabled: true);

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

  test('rule 3: SYS-02 step 4 may open SYS-04 to set or change the PIN, '
      'but not to turn it off', () {
    String? pin(String mode) => redirectFor(
      location: Routes.pin,
      uri: Uri.parse(Routes.pinPath(mode)),
      bootstrap: ready,
      settings: fresh,
      registry: registry,
    );
    expect(pin(Routes.pinModeSet), isNull);
    expect(pin(Routes.pinModeChange), isNull);
    expect(pin(Routes.pinModeDisable), Routes.onboarding);
  });

  test('rule 5: a disabled module route goes to Home', () {
    const habitOnly = AppSettings(
      onboardingDone: true,
      enabledModules: ['habit'],
    );
    expect(go(Routes.expenses, settings: habitOnly), Routes.home);
    expect(go('${Routes.expenses}/anything', settings: habitOnly), Routes.home);
    expect(go(Routes.habits, settings: habitOnly), isNull);
    expect(go(Routes.more, settings: habitOnly), isNull);
  });

  test('rule 6: finished onboarding goes to Home', () {
    expect(go(Routes.onboarding), Routes.home);
    expect(go(Routes.home), isNull);
    expect(go(Routes.modules), isNull);
  });
}
