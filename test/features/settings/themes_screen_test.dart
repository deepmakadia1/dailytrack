import 'package:dailytrack/app/router/routes.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/theme/app_colors.dart';
import 'package:dailytrack/core/theme/app_text_scaler.dart';
import 'package:dailytrack/core/widgets/locked_feature_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/test_app.dart';
import '../expense/expense_test_app.dart';

/// SET-04 Themes and appearance (T057, US5, FR-015 – FR-021).
void main() {
  const premium = ['saffron', 'forest', 'rose', 'midnight', 'ocean', 'mono'];

  Future<FakeSettingsRepository> open(
    WidgetTester tester, {
    AppSettings initial = const AppSettings(onboardingDone: true, locale: 'en'),
    FakeFeatureGate? gate,
    FakeRewardedUnlockPresenter? presenter,
  }) async {
    tester.view
      ..physicalSize = const Size(412, 1600)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final settings = FakeSettingsRepository(initial: initial);
    await pumpTestApp(
      tester,
      settings: settings,
      gate: gate,
      // Feature 009: tapping a locked theme opens PRM-02; scripted here.
      rewardedPresenter: presenter ?? FakeRewardedUnlockPresenter(earn: false),
    );
    routerOf(tester).go(Routes.themes);
    await tester.pumpAndSettle();
    return settings;
  }

  ThemeData appTheme(WidgetTester tester) =>
      Theme.of(tester.element(find.byKey(const Key('themes_list'))));

  ColorScheme schemeOf(Color seed) => ColorScheme.fromSeed(seedColor: seed);

  Future<void> tapTile(WidgetTester tester, String id) async {
    await tester.ensureVisible(find.byKey(Key('theme_$id')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('theme_$id')));
    await tester.pumpAndSettle();
  }

  testWidgets('US5-1 Dark applies to the whole app at once; System follows '
      'the device', (tester) async {
    final settings = await open(tester);
    expect(appTheme(tester).brightness, Brightness.light);
    await tester.tap(find.text('Dark'));
    await tester.pump();
    expect(settings.current.themeMode, 'dark');
    await tester.pumpAndSettle();
    expect(appTheme(tester).brightness, Brightness.dark);

    await tester.tap(find.text('System'));
    await tester.pumpAndSettle();
    expect(settings.current.themeMode, 'system');
    expect(appTheme(tester).brightness, Brightness.light);
  });

  testWidgets('US5-2 tapping free Indigo stores it and recolors the app and '
      'the preview', (tester) async {
    final settings = await open(tester);
    await tapTile(tester, 'indigo');
    expect(settings.current.selectedTheme, 'indigo');
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seedIndigo).primary,
    );
    final preview = Theme.of(
      tester.element(find.byKey(const Key('theme_preview_sample'))),
    );
    expect(preview.colorScheme.primary, schemeOf(AppColors.seedIndigo).primary);
    expect(find.bySemanticsLabel('Indigo, selected'), findsOneWidget);
  });

  testWidgets('US5-3 the six premium themes are locked with a lock and a Pro '
      'chip; tapping one previews it behind the overlay and stores nothing', (
    tester,
  ) async {
    final settings = await open(tester);
    for (final id in premium) {
      expect(find.byKey(Key('theme_${id}_pro')), findsOneWidget, reason: id);
    }
    expect(find.byKey(const Key('theme_default_pro')), findsNothing);
    expect(find.byKey(const Key('theme_indigo_pro')), findsNothing);
    expect(find.bySemanticsLabel('Saffron, Pro, locked'), findsOneWidget);

    final writes = settings.writeCount;
    await tapTile(tester, 'saffron');
    expect(settings.writeCount, writes);
    expect(settings.current.selectedTheme, 'default');
    expect(find.byType(LockedFeatureOverlay), findsOneWidget);
    expect(find.text('Get Pro to use this theme'), findsOneWidget);
    // Feature 009: "Watch an ad" and an enabled "Get Pro".
    expect(find.text('Watch an ad to unlock this theme'), findsOneWidget);
    final getPro = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Get Pro'),
    );
    expect(getPro.onPressed, isNotNull);
    // The app keeps Default teal.
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seed).primary,
    );
  });

  testWidgets('US5-4 the debug unlock removes the lock badges live; a premium '
      'theme can then be applied', (tester) async {
    final gate = FakeFeatureGate();
    final settings = await open(tester, gate: gate);
    for (final id in premium) {
      gate.set(FeatureKey.premiumTheme(id), unlocked: true);
    }
    await tester.pumpAndSettle();
    for (final id in premium) {
      expect(find.byKey(Key('theme_${id}_pro')), findsNothing, reason: id);
    }
    await tapTile(tester, 'saffron');
    expect(settings.current.selectedTheme, 'saffron');
    expect(find.byType(LockedFeatureOverlay), findsNothing);
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seedSaffron).primary,
    );
  });

  testWidgets('US5-5 locking an applied premium theme shows Default teal; '
      'unlocking restores it', (tester) async {
    final gate = FakeFeatureGate(
      unlocked: {FeatureKey.premiumTheme('ocean'): true},
    );
    await open(
      tester,
      gate: gate,
      initial: const AppSettings(
        onboardingDone: true,
        locale: 'en',
        selectedTheme: 'ocean',
      ),
    );
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seedOcean).primary,
    );
    gate.set(FeatureKey.premiumTheme('ocean'), unlocked: false);
    await tester.pumpAndSettle();
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seed).primary,
    );
    gate.set(FeatureKey.premiumTheme('ocean'), unlocked: true);
    await tester.pumpAndSettle();
    expect(
      appTheme(tester).colorScheme.primary,
      schemeOf(AppColors.seedOcean).primary,
    );
  });

  testWidgets('US5-6 Large stores the setting and scales app text by 15%', (
    tester,
  ) async {
    final settings = await open(tester);
    double scale() =>
        MediaQuery.textScalerOf(
          tester.element(find.byKey(const Key('themes_list'))),
        ).scale(10) /
        10;
    expect(scale(), 1);
    await tester.ensureVisible(find.text('Large'));
    await tester.tap(find.text('Large'));
    await tester.pumpAndSettle();
    expect(settings.current.fontSize, 'large');
    expect(scale(), closeTo(largeFontFactor, 1e-9));
  });

  testWidgets('every color tile is at least 48 dp tall', (tester) async {
    await open(tester);
    for (final id in [...premium, 'default', 'indigo']) {
      final size = tester.getSize(find.byKey(Key('theme_$id')));
      expect(size.height, greaterThanOrEqualTo(48), reason: id);
    }
  });

  // --- 009-ads-rewarded-pro (T067): SET-04 rewarded themes. ---
  group('SET-04 tapping a locked theme opens PRM-02', () {
    testWidgets('the offer names the theme; an earned reward unlocks it for '
        'good and applies it', (tester) async {
      final presenter = FakeRewardedUnlockPresenter();
      final settings = await open(tester, presenter: presenter);
      await tapTile(tester, 'saffron');
      final request = presenter.requests.single;
      expect(request.key, FeatureKey.premiumTheme('saffron'));
      expect(request.duration, isNull, reason: 'permanent');
      expect(request.subjectName, 'Saffron');
      expect(settings.current.selectedTheme, 'saffron');
    });

    testWidgets('"Not now" keeps the old theme and the preview overlay with '
        'both buttons', (tester) async {
      final settings = await open(tester);
      await tapTile(tester, 'forest');
      expect(settings.current.selectedTheme, 'default');
      expect(find.byKey(const Key('theme_preview_locked')), findsOneWidget);
      expect(find.byKey(const Key('locked_watch_ad')), findsOneWidget);
    });
  });
}
