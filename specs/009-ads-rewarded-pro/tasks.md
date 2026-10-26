---

description: "Task list for Ads, Rewarded Unlocks, and Pro Purchase (§11, PRM-01, PRM-02, T4.1–T4.5)"
---

# Tasks: Ads, Rewarded Unlocks, and Pro Purchase (§11, PRM-01, PRM-02, T4.1–T4.5)

**Input**: Design documents from `specs/009-ads-rewarded-pro/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and spec §13 require:
- At least one automated test per copied acceptance criterion:
  - §11 ×3, DSH-01, EXP-01, EXP-02, EXP-11, SET-03, SYS-01, PRM-01 ×2, PRM-02 ×2
  - the full map is in [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests)
- Unit tests for the ad frequency cap.
- Widget tests with fakes and `NoAdsService`.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US5). Test names start with the
Screen ID or area and the scenario, e.g. `PRM-02 US2-4 early close keeps the sheet open`
(Constitution I).

**Constitution**: 1.0.3 (amended 2026-10-22: the ad-behavior test exception in IV, and "ad-free
day" dropped from VI). No prerequisite remains.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`. The Kotlin root is
  `android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/` (written `<kt>/` below).
- **Strings**:
  - Add keys to `tool/l10n/phase0_strings.py` (en, hi, gu together), then run
    `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit ARB files by hand.
  - Use sentence case, start buttons with a verb, and use ICU placeholders, never concatenation.
  - Prefixes: `ads_`, `premium_`, `rewarded_`, `locked_`, `privacy_` (research R19).
- **Codegen**: after changing any `@riverpod` or `@freezed` file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: read time only from `clockProvider` or an injected `Clock`. Never call `DateTime.now()`
  (scan-enforced). Cap and expiry math uses `effectiveNow` from `lib/core/utils/effective_clock.dart`.
- **Layering** (scan-enforced from T006):
  - `package:google_mobile_ads` only under `lib/core/ads/data/`.
  - `package:in_app_purchase*` only under `lib/core/billing/data/`.
  - `lib/core/ads/domain/**` and `lib/core/billing/domain/**` import no `package:flutter/`,
    Riverpod, or plugins.
  - `lib/features/premium/` imports no other feature, and no other feature imports it.
  - Screens use only `AppBannerAd`, `AppNativeAd`, `AdService` (via `adServiceProvider`), and
    `showRewardedUnlock` (contracts/services.md §13).
- **Ads in widget tests**:
  - `pumpTestApp` keeps `NoAdsService` by default.
  - Use `FakeAdService`, `FakeConsentService`, `FakeProStore`, `FakeRewardedUnlockPresenter`, and
    `FakeAdScreenProbe` from `test/helpers/fakes.dart` only where ad or Pro behavior is under test.
- **Never commit** a `ca-app-pub-` id other than Google's test publisher `3940256099942544`
  (SC-010).
- **Keys**: use the widget keys from contracts/screens.md exactly.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, guidance, and scans that every story relies on.

- [X] T001 Add `google_mobile_ads: 9.2.0`, `in_app_purchase: 3.3.1`, and `in_app_purchase_android` (the version `in_app_purchase` resolves, pinned exactly) to `dependencies` in `pubspec.yaml`. Run `flutter pub get` and commit `pubspec.lock` (research R1). If 9.2.0 fails to build, use `9.1.0` and note it in research R1.
- [ ] T002 [P] Update `docs/CLAUDE.md`:
  - Ads section: `google_mobile_ads` only in `lib/core/ads/data/`; screens use `AppBannerAd`, `AppNativeAd`, `AdService`, `showRewardedUnlock`.
  - New Billing bullet: `in_app_purchase` only in `lib/core/billing/data/`.
  - PRM-01 and PRM-02 live in `lib/features/premium/`.
  - The interstitial cap and unlock expiry are pure domain logic with an injected clock (research R16).
- [ ] T003 [P] Create empty folders with a `.gitkeep`, to be removed once real files land: `lib/core/ads/domain/`, `lib/core/ads/data/`, `lib/core/ads/widgets/`, `lib/core/billing/domain/`, `lib/core/billing/data/`, `lib/features/premium/presentation/screens/`, `lib/features/premium/presentation/controllers/`, `test/core/ads/{domain,data,widgets}/`, `test/core/billing/`, `test/features/premium/`.
- [X] T004 [P] Add the shared strings to `tool/l10n/phase0_strings.py`, then regenerate:
  - `ads_badge` ("Ad")
  - `ads_bannerLabel` ("Advertisement")
  - `locked_watchAd` ("Watch an ad")
  - `locked_getPro` ("Get Pro")

  Story-specific strings are added in their stories.

### Layering scans (write first, expect them to fail until later tasks land)

- [X] T005 In `test/core/theme/no_hardcoded_style_test.dart`, relax the 003 scan "(e) the expense feature never imports ad code (FR-038)" to "(e) the expense feature never imports `lib/core/ads/data/` or `package:google_mobile_ads`" and update its comment (plan Complexity Tracking).
- [ ] T006 In `test/core/theme/no_hardcoded_style_test.dart`, add a `// --- 009-ads-rewarded-pro ---` group with these scans:
  - (a) `package:google_mobile_ads` only under `lib/core/ads/data/`
  - (b) `package:in_app_purchase` and `package:in_app_purchase_android` only under `lib/core/billing/data/`
  - (c) `lib/core/ads/domain/**` and `lib/core/billing/domain/**` import no `package:flutter/`, `package:riverpod`, `package:flutter_riverpod`, or plugins
  - (d) `lib/features/premium/**` imports no `package:dailytrack/features/` path outside `features/premium/`
  - (e) no file outside `lib/features/premium/` and `lib/app/` imports `features/premium/`
  - (f) no feature imports `lib/core/ads/data/` or `lib/core/billing/data/`

**Checkpoint**: Packages resolve; scans exist.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Shared types, settings keys, the effective clock, the pure unlock policy, ad and Pro
providers, the `/premium` route, and test fakes. Every story needs these.

**⚠️ CRITICAL**: No user story work can begin until this phase is complete.

### Tests for Foundational ⚠️

- [X] T007 [P] Write `test/core/utils/effective_clock_test.dart`. `effectiveNow(clockNow, latestSeenAtMs)` returns the later of the two in UTC, returns `clockNow` when `latestSeenAtMs` is null, and handles a clock moved back by 2 days.
- [X] T008 [P] Write `test/core/feature_gate/unlock_policy_test.dart` for `UnlockPolicy.evaluate` (research R12, data-model §3), using `Clock.fixed` and `MutableClock`:
  - `proOwned` unlocks `advancedReports`, `exportCsv`, `exportPdf`, `premiumTheme_saffron`, and `streakFreeze` with `nextExpiryMs == null`
  - `adFreeDay` is never unlocked, even with Pro, debug, or a stored row (FR-035)
  - the debug switch unlocks only when `debugUnlockAll` is passed true
  - a row expiring at exactly effective now is locked; one expiring 1 ms later is unlocked, with `nextExpiryMs` set
  - a permanent row is unlocked
  - PRM-02 AC: with `latestSeenAt` 25 h after `createdAt` and the clock moved back to 1 h after `createdAt`, a 24 h unlock stays expired
  - of several live rows, the latest expiry is reported
- [ ] T009 [P] Extend `test/core/feature_gate/drift_feature_gate_test.dart` (create it if missing, using `makeRealContainer`):
  - with `removeAdsPurchased = true` in settings, `watch(FeatureKey.premiumTheme('ocean'))` emits `true`
  - flipping it to false emits `false`
  - PRM-02 AC "expiry is respected after app restart": a new gate over the same DB after expiry reports locked
- [X] T009a [P] Extend `test/core/feature_gate/drift_feature_gate_test.dart`: with `removeAdsPurchased = true` and `proRemovalPending = true`, `watch(FeatureKey.premiumTheme('ocean'))` stays `true` for the whole session and never emits `false` (clarification Q1 edge case: locks return only from the next cold start; analysis I1).
- [X] T010 [P] Write `test/core/settings/settings_ads_pro_keys_test.dart` (real Drift):
  - round-trips the 8 new keys plus `removeAdsPurchased` and `adConsentStatus` through `SettingsRepositoryImpl`. The new keys are `proNotOwnedStreak` (int 0–2), `proPurchasePending` (bool), `proRemovalPending` (bool), `adsInstallAt`, `adsLastInterstitialAt`, `adsInterstitialDay` (`yyyy-MM-dd`), `adsInterstitialsToday`, and `adsLastSessionDay`
  - `setProState` writes owned, streak, pending, and removalPending in one transaction
  - FR-025: none of the keys is in `BackupSettingsPolicy.restorableKeys`, and `BackupSettingsPolicy.exportable` drops them
- [X] T011 [P] Extend `test/core/reset/drift_app_reset_service_test.dart`: after `eraseAll`, `adsInstallAt` keeps its earlier value; `adsLastInterstitialAt`, `adsInterstitialsToday`, `removeAdsPurchased`, `proNotOwnedStreak`, and every unlock row are gone (spec edge case, research R9).
- [X] T012 [P] Write `test/core/ads/providers/ads_allowed_test.dart` (ProviderContainer, `FakeSettingsRepository`). `adsAllowedProvider` is true only when `removeAdsPurchased == false` and `AdsSessionGate` was set true. Flipping `removeAdsPurchased` to true makes it false. Flipping it back to false does **not** make it true again unless the gate is true (Pro removal takes effect from the next cold start, clarification Q1). `adServiceProvider` default is `NoAdsService`.

### Implementation for Foundational

- [X] T013 [P] Create `lib/core/utils/effective_clock.dart`: `DateTime effectiveNow(DateTime clockNow, int? latestSeenAtMs)`, which returns the later of the two as UTC (data-model §3). Make T007 pass.
- [X] T014 [P] Create the pure types in `lib/core/ads/domain/`:
  - `ad_config.dart`: `AdConfig` const with `installAgeDays 2`, `minGap 3 min`, `maxPerDay 4`, `savesPerInterstitial 4`, `sessionGap 30 min`, `rewardedTimeout 8 s`, `retryBackoff [30 s, 60 s, 120 s]`, `afterCloseDelay 400 ms`, `consentUpdateTimeout 5 s`, `nativeFirstRow 8`, `nativeEvery 15`, `nativeMaxPerLoad 3`, `habitsNativeMinCards 5`, `habitsNativeAfter 4`, and `static const defaults`
  - `ad_trigger.dart`: sealed `AdTrigger` with `ExpenseSaved({required bool screenClosing})`, `HabitCreated()`, `ManualBackupSucceeded()`
  - `rewarded_outcome.dart`: `enum RewardedOutcome { earned, closedEarly, notReady, failed }`
  - `ad_placement.dart`: `enum NativePlacement { home, transactions, budgets, habits }`
- [X] T015 [P] Create `lib/core/ads/ad_view.dart` with `abstract interface class AdView { double get height; Widget build(BuildContext context); void dispose(); }` and `NativeAdLook` (surface, onSurface, primary, onPrimary, corner radius, and title/body text styles) (contracts/services.md §1).
- [X] T016 Rewrite `lib/core/ads/ad_service.dart` to the contracts/services.md §1 interface:
  - members: `init()`, renamed from `initialize()`; `adsEnabled`; `adsEnabledStream`; `loadBanner({required double width})`; `loadNative(NativePlacement, NativeAdLook)`; `preloadInterstitial()`; `maybeShowInterstitial(AdTrigger)`; `prepareRewarded()`; `showRewarded(FeatureKey, {required Future<void> Function() onEarned})`; `dispose()`
  - `NoAdsService`: loads return `null`, `prepareRewarded` returns `false`, `showRewarded` returns `RewardedOutcome.notReady` and never calls `onEarned`, `adsEnabledStream` is `Stream.value(false)`
  - update the stale comment ("arrive in T4.x")
  - rename the call in `lib/app/bootstrap.dart` to `init()`
- [X] T017 [P] Add the settings keys in `lib/core/settings/`. Make T010 pass.
  - `data/settings_codec.dart`: constants and decoding for `proNotOwnedStreak` (int clamped 0–2, default 0), `proPurchasePending` (bool, default false), `proRemovalPending` (bool, default false), `adsInstallAt`, `adsLastInterstitialAt`, `adsInterstitialDay`, `adsInterstitialsToday` (int ≥ 0, default 0), and `adsLastSessionDay`
  - `domain/app_settings.dart`: freezed fields with doc comments
  - `domain/settings_repository.dart` and `data/settings_repository_impl.dart`: `setProState({required bool owned, required int notOwnedStreak, required bool pending, bool removalPending = false})` (one transaction), `setAdConsentStatus(String)`, `setAdsInstallAt(int)`, `recordInterstitialShown({required int at, required String dayKey, required int countToday})`, `setAdsLastSessionDay(String)`, `resetAdCounters({required int installAt})`
  - mirror all of them in `FakeSettingsRepository` in `test/helpers/fakes.dart`
- [X] T018 Update `lib/core/reset/data/drift_app_reset_service.dart` so the erase transaction reads the `adsInstallAt` row before deleting and re-inserts it in the same transaction. Make T011 pass.
- [X] T019 Create `lib/core/feature_gate/domain/unlock_policy.dart`: a pure `UnlockPolicy.evaluate(FeatureKey key, List<Unlock> unlocks, {required int effectiveNowMs, required bool debugUnlockAll, required bool proOwned})` → `UnlockDecision {bool unlocked, int? nextExpiryMs}`.
  - Order of checks: `adFreeDay` → locked; then Pro; then debug; then rows (research R12).
  - Refactor `lib/core/feature_gate/data/drift_feature_gate.dart` to delegate to it, passing `proOwned: settings.removeAdsPurchased` and `debugUnlockAll: debugToolsAvailable && settings.debugUnlockAll`, and computing effective now with `effectiveNow`.
  - Keep the `latestSeenAt` raising and the expiry timer.
  - Make T008 and T009 pass.
- [X] T020 Extend `lib/core/ads/ad_providers.dart` (contracts/services.md §2). Make T012 pass.
  - `adConfigProvider` (returns `AdConfig.defaults`)
  - `AdsSessionGate` notifier (`build() => false`, `startedWithAds(bool)`)
  - `adsAllowedProvider` (`!removeAdsPurchased` from `appSettingsProvider` && gate)
  - `adServiceProvider` (default `NoAdsService`; the composition root binds the switch in US1)
- [X] T021 [P] Create `lib/core/billing/billing_providers.dart` with `@Riverpod(keepAlive: true) Stream<bool> proOwned(Ref ref)` mapped from `appSettingsProvider` → `removeAdsPurchased`, distinct. Run codegen.
- [X] T022 Add the route and a skeleton screen:
  - `static const String premium = '/premium';` in `lib/app/router/routes.dart`
  - a root-navigator `GoRoute` with `fullscreenDialog: true` in `lib/app/router/app_router.dart` (contracts/routes.md)
  - skeleton `lib/features/premium/presentation/screens/premium_screen.dart`: an `AppScaffold` with a close button, the headline `premium_title` ("DailyTrack Pro"), and the five benefit rows (`premium_benefitNoAds`, `premium_benefitThemes`, `premium_benefitReports`, `premium_benefitExports`, `premium_benefitFreezes`), each an icon plus text; add those strings
  - US3 completes the screen
- [X] T023 Add a `watchAdLabel` (String?) parameter to `lib/core/widgets/locked_feature_overlay.dart`, defaulting to `l10n.locked_watchAd`, and rewrite the class comment: both actions are now supplied by callers, and "Get Pro" opens PRM-01. Keep `onGetPro: null` → disabled for backward compatibility in tests only.
- [X] T024 [P] Add the test fakes to `test/helpers/fakes.dart`:
  - `FakeAdService`: records `init`, `loadBanner`, `loadNative`, `preloadInterstitial`, `maybeShowInterstitial` (with triggers), `prepareRewarded`, and `showRewarded` calls; scripted `bannerResult`/`nativeResult` (a `FakeAdView` with a given height, or null); `prepareResult`; an `outcomes` queue that calls `onEarned` for `earned`
  - `FakeAdView`
  - `FakeConsentService`
  - `FakeAdScreenProbe`
  - `FakeRewardedUnlockPresenter` (scripted bool, records requests)
  - `FakeProStore`: a controllable `purchaseUpdates` stream, plus `product`, `ownership`, and `available` fields
- [X] T025 [P] Add `test/helpers/test_app.dart` parameters `consent`, `proStore`, `rewardedPresenter`, and `probe`, defaulting to the fakes, and override the matching providers. `ads` keeps defaulting to `const NoAdsService()`.

**Checkpoint**: Foundation ready. The gate honors Pro, the new keys persist, `/premium` opens, and
the fakes exist.

---

## Phase 3: User Story 1 - Ads that respect consent and never get in the way (Priority: P1) 🎯 MVP

**Goal**:
- UMP consent runs before the SDK starts.
- Banners appear on the 10 listed screens and natives on DSH-01, EXP-01, EXP-08, and HAB-01.
- Every ad is 0 dp until loaded, animates in, retries, and is disposed.
- "Ad privacy choices" appears when required.
- Dev and debug use Google test IDs.

**Independent Test**: On a dev build with `UMP_DEBUG_GEOGRAPHY=eea`, the consent form appears
before any ad request. Each listed screen then shows its placements with the "Ad" badge, slots
collapse on failure, and no content moves under a touch (quickstart §4.1).

### Tests for User Story 1 ⚠️

- [X] T026 [P] [US1] Write `test/core/ads/domain/ad_unit_ids_test.dart` (research R3), test-ID path only:
  - `AdUnitIds.test` holds the four public test IDs from research R3
  - `resolve(isProd: false, …)` and `resolve(isRelease: false, …)` always return `AdUnitIds.test`, even when `fromEnv` has values (US5-1, FR-004)
- [X] T027 [P] [US1] Write `test/core/ads/domain/native_ad_slots_test.dart`:
  - `nativeAdRowIndexes(40) == [8, 23, 38]`
  - `(8) == []`, `(9) == [8]`, `(23) == [8]`, `(24) == [8, 23]`
  - `(100)` is capped at 3 entries
  - `(0) == []`
- [ ] T028 [P] [US1] Write `test/core/ads/data/admob_ad_service_test.dart` using a `FakeAdsSdk` (the seam from T041):
  - §11 AC: no `loadBanner`, `loadNative`, interstitial, or rewarded load reaches the SDK while `canRequestAds` is false or before `init()` completed
  - after `init()` with consent, `loadBanner(width: 360)` requests the large anchored adaptive size for 360
  - `dispose()` releases preloaded ads, and later loads return null
  - no request carries keywords or a content URL (FR-010)
  - a `null` unit ID for a format means no request and `null` returned (US5-4)
- [ ] T029 [P] [US1] Write `test/core/ads/data/ump_consent_service_test.dart` against a `FakeConsentSdk` seam:
  - `gather` calls `beforeForm` only when a form will show
  - a timeout or error returns the stored `canRequestAds` without throwing
  - `privacyOptionsRequired` reflects the SDK status
  - dev debug geography is applied only when `isProd == false`
- [X] T030 [P] [US1] Write `test/app/bootstrap_ads_test.dart` (R4, contracts/services.md §12):
  - **consent already allowed**: `AdsSessionGate` is true, `init()` is called without awaiting `gather`, and `gather` still runs once in the background
  - **consent unknown**: `gather` is awaited before `init()`; `beforeForm` removes the splash; `init()` is never called when the result is `canRequestAds == false`
  - **SYS-01 AC "Ads SDK is not initialized when Remove Ads is purchased"**: with `removeAdsPurchased = true` cached, neither `gather` nor `init()` is called and the gate is false
  - **consent throws or offline**: bootstrap still returns `BootstrapReady`
- [ ] T031 [P] [US1] Write `test/core/ads/widgets/app_banner_ad_test.dart` (`FakeAdService`, `fakeAsync`):
  - **US1-12 and FR-007**: height is 0 before load and on a null load; retries happen at 30, 60, and 120 s, then stop
  - **US1-5**: on load, `AnimatedSize` grows to `FakeAdView.height` + 8 dp in 200 ms, and in 0 ms with `disableAnimations`
  - **US1-13**: unmount disposes the view; switching `adServiceProvider` to `NoAdsService` disposes it and height returns to 0
  - semantics label "Advertisement"
  - FR-008: with a FAB on the scaffold, the vertical gap between the loaded banner and the FAB's bounds is ≥ 8 dp (`tester.getRect`)
- [ ] T032 [P] [US1] Write `test/core/ads/widgets/app_native_ad_test.dart`:
  - the same 0 dp, animate, retry, and dispose cases as T031
  - **US1-11**: the "Ad" badge text (`ads_badge`) is top-left inside the card header, styled `labelSmall` on `AppTokens.adBadge`, and the card uses the app card shape
  - the 12 dp margin appears only when loaded
  - **§11 AC "With `NoAdsService`, no ad widget occupies any space"**: both widgets under `NoAdsService` measure `Size(w, 0)`
- [X] T033 [P] [US1] Write `test/features/dashboard/home_native_ad_test.dart`:
  - **DSH-01 AC**: with 2 module cards, `home_native` sits after `home_card_habit` and before the sections
  - with only Expense enabled, it sits after `home_card_expense`
  - with no module cards, there is no ad
  - it never appears above the first module card
  - with `NoAdsService` the slot is 0 dp
  - FR-008: the loaded `home_native` rect is ≥ 8 dp from the quick-add FAB rect after scrolling it into view
- [ ] T034 [P] [US1] Write `test/features/expense/transactions_native_ads_test.dart`:
  - with 40 rows across several days, `transactions_native_0..2` sit after global rows 8, 23, and 38, even when row 8 is mid-day (the day group is split and both parts keep `itemExtent`)
  - with 8 rows there are none
  - no natives in skeleton, empty, "No matches", or error states
  - **EXP-01 AC**: changing the period updates the list, totals, and ad slots without leaving the screen (the ad keys change with the period)
- [ ] T035 [P] [US1] Write `test/features/expense/budgets_native_ad_test.dart` (`budgets_native` at the end of the content list when budgets exist; none in the empty state) and `test/features/habit/habits_native_ad_test.dart` (`habits_native` after the 4th scheduled card with 5 scheduled habits; none with 4; none in Reorder mode; FR-008: the loaded ad rect is ≥ 8 dp from the check button rects of cards 4 and 5 and never shares a row with a check button).
- [X] T036 [P] [US1] Write `test/core/ads/ad_placements_scan_test.dart` (US1-6, FR-009, FR-015): scan `lib/` for `AppBannerAd(` and `AppNativeAd(` uses and assert the files match exactly the contracts/screens.md placement table. In particular, `transaction_form_screen.dart`, `habit_form_screen.dart`, the `lock/` and `onboarding/` features, `premium_screen.dart`, and `rewarded_unlock_sheet.dart` have none.
- [X] T037 [P] [US1] Write `test/features/settings/settings_ad_privacy_test.dart` (US1-4, FR-014, SET-01 AC "'Ad privacy choices' is visible whenever the UMP SDK reports a privacy options requirement"):
  - `ad_privacy_choices` is shown when `FakeConsentService.privacyOptionsRequired` emits true and Pro is not owned
  - it is hidden when false or when Pro is owned
  - tapping it calls `showPrivacyOptionsForm()` once

### Implementation for User Story 1

- [X] T038 [P] [US1] Create `lib/core/ads/domain/ad_unit_ids.dart` with `AdUnitIds {String? banner, native, interstitial, rewarded}`, `static const test` (the four IDs in research R3), `static const none`, `fromEnvironment()` (`ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID`; empty → null), and `resolve({required bool isProd, required bool isRelease, required bool manifestUsesTestAppId, required AdUnitIds fromEnv})` per research R3. Make T026 pass.
- [X] T039 [P] [US1] Create `lib/core/ads/domain/native_ad_slots.dart`: `List<int> nativeAdRowIndexes(int rowCount, {int first = 8, int every = 15, int max = 3})`, which returns the indexes `i` with `i < rowCount`. Make T027 pass.
- [X] T040 [P] [US1] Create `lib/core/ads/domain/consent_service.dart`: the `ConsentService` interface and `ConsentResult {bool canRequestAds, bool privacyOptionsRequired, String status}` (contracts/services.md §5).
- [ ] T041 [US1] Create `lib/core/ads/data/ads_sdk.dart`:
  - `AdsSdk`, a thin seam over the plugin: `initialize()`, `updateRequestConfiguration(...)`, `loadBanner(unitId, size)`, `loadNative(unitId, templateStyle)`, `loadInterstitial(unitId)`, `loadRewarded(unitId)`, each returning handles with callbacks
  - `admob_ads_sdk.dart`, implementing it with `google_mobile_ads`: `AdSize.getLargeAnchoredAdaptiveBannerAdSize`, `NativeTemplateStyle(templateType: TemplateType.medium)`, `RequestConfiguration` with child-directed and under-age tags unspecified, and test device IDs from `UMP_TEST_DEVICE_ID` in dev only
  - add `FakeAdsSdk` to `test/helpers/fakes.dart`
- [X] T042 [US1] Create `lib/core/ads/data/admob_ad_views.dart`: the `AdView` implementations wrapping `AdWidget` for banners (height = ad size height) and for natives (a `ConstrainedBox` with min 320×320 and max height 400, research R7).
- [X] T043 [US1] Create `lib/core/ads/data/admob_ad_service.dart`: `AdMobAdService implements AdService`. It takes `AdsSdk`, `ConsentService`, `AdUnitIds`, `AdConfig`, and the clock. Make T028 pass.
  - `init()`: idempotent, swallows errors, sets `adsEnabled = consent.canRequestAds`
  - `loadBanner` and `loadNative`: null unless `adsEnabled` and the format's unit ID is non-null; no keywords or content URL
  - `dispose()`
  - `preloadInterstitial`, `maybeShowInterstitial`, `prepareRewarded`, and `showRewarded` are stubs that do nothing or return `notReady`; US2 and US4 fill them in
- [X] T044 [US1] Create `lib/core/ads/data/ump_consent_service.dart`: `UmpConsentService implements ConsentService` over a `ConsentSdk` seam (adapter over `ConsentInformation.instance` and `ConsentForm`). Make T029 pass.
  - `gather`: `requestConsentInfoUpdate` with `consentUpdateTimeout`, then `beforeForm()`, then `loadAndShowConsentFormIfRequired`; never throws
  - mirrors the status to `settings.setAdConsentStatus`
  - `privacyOptionsRequired` stream, refreshed after `gather` and `showPrivacyOptionsForm`
  - `showPrivacyOptionsForm`
  - dev-only `ConsentDebugSettings` from `UMP_DEBUG_GEOGRAPHY` (`eea` → `DebugGeography.debugGeographyEea`) and `UMP_TEST_DEVICE_ID`
  - `resetForDebug()`: calls `ConsentInformation.instance.reset()`
- [X] T045 [US1] Create `lib/core/ads/widgets/app_banner_ad.dart` (research R6, contracts/services.md §3). Make T031 pass.
  - a `ConsumerStatefulWidget` watching `adServiceProvider`
  - a `LayoutBuilder` width with a 500 ms debounce on change > 1 dp
  - a load/retry loop over `adConfig.retryBackoff` that stops on unmount or a service change
  - `AnimatedSize(duration: disableAnimations ? zero : 200 ms, curve: standard easing)`
  - `AppTokens.s8` top gap only when loaded
  - `Semantics(label: l10n.ads_bannerLabel)`
  - disposes its `AdView` on unmount and when the service changes
- [X] T046 [US1] Create `lib/core/ads/widgets/app_native_ad.dart` (research R7). Make T032 pass.
  - builds a `NativeAdLook` from the `ColorScheme`, `AppTokens` (card radius 16), and `TextTheme`
  - a `Card` with the app shape, holding a header row with the `ads_badge` text (`labelSmall`, background `AppTokens.adBadge`, 4/8 dp padding, top-left), then `AdView.build`
  - vertical margin `AppTokens.s12` only when loaded
  - the same 0 dp, animate, retry, and dispose behavior as T045
- [ ] T047 [US1] Create `lib/core/ads/data/admob_manifest_source.dart`. `Future<bool> usesTestAppId()` calls `getAdmobAppId` on the `dailytrack/window` channel and compares it to `ca-app-pub-3940256099942544~3347511713`. It returns true on any error. (First used by T117.)
- [ ] T048 [US1] Add `getAdmobAppId` to the `dailytrack/window` handler in `<kt>/MainActivity.kt`: read `packageManager.getApplicationInfo(packageName, PackageManager.GET_META_DATA).metaData?.getString("com.google.android.gms.ads.APPLICATION_ID")` and return it, or null (contracts/android.md). (First used by T117.)
- [X] T049 [US1] Edit `android/app/src/main/AndroidManifest.xml`. Inside `<application>`, add the `com.google.android.gms.ads.APPLICATION_ID` meta-data with `android:value="${admobAppId}"`, plus `com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION` and `…OPTIMIZE_AD_LOADING` set to `true` (contracts/android.md).
- [X] T050 [US1] Edit `android/app/build.gradle.kts`. Add `val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"` and `androidComponents { onVariants { v -> v.manifestPlaceholders.put("admobAppId", admobTestAppId) } }`. This gives the test App ID for every variant for now; US5 adds the prod value and the store check.
- [X] T051 [US1] Bind US1 in `lib/app/production_overrides.dart`:
  - `consentServiceProvider` → `UmpConsentService`
  - `adUnitIdsProvider` → `AdUnitIds.resolve(isProd: FlavorConfig.current.isProd, isRelease: kReleaseMode, manifestUsesTestAppId: true, fromEnv: AdUnitIds.none)`. In US1 this means test IDs in dev and debug builds and no ads in prod release. T117 replaces it with the real manifest check and `AdUnitIds.fromEnvironment()`.
  - `adServiceProvider` → `ref.watch(adsAllowedProvider) ? AdMobAdService(...) : const NoAdsService()`, with `ref.onDispose(service.dispose)`
  - add `adUnitIdsProvider` and `consentServiceProvider` declarations to `lib/core/ads/ad_providers.dart`
- [X] T052 [US1] Implement bootstrap step 3 in `lib/app/bootstrap.dart` (contracts/services.md §12, research R4). Make T030 pass.
  - if `removeAdsPurchased`: gate false, skip ads
  - else if `consent.canRequestAds`: gate true; `init()` unawaited; `gather` unawaited
  - else: await `gather(beforeForm: () async => FlutterNativeSplash.remove(), timeout: adConfig.consentUpdateTimeout)`, then gate = result, and `init()` unawaited when true
  - swallow every error
  - update the numbered doc comment
- [X] T053 [P] [US1] Place `bannerSlot: const AppBannerAd()` in the `AppScaffold` of `lib/features/expense/presentation/screens/transactions_screen.dart` (EXP-01), `transaction_detail_screen.dart` (EXP-03), `categories_screen.dart` (EXP-04), `accounts_screen.dart` (EXP-06), and `reports_screen.dart` (EXP-11). Update stale "No ads" comments.
- [X] T054 [P] [US1] Place `bannerSlot: const AppBannerAd()` in `lib/features/habit/presentation/screens/habits_today_screen.dart` (HAB-01), `habit_detail_screen.dart` (HAB-03), and `archived_habits_screen.dart` (HAB-04).
- [X] T055 [P] [US1] Place `bannerSlot: const AppBannerAd()` in `lib/features/settings/presentation/screens/settings_screen.dart` (SET-01) and `backup_screen.dart` (SET-02). Remove the "banner come in later features" note from the SET-01 class comment.
- [X] T056 [US1] Add the DSH-01 native in `lib/features/dashboard/presentation/screens/home_screen.dart`: insert `DashboardSlot(key: ValueKey('slot_native'), child: const AppNativeAd(key: Key('home_native'), placement: NativePlacement.home))` after the first `min(2, state.modules.length)` module-card slots and before the sections. Skip it when there are no module cards. Make T033 pass.
- [X] T057 [US1] Add the EXP-01 natives in `lib/features/expense/presentation/screens/transactions_screen.dart` (research R8). Make T034 pass.
  - compute `nativeAdRowIndexes(rows.length)` over the loaded, filtered rows (content state only)
  - in `_daySlivers`, split the `SliverFixedExtentList` of the day group that contains a slot index into two lists around a `SliverToBoxAdapter(AppNativeAd(key: Key('transactions_native_$n'), placement: NativePlacement.transactions))`
  - key the slivers by period and filter, so a period change rebuilds the ads
- [X] T058 [P] [US1] Add `AppNativeAd(key: Key('budgets_native'), placement: NativePlacement.budgets)` as the last child of the content `ListView` in `lib/features/expense/presentation/screens/budgets_screen.dart`, only in the non-empty state. Make the EXP-08 part of T035 pass.
- [X] T059 [P] [US1] Add `AppNativeAd(key: Key('habits_native'), placement: NativePlacement.habits)` after the 4th card in the scheduled list of `lib/features/habit/presentation/screens/habits_today_screen.dart`, only when `data.scheduled.length >= 5` and not in Reorder mode. Make the HAB-01 part of T035 pass.
- [X] T060 [US1] Add the "Ad privacy choices" row:
  - `consentService` → `privacyOptionsRequiredProvider` in `lib/core/ads/ad_providers.dart`, false while `proOwned`
  - an `ad_privacy_choices` `ListTile` in `lib/features/settings/presentation/widgets/privacy_section.dart`, shown only while that provider is true, calling `showPrivacyOptionsForm()`
  - string `privacy_adChoices` ("Ad privacy choices")
  - make T037 pass
- [X] T061 [US1] Run T036 and fix any extra or missing placement. Run the layering scans T005 and T006(a) and (f). Run `flutter analyze`.

**Checkpoint**: Consent and banner/native ads work end to end with test IDs; the MVP ships ads
safely.

---

## Phase 4: User Story 2 - Unlock a premium feature by watching a rewarded ad (Priority: P1)

**Goal**:
- PRM-02 sheet and `showRewardedUnlock()`.
- The grant runs only in `onUserEarnedReward`.
- An early close keeps the sheet open and reloads (Q5).
- Every locked state (EXP-11, HAB-03 chart and freeze card, SET-03, SET-04) is wired with "Watch
  an ad" and "Get Pro".

**Independent Test**: With `FakeAdService` scripted to earn, close early, fail, or time out, open
each locked state. The right unlock (key, duration, target) is written only on an earned reward,
the locked state clears immediately, and the expiry survives restart and clock rollback.

### Tests for User Story 2 ⚠️

- [ ] T062 [P] [US2] Extend `test/core/ads/data/admob_ad_service_test.dart` with rewarded cases:
  - `prepareRewarded` loads exactly one rewarded ad, only when `adsEnabled`
  - `showRewarded` calls `onEarned` only from the SDK's `onUserEarnedReward`, awaits it, then returns `earned`
  - a dismiss without a reward returns `closedEarly` and never calls `onEarned`
  - not prepared → `notReady`
  - a show failure → `failed`
  - `expectExternalActivity` is called before showing
- [X] T063 [P] [US2] Write `test/features/premium/rewarded_unlock_sheet_test.dart` with the real presenter and `FakeAdService`:
  - **US2-1**: icon, title per `RewardedOffer`, explanation, and the buttons `rewarded_watch`, `rewarded_getPro`, `rewarded_notNow`; no ad shown before the tap
  - **US2-2**: a spinner (semantics "Loading ad") until `prepareRewarded` completes; with no answer in 8 s (`fakeAsync`) or `false`, `rewarded_unavailable` "Ad not available, try again later" with Try again
  - **US2-3**: `earned` → the grant runs and the sheet pops `true`
  - **PRM-02 AC "Closing the ad early grants nothing"** (US2-4, Q5): `closedEarly` → no grant, the sheet stays open with `rewarded_closedEarly`, and `prepareRewarded` is called again
  - **US2-10**: "Not now" or swipe → `false`
  - **US2-9**: "Get Pro instead" → `false` and `/premium` pushed
  - Pro becoming owned while open → `true`
  - double-tapping Watch shows one ad (FR-046)
  - 200% font and a 360 dp width do not overflow
- [X] T064 [P] [US2] Write `test/core/ads/rewarded_unlock_test.dart` (`makeRealContainer` for unlocks):
  - the default grant for `advancedReports` with `duration: 24 h` writes a `rewardedAd` row expiring at effectiveNow + 24 h
  - `exportPdf` and `premiumTheme_rose` write permanent rows
  - a custom `grant` writes no row
  - `showRewardedUnlock` asserts on `FeatureKey.adFreeDay` (FR-035)
- [X] T065 [P] [US2] Write `test/features/expense/reports_locked_test.dart`:
  - **EXP-11 AC "Locked tabs show a blurred preview and a 'Watch an ad to unlock for 24 hours' button"**: the Trends tab shows `reports_locked` with that label and an enabled `locked_getPro`
  - the watch button calls `showRewardedUnlock(advancedReports, duration: 24h)` (`FakeRewardedUnlockPresenter`)
  - after a fake gate flip, the tab content shows without leaving the screen
  - Get Pro pushes `/premium`
- [X] T066 [P] [US2] Write `test/features/settings/export_rewarded_test.dart`:
  - **SET-03 AC "Cancelling the rewarded ad does not start the export"**: presenter `false` → no `ExportUseCase` call
  - presenter `true` → the export runs once for the selected format (`exportPdf` key requested)
  - with no mounted screen after the reward, no export starts
- [X] T067 [P] [US2] Write `test/features/settings/themes_rewarded_test.dart`:
  - tapping locked Saffron previews it behind `theme_preview_locked` and opens the presenter once with `premiumTheme_saffron`
  - `true` → `selectedTheme` is stored as `saffron`
  - `false` → the stored theme is unchanged and the overlay still shows "Watch an ad to unlock this theme" and Get Pro
- [X] T068 [P] [US2] Write `test/features/habit/freeze_card_rewarded_test.dart`:
  - free user with 0 freezes: `watch_ad_freeze` calls the presenter with `streakFreeze`, a `grant`, and the habit name; running the grant adds 1 freeze
  - with 2 freezes, `watch_ad_freeze` is disabled and the cap text shows (US2-8)
  - the weekly chart `weekly_chart_locked` wires `advancedReports`, 24 h
  - with the debug switch on, `add_freeze_debug` still shows
  - HAB-01 "Skip today" is unchanged

### Implementation for User Story 2

- [X] T069 [US2] Implement the rewarded part of `lib/core/ads/data/admob_ad_service.dart` (research R11). Make T062 pass.
  - `prepareRewarded()`: one `RewardedAd.load` through `AdsSdk`; replaces any stale one
  - `showRewarded(key, onEarned:)`: `notReady` if none; otherwise call `ExternalActivityGuard.expectExternalActivity()` (inject the guard), set `fullScreenContentCallback`, and `show(onUserEarnedReward: …)`, which runs and awaits `onEarned`; resolve `earned` when the reward fired before dismiss, `closedEarly` on dismiss without a reward, `failed` on a show error; dispose the ad afterwards
- [X] T070 [P] [US2] Create `lib/core/ads/rewarded_unlock.dart` (contracts/services.md §4):
  - `RewardedUnlockRequest`
  - the `RewardedUnlockPresenter` interface
  - `rewardedUnlockPresenterProvider` (throws unless overridden)
  - `showRewardedUnlock(context, key, {duration, grant, subjectName})`: asserts `key != FeatureKey.adFreeDay`; the default grant is `unlockRepository.grant(key, source: UnlockSource.rewardedAd, expiresAt: duration == null ? null : effectiveNow(clock, latestSeenAt) + duration)`; delegates to the presenter
  - make T064 pass
- [X] T071 [P] [US2] Create `lib/features/premium/presentation/rewarded_offers.dart`, mapping `FeatureKey` to `RewardedOffer {IconData icon, String Function(AppLocalizations, String?) title, explanation}`: `advancedReports`, `exportCsv`, `exportPdf`, `premiumTheme_*` (theme name placeholder), `streakFreeze` (habit name placeholder). Add the strings:
  - `rewarded_titleReports` "Unlock advanced reports for 24 hours"
  - `rewarded_titleCsv` "Unlock one CSV export"
  - `rewarded_titlePdf` "Unlock one PDF export"
  - `rewarded_titleTheme` "Unlock the {theme} theme for good"
  - `rewarded_titleFreeze` "Get 1 streak freeze for {habit}"
  - a one-line `rewarded_explain*` for each
- [X] T072 [US2] Create `lib/features/premium/presentation/controllers/rewarded_unlock_controller.dart` (+ freezed state). `RewardedUnlockController` is a family Notifier keyed by the request, with phases `loading | ready | unavailable | showing | closedEarly` (data-model §5).
  - `prepare()` races `adService.prepareRewarded()` against `adConfig.rewardedTimeout`
  - `watch()` (ignored unless `ready` or `closedEarly` with an ad ready) calls `adService.showRewarded(key, onEarned: request.grant)` and maps the outcome: `earned` → done(true), `closedEarly` → `closedEarly` + `prepare()`, else `unavailable`
  - it listens to `proOwnedProvider` and finishes `true` when it becomes owned
- [X] T073 [US2] Create `lib/features/premium/presentation/rewarded_unlock_sheet.dart` (contracts/screens.md PRM-02). Make T063 pass.
  - `PremiumRewardedUnlockPresenter implements RewardedUnlockPresenter`, which shows `AppBottomSheet` with `RewardedUnlockSheet`
  - layout: the 40 dp icon circle, title, explanation, the `rewarded_watch` `FilledButton` (spinner with semantics `rewarded_loadingAd` "Loading ad" while loading; label "Try again" when `unavailable`), the `rewarded_closedEarly` / `rewarded_unavailable` texts, the `rewarded_getPro` `OutlinedButton`, and the `rewarded_notNow` `TextButton`
  - pops a bool; "Get Pro instead" pops `false`, then `context.push(Routes.premium)`
  - add the remaining `rewarded_*` strings (`rewarded_watch` "Watch a short ad", `rewarded_getPro` "Get Pro instead", `rewarded_notNow` "Not now", `rewarded_unavailable`, `rewarded_closedEarly` "Watch the whole ad to unlock", `rewarded_tryAgain` "Try again")
- [X] T074 [US2] Bind `rewardedUnlockPresenterProvider` to `PremiumRewardedUnlockPresenter` in `lib/app/production_overrides.dart`.
- [X] T075 [US2] Wire EXP-11 in `lib/features/expense/presentation/screens/reports_screen.dart`. The `LockedFeatureOverlay` gets `watchAdLabel: l10n.locked_watchAdReports` ("Watch an ad to unlock for 24 hours"), `onWatchAd: () => showRewardedUnlock(context, FeatureKey.advancedReports, duration: const Duration(hours: 24))`, and `onGetPro: () => context.push(Routes.premium)`. Make T065 pass.
- [X] T076 [US2] Wire the HAB-03 weekly chart in `lib/features/habit/presentation/screens/habit_detail_screen.dart` the same way as T075, adding `key: Key('weekly_chart_locked')`.
- [X] T077 [US2] Update `lib/features/habit/presentation/widgets/freeze_card.dart` and `lib/features/habit/presentation/controllers/habit_detail_controller.dart` (contracts/screens.md freeze table):
  - new parameters `isPro` and `onWatchAd`
  - a `watch_ad_freeze` `FilledButton.tonal` "Watch an ad to get a freeze" (`locked_watchAdFreeze`) for free users, disabled at `maxFreezes` (2) with the existing `habit_freezeCapReached` text
  - `add_freeze_debug` kept when the switch is on
  - `onWatchAd` calls `showRewardedUnlock(context, FeatureKey.streakFreeze, grant: () => <habit repository>.addFreeze(habitId), subjectName: habit.name)`
  - update the class comment
  - make T068 pass
- [X] T078 [US2] Wire SET-03 in `lib/features/settings/presentation/screens/export_screen.dart`. On `export_locked`: `watchAdLabel: l10n.locked_watchAdExport` ("Watch an ad to unlock one export"), `onWatchAd`: `final ok = await showRewardedUnlock(context, state.format.featureKey); if (ok && context.mounted) controller.export();`, `onGetPro` → `/premium`. Make T066 pass.
- [X] T079 [US2] Wire SET-04 in `lib/features/settings/presentation/controllers/themes_controller.dart`, `screens/themes_screen.dart`, and `widgets/theme_preview_card.dart`:
  - tapping a locked theme keeps the preview, then the screen calls `showRewardedUnlock(context, FeatureKey.premiumTheme(id), subjectName: <localized theme name>)`
  - on `true`, `tapTheme(id, unlocked: true)`
  - the overlay gets `watchAdLabel: l10n.locked_watchAdTheme` ("Watch an ad to unlock this theme"), `onWatchAd` (same call), and `onGetPro` → `/premium`
  - remove the "until PRM-02" comments
  - make T067 pass
- [X] T080 [US2] Run the US2 tests, the scans T006(d) and (e), and `flutter analyze`.
- [X] T127 [P] [US2] Write `test/core/ads/domain/rewarded_daily_limit_test.dart` (FR-053): 10 per key per local day; other keys unaffected; each premium theme counts separately; a new local day resets; a clock moved backwards (effective now) never resets. Extend `test/features/premium/rewarded_unlock_sheet_test.dart`: at the limit no ad loads and only Get Pro / Not now show; an earned reward raises the count.
- [X] T128 [US2] Implement `lib/core/ads/domain/rewarded_daily_limit.dart` (pure) and the `rewardedDay` / `rewardedCounts` settings keys (codec, `AppSettings`, `SettingsRepository.recordRewardEarned`, fake); PRM-02 checks the limit before loading and records inside the grant. Make T127 pass.

**Checkpoint**: Every locked feature can be unlocked by a rewarded ad. PRM-02 ACs pass.

---

## Phase 5: User Story 3 - Buy Pro once and never see an ad again (Priority: P1)

**Goal**:
- PRM-01 with the real price, buy, pending, error, restore, and owned states.
- The purchase stream is subscribed at startup.
- Every purchase is acknowledged.
- An ownership check runs on every start, with the 2-check removal (Q1).
- Ads switch off at once, and all premium features unlock.
- The SET-01 premium card, and Pro freezes without ads.

**Independent Test**: With `FakeProStore`, buy, cancel, fail, leave pending, and restore. The ad
service switches to `NoAdsService` with zero SDK calls (including after restart), gated features
open, purchases are completed, and the start-up check behaves online, offline, and under the
2-check rule.

### Tests for User Story 3 ⚠️

- [X] T081 [P] [US3] Write `test/core/billing/pro_ownership_policy_test.dart` (clarification Q1, data-model §5 table). Every row:
  - `owned` → (true, 0, pending false, removalPending false)
  - `pending` keeps owned and streak, with pending true
  - (true, 0) + `notOwned` → (true, 1)
  - (true, 1) + `notOwned` → (true, 0, removalPending true): never `owned: false` mid-session
  - (false, s) + `notOwned` → (false, 0)
  - `unavailable` → unchanged
  - an `owned` between two `notOwned` resets the streak
- [X] T082 [P] [US3] Write `test/core/billing/pro_service_test.dart` (`FakeProStore`, `FakeSettingsRepository`):
  - `start()` subscribes before any query
  - `purchased` → `setProState(owned: true, 0, false)` and `complete()` called when `needsCompletion`
  - `pending` → pending true and a `PurchaseEvent.pending` event
  - `canceled` → no state change
  - `error` → an error event
  - `verifyOwnership()` applies the policy and writes once; `unavailable` writes nothing
  - **US3-10**: `queryOwnership` completes unacknowledged owned purchases
  - `restore()` → `restored` / `notFound` / `unavailable`, and never changes the streak
  - `buy()` calls `expectExternalActivity()` first
- [X] T083 [P] [US3] Write `test/features/premium/premium_screen_test.dart`:
  - **US3-1**: `loading` → `premium_buy` "Get Pro for ₹299" from `FakeProStore.product.price`; no product or unavailable → disabled with `premium_storeUnavailable`, and `premium_restore` still enabled
  - **US3-2**: purchased → `premium_owned` card, and the buy button hidden
  - **US3-3**: canceled → back to ready with no snackbar
  - **US3-4**: error → `ErrorState` with Try again
  - **US3-5**: pending → `premium_pending`
  - **PRM-01 AC "Reinstalling and tapping 'Restore purchase' restores Pro"**: fresh settings plus `FakeProStore.ownership = owned`, then tapping restore shows `premium_restored`, the owned state, and `removeAdsPurchased == true`; `notOwned` → `premium_restoreNotFound`
  - no `AppBannerAd`/`AppNativeAd` in the tree
  - FR-046: double-tapping `premium_buy` calls `ProService.buy` once (the button is disabled while `purchasing`)
  - 200% font and a 360 dp width do not overflow
- [X] T084 [P] [US3] Write `test/app/pro_switch_test.dart`:
  - **PRM-01 AC "After purchase, no ad of any kind is requested again, including after restart"**:
    - with `AdMobAdService` over `FakeAdsSdk` bound through the real `adsAllowed` switch, a `purchased` event switches `adServiceProvider` to `NoAdsService`; the `FakeAdsSdk` load count stops changing; preloaded ads are disposed; every banner and native on a pumped EXP-01 measures 0 dp
    - restarting 3 times with `removeAdsPurchased = true` (a fresh `ProviderContainer` and `restartTestApp` each time) makes zero `FakeAdsSdk` calls and zero `FakeConsentService.gather` calls on every restart (SC-001)
  - SC-007: a gated overlay (EXP-11) disappears within one frame of the purchase
- [X] T085 [P] [US3] Write `test/features/settings/settings_premium_card_test.dart` (US3-8, FR-045): `premium_card` is the first item and pushes `/premium`; it is hidden while Pro is owned. Write `test/features/habit/freeze_card_pro_test.dart` (US3-9, FR-044): Pro shows `add_freeze_pro` (no presenter call, adds 1 freeze, disabled at 2) and no `watch_ad_freeze`.
- [X] T086 [P] [US3] Extend `test/app/bootstrap_ads_test.dart`:
  - `proService.start()` runs before `verifyOwnership()`
  - `verifyOwnership()` is scheduled after the first frame and never awaited by bootstrap
  - bootstraps 1 and 2 with `FakeProStore.ownership = notOwned` and Pro cached keep Pro: every gated feature stays unlocked during session 2 (the gate's watch never emits `false`) and that session stays ad-free; bootstrap 3 applies the staged removal (step 3b′) before the gate and ads are read, so locks and ads return together (Q1, analysis I1)

### Implementation for User Story 3

- [X] T087 [P] [US3] Create the pure billing domain in `lib/core/billing/domain/` (data-model §3). Make T081 pass.
  - `store_product.dart`: `StoreProduct {id, title, price}`
  - `store_purchase.dart`: `StorePurchase {productId, status: purchased|pending|restored|error|canceled, needsCompletion, errorCode}`
  - `ownership_check.dart`: `enum OwnershipCheck { owned, pending, notOwned, unavailable }`
  - `pro_state.dart`: freezed `ProState {owned, notOwnedStreak, pending, removalPending}`
  - `pro_ownership_policy.dart`: `ProOwnershipPolicy.apply`
  - `pro_store.dart`: the `ProStore` interface from contracts/services.md §9
  - `const String proProductId = 'pro_lifetime'`
- [X] T088 [US3] Create `lib/core/billing/data/in_app_purchase_pro_store.dart`, implementing `ProStore` with `in_app_purchase` (research R13):
  - `purchaseUpdates` maps `InAppPurchase.instance.purchaseStream` to `StorePurchase`
  - `isAvailable()`
  - `loadProduct()`: `queryProductDetails({proProductId})`, null when not found or on error
  - `buy`: `buyNonConsumable`
  - `queryOwnership()`: via `InAppPurchase.instance.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>().queryPastPurchases()`; error → `unavailable`; Play state `PENDING` → `pending`; owned `pro_lifetime` → `owned` (completing it if `!billingClientPurchase.isAcknowledged`); otherwise `notOwned`
  - `complete`: `completePurchase` when `pendingCompletePurchase`
- [X] T089 [US3] Create `lib/core/billing/pro_service.dart` (contracts/services.md §9) and add `proStoreProvider` and `proServiceProvider` to `lib/core/billing/billing_providers.dart`. Make T082 pass.
  - `start()`: idempotent subscription
  - purchase handling per research R13: `setProState`, `complete`, events
  - `verifyOwnership()`: `ProOwnershipPolicy` + `setProState` only when changed; a removal is only staged through `removalPending`, never `owned: false`
  - `loadProduct()`
  - `buy()`: `expectExternalActivity()` then `store.buy`
  - `restore()`: the `owned` row only, plus `restorePurchases()`
  - `events` stream
- [X] T090 [US3] Bind `proStoreProvider` → `InAppPurchaseProStore()` in `lib/app/production_overrides.dart`. Extend `lib/app/bootstrap.dart`: first apply a staged removal (step 3b′: if `proRemovalPending`, `setProState(owned: false, notOwnedStreak: 0, pending: false, removalPending: false)`) before the ads step and before anything reads the gate, then call `ref.read(proServiceProvider).start()` before the ads step, and schedule `verifyOwnership()` unawaited after the first frame (`WidgetsBinding.instance.addPostFrameCallback`). Make T086 pass.
- [X] T091 [US3] Create `lib/features/premium/presentation/controllers/premium_controller.dart` (+ freezed `PremiumState {phase, product?, error?}`, phases `loading | ready | unavailable | purchasing | pending | error | owned`). It loads the product (or reads `owned` from `proOwnedProvider`), handles `buy()`, `restore()` (returns `restored`, `notFound`, or `unavailable` for the screen's snackbar), and `retry()`, and listens to `proService.events` and `proOwnedProvider`.
- [X] T092 [US3] Complete `lib/features/premium/presentation/screens/premium_screen.dart` (contracts/screens.md PRM-01). Make T083 pass.
  - `premium_buy` ("Get Pro for {price}", `premium_buyFor`), with a spinner and disabled state
  - `premium_restore` "Restore purchase", with the snackbars `premium_restored` "Pro restored", `premium_restoreNotFound` "No Pro purchase found for this Google account", and `premium_storeUnavailable` "Store not available right now, try again later"
  - `premium_accountNote` "Your purchase is tied to your Google account."
  - the `premium_pending` card "Pro unlocks when the payment completes"
  - `ErrorState` for error ("Couldn't complete the purchase. Try again.", `premium_purchaseError`)
  - the `premium_owned` card "You have Pro. Thanks for your support."
  - one primary button; no empty state (fixed controls)
- [X] T093 [US3] Add the `premium_card` "Remove ads and unlock everything" (`premium_cardTitle`, with a short subtitle `premium_cardSubtitle`) as the first item of `lib/features/settings/presentation/screens/settings_screen.dart`. It is hidden while `proOwnedProvider` is true and pushes `Routes.premium`. Update the class comment. Make the SET-01 part of T085 pass.
- [X] T094 [US3] Add the Pro button to `lib/features/habit/presentation/widgets/freeze_card.dart` and `habit_detail_controller.dart`: when `isPro`, show `add_freeze_pro` "Add a freeze" (`habit_addFreezePro`) calling the repository's `addFreeze(habitId)` directly, disabled at 2, instead of `watch_ad_freeze`. Make the HAB-03 part of T085 pass.
- [X] T095 [US3] Verify the mid-session switch end to end and make T084 pass. Check that `adServiceProvider`'s `onDispose` releases preloaded ads, and that `AppBannerAd`/`AppNativeAd` dispose on the provider change. Fix any leak found.

**Checkpoint**: Pro works offline-first and survives reinstall. PRM-01 and SYS-01 ACs pass.

---

## Phase 6: User Story 4 - Interstitials only after a finished action, within a strict cap (Priority: P2)

**Goal**:
- The pure cap and session logic.
- Three triggers that fire after their screen or success snackbar closes.
- A foreground, lock, and reading-screen probe.
- Preload after show.

**Independent Test**: Unit-test the cap with an injected clock. Widget-test that EXP-02, HAB-02,
and SET-02 trigger only after their screen or snackbar closed, with `FakeAdService` and
`FakeAdScreenProbe`.

### Tests for User Story 4 ⚠️

- [X] T096 [P] [US4] Write `test/core/ads/domain/interstitial_cap_test.dart`.
  - **§11 AC** "Unit tests cover the frequency cap: install-age rule, 3-minute gap, 4-per-day maximum, and counter reset", table-driven with `Clock.fixed`:
    - `installAge` blocks at 2 days − 1 ms and allows at exactly 2 days
    - `firstSession` blocks
    - `gap` blocks at 2:59 and allows at 3:00
    - `dailyMax` blocks the 5th on the same `dayKey` and allows after the local day changes
    - `notEnoughSaves` blocks `ExpenseSaved` with 3 saves and allows with 4
    - `afterShown` resets `expenseSaves` to 0 and increments `shownToday`
    - a block never resets `expenseSaves` (FR-022)
    - `HabitCreated` and `ManualBackupSucceeded` ignore `expenseSaves`
    - a clock moved back uses `effectiveNow` (the gap still blocks)
  - **SC-004**: a simulated week of random triggers every 30 s never exceeds 4 per day or goes under 3 min apart
- [X] T097 [P] [US4] Write `test/core/ads/domain/ad_session_test.dart` (clarification Q3):
  - a cold start is a new session
  - background 29:59 → same session; 30:00 → new session
  - the first session of a day → `isFirstSessionOfDay = true`; a later session the same day → false
  - a local-day change mid-session keeps the flag (spec edge case)
- [X] T098 [P] [US4] Extend `test/core/ads/data/admob_ad_service_test.dart` with interstitial cases (`FakeAdsSdk`, `FakeAdScreenProbe`, `MutableClock`):
  - `ExpenseSaved(screenClosing: false)` counts but never shows
  - the 4th `ExpenseSaved(screenClosing: true)` shows after 400 ms only if preloaded, allowed, and `probe.canShowFullScreenAd`
  - not preloaded → no wait and no show
  - probe false → no show, with saves kept
  - after a show: `recordInterstitialShown` is written, saves reset, and the next is preloaded
  - `expectExternalActivity` is called before the show
  - a new session (via `AdSession`) resets the saves
- [X] T099 [P] [US4] Write `test/features/expense/transaction_form_interstitial_test.dart`:
  - **EXP-02 AC "Interstitial never appears while the keypad or form is visible"**: saving a new expense pops `/expenses/add` before `FakeAdService.maybeShowInterstitial(ExpenseSaved(screenClosing: true))` is recorded, and the real `AdScreenProbe` binding reports `false` while `/expenses/add` is current
  - "Save and add another" records `screenClosing: false` and stays open
  - **Q4**: editing an existing entry records no trigger; a swipe-right duplicate (opens as new) does
  - with EXP-02 opened from Home, the trigger happens with `/home` current, and the probe is true (Q1)
- [X] T100 [P] [US4] Write `test/features/habit/habit_form_interstitial_test.dart` (US4-5: a new habit save records `HabitCreated()` after the pop; edit mode records nothing) and `test/features/settings/backup_interstitial_test.dart` (US4-6: `ManualBackupSucceeded()` is recorded only after the success `SnackBar` of "Save backup file" and of "Back up now" closes; failures record nothing).
- [X] T101 [P] [US4] Write `test/app/ad_screen_probe_test.dart` (contracts/routes.md):
  - false for `/splash`, `/onboarding`, `/lock`, `/premium`, `Routes.pin`, `/expenses/add`, `/expenses/x/edit`, `/habits/add`, `/habits/x/edit`, `/expenses/recurring/add`, and `/expenses/recurring/r/edit`
  - false when locked or not resumed
  - true for `/home`, `/expenses`, `/habits`, `/more`, `/more/backup`
- [ ] T102 [P] [US4] Extend `test/app/bootstrap_ads_test.dart` (US4-9, FR-026): no interstitial is ever shown during bootstrap; `preloadInterstitial` is scheduled 10 s after bootstrap (`fakeAsync`) only when ads are allowed; `adsInstallAt` is set once when null and kept when already set.

### Implementation for User Story 4

- [X] T103 [P] [US4] Create `lib/core/ads/domain/interstitial_cap.dart` (data-model §3, contracts/services.md §6). Make T096 pass.
  - freezed `InterstitialCapState`
  - sealed `CapDecision` (`CapAllow`, `CapBlock(CapBlockReason)`)
  - `enum CapBlockReason { installAge, firstSession, gap, dailyMax, notEnoughSaves, notPreloaded, notOnReadingScreen, adsDisabled }`
  - `InterstitialCap.check` in the order install age → first session → gap → daily max → saves
  - `afterShown` and `afterExpenseSave`
- [X] T104 [P] [US4] Create `lib/core/ads/domain/ad_session.dart` (`AdSession.isNewSession`, `AdSession.start`) and `lib/core/ads/domain/ad_screen_probe.dart` (interface). Make T097 pass.
- [X] T105 [P] [US4] Create `lib/core/ads/domain/interstitial_cap_store.dart` (interface: `load()`, `saveShown`, `setInstallAtIfMissing`, `setLastSessionDay`, `resetForDebug`) and `lib/core/ads/data/ads_settings_store.dart`, implementing it over `SettingsRepository` with the keys from data-model §1.
- [X] T106 [US4] Implement the interstitial part of `lib/core/ads/data/admob_ad_service.dart` (research R10). Make T098 pass.
  - `preloadInterstitial()`: at most one, via `AdsSdk`
  - `maybeShowInterstitial(trigger)`: update in-memory saves; return if not closing; wait `afterCloseDelay`; require preloaded + `InterstitialCap.check` allow + `probe.canShowFullScreenAd`; call `expectExternalActivity()`; show; on showed, `afterShown` + `store.saveShown`; on dismissed, preload the next
  - session handling through an `AppLifecycleListener` feeding `AdSession` (new session → reset saves, compute `isFirstSessionOfDay`, `setLastSessionDay`)
- [X] T107 [US4] Bind `adScreenProbeProvider` in `lib/app/production_overrides.dart` (contracts/routes.md). Make T101 pass. The binding combines:
  - the current `GoRouter` location (`appRouterProvider` → `routerDelegate.currentConfiguration.uri.path`)
  - `lockSessionProvider` locked state
  - `WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed`
  - the non-reading route list, using `Routes` constants and the `/add` and `/edit` suffix rules
- [X] T108 [US4] Extend `lib/app/bootstrap.dart`. Make T102 pass.
  - `adsSettingsStore.setInstallAtIfMissing(effectiveNow)` (step 3a)
  - `AdSession` cold-start start (step 3d)
  - when the gate is true, schedule `adService.preloadInterstitial()` unawaited after 10 s
- [X] T109 [US4] Add the EXP-02 trigger in `lib/features/expense/presentation/screens/transaction_form_screen.dart` and its controller:
  - expose whether the saved entry was new (not edit; duplicates count as new) from `save()`
  - in `_save`, after `_close()` call `unawaited(ref.read(adServiceProvider).maybeShowInterstitial(ExpenseSaved(screenClosing: true)))`; for `addAnother` use `screenClosing: false`
  - no call for edits or rule deletes
  - make T099 pass
- [X] T110 [P] [US4] Add the HAB-02 trigger in `lib/features/habit/presentation/screens/habit_form_screen.dart`: in `_save`, after `_close()`, when `!state.isEdit`, call `maybeShowInterstitial(HabitCreated())`. Make the HAB-02 part of T100 pass.
- [X] T111 [P] [US4] Add the SET-02 trigger in `lib/features/settings/presentation/screens/backup_screen.dart`: chain `.closed.then((_) => ref.read(adServiceProvider).maybeShowInterstitial(ManualBackupSucceeded()))` on the success `showSnackBar` controllers in `save()` (`backup_saved`) and `backUpNow()` (`backup_drive_saved`). Make the SET-02 part of T100 pass.

**Checkpoint**: Interstitials respect every cap rule and never interrupt a task.

---

## Phase 7: User Story 5 - Developers can test ads safely (Priority: P3)

**Goal**:
- Prod release reads the real App ID and unit IDs.
- Store builds fail without the App ID; other prod builds fall back to the test App ID and request
  no ads.
- No real IDs are committed.
- A dev-only "Reset ad counters"; the debug unlock switch is kept.

**Independent Test**: Build the dev, prod-debug, prod-release, and store variants and check the
merged App ID and the failure. In a dev build, "Reset ad counters" makes an interstitial possible
at once (quickstart §4.2, §4.5).

### Tests for User Story 5 ⚠️

- [ ] T112 [P] [US5] Extend `test/core/ads/domain/ad_unit_ids_test.dart` (US5-2 to US5-4):
  - prod release with `manifestUsesTestAppId: true` → `AdUnitIds.none`
  - prod release with full `fromEnv` → those IDs
  - prod release missing `ADMOB_NATIVE_ID` → `native == null` and the others kept
- [ ] T113 [P] [US5] Extend `test/android/manifest_test.dart` (SC-010):
  - the manifest has `com.google.android.gms.ads.APPLICATION_ID` with value `${admobAppId}` and both `OPTIMIZE_*` flags
  - `android/app/build.gradle.kts` contains `manifestPlaceholders.put("admobAppId"` and the `checkAdmobAppId` task
  - a regex scan of `lib/`, `android/` (excluding `local.properties` and build outputs), and `test/` finds no `ca-app-pub-\d{16}` other than `ca-app-pub-3940256099942544`
- [X] T114 [P] [US5] Write `test/features/settings/settings_dev_tools_test.dart`:
  - **US5-5**: with `debugToolsAvailable` true, `reset_ad_counters` calls `AdDebugTools.resetCounters()` and shows the "Ad counters reset" snackbar; with it false, the tile is absent
  - **US5-6**: `debug_unlock_all` still toggles and does not change `adsAllowedProvider`
- [X] T115 [P] [US5] Write `test/core/ads/ad_debug_tools_test.dart`:
  - `resetCounters()` sets `adsInstallAt = effectiveNow − 2 days − 1 min`
  - it clears `adsLastInterstitialAt`, `adsInterstitialDay`, and `adsInterstitialsToday`
  - it clears in-memory saves and sets `isFirstSessionOfDay = false`
  - it calls `consent.resetForDebug()`
  - afterwards `InterstitialCap.check` allows a `HabitCreated` trigger
  - the prod binding is a no-op

### Implementation for User Story 5

- [ ] T116 [US5] Finish `android/app/build.gradle.kts` per contracts/android.md:
  - read `admob.appId` from `rootProject.file("local.properties")` or the `ADMOB_APP_ID` env var
  - `isStoreBuild` from `-PstoreBuild=true`, `DAILYTRACK_STORE_BUILD=true`, or `key.properties` existing
  - `onVariants`: prod release gets the prod ID or the test ID with `logger.warn`; everything else gets the test ID
  - register `checkAdmobAppId` that throws `GradleException("AdMob App ID missing: set admob.appId in android/local.properties or ADMOB_APP_ID")` when store and missing, wired with `tasks.matching { it.name == "preProdReleaseBuild" }.configureEach { dependsOn(checkAdmobAppId) }`
  - make T113 pass
- [ ] T117 [US5] Wire the prod resolution in `lib/app/production_overrides.dart` and `lib/app/bootstrap.dart`. `adUnitIdsProvider` uses `AdUnitIds.resolve(...)`, with `manifestUsesTestAppId` from `AdmobManifestSource.usesTestAppId()`, awaited in bootstrap only when `FlavorConfig.current.isProd && kReleaseMode` (default true on error). Make T112 pass.
- [X] T118 [P] [US5] Create `lib/core/ads/domain/ad_debug_tools.dart` (`AdDebugTools` interface) and the dev implementation in `lib/core/ads/data/ads_settings_store.dart` or a new `lib/core/ads/data/dev_ad_debug_tools.dart` (research R15). Bind `adDebugToolsProvider` in `lib/app/production_overrides.dart`: dev when `debugToolsAvailableProvider`, otherwise a no-op. Make T115 pass.
- [X] T119 [US5] Add the `reset_ad_counters` `ListTile` ("Reset ad counters", `ads_resetCounters`; snackbar `ads_resetCountersDone` "Ad counters reset") to the Developer section of `lib/features/settings/presentation/screens/settings_screen.dart`. Make T114 pass.

**Checkpoint**: Safe dev and CI builds; store builds can't ship without the App ID.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Cleanup, docs, accessibility, and the full gate run.

- [ ] T120 [P] Remove stale "until PRM-02 exists", "T4.4", "feature 008 adds it", and "Get Pro is disabled" comments across `lib/core/widgets/locked_feature_overlay.dart`, `lib/features/settings/presentation/widgets/theme_preview_card.dart`, `lib/features/settings/presentation/screens/themes_screen.dart`, `lib/features/habit/presentation/widgets/freeze_card.dart`, and `lib/features/expense/presentation/screens/reports_screen.dart`, and the ad comments in `lib/app/bootstrap.dart` and `lib/core/ads/ad_providers.dart` (research R16). Search with `grep -rn "T4\.\|PRM-02 exists\|feature 008 adds" lib`.
- [X] T121 [P] Write `test/a11y/premium_font_scale_test.dart`. PRM-01, the PRM-02 sheet (every offer title in Gujarati and Hindi), the SET-01 premium card, and the HAB-03 freeze card render at 200% font on a 360 dp width with no overflow. Every button is ≥ 48 dp, and the badge and spinner have semantics labels (Constitution V, FR-050).
- [ ] T122 [P] Run the existing DSH-01, EXP-01, and HAB-01 golden tests on Linux CI (`flutter test --tags golden`). They must be unchanged under `NoAdsService`. Do not regenerate goldens on Windows.
- [ ] T123 Remove the `.gitkeep` files from T003 where real files now exist.
- [ ] T124 Run the full gates in quickstart §2: `dart run build_runner build --delete-conflicting-outputs`, `flutter analyze` with zero warnings, `dart format --set-exit-if-changed .`, and `flutter test --exclude-tags golden`. Fix all failures.
- [ ] T125 Walk the device steps in quickstart §4.1–§4.5 (consent EEA form, placements, cap, rewarded, Pro on an internal track, build checks), including the SC-009 cold-start measurement in quickstart §4.1 step 5 (a median over 1.5 s blocks this task), and record the results and any skipped steps in the task summary. Check every changed screen against the §15.10 design review checklist (plan V gate).
- [ ] T126 Confirm `docs/CLAUDE.md` (T002) matches constitution 1.0.3 (the ad-behavior test exception in IV; no ad-free day in VI). Then mark T4.1–T4.5 done in `docs/spec.md` §14.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: no dependencies. T005 and T006 are expected to fail until their stories land.
- **Foundational (Phase 2)**: depends on Setup and blocks every story.
- **US1 (Phase 3)**: depends on Foundational. It provides `AdMobAdService`, `AdsSdk`, the
  consent service, and the bootstrap ads step, all of which US2, US4, and US5 extend.
- **US2 (Phase 4)**: depends on US1 (T043, T051) for the real rewarded path. Its UI tasks
  (T070–T079) can start right after Foundational, using `FakeAdService`.
- **US3 (Phase 5)**: depends on Foundational. T084 and T095 also need US1's switch binding
  (T051). It is independent of US2, apart from `freeze_card.dart`: do T077 before T094.
- **US4 (Phase 6)**: depends on US1 (T043, T051, T052).
- **US5 (Phase 7)**: depends on US1 (T038, T047, T050, T051) and US4 (T105) for the reset.
- **Polish (Phase 8)**: depends on all stories.

### Within Each User Story

- Test tasks come first and must fail before implementation.
- Pure domain → data adapters → providers and bindings → widgets and screens → wiring.
- Run codegen after each `@riverpod` or `@freezed` change.
- Shared files edited by several stories (do these in order):
  - `admob_ad_service.dart`: T043 → T069 → T106
  - `bootstrap.dart`: T016 → T052 → T090 → T108 → T117
  - `production_overrides.dart`: T051 → T074 → T090 → T107 → T117/T118
  - `freeze_card.dart`: T077 → T094
  - `settings_screen.dart`: T055 → T093 → T119
  - `habits_today_screen.dart`: T054 → T059

### Parallel Opportunities

- Setup: T002, T003, and T004 together.
- Foundational tests T007–T012 and T009a together. Then T013, T014, T015, T017, T021, T024, and T025 in
  parallel; T016, T018, T019, T020, T022, and T023 after their inputs.
- US1: tests T026–T037 together. T038, T039, and T040 together. Banner placements T053, T054,
  and T055 together. T058 and T059 together.
- US2: tests T062–T068 together. T070 and T071 together. After T073, the wiring tasks
  T075, T076, T078, and T079 are in different files and can run in parallel; T077 goes alone
  because it touches `freeze_card.dart`.
- US3: tests T081–T086 together. T087 starts in parallel with the US2 work.
- US4: tests T096–T102 together. T103, T104, and T105 together. T110 and T111 together.
- US5: tests T112–T115 together.
- Polish: T120, T121, and T122 together.

---

## Parallel Example: User Story 1

```text
# Tests first (all [P]):
T026 ad_unit_ids_test.dart        T027 native_ad_slots_test.dart     T028 admob_ad_service_test.dart
T029 ump_consent_service_test.dart T030 bootstrap_ads_test.dart      T031 app_banner_ad_test.dart
T032 app_native_ad_test.dart       T033 home_native_ad_test.dart     T034 transactions_native_ads_test.dart
T035 budgets/habits native tests   T036 ad_placements_scan_test.dart T037 settings_ad_privacy_test.dart

# Then the pure domain in parallel:
T038 ad_unit_ids.dart   T039 native_ad_slots.dart   T040 consent_service.dart

# After T045/T046 (widgets), the placements in parallel:
T053 expense banners    T054 habit banners    T055 settings banners    T058 EXP-08 native    T059 HAB-01 native
```

## Parallel Example: User Story 2

```text
# Tests (all [P]): T062 T063 T064 T065 T066 T067 T068
# Core + offers in parallel: T070 rewarded_unlock.dart   T071 rewarded_offers.dart
# After T073 (sheet) and T074 (binding), wire the locked states in parallel:
T075 reports_screen.dart   T076 habit_detail_screen.dart   T078 export_screen.dart   T079 themes_*
```

---

## Implementation Strategy

### MVP First (US1)

1. Phase 1 Setup, then Phase 2 Foundational.
2. Phase 3 US1: consent and banner/native ads with test IDs.
3. **Stop and validate**: run quickstart §4.1 on a device (the EEA form, placements, 0 dp
   collapse) and the §11 and DSH-01 ACs.

### Incremental Delivery

1. US1 → ads earn revenue safely.
2. US2 → every locked feature becomes reachable for free users (rewarded revenue).
3. US3 → Pro purchase; ads off for buyers. It can ship together with US2 because both are P1.
4. US4 → interstitials under the cap.
5. US5 → store-build guard and dev tools, required before the first Play upload (T5.2).
6. Polish → the full gates and the device walkthrough.

### Task counts

| Phase | Tasks |
| --- | --- |
| Setup | 6 (T001–T006) |
| Foundational | 20 (T007–T025, plus T009a) |
| US1 | 36 (T026–T061) |
| US2 | 19 (T062–T080) |
| US3 | 15 (T081–T095) |
| US4 | 16 (T096–T111) |
| US5 | 8 (T112–T119) |
| Polish | 7 (T120–T126) |
| **Total** | **127** |
