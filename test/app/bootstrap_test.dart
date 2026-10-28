import 'dart:async';

import 'package:dailytrack/app/app_open_runner.dart';
import 'package:dailytrack/app/bootstrap.dart';
import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/account/account_providers.dart';
import 'package:dailytrack/core/account/domain/account.dart';
import 'package:dailytrack/core/account/domain/account_auth.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/consent_service.dart';
import 'package:dailytrack/core/backup/backup_providers.dart';
import 'package:dailytrack/core/backup/domain/restore_types.dart';
import 'package:dailytrack/core/backup/domain/safety_copy.dart';
import 'package:dailytrack/core/billing/billing_providers.dart';
import 'package:dailytrack/core/billing/domain/pro_store.dart';
import 'package:dailytrack/core/database/app_database.dart';
import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/core/widget/glance_refresher.dart';
import 'package:dailytrack/core/widget/widget_providers.dart';
import 'package:dailytrack/features/expense/domain/enums.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/fakes.dart';
import '../helpers/mutable_clock.dart';
import '../helpers/real_container.dart';

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;
  late MockAdService ads;
  late FakeConsentService consent;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    ads = MockAdService();
    when(() => ads.init()).thenAnswer((_) async {});
    // Consent from an earlier session already allows ads.
    consent = FakeConsentService(
      stored: true,
      gatherResult: const ConsentResult(
        canRequestAds: true,
        privacyOptionsRequired: false,
      ),
    );
  });
  tearDown(() => db.close());

  Future<BootstrapResult> boot(ProviderContainer c) {
    c.listen(bootstrapProvider, (_, _) {});
    return c.read(bootstrapProvider.future);
  }

  Future<ProviderContainer> containerWith({
    bool onboardingDone = false,
    bool lockEnabled = false,
    bool removeAdsPurchased = false,
    List<String>? enabled,
  }) async {
    final c = makeRealContainer(
      db,
      ads: ads,
      overrides: [consentServiceProvider.overrideWithValue(consent)],
    );
    final repo = c.read(settingsRepositoryProvider);
    if (onboardingDone) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
      );
    }
    if (lockEnabled) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('lockEnabled', 'true', 0)",
      );
    }
    if (removeAdsPurchased) {
      await db.customStatement(
        "INSERT INTO settings VALUES ('removeAdsPurchased', 'true', 0)",
      );
    }
    if (enabled != null) {
      await repo.setModules(order: ['expense', 'habit'], enabled: enabled);
    }
    return c;
  }

  group('SYS-01 returning user with lock on lands on SYS-03; without lock '
      'lands on DSH-01', () {
    test('lock on → /lock', () async {
      final c = await containerWith(onboardingDone: true, lockEnabled: true);
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        Routes.lockPath(from: Routes.home),
      );
    });

    test('lock off → /home', () async {
      final c = await containerWith(onboardingDone: true);
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
    });

    test('onboarding not done → /onboarding', () async {
      final c = await containerWith(lockEnabled: true);
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.onboarding);
    });
  });

  group('SYS-01 ads SDK is not initialized when Remove Ads is purchased', () {
    test('purchased → neither the consent SDK nor the ads SDK is touched, '
        'and the session starts without ads', () async {
      final c = await containerWith(removeAdsPurchased: true);
      await boot(c);
      await pumpEventQueue();
      verifyNever(() => ads.init());
      expect(consent.canRequestCalls, 0);
      expect(consent.gatherCalls, 0);
      expect(c.read(adsSessionGateProvider), isFalse);
    });

    test('not purchased → init is called once', () async {
      final c = await containerWith();
      await boot(c);
      verify(() => ads.init()).called(1);
    });
  });

  // --- 009-ads-rewarded-pro (T084, T086): Pro at startup. ---
  group('Pro at startup', () {
    test('PRM-01 AC no ad of any kind after purchase, including after '
        'restart: three cold starts with Pro touch neither SDK', () async {
      final c1 = await containerWith(removeAdsPurchased: true);
      await boot(c1);
      for (var i = 0; i < 2; i++) {
        final c = makeRealContainer(
          db,
          ads: ads,
          overrides: [consentServiceProvider.overrideWithValue(consent)],
        );
        await boot(c);
      }
      await pumpEventQueue();
      verifyNever(() => ads.init());
      expect(consent.canRequestCalls, 0);
      expect(consent.gatherCalls, 0);
    });

    test('a removal staged by an earlier start is applied before ads and '
        'locks are decided: this start has ads again', () async {
      final c = await containerWith(onboardingDone: true);
      await db.customStatement(
        "INSERT INTO settings VALUES ('removeAdsPurchased', 'true', 0)",
      );
      await db.customStatement(
        "INSERT INTO settings VALUES ('proRemovalPending', 'true', 0)",
      );
      await boot(c);
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.removeAdsPurchased, isFalse);
      expect(s.proRemovalPending, isFalse);
      verify(() => ads.init()).called(1);
      expect(c.read(adsSessionGateProvider), isTrue);
    });

    test('the purchase stream is listened to at startup and ownership is '
        'checked in the background', () async {
      final store = FakeProStore(ownership: OwnershipCheck.owned);
      final c = makeRealContainer(
        db,
        ads: ads,
        overrides: [
          consentServiceProvider.overrideWithValue(consent),
          proStoreProvider.overrideWithValue(store),
        ],
      );
      await boot(c);
      await pumpEventQueue();
      expect(store.listens, 1);
      expect(store.ownershipQueries, 1);
      // A reinstall gets Pro back from Play on its own.
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.removeAdsPurchased, isTrue);
    });
  });

  // --- 009-ads-rewarded-pro (T030): consent before the ads SDK. ---
  group('§11 no ad request is made before consent is resolved', () {
    test('stored consent allows ads → the SDK starts without waiting, and '
        'consent is refreshed once in the background', () async {
      final c = await containerWith(onboardingDone: true);
      final r = await boot(c);
      expect(r, isA<BootstrapReady>());
      verify(() => ads.init()).called(1);
      expect(c.read(adsSessionGateProvider), isTrue);
      await pumpEventQueue();
      expect(consent.gatherCalls, 1);
    });

    test('consent still unknown → the check (and form) finishes before the '
        'SDK starts', () async {
      consent
        ..stored = false
        ..showsForm = true;
      final c = await containerWith(onboardingDone: true);
      await boot(c);
      expect(consent.gatherCalls, 1);
      expect(consent.beforeFormCalls, 1);
      verify(() => ads.init()).called(1);
      expect(c.read(adsSessionGateProvider), isTrue);
    });

    test('consent does not allow ads → the SDK never starts', () async {
      consent
        ..stored = false
        ..gatherResult = ConsentResult.none;
      final c = await containerWith(onboardingDone: true);
      await boot(c);
      await pumpEventQueue();
      verifyNever(() => ads.init());
      expect(c.read(adsSessionGateProvider), isFalse);
    });

    test('FR-013 a failing consent check never blocks startup', () async {
      consent.throwOnCheck = true;
      final c = await containerWith(onboardingDone: true);
      expect(await boot(c), isA<BootstrapReady>());
      verifyNever(() => ads.init());
      expect(c.read(adsSessionGateProvider), isFalse);
    });
  });

  test('an ads failure never blocks startup', () async {
    when(() => ads.init()).thenThrow(StateError('ads down'));
    final c = await containerWith(onboardingDone: true);
    expect(await boot(c), isA<BootstrapReady>());
  });

  test('a database that cannot open gives BootstrapFailed', () async {
    final broken = AppDatabase(
      LazyDatabase(() async => throw StateError('disk full')),
    );
    // Never opened, so there is nothing to close (closing would rethrow).
    final c = makeRealContainer(broken, ads: ads);
    expect(await boot(c), isA<BootstrapFailed>());
    verifyNever(() => ads.init());
  });

  test('seeds every registered module, even disabled ones', () async {
    final c = await containerWith(enabled: ['habit']);
    await boot(c);
    final expense = await (db.select(
      db.categories,
    )..where((r) => r.type.equalsValue(CategoryType.expense))).get();
    expect(expense, hasLength(12));
    expect(await db.select(db.accounts).get(), hasLength(1));
  });

  test('retry runs startup again', () async {
    final c = await containerWith(onboardingDone: true);
    await boot(c);
    await c.read(bootstrapProvider.notifier).retry();
    expect(c.read(bootstrapProvider).value, isA<BootstrapReady>());
    expect(await db.select(db.accounts).get(), hasLength(1));
  });

  test('FakeBootstrap mirrors the real startup rule', () async {
    final repo = FakeSettingsRepository();
    final c = ProviderContainer(
      overrides: [
        bootstrapProvider.overrideWith(() => FakeBootstrap.fromSettings(repo)),
      ],
    );
    addTearDown(c.dispose);
    final r = await boot(c);
    expect((r as BootstrapReady).initialLocation, Routes.onboarding);
  });

  // --- 003-budgets-recurring-reports (T021): app-open hooks and the
  // notification launch payload (research R10, R15). ---
  group('app open', () {
    late FakeTrackerModule expense;
    late FakeTrackerModule habit;
    late FakeNotificationService notifications;
    late FakeHomeWidgetBridge widget;

    Future<ProviderContainer> start({
      bool lockEnabled = false,
      String? payload,
      String? widgetLaunch,
      List<String> enabled = const ['expense', 'habit'],
    }) async {
      widget = FakeHomeWidgetBridge(launchAt: widgetLaunch);
      expense = FakeTrackerModule(id: 'expense');
      habit = FakeTrackerModule(id: 'habit');
      notifications = FakeNotificationService(payloadAtLaunch: payload);
      final c = makeRealContainer(
        db,
        ads: ads,
        registry: ModuleRegistry([expense, habit]),
        notifications: notifications,
        overrides: [homeWidgetBridgeProvider.overrideWithValue(widget)],
      );
      await db.customStatement(
        "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
      );
      if (lockEnabled) {
        await db.customStatement(
          "INSERT INTO settings VALUES ('lockEnabled', 'true', 0)",
        );
      }
      await c
          .read(settingsRepositoryProvider)
          .setModules(order: ['expense', 'habit'], enabled: enabled);
      return c;
    }

    test(
      'a never-completing onAppOpen does not delay the first route',
      () async {
        final c = await start();
        final never = Completer<void>();
        expense.onAppOpenBody = () => never.future;
        final r = await boot(c).timeout(const Duration(seconds: 2));
        expect((r as BootstrapReady).initialLocation, Routes.home);
        await pumpEventQueue();
        expect(expense.appOpenCalls, 1);
        expect(c.read(appOpenRunnerProvider).isRunning, isTrue);
      },
    );

    test(
      'a throwing onAppOpen is ignored and later modules still run',
      () async {
        final c = await start();
        expense.onAppOpenBody = () async => throw StateError('rollover failed');
        expect(await boot(c), isA<BootstrapReady>());
        await c.read(appOpenRunnerProvider).run();
        expect(expense.appOpenCalls, greaterThanOrEqualTo(1));
        expect(habit.appOpenCalls, greaterThanOrEqualTo(1));
      },
    );

    test('disabled modules are skipped', () async {
      final c = await start(enabled: ['habit']);
      await boot(c);
      await c.read(appOpenRunnerProvider).run();
      expect(expense.appOpenCalls, 0);
      expect(habit.appOpenCalls, greaterThanOrEqualTo(1));
    });

    test('the in-flight guard skips a second run while one is going', () async {
      final c = await start();
      final gate = Completer<void>();
      expense.onAppOpenBody = () => gate.future;
      final runner = c.read(appOpenRunnerProvider);
      final first = runner.run();
      final second = runner.run(); // e.g. a resume during cold start
      await pumpEventQueue();
      expect(expense.appOpenCalls, 1);
      gate.complete();
      await Future.wait([first, second]);
      await runner.run();
      expect(expense.appOpenCalls, 2);
    });

    test('app open raises latestSeenAt for the feature gate', () async {
      final c = await start();
      await c.read(appOpenRunnerProvider).run();
      await pumpEventQueue();
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.latestSeenAt, isNotNull);
    });

    test('notifications are initialized at startup', () async {
      final c = await start();
      await boot(c);
      expect(notifications.initializeCalls, 1);
    });

    test(
      'EXP-02 US2-6 a launch payload opens its location when lock is off',
      () async {
        final c = await start(payload: '/expenses/budgets?month=2026-09');
        final r = await boot(c);
        expect(
          (r as BootstrapReady).initialLocation,
          '/expenses/budgets?month=2026-09',
        );
      },
    );

    test('EXP-02 US2-6 tap with lock on goes through SYS-03, then to the '
        'alert (feature 007)', () async {
      final c = await start(
        lockEnabled: true,
        payload: '/expenses/budgets?month=2026-09',
      );
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        Routes.lockPath(from: '/expenses/budgets?month=2026-09'),
      );
    });

    test('a payload that is not a location is ignored', () async {
      final c = await start(payload: 'budget');
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
    });

    // --- 008 (T128, research R20): the home screen widget. ---
    test('a widget tap that started the app opens Home', () async {
      final c = await start(widgetLaunch: '/home');
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
    });

    test('FR-046 a widget cold start with the lock on goes through SYS-03 '
        'first', () async {
      final c = await start(lockEnabled: true, widgetLaunch: '/home');
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        Routes.lockPath(from: Routes.home),
      );
    });

    test('a notification payload wins over the widget', () async {
      final c = await start(
        payload: '/expenses/budgets?month=2026-09',
        widgetLaunch: '/home',
      );
      final r = await boot(c);
      expect(
        (r as BootstrapReady).initialLocation,
        '/expenses/budgets?month=2026-09',
      );
    });

    test('startup registers the widget callback, arms midnight, and starts '
        'the glance refresher (research R19, R21)', () async {
      final c = await start();
      await boot(c);
      await pumpEventQueue();
      expect(widget.callbacks, hasLength(1));
      expect(widget.armMidnightCalls, 1);
      expect(c.read(glanceRefresherProvider).started, isTrue);
    });
  });

  // --- 010-google-account-backup (T042, T071; spec §16, FR-004, FR-019a,
  // FR-044). ---
  group('SYS-01 account and device at startup', () {
    late FakeDeviceIdFile file;
    late _GatedAccountAuth auth;
    late _MemorySafetyCopyStore safety;
    late MutableClock clock;

    setUp(() {
      file = FakeDeviceIdFile();
      auth = _GatedAccountAuth();
      safety = _MemorySafetyCopyStore();
      clock = MutableClock(DateTime.utc(2026, 10, 28, 9));
    });

    Future<ProviderContainer> start({bool signedIn = true}) async {
      final c = makeRealContainer(
        db,
        ads: ads,
        overrides: [
          consentServiceProvider.overrideWithValue(consent),
          deviceIdFileProvider.overrideWithValue(file),
          accountAuthProvider.overrideWithValue(auth),
          safetyCopyStoreProvider.overrideWithValue(safety),
          clockProvider.overrideWithValue(clock),
          restoreAftermathProvider.overrideWithValue(() async {}),
        ],
      );
      await db.customStatement(
        "INSERT INTO settings VALUES ('onboardingDone', 'true', 0)",
      );
      if (signedIn) {
        await c
            .read(settingsRepositoryProvider)
            .setAccount(const AccountProfile(email: 'me@example.com'));
      }
      return c;
    }

    test('SYS-01 the device ID is made before routing on a fresh install and '
        'kept in the file and the settings copy (FR-044)', () async {
      final c = await start(signedIn: false);
      final r = await boot(c);
      expect((r as BootstrapReady).initialLocation, Routes.home);
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.deviceId, isNotNull);
      expect(file.value, s.deviceId);
      // A fresh ID is not an Android restore: nothing is reset.
      expect(s.finishSetupPending, isFalse);
    });

    test('SYS-01 an existing device ID is kept as it is', () async {
      file.value = 'this-phone';
      final c = await start();
      await c.read(settingsRepositoryProvider).setDeviceIdCopy('this-phone');
      await boot(c);
      await pumpEventQueue();
      final s = await c.read(settingsRepositoryProvider).load();
      expect(s.deviceId, 'this-phone');
      expect(s.backupAccountEmail, 'me@example.com');
    });

    test('§16 the silent sign-in runs behind the first screen: a sign-in that '
        'never answers does not delay routing', () async {
      final c = await start();
      final r = await boot(c).timeout(const Duration(seconds: 2));
      expect((r as BootstrapReady).initialLocation, Routes.home);
      await pumpEventQueue();
      expect(auth.silentSignIns, 1);
      expect(auth.gate.isCompleted, isFalse);
      // Still signed in while it runs.
      expect(
        (await c.read(settingsRepositoryProvider).load()).backupAccountEmail,
        'me@example.com',
      );
    });

    test('§16 FR-004 an offline silent sign-in keeps the account; a revoked '
        'one clears it and keeps the data', () async {
      final c = await start();
      auth.gate.complete();
      auth.silentResult = StateError('offline');
      await boot(c);
      await pumpEventQueue();
      final repo = c.read(settingsRepositoryProvider);
      expect((await repo.load()).backupAccountEmail, 'me@example.com');

      auth.silentResult = null;
      await c.read(accountServiceProvider).restoreSession();
      expect((await repo.load()).backupAccountEmail, isNull);
      expect((await repo.load()).onboardingDone, isTrue);
    });

    test(
      'FR-019a a safety copy 7 days old or more is deleted at startup',
      () async {
        auth.gate.complete();
        safety.copy = SafetyCopyInfo(
          createdAt: clock
              .now()
              .subtract(SafetyCopyPolicy.keepFor)
              .millisecondsSinceEpoch,
          counts: const {'expense.transactions': 3},
          fileName: 'safety.json',
        );
        final c = await start();
        await boot(c);
        await pumpEventQueue();
        expect(safety.copy, isNull);
        expect(safety.deletes, 1);
      },
    );

    test(
      'FR-019a a safety copy younger than 7 days is kept at startup',
      () async {
        auth.gate.complete();
        safety.copy = SafetyCopyInfo(
          createdAt: clock
              .now()
              .subtract(const Duration(days: 6, hours: 23))
              .millisecondsSinceEpoch,
          counts: const {'expense.transactions': 3},
          fileName: 'safety.json',
        );
        final c = await start();
        await boot(c);
        await pumpEventQueue();
        expect(safety.copy, isNotNull);
        expect(safety.deletes, 0);
      },
    );
  });
}

