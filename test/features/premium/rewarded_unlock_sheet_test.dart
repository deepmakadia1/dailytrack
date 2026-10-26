import 'package:clock/clock.dart';
import 'package:dailytrack/core/ads/ad_providers.dart';
import 'package:dailytrack/core/ads/domain/rewarded_outcome.dart';
import 'package:dailytrack/core/ads/rewarded_unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/feature_key.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock.dart';
import 'package:dailytrack/core/feature_gate/domain/unlock_repository.dart';
import 'package:dailytrack/core/feature_gate/feature_gate_providers.dart';
import 'package:dailytrack/core/l10n/gen/app_localizations.dart';
import 'package:dailytrack/core/settings/domain/app_settings.dart';
import 'package:dailytrack/core/settings/settings_providers.dart';
import 'package:dailytrack/core/theme/app_theme.dart';
import 'package:dailytrack/core/utils/clock_provider.dart';
import 'package:dailytrack/features/premium/presentation/rewarded_unlock_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/fakes.dart';

/// Records rewarded unlocks the default grant writes.
final class _Unlocks implements UnlockRepository {
  final granted = <(FeatureKey, DateTime?)>[];

  @override
  Future<Unlock> grant(
    FeatureKey key, {
    required UnlockSource source,
    DateTime? expiresAt,
  }) async {
    granted.add((key, expiresAt));
    return Unlock(
      id: 'u${granted.length}',
      featureKey: key,
      source: source,
      createdAt: DateTime.utc(2026),
      expiresAt: expiresAt,
    );
  }

  @override
  Stream<List<Unlock>> watchLive() => const Stream.empty();

  @override
  Future<void> revoke(String unlockId) async {}

  @override
  Future<bool> consumeOne(FeatureKey key) async => false;
}

