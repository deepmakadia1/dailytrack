import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/color_themes.dart';
import 'package:dailytrack/core/theme/theme_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';

/// SET-04 effective theme (T055, FR-017, FR-020, US5-5).
void main() {
  late FakeSettingsRepository settings;
  late FakeFeatureGate gate;
  late ProviderContainer container;

  setUp(() {
    settings = FakeSettingsRepository();
    gate = FakeFeatureGate();
    container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        featureGateProvider.overrideWithValue(gate),
      ],
    );
    addTearDown(container.dispose);
  });

  Future<String> effective() async {
    // Settle the settings stream and the gate stream.
    await container.read(appSettingsProvider.future);
    await Future<void>.delayed(Duration.zero);
    return (await container.read(effectiveColorThemeProvider.future)).id;
  }

  test('a stored free theme is shown as is', () async {
    container.listen(effectiveColorThemeProvider, (_, _) {});
    await settings.setSelectedTheme('indigo');
    expect(await effective(), 'indigo');
  });

  test('a locked premium theme shows Default teal; unlocking shows it with '
      'no settings write, and locking again falls back', () async {
    container.listen(effectiveColorThemeProvider, (_, _) {});
    await settings.setSelectedTheme('saffron');
    expect(await effective(), 'default');
    final writes = settings.writeCount;

    gate.set(FeatureKey.premiumTheme('saffron'), unlocked: true);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(effectiveColorThemeProvider).value?.id, 'saffron');

    gate.set(FeatureKey.premiumTheme('saffron'), unlocked: false);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(effectiveColorThemeProvider).value?.id, 'default');
    expect(settings.writeCount, writes);
    expect(settings.current.selectedTheme, 'saffron');
  });

  test('colorThemeUnlocked: free themes are always unlocked; premium themes '
      'follow the gate', () async {
    // Keep the auto-dispose providers alive while they load.
    container
      ..listen(colorThemeUnlockedProvider('indigo'), (_, _) {})
      ..listen(colorThemeUnlockedProvider('mono'), (_, _) {});
    expect(
      await container.read(colorThemeUnlockedProvider('indigo').future),
      isTrue,
    );
    expect(
      await container.read(colorThemeUnlockedProvider('mono').future),
      isFalse,
    );
    expect(appColorThemes.where((t) => t.isPremium), hasLength(6));
    expect(const AppSettings().selectedTheme, 'default');
  });
}
