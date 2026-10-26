# Research: Ads, Rewarded Unlocks, and Pro Purchase (T4.1–T4.5)

Feature: `specs/009-ads-rewarded-pro` · Date: 2026-10-22

Each entry: **Decision**, **Rationale**, **Alternatives considered**. Codebase facts were read from
the repository on 2026-10-22; package facts from pub.dev and the `googleads-mobile-flutter`
changelog on the same day.

---

## R1. Packages and versions

**Decision**: Add exactly two packages from spec §2:
- `google_mobile_ads: 9.2.0` (bundles the UMP consent SDK: Android UMP 4.0.0, GMA Android 25.5.0)
- `in_app_purchase: 3.3.1` (pulls `in_app_purchase_android` 0.5.x, Play Billing)

Both are pinned exactly, like the other plugins added in feature 008. Both need Flutter ≥ 3.38 and
Dart ≥ 3.10; the project is on Flutter 3.47.7 and Dart 3.13.5. No mediation adapters, no
Remote Config, no `in_app_purchase_android` direct dependency unless a platform-addition API
needs it (R13: `InAppPurchaseAndroidPlatformAddition` is exported through
`in_app_purchase_android`, so it becomes a direct dependency at the version `in_app_purchase`
resolves; pinned in `pubspec.lock`).

**Rationale**: 9.2.0 fixes the large anchored adaptive banner size bug (PR 1495), which is
exactly the banner size this feature uses (R6). If 9.2.0 shows a regression during
implementation, 9.1.0 (2026-08-11) is the fallback with the same APIs apart from that fix.

**Alternatives considered**: `google_mobile_ads` 9.1.0 (older banner sizing bug); a separate
UMP plugin (redundant, the ads plugin ships UMP); RevenueCat or another billing wrapper (not in
§2, needs a server account, Constitution VII).

---

## R2. AdMob App ID in the manifest

**Decision**:
- `AndroidManifest.xml` gets
  `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="${admobAppId}"/>`.
- `android/app/build.gradle.kts` sets the placeholder per variant with the AGP variant API
  (`androidComponents { onVariants { … manifestPlaceholders.put("admobAppId", …) } }`):
  - **dev flavor** (debug and release) and **any debug build**: Google's test App ID
    `ca-app-pub-3940256099942544~3347511713`.
  - **prod release**: `admob.appId` from `android/local.properties` (already git-ignored), else the
    environment variable `ADMOB_APP_ID`, else the test App ID with a Gradle warning.
- **Store build check** (clarification Q2 of `/speckit-clarify`): a build is "meant for Play upload"
  when the Gradle property `-PstoreBuild=true` or the environment variable
  `DAILYTRACK_STORE_BUILD=true` is set, or `android/key.properties` exists (the upload-key signing
  config that T5.2 adds). For such a prod release build, a `checkAdmobAppId` task wired before
  `preProdReleaseBuild` fails with "AdMob App ID missing: set admob.appId in
  android/local.properties or ADMOB_APP_ID".
- **Runtime guard**: `MainActivity`'s existing `dailytrack/window` channel gains
  `getAdmobAppId`, which reads the manifest meta-data. In a prod release, when it equals the test
  App ID, `AdUnitIds` reports no usable IDs, so no ads are requested (spec US5-3).

**Rationale**: The user asked for a manifest placeholder per flavor, never committed.
`local.properties` is already ignored (`/android/local.properties`). Doing the check in a task
rather than at configuration time means debug builds and `flutter analyze` never fail because a
store flag is set. Reading the App ID back at runtime is the only reliable way for Dart to know
the build fell back to the test App ID, and it reuses an existing channel (one `when` branch).

**Alternatives considered**: parsing Flutter's base64 `dart-defines` Gradle property (fragile,
undocumented); a `resValue` boolean (still needs a channel to read it); failing every prod release
build without the ID (breaks CI pull-request builds, rejected in clarification).

---

## R3. Ad unit IDs per flavor

**Decision**: `lib/core/ads/domain/ad_unit_ids.dart` (pure Dart):
- `AdUnitIds.test` holds Google's public Android test IDs:
  - banner `ca-app-pub-3940256099942544/6300978111` (fixed size; was the adaptive test unit `…/9214589741`)
  - native `ca-app-pub-3940256099942544/2247696110`
  - interstitial `ca-app-pub-3940256099942544/1033173712`
  - rewarded `ca-app-pub-3940256099942544/5224354917`
- `AdUnitIds.fromEnvironment()` reads `ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`,
  `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID` via `String.fromEnvironment` (empty = missing).
- `AdUnitIds.resolve({required bool isProd, required bool isRelease, required bool
  manifestUsesTestAppId, required AdUnitIds fromEnv})`:
  - dev flavor or not release → `AdUnitIds.test` (whatever was passed, FR-004)
  - prod release with the test App ID → `AdUnitIds.none` (no ads)
  - prod release otherwise → `fromEnv`; a missing format is `null`, and that format requests
    nothing and takes no space (US5-4).
- The composition root passes `FlavorConfig.current.isProd`, `kReleaseMode`, and the channel answer.
  A test asserts every prod value is ignored in dev and debug builds.

**Rationale**: Test IDs are public, so committing them is allowed and required (Constitution VI).
Resolution is a pure function, so the "dev and debug always use test IDs" rule is unit-tested.