/// PRM-02 Rewarded unlock prompt (feature 009 T063, T064, T127; spec US2,
/// FR-027 – FR-031, FR-053). "Now" is 2026-10-22 12:00 local.
void main() {
  final now = DateTime(2026, 10, 22, 12);
  late FakeAdService ads;
  late FakeSettingsRepository settings;
  late _Unlocks unlocks;
  late int grants;
  late bool? result;

  setUp(() {
    ads = FakeAdService();
    settings = FakeSettingsRepository();
    unlocks = _Unlocks();
    grants = 0;
    result = null;
  });

  Future<void> countGrant() async => grants++;

  Future<void> pump(
    WidgetTester tester, {
    FeatureKey key = FeatureKey.advancedReports,
    Duration? duration,
    bool customGrant = true,
    String? subjectName,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => Scaffold(
            body: Center(
              child: Builder(
                builder: (context) => TextButton(
                  key: const Key('open'),
                  onPressed: () async {
                    result = await showRewardedUnlock(
                      context,
                      key,
                      duration: duration,
                      grant: customGrant ? countGrant : null,
                      subjectName: subjectName,
                    );
                  },
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/premium',
          builder: (context, state) => const Text('PREMIUM'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          adServiceProvider.overrideWithValue(ads),
          rewardedUnlockPresenterProvider.overrideWithValue(
            const PremiumRewardedUnlockPresenter(),
          ),
          settingsRepositoryProvider.overrideWithValue(settings),
          unlockRepositoryProvider.overrideWithValue(unlocks),
          clockProvider.overrideWithValue(Clock.fixed(now)),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> open(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('open')));
    await tester.pumpAndSettle();
  }

  Finder watch() => find.byKey(const Key('rewarded_watch'));

  Future<void> tapWatch(WidgetTester tester) async {
    await tester.tap(watch());
    await tester.pumpAndSettle();
  }

  testWidgets('US2-1 the sheet says what the user gets, with "Watch a short '
      'ad", "Get Pro instead", and "Not now"; no ad plays before the tap', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    expect(find.text('Unlock advanced reports for 24 hours'), findsOneWidget);
    expect(find.byKey(const Key('rewarded_explanation')), findsOneWidget);
    expect(find.text('Watch a short ad'), findsOneWidget);
    expect(find.text('Get Pro instead'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
    expect(ads.prepareCalls, 1, reason: 'one rewarded ad loads on open');
    expect(ads.rewardedShows, 0);
  });

  testWidgets('US2-3 watching to the reward grants once and closes with '
      'true', (tester) async {
    await pump(tester);
    await open(tester);
    await tapWatch(tester);
    expect(grants, 1);
    expect(result, isTrue);
    expect(find.text('Watch a short ad'), findsNothing);
  });

  group('PRM-02 AC closing the ad early grants nothing', () {
    testWidgets('an early close writes nothing, keeps the sheet open with '
        '"Watch the whole ad to unlock", and loads a new ad', (tester) async {
      ads.rewardedOutcomes.add(RewardedOutcome.closedEarly);
      await pump(tester, customGrant: false);
      await open(tester);
      await tapWatch(tester);
      expect(grants, 0);
      expect(unlocks.granted, isEmpty);
      expect(result, isNull, reason: 'the sheet is still open');
      expect(find.text('Watch the whole ad to unlock'), findsOneWidget);
      expect(ads.prepareCalls, 2);
      expect(settings.current.rewardedCounts, isEmpty);
    });

    testWidgets('then watching the whole ad unlocks', (tester) async {
      ads.rewardedOutcomes.add(RewardedOutcome.closedEarly);
      await pump(tester);
      await open(tester);
      await tapWatch(tester);
      expect(grants, 0);
      await tapWatch(tester);
      expect(grants, 1);
      expect(result, isTrue);
    });

    testWidgets('closing early again and again still grants nothing', (
      tester,
    ) async {
      ads.rewardedOutcomes.addAll([
        RewardedOutcome.closedEarly,
        RewardedOutcome.closedEarly,
        RewardedOutcome.closedEarly,
      ]);
      await pump(tester);
      await open(tester);
      for (var i = 0; i < 3; i++) {
        await tapWatch(tester);
      }
      expect(grants, 0);
      await tester.tap(find.byKey(const Key('rewarded_not_now')));
      await tester.pumpAndSettle();
      expect(result, isFalse);
      expect(grants, 0);
    });

    testWidgets('a failed show grants nothing and offers "Try again"', (
      tester,
    ) async {
      ads.rewardedOutcomes.add(RewardedOutcome.failed);
      await pump(tester);
      await open(tester);
      await tapWatch(tester);
      expect(grants, 0);
      expect(find.text('Ad not available, try again later'), findsOneWidget);
      expect(find.byKey(const Key('rewarded_try_again')), findsOneWidget);
    });
  });

  testWidgets('US2-2 no ad within 8 seconds → "Ad not available, try again '
      'later"; Try again loads once more', (tester) async {
    ads.rewardedReady = null;
    await pump(tester);
    await tester.tap(find.byKey(const Key('open')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<ButtonStyleButton>(watch()).onPressed, isNull);
    final spinner = find.byType(CircularProgressIndicator);
    expect(spinner, findsOneWidget);
    expect(
      tester.widget<CircularProgressIndicator>(spinner).semanticsLabel,
      'Loading ad',
    );
    await tester.pump(const Duration(seconds: 8));
    await tester.pumpAndSettle();
    expect(find.text('Ad not available, try again later'), findsOneWidget);
    ads.rewardedReady = true;
    await tester.tap(find.byKey(const Key('rewarded_try_again')));
    await tester.pumpAndSettle();
    expect(ads.prepareCalls, 2);
    expect(watch(), findsOneWidget);
  });

  testWidgets('US2-10 "Not now" closes with false and grants nothing', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('rewarded_not_now')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(grants, 0);
    expect(ads.rewardedShows, 0);
  });

  testWidgets('US2-9 "Get Pro instead" closes with false and opens PRM-01', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    await tester.tap(find.byKey(const Key('rewarded_get_pro')));
    await tester.pumpAndSettle();
    expect(result, isFalse);
    expect(find.text('PREMIUM'), findsOneWidget);
  });

  testWidgets('FR-046 a double tap shows one ad', (tester) async {
    await pump(tester);
    await open(tester);
    await tester.tap(watch());
    await tester.tap(watch(), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(ads.rewardedShows, 1);
    expect(grants, 1);
  });

  testWidgets('FR-031 the default grant writes 24 hours of advanced reports '
      'from the effective now, even with the clock moved back', (tester) async {
    final seen = now.add(const Duration(hours: 5)).toUtc();
    settings = FakeSettingsRepository(
      initial: AppSettings(latestSeenAt: seen.millisecondsSinceEpoch),
    );
    await pump(tester, customGrant: false, duration: const Duration(hours: 24));
    await open(tester);
    await tapWatch(tester);
    final (key, expires) = unlocks.granted.single;
    expect(key, FeatureKey.advancedReports);
    expect(expires, seen.add(const Duration(hours: 24)));
  });

  testWidgets('FR-031 a theme reward is permanent', (tester) async {
    await pump(
      tester,
      key: FeatureKey.premiumTheme('saffron'),
      customGrant: false,
      subjectName: 'Saffron',
    );
    await open(tester);
    expect(find.text('Unlock the Saffron theme for good'), findsOneWidget);
    await tapWatch(tester);
    expect(unlocks.granted.single, (FeatureKey.premiumTheme('saffron'), null));
  });

  group('FR-053 at most 10 rewards per feature per local day', () {
    AppSettings withCounts(Map<String, int> counts, {String? day}) =>
        AppSettings(rewardedDay: day ?? '2026-10-22', rewardedCounts: counts);

    testWidgets('an earned reward is counted for its feature today', (
      tester,
    ) async {
      await pump(tester);
      await open(tester);
      await tapWatch(tester);
      expect(settings.current.rewardedDay, '2026-10-22');
      expect(settings.current.rewardedCounts, {'advancedReports': 1});
    });

    testWidgets('at 10 today: no ad loads; only Get Pro and Not now', (
      tester,
    ) async {
      settings = FakeSettingsRepository(
        initial: withCounts({'advancedReports': 10}),
      );
      await pump(tester);
      await open(tester);
      expect(find.byKey(const Key('rewarded_limit')), findsOneWidget);
      expect(watch(), findsNothing);
      expect(ads.prepareCalls, 0);
      expect(find.text('Get Pro instead'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);
    });

    testWidgets('other features are not limited', (tester) async {
      settings = FakeSettingsRepository(
        initial: withCounts({'advancedReports': 10}),
      );
      await pump(tester, key: FeatureKey.exportPdf);
      await open(tester);
      expect(find.byKey(const Key('rewarded_limit')), findsNothing);
      expect(watch(), findsOneWidget);
    });

    testWidgets("yesterday's count does not block today", (tester) async {
      settings = FakeSettingsRepository(
        initial: withCounts({'advancedReports': 10}, day: '2026-10-21'),
      );
      await pump(tester);
      await open(tester);
      expect(watch(), findsOneWidget);
      await tapWatch(tester);
      expect(settings.current.rewardedCounts, {'advancedReports': 1});
    });

    testWidgets('a clock moved back to yesterday cannot start a fresh day', (
      tester,
    ) async {
      // The latest time ever seen is tomorrow (2026-10-23), so "today" for
      // the limit is still 2026-10-23 although the clock says the 22nd.
      final tomorrow = DateTime(2026, 10, 23, 9).toUtc();
      settings = FakeSettingsRepository(
        initial: AppSettings(
          latestSeenAt: tomorrow.millisecondsSinceEpoch,
          rewardedDay: '2026-10-23',
          rewardedCounts: const {'advancedReports': 10},
        ),
      );
      await pump(tester);
      await open(tester);
      expect(find.byKey(const Key('rewarded_limit')), findsOneWidget);
    });
  });

  testWidgets('Pro bought while the sheet is open closes it with true', (
    tester,
  ) async {
    await pump(tester);
    await open(tester);
    settings.replace(settings.current.copyWith(removeAdsPurchased: true));
    await tester.pumpAndSettle();
    expect(result, isTrue);
    expect(grants, 0);
  });
}
