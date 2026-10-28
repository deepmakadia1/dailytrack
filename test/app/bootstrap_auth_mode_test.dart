import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/security/lock_session.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fakes.dart';
import '../helpers/real_container.dart';

/// SYS-01 with the sign-in mode (feature 011 T030), over the real startup
/// and a real in-memory database. "First launch seeds … exactly once" is
/// `test/app/bootstrap_test.dart` "seeds every registered module, even
/// disabled ones" and `test/core/database/seed_runner_test.dart`; "Ads SDK
/// is not initialized when Remove Ads is purchased" is
/// `test/app/bootstrap_test.dart` "purchased → neither the consent SDK nor
/// the ads SDK is touched".
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> row(String key, String json) =>
      db.customStatement('INSERT INTO settings VALUES (?, ?, 0)', [key, json]);

  /// Starts the app over [db] with these stored rows; [authMode] null
  /// leaves the row missing (an install updated from before feature 011).
  Future<(BootstrapReady, ProviderContainer)> start({
    bool onboardingDone = true,
    bool lockEnabled = false,
    AuthMode? authMode,
    String? email,
  }) async {
    final ads = MockAdService();
    when(ads.init).thenAnswer((_) async {});
    final c = makeRealContainer(
      db,
      ads: ads,
      overrides: [
        consentServiceProvider.overrideWithValue(
          FakeConsentService(
            stored: true,
            gatherResult: const ConsentResult(
              canRequestAds: true,
              privacyOptionsRequired: false,
            ),
          ),
        ),
      ],
    );
    if (onboardingDone) await row('onboardingDone', 'true');
    if (lockEnabled) await row('lockEnabled', 'true');
    if (authMode != null) await row('authMode', '"${authMode.name}"');
    if (email != null) await row('backupAccountEmail', '"$email"');
    c.listen(bootstrapProvider, (_, _) {});
    final result = await c.read(bootstrapProvider.future);
    return (result as BootstrapReady, c);
  }

  group('SYS-01 returning user with authMode guest or google and lock on '
      'lands on SYS-03; without lock lands on DSH-01', () {
    for (final mode in [AuthMode.guest, AuthMode.google]) {
      test('${mode.name}, lock on → SYS-03, locked', () async {
        final (r, c) = await start(
          lockEnabled: true,
          authMode: mode,
          email: mode == AuthMode.google ? 'me@example.com' : null,
        );
        expect(r.initialLocation, Routes.lockPath(from: Routes.home));
        expect(c.read(lockSessionProvider).locked, isTrue);
      });

      test('${mode.name}, lock off → DSH-01', () async {
        final (r, c) = await start(authMode: mode);
        expect(r.initialLocation, Routes.home);
        expect(c.read(lockSessionProvider).locked, isFalse);
      });
    }
  });

  group('SYS-01 onboarding done with authMode none lands on AUTH-01, even '
      'with app lock on', () {
    for (final lock in [false, true]) {
      test('lock ${lock ? 'on' : 'off'} → AUTH-01, not locked', () async {
        final (r, c) = await start(lockEnabled: lock, authMode: AuthMode.none);
        expect(r.initialLocation, Routes.login);
        expect(c.read(lockSessionProvider).locked, isFalse);
      });
    }
  });

  group('SYS-01 an updated install with onboarding done and no authMode gets '
      'guest, or google when a Google account is signed in, and never sees '
      'AUTH-01', () {
    test('no account → guest, Home', () async {
      final (r, c) = await start();
      expect(r.initialLocation, Routes.home);
      expect(
        (await c.read(settingsRepositoryProvider).load()).authMode,
        AuthMode.guest,
      );
    });

    test('signed in → google, SYS-03 with app lock on', () async {
      final (r, c) = await start(lockEnabled: true, email: 'me@example.com');
      expect(r.initialLocation, Routes.lockPath(from: Routes.home));
      expect(
        (await c.read(settingsRepositoryProvider).load()).authMode,
        AuthMode.google,
      );
    });

    test(
      'the migration runs once: a later start keeps the stored mode',
      () async {
        final (_, first) = await start();
        final repo = first.read(settingsRepositoryProvider);
        expect((await repo.load()).authMode, AuthMode.guest);
        await repo.setAuthMode(AuthMode.none);
        await first.read(bootstrapProvider.notifier).retry();
        final again = first.read(bootstrapProvider).value! as BootstrapReady;
        expect(again.initialLocation, Routes.login);
      },
    );
  });

  test(
    'SYS-01 a fresh install writes authMode none on its first start and '
    'opens Intro; finishing Intro later is never taken for an old install',
    () async {
      final (r, c) = await start(onboardingDone: false);
      expect(r.initialLocation, Routes.onboarding);
      final repo = c.read(settingsRepositoryProvider);
      expect((await repo.load()).authMode, AuthMode.none);
      await row('onboardingDone', 'true');
      await c.read(bootstrapProvider.notifier).retry();
      final again = c.read(bootstrapProvider).value! as BootstrapReady;
      expect(again.initialLocation, Routes.login);
    },
  );

  test('SYS-01 order: the migration runs before routing, so the first '
      'location already reads the migrated mode', () async {
    // With the row missing, routing before the migration would give
    // AUTH-01; after it, Home.
    final (r, _) = await start();
    expect(r.initialLocation, isNot(Routes.login));
  });
}