**Alternatives considered**: Gradle-generated Dart file (adds codegen to the Android build);
reading IDs from the manifest (they don't belong there).

---

## R4. Consent (UMP) in SYS-01

**Decision**:
- `lib/core/ads/domain/consent_service.dart` defines `ConsentService`:
  - `Future<ConsentResult> gather({required Future<void> Function() beforeForm, required Duration timeout})`
  - `bool get canRequestAds`
  - `Stream<bool> get privacyOptionsRequired`
  - `Future<void> showPrivacyOptionsForm()`
- `UmpConsentService` (in `data/`, the only UMP caller) wraps `ConsentInformation.instance` and
  `ConsentForm` from `google_mobile_ads`:
  1. Call `requestConsentInfoUpdate(ConsentRequestParameters(...))`.
  2. On success, call `ConsentForm.loadAndShowConsentFormIfRequired`.
  3. Read `canRequestAds()` and `getPrivacyOptionsRequirementStatus()`.
- **Bootstrap order** (`lib/app/bootstrap.dart`, step 3), skipped entirely when
  `removeAdsPurchased` is cached true (SYS-01 AC, R14):
  - If the SDK already reports `canRequestAds()` from an earlier session, start
    `MobileAds.initialize()` right away and refresh consent unawaited (Google's recommended
    parallel path). Startup is not slowed (SC-009).
  - Otherwise (first launch, or consent required and still unknown), await `gather` with a 5 s
    timeout for the info update. If a form must show, `beforeForm` removes the native splash first
    (`FlutterNativeSplash.remove()`), so the form appears over the Flutter SYS-01 splash instead of
    behind the system splash. The form itself has no timeout (the user is answering it).
  - After `gather`: when `canRequestAds` is true, initialize the SDK unawaited; when false, the
    SDK is not initialized this session and every ad component collapses (FR-012).
  - Offline or error: continue with whatever `canRequestAds()` reports from storage (FR-013); the
    next start tries again.
- `adConsentStatus` in settings mirrors the last known status, for display and diagnostics only.
  The UMP SDK stays the source of truth.
- **Debug geography**: dev builds read `--dart-define=UMP_DEBUG_GEOGRAPHY=eea` and
  `UMP_TEST_DEVICE_ID=<hashed id>` into `ConsentDebugSettings`. Prod ignores them. A dev-only
  "Reset consent" button is **not** added (out of scope); `ConsentInformation.reset()` is called
  by "Reset ad counters" in dev builds (R15), so the flow can be replayed.
- `RequestConfiguration`: `tagForChildDirectedTreatment` and `tagForUnderAgeOfConsent` are left
  unspecified, `testDeviceIds` come from the same dart-define in dev, and `maxAdContentRating` is
  not set (§11).

**Rationale**: This follows Google's UMP guidance (update on every launch, gate requests on
`canRequestAds`) without adding network latency to every cold start. Pro users never load the
UMP SDK because the ads plugin is never touched for them.

**Alternatives considered**: always awaiting the consent update (costs 300–1500 ms per start,
breaks SC-009); showing the form after Home appears (Home would request the DSH-01 native before
consent, breaking the §11 AC).

---

## R5. AdService shape, plugin isolation, and switching ads off

**Decision**:
- **Layout of `lib/core/ads/`**:
  - `domain/` (pure Dart): `ad_config.dart`, `ad_unit_ids.dart`, `ad_trigger.dart`,
    `interstitial_cap.dart`, `ad_session.dart`, `consent_service.dart`, `ad_placement.dart`,
    `rewarded_outcome.dart`, `native_ad_slots.dart`, `ad_screen_probe.dart`,
    `interstitial_cap_store.dart`.
  - Root (Flutter allowed, no plugin): `ad_service.dart` (interface plus `NoAdsService`),
    `ad_view.dart`, `ad_providers.dart`, `rewarded_unlock.dart` (`showRewardedUnlock`),
    `widgets/app_banner_ad.dart`, `widgets/app_native_ad.dart`.
  - `data/`: the **only** files that import `google_mobile_ads`. These are `admob_ad_service.dart`,
    `ump_consent_service.dart`, `admob_ad_views.dart`, `ads_settings_store.dart`, and
    `admob_ads_sdk.dart` (initialize and request configuration).
- **`AdService`** (contracts/services.md §1) keeps the §11 members (`init`, `adsEnabled`,
  `adsEnabledStream`, `preloadInterstitial`, `maybeShowInterstitial`, `showRewarded`) and adds
  three more:
  - `loadBanner` and `loadNative`, which return an `AdView`. An `AdView` is a plugin-free
    handle: `Widget build()`, `double height`, `void dispose()`. The AdMob version wraps
    `AdWidget`. This way `AppBannerAd` and `AppNativeAd` never import the plugin.
  - `prepareRewarded()`, which loads the one rewarded ad PRM-02 needs.
  - `showRewarded` returns a `RewardedOutcome` instead of a `bool` (earned / closedEarly /
    notReady / failed), because PRM-02 reacts differently to each (clarification Q5). The spec §11
    line was updated to match.
- **Switching** (FR-002, FR-039, FR-043): `adServiceProvider` (keepAlive) watches
  `adsAllowedProvider`:

  ```text
  adsAllowed = !removeAdsPurchased (live) && sessionStartedWithAds
  ```

  - `sessionStartedWithAds` is fixed at bootstrap: false when Pro was cached at cold start, or
    when consent did not allow ads.
  - When `adsAllowed` is true the provider builds `AdMobAdService`. Otherwise it builds
    `NoAdsService`.
  - When it flips, the old service's `ref.onDispose` releases the preloaded interstitial and
    rewarded ad. Ad widgets watch the provider, so they rebuild, dispose their `AdView`, and
    collapse to 0 dp.
  - A Pro purchase therefore removes every ad without a restart (SC-007).
  - Pro removal (2 "not owned" checks, clarification Q1) only changes the stored flag. This
    session started without ads, so ads come back only from the next cold start.
- `AdMobAdService.adsEnabled` is true only while the SDK is initialized, `canRequestAds` is true,
  and the service is not disposed. Every load checks it first, which also covers "no request
  before consent" (§11 AC).