/// A Google session whose silent sign-in waits for [gate] (feature 010).
final class _GatedAccountAuth implements AccountAuth {
  final gate = Completer<void>();

  /// What a silent sign-in returns, or an error to throw.
  Object? silentResult = const AccountProfile(email: 'me@example.com');
  int silentSignIns = 0;

  @override
  Future<AccountProfile> signIn() => throw UnimplementedError();

  @override
  Future<AccountProfile?> signInSilently() async {
    silentSignIns++;
    await gate.future;
    final result = silentResult;
    if (result is Error) throw result;
    return result as AccountProfile?;
  }

  @override
  Future<void> signOut() async {}
}

/// One safety copy in memory (feature 010 FR-019a).
final class _MemorySafetyCopyStore implements SafetyCopyStore {
  SafetyCopyInfo? copy;
  int deletes = 0;

  @override
  Future<void> save(
    BackupFile file, {
    required Map<String, int> counts,
    required int createdAt,
  }) async {
    copy = SafetyCopyInfo(
      createdAt: createdAt,
      counts: counts,
      fileName: file.fileName,
    );
  }

  @override
  Future<SafetyCopyInfo?> info() async => copy;

  @override
  Future<Uint8List?> read() async => copy == null ? null : Uint8List(0);

  @override
  Future<void> delete() async {
    deletes++;
    copy = null;
  }
}
