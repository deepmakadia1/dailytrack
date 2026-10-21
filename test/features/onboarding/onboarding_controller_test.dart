import 'package:dailytrack/core/module/module_registry.dart';
import 'package:dailytrack/core/notifications/notification_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:dailytrack/features/onboarding/presentation/controllers/onboarding_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

void main() {
  late FakeSettingsRepository repo;
  late FakeNotificationPermission permission;
  late ProviderContainer container;

  Future<OnboardingController> setUpController({
    AppSettings initial = const AppSettings(),
  }) async {
    repo = FakeSettingsRepository(initial: initial);
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(repo),
        notificationPermissionProvider.overrideWithValue(permission),
        moduleRegistryProvider.overrideWithValue(
          ModuleRegistry([
            FakeTrackerModule(id: 'expense'),
            FakeTrackerModule(id: 'habit'),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);
    // Riverpod 3 pauses providers without listeners, so listen first.
    container.listen(appSettingsProvider, (_, _) {});
    await container.read(appSettingsProvider.future);
    container.listen(onboardingControllerProvider, (_, _) {});
    final controller = container.read(onboardingControllerProvider.notifier);
    return controller;
  }

  OnboardingState view() => container.read(onboardingControllerProvider);

  setUp(() => permission = FakeNotificationPermission());

  test('starts on step 1 seeded from current settings', () async {
    await setUpController(
      initial: const AppSettings(locale: 'hi', currencyCode: 'USD'),
    );
    expect(view().step, 1);
    expect(view().languageCode, 'hi');
    expect(view().currencyCode, 'USD');
    expect(view().enabledModules, ['expense', 'habit']);
  });

  test('next and back stay within steps 1..4', () async {
    final c = await setUpController();
    c.back();
    expect(view().step, 1);
    for (var i = 0; i < 6; i++) {
      c.next();
    }
    expect(view().step, 4);
    c.back();
    expect(view().step, 3);
  });

  test('skip is allowed only on steps 1 and 2', () async {
    final c = await setUpController();
    expect(view().canSkip, isTrue);
    c
      ..next()
      ..next();
    expect(view().canSkip, isFalse);
    await c.skip();
    expect(repo.calls['completeOnboarding'], isNull);
  });

  test('toggleModule refuses to turn off the last enabled module', () async {
    final c = await setUpController()
      ..toggleModule('habit');
    expect(view().enabledModules, ['expense']);
    c.toggleModule('expense');
    expect(view().enabledModules, ['expense']);
    expect(view().moduleMessageKey, atLeastOneModuleKey);
    c.toggleModule('habit');
    expect(view().enabledModules, ['expense', 'habit']);
    expect(view().moduleMessageKey, isNull);
  });

  test('selectLanguage writes the locale immediately', () async {
    final c = await setUpController();
    await c.selectLanguage('gu');
    expect(repo.current.locale, 'gu');
    expect(view().languageCode, 'gu');
  });

  test('selecting a language does not reset progress', () async {
    final c = await setUpController()
      ..next()
      ..selectCurrency('USD')
      ..back();
    await c.selectLanguage('hi');
    await pumpEventQueue();
    expect(view().currencyCode, 'USD');
    expect(view().step, 1);
  });

  test('complete saves the chosen values exactly once', () async {
    final c = await setUpController()
      ..selectCurrency('USD')
      ..toggleModule('expense');
    await c.selectLanguage('gu');
    await c.complete();
    expect(repo.calls['completeOnboarding'], 1);
    expect(repo.current.locale, 'gu');
    expect(repo.current.currencyCode, 'USD');
    expect(repo.current.enabledModules, ['habit']);
    expect(repo.current.onboardingDone, isTrue);
  });

  test('skip saves the defaults', () async {
    final c = await setUpController()
      ..selectCurrency('USD');
    await c.selectLanguage('gu');
    await c.skip();
    expect(repo.current.locale, isNull);
    expect(repo.current.currencyCode, 'INR');
    expect(repo.current.enabledModules, ['expense', 'habit']);
    expect(repo.current.onboardingDone, isTrue);
  });

  test(
    'a failed save keeps choices and sets the error; retry clears it',
    () async {
      final c = await setUpController()
        ..selectCurrency('USD');
      repo.failNextCompleteOnboarding = true;
      await c.complete();
      expect(view().saveErrorKey, saveErrorKey);
      expect(view().saving, isFalse);
      expect(view().currencyCode, 'USD');
      expect(repo.current.onboardingDone, isFalse);
      await c.retrySave();
      expect(view().saveErrorKey, isNull);
      expect(repo.current.onboardingDone, isTrue);
      expect(repo.current.currencyCode, 'USD');
    },
  );

  test('requestNotifications records the result and never throws', () async {
    permission = FakeNotificationPermission(result: false);
    var c = await setUpController();
    await c.requestNotifications();
    expect(view().notificationsGranted, isFalse);

    permission = FakeNotificationPermission(throws: true);
    c = await setUpController();
    await c.requestNotifications();
    expect(view().notificationsGranted, isFalse);
  });

  group('filterCurrencies', () {
    String nameOf(String code) => switch (code) {
      'USD' => 'US Dollar',
      'INR' => 'Indian Rupee',
      _ => code,
    };

    test('empty query returns all 30 currencies', () {
      expect(filterCurrencies('', nameOf), hasLength(30));
    });

    test('matches code or localized name, case-insensitively', () {
      expect(filterCurrencies('dol', nameOf).map((c) => c.code), ['USD']);
      expect(filterCurrencies('inr', nameOf).map((c) => c.code), ['INR']);
      expect(filterCurrencies('RUPEE', nameOf).map((c) => c.code), ['INR']);
    });

    test('no match returns an empty list', () {
      expect(filterCurrencies('zzz', nameOf), isEmpty);
    });
  });
}