- Rename the existing `initialize()` to `init()` to match §11. The bootstrap call site changes in
  the same task.

**Rationale**: This keeps the plugin in `data/`, as Constitution II and the user require ("never
google_mobile_ads directly"). The switch is driven by one provider, so testing "no ad of any
kind after purchase" means checking that `NoAdsService` is bound and that a fake SDK recorded zero
loads.

**Alternatives considered**:
- A single `AdMobAdService` with an internal "disabled" flag. Old ads could leak if one code path
  forgot to check the flag.
- `AppBannerAd` importing `AdWidget` directly. That violates the user's rule and the CLAUDE.md
  layering rule.
- Keeping `showRewarded` returning `bool`. PRM-02 then can't tell "closed early" from "failed to
  show", and they need different text.

---

## R6. `AppBannerAd`

**Decision**:
- **Size**: `AdSize.getLargeAnchoredAdaptiveBannerAdSize(width)`, using the 8.0+ replacement for
  the deprecated `getCurrentOrientationAnchoredAdaptiveBannerAdSize`. The width is the screen
  width truncated to whole dp.
- **States**: `idle` (0 dp) → `loading` (0 dp) → `loaded` (animates to the ad's height).
  - The animation is `AnimatedSize` with `AppTokens.motionMedium` (200 ms) and standard easing.
  - It takes `Duration.zero` when `MediaQuery.disableAnimationsOf(context)` is true.
- **Retry**: on failure the widget stays at 0 dp and retries after the `AdConfig.retryBackoff`
  delays (30 s, 60 s, 120 s), then gives up until it is mounted again.
- **Cleanup**: retries stop and the `AdView` is disposed when the widget unmounts or when
  `adServiceProvider` switches to `NoAdsService`.
- **Gap**: an `AppTokens.s8` top gap, so the banner keeps 8 dp from the list or FAB above it
  (§15.8).
- **Semantics**: the banner's container gets the label "Advertisement" (ARB `ads_bannerLabel`).
- **Placement**: always through `AppScaffold.bannerSlot`, which already puts it above the shell
  `NavigationBar` and the FAB above it, with safe areas.
- **Orientation**: the ad is reloaded when the width changes by more than 1 dp. A new
  `LayoutBuilder` width triggers one reload, after a 500 ms debounce.

**Update (2026-10-27)**: the banner is now the standard `AdSize.banner` (320×50), centered,
for a smaller ad on every screen; screens narrower than 320 dp show none. This replaces the size
decision above and FR-006's screen-width adaptive size.

**Rationale**: This covers FR-006, FR-007, FR-015, the §15.6 no-layout-shift rule, and the §15.8
8 dp gap. The large anchored size is AdMob's current recommendation.

**Alternatives considered**: reserving the banner height before load (§15.8 forbids empty
boxes); collapsible banners (more intrusive, not in §11).

---

## R7. `AppNativeAd` (medium template)

**Decision**:
- **Template**: `NativeAd` with `NativeTemplateStyle(templateType: TemplateType.medium, …)`, which
  needs no custom native layout code. Its colors and text styles come from the theme:
  - surface: `surfaceContainerLow`
  - call-to-action: `primary` / `onPrimary`
  - primary text: `titleMedium`
  - secondary and tertiary text: `bodySmall`
  - corner radius: the 16 dp card radius
- **Size**: inside a `ConstrainedBox` sized as the plugin's sample recommends (min 320×320, max
  height 400). It shrinks to the available width on a 360 dp screen (328 dp of content).
- **Look**:
  - The Flutter wrapper is a `Card` with the app's card shape.
  - A header row comes before the platform view, with the **"Ad" badge**: `labelSmall` text on
    `AppTokens.adBadge`, top-left (§15.8, FR-008). Putting the badge in Flutter, not over the
    platform view, avoids hybrid-composition overlay problems.
  - The template's own attribution stays.
- **Behavior**:
  - The same 0 dp → animate-in, retry, and dispose behavior as R6.
  - A vertical margin of `AppTokens.s12` (the card gap) applies only once loaded, so a collapsed
    slot adds no gap.
  - Medium content does not look like a transaction row or habit card: those are 64–72 dp rows,
    and the ad is a ≥ 320 dp media card with a CTA button.
- `NativePlacement` (`home`, `transactions`, `budgets`, `habits`) is sent as the request's
  `contentUrl`-free placement tag for reporting only. No keywords are set, and no app data goes
  into requests (FR-010).

**Rationale**: The medium template is what §11 names. Styling it from tokens keeps "styled like
app cards" without native Kotlin layout.

**Alternatives considered**: a custom `NativeAdFactory` in Kotlin (more code, needs XML layouts,
not needed); a small template (§11 says medium).

---

## R8. Placements

**Decision**:
- **Banners** (FR-015): pass `bannerSlot: const AppBannerAd()` on EXP-01
  (`transactions_screen`), EXP-03 (`transaction_detail_screen`), EXP-04 (`categories_screen`),
  EXP-06 (`accounts_screen`), EXP-11 (`reports_screen`), HAB-01 (`habits_today_screen`), HAB-03
  (`habit_detail_screen`), HAB-04 (`archived_habits_screen`), SET-01 (`settings_screen`), and
  SET-02 (`backup_screen`). No other `AppScaffold` gets one; a test lists all `bannerSlot:` uses
  (FR-009).
- **Natives** (FR-016, FR-017):
  - **DSH-01**: in `home_screen.dart` the slot list is built in order. An `AppNativeAd(home)` slot
    goes after `min(2, moduleCardCount)` module cards, before the sections, insight, and Coming
    soon card. With 0 module cards there is no ad.
  - **EXP-01**: a pure `nativeAdRowIndexes(rowCount, {first: 8, every: 15, max: 3})` returns
    `[8, 23, 38]` capped by row count. "After row 8" means between row index 7 and 8, and only
    when row 9 exists or the list has more than 8 rows.
    - `_daySlivers` currently builds one `SliverFixedExtentList` per day. It splits the day group
      that holds a slot index into two fixed-extent lists with a `SliverToBoxAdapter(AppNativeAd)`
      between them, so rows keep their fixed extent for 60 fps.
    - "Per screen load": slot indexes count over the loaded rows of the current period and
      filters. When the period changes, the list (and its ads) rebuild with new keys, which
      covers the EXP-01 AC "updates … ads". Only the content state gets slots: no ads in
      skeleton, empty, "No matches", or error states.
  - **EXP-08**: after the "Categories without budget" section, which is the end of the content
    list (spec EXP-08 item 5 follows item 4), only when budgets exist (the non-empty state).
  - **HAB-01**: after the 4th card of the scheduled list, only when the selected day's scheduled
    list has ≥ 5 cards and the screen is not in Reorder mode. The ad keeps 8 dp from the cards'
    check buttons through the 12 dp card gap.
- **Interstitials are never placed in widgets.** Only the three triggers in R10 exist.

**Rationale**: This matches the §11 table and FR-016 exactly, and keeps EXP-01's fixed-extent
performance. Slot math is pure, so it is unit-tested.

**Alternatives considered**: a single `SliverList` with mixed rows (loses `itemExtent` and
60 fps on 10k rows); putting the EXP-08 ad between the category list and "without budget" (the
spec's item order says after).

---

## R9. Interstitial frequency cap and sessions (pure logic)

**Decision**:
- **`AdConfig`** (pure, `const`): `installAgeDays = 2`, `minGap = 3 min`, `maxPerDay = 4`,
  `savesPerInterstitial = 4`, `sessionGap = 30 min`, `rewardedTimeout = 8 s`,
  `retryBackoff = [30 s, 60 s, 120 s]`, `afterCloseDelay = 400 ms`,
  `consentUpdateTimeout = 5 s`. One `AdConfig.defaults` constant is read through
  `adConfigProvider`, which is the later Remote Config hook.
- **`InterstitialCapState`** (freezed, pure): `installAt`, `lastShownAt`, `dayKey`,
  `shownToday`, `isFirstSessionOfDay`, `expenseSaves`.
- **`InterstitialCap.check(state, {required DateTime effectiveNow, required String todayKey,
  required AdTrigger trigger})`** returns `CapDecision.allow` or `CapDecision.block(reason)`, in
  this order:
  1. `effectiveNow - installAt < 2 days` → `installAge`
  2. `isFirstSessionOfDay` → `firstSession`
  3. `lastShownAt != null && effectiveNow - lastShownAt < 3 min` → `gap`
  4. `dayKey == todayKey && shownToday >= 4` → `dailyMax`
  5. an expense-save trigger with `expenseSaves < 4` → `notEnoughSaves`
- **`InterstitialCap.afterShown(state, now, todayKey)`** sets `lastShownAt`, rolls the day if
  needed, increments `shownToday`, and resets `expenseSaves` to 0. `afterExpenseSave(state)`
  increments `expenseSaves`. Blocking never resets the counter (FR-022).
- **`AdSession`** (pure): `onColdStart(now)` and `onForeground(now, backgroundedAt)` decide
  whether a new session starts (cold start, or background ≥ 30 min; clarification Q3). When a new
  session starts, `isFirstSessionOfDay = (todayKey != lastSessionDayKey)`, then
  `lastSessionDayKey = todayKey`, and `expenseSaves = 0` (the counter is per session).
  - The session keeps its flag when the local day changes mid-session (spec edge case); only the
    per-day count rolls.
  - Watching a full-screen ad never starts a session, because its background trip is far shorter
    than 30 min.
- **Effective now**: a shared pure helper, `effectiveNow(clockNow, latestSeenAt) = max(...)`, in
  `lib/core/utils/effective_clock.dart`. It is used by the cap and by `UnlockPolicy` (R12). The
  gate's existing `latestSeenAt` raising logic stays where it is.
- **Storage** (`AdsSettingsStore` in `data/` over `SettingsRepository`):
  - settings keys `adsInstallAt`, `adsLastInterstitialAt`, `adsInterstitialDay`,
    `adsInterstitialsToday`, `adsLastSessionDay`
  - `expenseSaves` and `isFirstSessionOfDay` stay in memory, because both are per session and a
    cold start begins a new session
  - `adsInstallAt` is written on the first bootstrap that finds it null. For existing installs
    that is the first start after this update (spec assumption).
- **Backups**: none of these keys are in `BackupSettingsPolicy.restorableKeys` (FR-025). A test
  asserts it.
- **Erase all data**: `DriftAppResetService` deletes every settings row today. It now re-inserts
  `adsInstallAt` inside the same transaction (spec edge case: the install time is kept), while the
  other ad counters are cleared.
- All time math uses the injected `Clock` (`clockProvider`); `DateTime.now(` stays banned (the
  existing scan).

**Rationale**: The user asked for the cap as pure logic with an injected clock. Each rule maps to
one named block reason, so the §11 AC test ("install-age rule, 3-minute gap, 4-per-day maximum,
counter reset") is a table-driven unit test, plus a simulated-week property test for SC-004.

**Alternatives considered**: storing counters in `SharedPreferences` (a second store, not covered
by Drift streams or the reset service); a separate Drift table (a schema migration for six
scalars, YAGNI).

---

## R10. Triggering interstitials (when and where)

**Decision**:
- **`AdTrigger`** is a sealed class with three cases:
  - `ExpenseSaved({required bool screenClosing})`. EXP-02 sends it only for **new** entries,
    including swipe-right duplicates (which open EXP-02 as new) and "Save and add another"
    (`screenClosing: false`). Edits never send it (clarification Q4).
  - `HabitCreated()`, sent by HAB-02 only when it was not in edit mode.
  - `ManualBackupSucceeded()`, sent by SET-02 for both "Save backup file" and Drive "Back up now".
- **Call sites**:
  - EXP-02 `_save`: after `_close()` (or after clearing the form for "add another"), it calls
    `unawaited(ref.read(adServiceProvider).maybeShowInterstitial(...))`.
  - HAB-02 `_save`: the same, after `_close()`.
  - SET-02 `save()` and `backUpNow()`:
    `messenger.showSnackBar(...).closed.then((_) => maybeShowInterstitial(ManualBackupSucceeded()))`.
    The success message is a `SnackBar`, not a dialog, so "closes its success message" maps to
    `ScaffoldFeatureController.closed`. The spec SET-02 text was updated.
- **`AdMobAdService.maybeShowInterstitial`**:
  1. Update the save counter for `ExpenseSaved`.
  2. If the trigger is `ExpenseSaved` with `screenClosing: false`, stop.
  3. Wait `AdConfig.afterCloseDelay` (400 ms, longer than the 300 ms route transition).
  4. Require all of: an interstitial is preloaded (never wait, FR-024); the cap allows it (R9);
     the `AdScreenProbe` says the app is in the foreground (`AppLifecycleState.resumed`), not
     locked, and on a reading screen.
  5. Call `ExternalActivityGuard.expectExternalActivity()`, so the ad's activity never starts the
     lock timer (spec edge case).
  6. Show the ad.
  7. On `onAdShowedFullScreenContent`, record `afterShown`.
  8. On dismiss, preload the next one.
- **Preloading**: the first preload starts 10 s after bootstrap finishes, unawaited and only when
  ads are allowed, so it never competes with cold start.
- **`AdScreenProbe`** (domain interface; bound in the composition root over `GoRouter` and
  `lockSessionProvider`): `bool get canShowFullScreenAd`. It is false when the current location
  matches a non-reading route: `/splash`, `/onboarding`, `/lock`, `/premium`, `/settings/security/pin`,
  any `…/add`, `…/edit`, or `/expenses/recurring/add`. Home (`/home`) is a reading screen, so the
  EXP-02 and HAB-02 interstitials can appear over Home after closing back to it (clarification Q1
  of `/speckit-clarify`). Home itself sends no trigger (FR-018).
- **No interstitial on cold start**: nothing triggers one, and bootstrap only preloads. Habit
  check-in has no trigger.

**Rationale**: Triggers stay in the three screens §11 names. Timing relies on route completion
plus a probe instead of guesses, and the probe is what makes the EXP-02 AC ("never while the
keypad or form is visible") testable.

**Alternatives considered**: a `NavigatorObserver` that fires interstitials on pops (fires on
every pop, hard to scope to triggers); showing immediately in `_save` before the pop (breaks the
EXP-02 AC).

---

## R11. Rewarded unlocks and PRM-02

**Decision**:
- **Public API** (`lib/core/ads/rewarded_unlock.dart`):

  ```dart
  Future<bool> showRewardedUnlock(
    BuildContext context,
    FeatureKey key, {
    Duration? duration,
    Future<void> Function()? grant,
  })
  ```

  It reads `rewardedUnlockPresenterProvider` from the `ProviderScope` and returns its result. The
  presenter interface lives in core; the composition root binds it to
  `features/premium/presentation/rewarded_unlock_sheet.dart`. Callers in expense, habit, and
  settings therefore never import the premium feature (Constitution II; features may import only
  `routes.dart` from `app/`).
- **Default grant** when `grant` is null: `UnlockRepository.grant(key, source: rewardedAd,
  expiresAt: duration == null ? null : effectiveNow + duration)`.
  - Advanced reports: `duration: 24 h`.
  - Export: no duration. It is one-time, and `consumeOne` uses it up (feature 008).
  - Theme: no duration (permanent).
- **Custom grant** for the streak freeze: HAB-03 passes
  `grant: () => habitRepository.addFreeze(habitId)` (the existing method, capped at 2) and no
  unlock row is written (spec §4 note updated).
- **Rewarded offers** (`RewardedOffer`, in premium presentation): icon, title, and explanation ARB
  keys per `FeatureKey` kind:
  - `advancedReports`: "Unlock advanced reports for 24 hours"
  - `exportCsv` / `exportPdf`: "Unlock one CSV export" / "Unlock one PDF export"
  - `premiumTheme_*`: "Unlock the {theme} theme for good"
  - `streakFreeze`: "Get 1 streak freeze for {habit}"
  - `adFreeDay` has no offer and asserts in debug (FR-035).
- **Sheet controller** (`RewardedUnlockController`, one Notifier):
  - The `AppBottomSheet` opens and calls `adService.prepareRewarded()`, raced against
    `AdConfig.rewardedTimeout` (8 s) → `ready` or `unavailable`.
  - Tapping "Watch a short ad" (only in `ready`) calls `expectExternalActivity()`, then
    `adService.showRewarded(key, onEarned: grant)`. The plugin calls `onEarned` from
    `onUserEarnedReward`, and the grant is awaited there (FR-030). Then:
    - `earned` → pop `true`
    - `closedEarly` → state `closedEarly` ("Watch the whole ad to unlock") and a new
      `prepareRewarded()` with the same timeout (clarification Q5)
    - `failed` / `notReady` → `unavailable`, with "Try again"
  - "Not now" or a swipe down pops `false`. "Get Pro instead" pops `false`, then pushes
    `Routes.premium`.
  - Re-entrancy: the button is disabled while loading or showing (FR-046).
- **Pro bought while the sheet is open**: the sheet watches `proOwnedProvider` and pops `true`
  (the feature is now unlocked).
- **Wiring the locked states** (FR-032). `LockedFeatureOverlay` already has `onWatchAd`/`onGetPro`;
  it gains an optional `watchAdLabel`. Every call site passes both callbacks:
  - **EXP-11 (`reports_screen`)**: `watchAdLabel: "Watch an ad to unlock for 24 hours"`, then
    `showRewardedUnlock(context, FeatureKey.advancedReports, duration: 24h)`. The gate stream
    reopens the tab live.
  - **HAB-03 weekly chart**: the same key and duration.
  - **HAB-03 freeze card**: "Watch an ad to get a freeze" (free users), disabled at 2 with the
    existing `habit_freezeCapReached` text. "Add a freeze" (Pro, no ad). The debug button stays.
  - **SET-03**: `showRewardedUnlock(context, format.featureKey)`. On `true`, it calls
    `controller.export()`. On `false`, nothing starts (SET-03 AC).
  - **SET-04**: `tapTheme` on a locked theme keeps the preview and then opens
    `showRewardedUnlock(context, FeatureKey.premiumTheme(id))`. On `true`, it calls
    `tapTheme(id, unlocked: true)` (applies and stores it). The overlay keeps both buttons.
  - "Get Pro" on every overlay → `context.push(Routes.premium)`.
- **Lifecycle**: if the screen was left (or re-locked) while the ad was showing, the grant is
  already written and the caller's `mounted` check skips follow-ups such as auto-export (spec
  edge case).

**Rationale**: The grant-in-callback rule holds even when the app is killed after the reward.
The presenter seam lets every feature call one function without breaking feature isolation.

**Alternatives considered**: a premium route for PRM-02 (spec §5 says it is a bottom sheet, not a
route); writing unlocks after the sheet closes (would lose the reward if the app dies, and
breaks "only in `onUserEarnedReward`").

---

## R12. Unlock expiry as pure logic, and Pro in the gate

**Decision**:
- Extract `DriftFeatureGate._evaluate` into
  `lib/core/feature_gate/domain/unlock_policy.dart` (pure):

  ```dart
  UnlockDecision UnlockPolicy.evaluate(
    FeatureKey key,
    List<Unlock> unlocks, {
    required int effectiveNowMs,
    required bool debugUnlockAll,
    required bool proOwned,
  })
  ```

  It returns `(unlocked, nextExpiryMs)`.
- **Order of checks**:
  1. `proOwned` → unlocked, permanent, for every key except `adFreeDay`, which is never unlocked
     (FR-035).
  2. Debug switch (dev only, as before).
  3. A live unlock that is permanent, or that expires after effective now.
- `DriftFeatureGate` keeps its streams and timers and delegates to the policy. Its debug
  parameter stays the same. `proOwned` comes from `settings.removeAdsPurchased`, which the gate
  already watches.
- **Pro is a flag, not rows** (FR-039): no `purchase` unlock rows are written.
  - Pro is never cleared mid-session: a removal is staged in `proRemovalPending` and applied at the
    next bootstrap (R13), so locks and ads return together from that cold start.
  - Applying the revocation (clarification Q1) is just the flag going false, and every gated screen, theme
    fallback (`effectiveColorTheme`), and export lock reacts through the existing streams.
  - Premium theme keys are open-ended (`premiumTheme_{name}`), so rows per theme would need a
    catalog in core.
- Unit tests use `Clock.fixed` / `MutableClock`:
  - expiry at exactly `expiresAt`
  - a clock moved back with `latestSeenAt` ahead (the PRM-02 AC)
  - Pro on and off
  - debug on in prod ignored
  - `adFreeDay` never unlocked
  - an export one-time unlock left as permanent until consumed

**Rationale**: The user asked for unlock expiry as pure logic with an injected clock, and the
PRM-02 AC about restart and clock rollback is now a unit test of the policy, plus the existing
data test of the gate.

**Alternatives considered**: granting `purchase` rows on purchase and revoking them on refund
(duplicated state; theme rows need a catalog; the flag must exist anyway for SYS-01).

---

## R13. Billing (`lib/core/billing/`)

**Decision**:
- **Domain** (pure):
  - `ProStore` interface:
    - `Stream<List<StorePurchase>> purchaseUpdates`
    - `Future<StoreProduct?> loadProduct()`
    - `Future<void> buy(StoreProduct)`
    - `Future<OwnershipCheck> queryOwnership()`
    - `Future<void> completePurchase(StorePurchase)`
  - `StorePurchase`: status `purchased | pending | restored | error | canceled`, `productId`,
    `needsAcknowledge`.
  - `OwnershipCheck`: `owned | pending | notOwned | unavailable`.
  - `ProOwnershipPolicy` (pure, clarification Q1): applying a check to `(proOwned, notOwnedStreak)`
    gives:
    - `owned` → `(true, 0)`, and clears `removalPending`
    - `pending` → unchanged, and `proPurchasePending = true`
    - `notOwned` → streak + 1; when Pro was owned and the streak reaches 2 → `(true, 0)` with
      `removalPending = true` (bootstrap applies it on the next cold start); otherwise Pro is kept
    - `unavailable` (offline or error) → unchanged
- **Data** (the only `in_app_purchase` importer):
  - `InAppPurchaseProStore` with product id `pro_lifetime`:
    - `InAppPurchase.instance.queryProductDetails({'pro_lifetime'})` gives a localized `price`.
      Missing → `null` (FR-038 store-unavailable).
    - `buyNonConsumable(PurchaseParam(productDetails: p))`.
    - Ownership uses `InAppPurchaseAndroidPlatformAddition.queryPastPurchases()`, the API the
      spec names, which wraps Billing `queryPurchasesAsync`. It returns currently owned,
      unconsumed purchases; refunded or revoked purchases are gone. An `error` gives
      `unavailable`. A purchase whose Play state is `PENDING` gives `pending`.
    - `InAppPurchase.instance.isAvailable()` false → `unavailable`.
- **`ProService`** (core, keepAlive; `ProController` notifier for the UI):
  - **Start**: it subscribes to `purchaseStream` **during bootstrap**, before any query, as the
    plugin requires, so purchases completed while the app was closed are delivered.
  - **On `purchased` or `restored` for `pro_lifetime`**:
    1. `settings.setRemoveAdsPurchased(true)`, streak 0, pending false.
    2. If `pendingCompletePurchase`, call `completePurchase`, which acknowledges on Android
       (FR-039, FR-040). Every start's ownership check also completes any owned purchase still
       unacknowledged (`GooglePlayPurchaseDetails.billingClientPurchase.isAcknowledged == false`),
       well inside Play's 3 days.
  - **On `pending`**: `proPurchasePending = true`, and PRM-01 shows the pending state (US3-5).
  - **On `error`**: PRM-01 shows a plain error with "Try again". **On `canceled`**: nothing
    (US3-3).
  - **Start-up ownership check**: unawaited after the first frame. It never blocks startup and
    never decides SYS-01 ad init, which uses the cached flag (R4, R14).
  - **"Restore purchase"**: runs the same `queryOwnership()` (plus
    `InAppPurchase.instance.restorePurchases()` for parity). `owned` grants Pro; `notOwned` shows
    "No Pro purchase found for this Google account". It does **not** count toward the removal
    streak; only start-up checks count, as the clarification says.
- The full-screen Play dialog is an external activity: call `expectExternalActivity()` before
  `buy` (no SYS-03 when coming back).
- **Settings keys**: `removeAdsPurchased` (existing), `proNotOwnedStreak` (int 0–2),
  `proPurchasePending` (bool). None is restorable. Erase all data clears them (the next online
  start restores Pro, spec edge case).
- **No server-side verification** in MVP (spec assumption). The `purchaseToken` is not stored.

**Rationale**: This is the documented `in_app_purchase` flow (listen early, complete purchases,
restore), with a pure, testable policy for the clarified removal rule.

**Alternatives considered**: `restorePurchases()` alone for the ownership check (it only emits
`restored` events and cannot tell "none owned" from "no answer", so the streak rule can't be
implemented); reading the Pro state from `unlocks` rows (R12).

---

## R14. Pro effects across the app

**Decision**:
- **SYS-01**: bootstrap reads the cached `removeAdsPurchased`. If it is true, it skips consent,
  SDK init, and preloads entirely, and fixes `sessionStartedWithAds = false` (SYS-01 AC, FR-043).
- **Mid-session purchase**:
  - `adsAllowedProvider` turns false → `NoAdsService` → every ad widget collapses, and the
    preloaded interstitial and rewarded ad are disposed.
  - The gate unlocks every key, so locked overlays disappear.
  - `SettingsScreen` hides the premium card and "Ad privacy choices".
  - PRM-01 shows "You have Pro".
- **HAB-03 freeze card**: `proOwned` → an "Add a freeze" button (no ad, capped at 2) instead of
  "Watch an ad to get a freeze" (FR-044).
- **Consent privacy row**: hidden while Pro is owned (spec assumption). No UMP call is made for Pro
  users.

---

## R15. Developer tools (dev flavor only)

**Decision**:
- **"Unlock all features (debug)"**: unchanged. `UnlockPolicy` keeps it after the Pro check. Ads
  are unaffected (FR-047).
- **"Reset ad counters"** is a new `ListTile` in the SET-01 Developer section (`devTools`). It calls
  `AdDebugTools.resetCounters()` (core/ads), which:
  - sets `adsInstallAt = effectiveNow − 2 days − 1 min` (the install-age rule counts as met)
  - clears `adsLastInterstitialAt`, `adsInterstitialDay`, and `adsInterstitialsToday`
  - clears the in-memory `expenseSaves` and sets `isFirstSessionOfDay = false` for the current
    session
  - calls `ConsentInformation.instance.reset()`, so the consent form replays on the next cold
    start (dev only)
  - shows the snackbar "Ad counters reset"
- `AdDebugTools` is bound only when `debugToolsAvailableProvider` is true. Prod builds get a no-op
  implementation, and the tile is not built (FR-048).

---

## R16. Spec and constitution updates (Constitution I, FR-052)

**Decision**:
- **`docs/spec.md` is updated in this plan run (2026-10-22, Changes line)**:
  - §4: `adFreeDay` is kept but never granted, a streak freeze adds to `freezesAvailable`, Pro
    comes from the flag, and the new settings keys are listed.
  - DSH-01 Ads: the Home interstitial rule, with the ad-free day removed.
  - EXP-02 Ads: only new entries count.
  - HAB-03: rewarded and Pro freezes; the debug button is kept.
  - SET-02 Ads: success message (snackbar), for both manual paths.
  - SET-03 and SET-04: final rewarded behavior.
  - PRM-01: the removal streak, pending, and store-unavailable states.
  - PRM-02: rewards, early close, and the API with `grant`.
  - §11: table rows, the session definition, the `AdService` shape, `NoAdsService` use, and the
    App ID placeholder.
  - §15.8: the ad-free day is removed.
- **Constitution 1.0.2 → 1.0.3 (PATCH)**: Principle VI says "With `NoAdsService` (Pro, ad-free
  day, tests)". It must drop "ad-free day". This is wording only, no principle change. It is done
  with `/speckit-constitution` before `/speckit-implement`. It is not a gate failure, because the
  principle's rule (no ad space with `NoAdsService`) is unchanged.
- **`docs/CLAUDE.md`** (a task in this feature):
  - Ads: `google_mobile_ads` only in `lib/core/ads/data/`; screens use `AppBannerAd`,
    `AppNativeAd`, `AdService`, `showRewardedUnlock`.
  - Billing: `in_app_purchase` only in `lib/core/billing/data/`.
  - PRM-01 and PRM-02 live in `lib/features/premium/`.
- Code comments that say "until PRM-02 exists", "T4.4", or "feature 008 adds it" (for example in
  `locked_feature_overlay.dart`, `theme_preview_card.dart`, `freeze_card.dart`, and
  `ad_service.dart`) are updated in the tasks that touch those files.

---

## R17. Testing and layering scans

**Decision**:
- **Unit tests** (pure, injected clock):
  - `interstitial_cap_test.dart`: table-driven per rule, the counter reset, blocking that doesn't
    reset the counter, and a simulated week (SC-004)
  - `ad_session_test.dart`: the 30-min gap, the first session of the day, and a mid-session day
    change
  - `ad_unit_ids_test.dart`: dev and debug always test IDs, a missing prod format, a test App ID
    in prod
  - `native_ad_slots_test.dart`
  - `unlock_policy_test.dart`
  - `pro_ownership_policy_test.dart`
- **Data tests** (in-memory Drift):
  - the gate with Pro and clock rollback
  - `AdsSettingsStore` round-trip and backup exclusion
  - the reset keeping `adsInstallAt`
  - the `ProService` purchase-stream handling with a `FakeProStore`
- **Service tests**:
  - `AdMobAdService` against a `FakeAdsSdk` seam inside `data/` (the plugin is wrapped by
    `AdsSdk`, so the service logic is testable without platform channels)
  - zero loads before consent or after Pro
  - preload after show
  - the probe blocking
- **Widget tests**: `NoAdsService` or a scripted `FakeAdService` (`test/helpers/fakes.dart`):
  - `AppBannerAd`/`AppNativeAd`: 0 dp with no ads or on failure, animate-in, retry timings with
    `fakeAsync`, dispose on switch
  - banner screens list; DSH-01 native position (DSH-01 AC); EXP-01 slots and the period-change
    rebuild; HAB-01 4th-card rule; EXP-08
  - EXP-02, HAB-02, and SET-02 trigger timing:
    - the EXP-02 AC: the fake records that the trigger happens after the route popped, and the
      probe is false while `/expenses/add` is current
  - PRM-02 states (ready, timeout, early close → retry, earned → `true`, Not now, Get Pro); each
    locked state's buttons (FR-032)
  - PRM-01 states (loading, unavailable, pending, error, owned, restore found and not found)
  - SET-01 premium card, privacy row, and dev tools; HAB-03 freeze card variants
- **Integration and manual checks** (quickstart): real test ads on a device, the UMP EEA debug
  form, a Play internal-testing purchase, restore, and refund. These cannot run in CI.
- **Layering scans** (`test/core/theme/no_hardcoded_style_test.dart`):
  - `package:google_mobile_ads` only under `lib/core/ads/data/`
  - `package:in_app_purchase*` only under `lib/core/billing/data/`
  - `lib/features/premium/` imports no other feature
  - the existing 003 scan "(e) the expense feature never imports ad code" is relaxed to "never
    imports `lib/core/ads/data/` or `google_mobile_ads`", because EXP-01/03/04/06/11 now place
    `AppBannerAd` and `AppNativeAd` (the scan's FR-038 was "no ads in feature 003").
- **Manifest test** (`test/android/manifest_test.dart`): asserts the `APPLICATION_ID` meta-data
  uses `${admobAppId}` and that no `ca-app-pub-` id other than Google's test publisher
  `3940256099942544` appears anywhere in the repo (SC-010).
- **Goldens**: DSH-01, EXP-01, and HAB-01 goldens stay valid because widget tests bind
  `NoAdsService` (0 dp). New goldens for PRM-01 and PRM-02 are not constitution-required; they
  get widget tests at 200% font and 360 dp instead.

---

## R18. Android manifest and permissions

**Decision**:
- Add the App ID meta-data (R2).
- Add `<meta-data android:name="com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION"
  android:value="true"/>` and `…OPTIMIZE_AD_LOADING` for faster SDK start (GMA 23+ flags).
- The SDK merges `com.google.android.gms.permission.AD_ID` (needed for ads, declared in the data
  safety form, T5.2), and Billing merges `com.android.vending.BILLING`. Neither is added by hand.
- No `tools:remove`.
- `MainActivity.kt` adds a `getAdmobAppId` branch to the `dailytrack/window` channel (R2).

---

## R19. Strings and accessibility

**Decision**: About 55 new ARB keys × 3 languages, added through `tool/l10n/phase0_strings.py`.
- **Prefixes**:
  - `ads_*`: badge "Ad", banner label, reset counters
  - `premium_*`: PRM-01 copy, benefits, states, restore results, SET-01 card
  - `rewarded_*`: PRM-02 titles and explanations per offer, buttons, timeout, early close
  - `locked_*`: the "Watch an ad to unlock for 24 hours" and "Watch an ad to get a freeze"
    variants
  - `privacy_adChoices`
- **PRM-01**:
  - The price comes from the store (`StoreProduct.price`) and is inserted with a placeholder
    (`premium_buyFor: "Get Pro for {price}"`).
  - Benefits are a list of `ListTile`s with icons and text, not color.
  - One primary button (§15.1).
- **PRM-02**: buttons start with a verb ("Watch a short ad", "Get Pro instead", "Not now").
- Both screens work at 200% font and 360 dp. The sheet scrolls inside `AppBottomSheet`.
- Semantics: the ad badge is read as "Advertisement", and the sheet's spinner has the label
  "Loading ad".

---

## Resolved unknowns

All Technical Context items are resolved. There is no remaining NEEDS CLARIFICATION.
