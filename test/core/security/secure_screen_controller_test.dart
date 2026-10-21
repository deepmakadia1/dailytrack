// Step-by-step state changes read better as separate calls.
// ignore_for_file: cascade_invocations

import 'package:dailytrack/core/security/secure_screen_service.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// FLAG_SECURE control (T017, FR-027, FR-033, research R9).
void main() {
  late FakeSettingsRepository settings;
  late FakeSecureScreenService screen;
  late ProviderContainer container;

  Future<SecureScreenController> controller() {
    settings = FakeSettingsRepository();
    screen = FakeSecureScreenService();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        secureScreenServiceProvider.overrideWithValue(screen),
      ],
    );
    addTearDown(container.dispose);
    container
      ..listen(appSettingsProvider, (_, _) {})
      ..listen(secureScreenControllerProvider, (_, _) {});
    return container
        .read(appSettingsProvider.future)
        .then((_) => container.read(secureScreenControllerProvider.notifier));
  }

  Future<void> settle() => Future<void>.delayed(Duration.zero);

  test('off by default: no platform call', () async {
    await controller();
    expect(screen.calls, isEmpty);
  });

  test('SYS-03 visible turns it on, and off again when it goes', () async {
    final c = await controller();
    c.setUnlockVisible(visible: true);
    c.setUnlockVisible(visible: false);
    expect(screen.calls, [true, false]);
  });

  test('hide in recents keeps it on whatever SYS-03 does', () async {
    final c = await controller();
    await settings.setHideInRecents(enabled: true);
    await settle();
    c
      ..setUnlockVisible(visible: true)
      ..setUnlockVisible(visible: false);
    expect(screen.calls, [true]);
    expect(container.read(secureScreenControllerProvider), isTrue);
  });

  test('turning hide in recents off while SYS-03 shows keeps it on', () async {
    final c = await controller();
    await settings.setHideInRecents(enabled: true);
    await settle();
    c.setUnlockVisible(visible: true);
    await settings.setHideInRecents(enabled: false);
    await settle();
    expect(screen.calls, [true]);
    c.setUnlockVisible(visible: false);
    expect(screen.calls, [true, false]);
  });
}
