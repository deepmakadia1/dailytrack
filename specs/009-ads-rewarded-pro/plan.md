# Implementation Plan: Ads, Rewarded Unlocks, and Pro Purchase (§11, PRM-01, PRM-02, T4.1–T4.5)

**Branch**: `009-ads-rewarded-pro` | **Date**: 2026-10-22 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/009-ads-rewarded-pro/spec.md`

## Summary

This feature delivers Phase 4 (`docs/spec.md` §11, §10 PRM-01 and PRM-02, §14 T4.1–T4.5): AdMob
ads with UMP consent, rewarded unlocks, and the one-time Pro purchase.

**Approach**:
- **`lib/core/ads/`** (R5): `google_mobile_ads` 9.2.0 is imported only in `data/`.
  - `AdService` keeps the §11 members and adds `loadBanner`/`loadNative`. They return a
    plugin-free `AdView`, so `AppBannerAd` and `AppNativeAd` never import the plugin.
  - `adServiceProvider` switches between `AdMobAdService` and `NoAdsService` from one
    `adsAllowed` provider. A purchase removes every ad at once; a cold start with Pro never
    touches the SDK.
- **Consent** (R4): UMP runs in SYS-01 before `MobileAds.initialize`.
  - It blocks only when consent is still unknown. Returning users start ads from the stored
    `canRequestAds` and refresh in the background (SC-009).
  - "Ad privacy choices" in SET-01 appears when required.
- **App ID and unit IDs** (R2, R3):
  - The App ID goes in through a Gradle variant manifest placeholder: the test ID for dev and
    debug builds, `local.properties` or `ADMOB_APP_ID` for prod release.
  - Only store builds fail without it (clarification Q2). Other prod builds fall back to the test
    App ID, detected at runtime, and request nothing.
  - Unit IDs come from `--dart-define` for prod release only.
- **Banner and native widgets** (R6, R7):
  - The banner is a large anchored adaptive banner. The native uses the medium template, styled
    from `AppTokens`, with a Flutter "Ad" badge header.
  - Both are 0 dp until loaded, animate in over 200 ms, retry after 30, 60, and 120 s, and are
    disposed on unmount or on the switch to no ads.
- **Placements** (R8): banners go in `AppScaffold.bannerSlot` on the 10 listed screens. Natives
  go on DSH-01, EXP-01 (pure slot math at 8, 23, and 38, with day slivers split so fixed extents
  are kept), EXP-08, and HAB-01.
- **Interstitials** (R9, R10):
  - The frequency cap and session rules are **pure logic** (`InterstitialCap`, `AdSession`) with
    an injected clock and the shared `effectiveNow`.
  - Three triggers fire after their screen or success snackbar closes: new EXP-02 entries
    (Q4), new habits, and manual backups.
  - Before showing, an `AdScreenProbe` checks the app is in the foreground, unlocked, and on a
    reading screen. Home counts as reading (Q1).
- **PRM-02** (R11): `showRewardedUnlock()` is a core function that delegates to a presenter
  bound to `features/premium`.
  - The grant runs inside `onUserEarnedReward`. An early close keeps the sheet open and reloads
    (Q5).
  - Every locked state is wired with "Watch an ad" and "Get Pro": EXP-11, the HAB-03 chart and
    freeze card, SET-03, and SET-04.
- **Unlock expiry** (R12) becomes the pure `UnlockPolicy`. Pro is read from
  `removeAdsPurchased`, not from unlock rows.
- **`lib/core/billing/`** (R13): `in_app_purchase` 3.3.1, with the `purchaseStream` subscribed
  during bootstrap.
  - Ownership is checked with `queryPastPurchases` on every start, and the pure
    `ProOwnershipPolicy` removes Pro only after 2 online "not owned" results (Q1).
  - Purchases are acknowledged through `completePurchase`. Restore and pending purchases are
    handled.
- **PRM-01** is in `lib/features/premium/`. SET-01 gains the premium card and the dev
  "Reset ad counters".
- The ad-free day reward is dropped (spec clarification).
- **No Drift schema change** (v4): 8 new settings keys, plus setters for 3 existing ones.
- **`docs/spec.md` was updated in this plan run** (FR-052, R16).

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged); Kotlin 2.4 / AGP 9.1 for
the Android host

**Primary Dependencies**:
- Existing (spec §2): `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0,
  `drift` 2.35, `freezed` 4.0, `intl` 0.20, `clock` 1.1, `flutter_native_splash` 2.4.
- **New** (user-specified, spec §2, research R1):
  - `google_mobile_ads` 9.2.0 (bundles UMP; GMA Android 25.5.0)
  - `in_app_purchase` 3.3.1, plus `in_app_purchase_android` (resolved by it) for
    `queryPastPurchases` and the acknowledgement state
  - Nothing else

**Storage**:
- SQLite through Drift `AppDatabase`, **schema v4 unchanged**.
- New `settings` keys:
  - Pro: `proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending` (removal staged for the next
    cold start, so locks and ads return together)
  - Interstitial cap: `adsInstallAt` (kept by Erase all data), `adsLastInterstitialAt`,
    `adsInterstitialDay`, `adsInterstitialsToday`, `adsLastSessionDay`
- New setters for `removeAdsPurchased`, `adConsentStatus`, and the ad counters.
- Existing tables carry the rewards: `unlocks` gets rewarded rows (24 h, one-time, permanent), and
  `habits.freezesAvailable` gets rewarded freezes.
- In-memory session state: `sessionStartedWithAds`, `isFirstSessionOfDay`, `expenseSaves`.

See [data-model.md](data-model.md).

**Testing**: `flutter_test` + `mocktail` + `fake_async` (through `flutter_test`).
- **Unit tests** (pure, `Clock.fixed`/`MutableClock`):
  - `InterstitialCap` (each rule, counter reset, simulated week)
  - `AdSession`, `AdUnitIds.resolve`, `nativeAdRowIndexes`
  - `UnlockPolicy` (expiry, rollback, Pro, debug, `adFreeDay`), `ProOwnershipPolicy`
- **Service tests**:
  - `AdMobAdService` over a `FakeAdsSdk` seam (no loads before consent or after Pro, preload after
    show, probe blocking)
  - `ProService` over `FakeProStore`
  - bootstrap ads ordering
- **Data tests**: the gate with Pro and clock rollback, the settings round-trip and backup
  exclusion, the reset keeping `adsInstallAt`.
- **Widget tests** with `NoAdsService` or `FakeAdService`:
  - the ad widgets (0 dp, animate, retry, dispose)
  - every placement and trigger
  - PRM-01 and PRM-02 states; every locked state
  - SET-01 additions and the HAB-03 freeze card
- **Scans**: plugin isolation, banner and native placement table, no real `ca-app-pub-` IDs.
- **Manual device checks**: real test ads, the UMP EEA form, a Play internal-testing purchase,
  restore, refund (quickstart §4).

**Target Platform**: Android API 24+ (the Dart is iOS-ready, but iOS ads and purchases are not
configured or tested)

**Project Type**: Mobile app (single Flutter project with an Android host)

**Performance Goals**:
- Cold start to Home stays < 1.5 s when consent is not required: consent refresh and SDK init are
  unawaited, and the first interstitial preload waits 10 s (SC-009).
- Ads never shift content under a touch: 0 dp until loaded, then a 200 ms height animation
  (SC-003).
- PRM-02 is ready or "not available" within 8 s (SC-006).
- After a purchase, ads disappear and features unlock within 1 s (SC-007).
- EXP-01 keeps `SliverFixedExtentList` for 60 fps with 10k rows.

**Constraints**:
- No ad request before consent; none ever after Pro, including at cold start (§11, PRM-01 ACs).
- `google_mobile_ads` only in `core/ads/data/`; `in_app_purchase` only in `core/billing/data/`.
- No app data in ad requests (FR-010).
- No real App ID or unit ID committed (SC-010).
- Offline: ads and purchases fail quietly; everything else works (Constitution V).
- ARB en, hi, gu; 200% font at 360 dp; status never shown by color alone.

**Scale/Scope**:
- 2 new screens (PRM-01, PRM-02 sheet).
- 16 changed screens:
  - banners and natives on 12 screens (DSH-01; EXP-01, 03, 04, 06, 08, 11; HAB-01, 03, 04;
    SET-01, 02)
  - interstitial triggers in EXP-02, HAB-02, and SET-02
  - locked states in EXP-11, HAB-03 (×2), SET-03, and SET-04
  - SET-01 additions
- 2 new core areas (`core/ads` built out, `core/billing`) and 1 new feature (`features/premium`).
- About 10 pure domain types.
- Android: the Gradle variant placeholder and check task, 3 manifest meta-data entries, 1
  channel method.
- About 55 ARB keys × 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs used; spec updated before code | ✅ `docs/spec.md` was updated on 2026-10-22 (17 edits, Changes line). It covers the ad-free day removal; the DSH-01 and EXP-02 interstitial rules; SET-02, SET-03, SET-04, and HAB-03 final rewarded behavior; PRM-01 removal, pending, and unavailable; PRM-02 rewards, early close, and API; §11 table, session, `AdService` shape, and App ID; §4 keys; §15.8. Tests and commits use `PRM-01/02`, `SYS-01`, `DSH-01`, `EXP-01/02/08/11`, `HAB-01/02/03`, `SET-01/02/03/04` |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; one notifier per screen | ✅ The plugins are confined to `core/ads/data/` and `core/billing/data/`, and scans enforce it (R17). The ad widgets use the plugin-free `AdView` (R5). `showRewardedUnlock` is in core and bound to `features/premium` through a presenter provider in the composition root, so expense, habit, and settings never import premium (R11). "Get Pro" uses `Routes.premium` (features may import `routes.dart`). The cap, session, unlock, and ownership policies are pure domain. PRM-01 (`PremiumController`) and PRM-02 (`RewardedUnlockController`) each have one notifier. The 003 scan "(e) expense never imports ad code" is relaxed to "never `core/ads/data/` or the plugin", because ads now belong on expense screens (Complexity Tracking) |
| III. Data integrity & privacy | int money; UTC ms; migrations; no egress; secrets | ✅ No money or schema change. Timestamps are UTC ms and day keys are local `yyyy-MM-dd`. No app data goes into ad requests (no keywords, no content URL, FR-010). Child-directed treatment stays unspecified. Release ad unit IDs come from `--dart-define`, and the App ID from git-ignored `local.properties` or an env var. Only Google's public test IDs are committed, and a scan enforces it (SC-010). The purchase token is not stored. Ad and Pro keys are never in backups |
| IV. Test-backed acceptance | ≥ 1 test per criterion; fakes + NoAdsService | ✅ Every copied AC (§11 ×3, DSH-01, EXP-01, EXP-02, EXP-11, SET-03, SYS-01, PRM-01 ×2, PRM-02 ×2) maps to a test ([quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests)). The ad frequency cap is unit-tested, as the constitution requires. Widget tests keep `NoAdsService` by default (`pumpTestApp`), and `FakeAdService` is used only where ad behavior is under test. Ad-behavior tests use fakes under the constitution 1.0.3 clarification of IV (Complexity Tracking) |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; ARB; 48 dp; 200%; never color only | ✅ PRM-01 and PRM-02 use `AppScaffold`, `AppBottomSheet`, `ErrorState`, and tokens. Loading, error, and content states are designed; PRM-01 is a fixed-control screen with no empty state (Complexity Tracking). The "Ad" badge is text, not color. Cold start is not slowed (R4). Offline: ads collapse, the store shows "not available", and Restore still works |
| VI. Isolated monetization | ads only via AdService; test IDs in dev; placements per §11; rewarded only from PRM-02; interstitials only after finished actions via the cap; consent first; `NoAdsService` = 0 dp | ✅ All of these are designed in R3–R11. Constitution VI's wording "(Pro, ad-free day, tests)" is out of date now that the ad-free day is dropped. The rule itself holds. Amended to 1.0.3 on 2026-10-22 (R16) |
| VII. Locked stack, YAGNI | §2 packages only; new deps justified | ✅ Only `google_mobile_ads` and `in_app_purchase`, both in spec §2 and the user's input (`in_app_purchase_android` is its own platform package). No mediation, Remote Config, app-open ads, or server verification. `AdConfig` is a const class, ready for Remote Config later without adding it now |

**Result**: PASS. **After Phase 1 design**: PASS, with the items below justified in Complexity
Tracking. The constitution PATCH 1.0.3 landed on 2026-10-22.

## Project Structure

### Documentation (this feature)

```text
specs/009-ads-rewarded-pro/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R19
├── data-model.md        # Phase 1: settings keys, session state, domain types, unlock rows, state machines
├── quickstart.md        # Phase 1: gates, focused runs, device walkthrough, AC→test map
├── contracts/
│   ├── services.md      # AdService, AdView, providers, widgets, showRewardedUnlock, consent, cap, probe, gate, billing, bootstrap, layering
│   ├── screens.md       # PRM-01, PRM-02, locked states, freeze card, SET-01, placements, triggers
│   ├── routes.md        # /premium, non-reading routes
│   └── android.md       # Gradle placeholder + check, manifest, channel, dart-defines, build commands
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
android/app/
  build.gradle.kts                             # admobAppId placeholder per variant, checkAdmobAppId
  src/main/AndroidManifest.xml                 # APPLICATION_ID + OPTIMIZE_* meta-data
  src/main/kotlin/.../MainActivity.kt          # dailytrack/window: getAdmobAppId
lib/
  app/
    bootstrap.dart                             # step 3: install time, ProService.start, consent, ads init, session
    production_overrides.dart                  # bind consent, ad unit IDs, adService switch, probe, presenter, proStore, debug tools
    router/{routes,app_router}.dart            # /premium (root, fullscreenDialog)
  core/
    ads/
      ad_service.dart                          # interface (+ load*, prepareRewarded, RewardedOutcome) + NoAdsService
      ad_view.dart                             # NEW AdView, NativeAdLook
      ad_providers.dart                        # adConfig, adUnitIds, consentService, probe, AdsSessionGate, adsAllowed, adService, privacyOptionsRequired, adDebugTools
      rewarded_unlock.dart                     # NEW showRewardedUnlock + RewardedUnlockPresenter
      widgets/{app_banner_ad,app_native_ad}.dart   # NEW
      domain/{ad_config,ad_unit_ids,ad_trigger,interstitial_cap,ad_session,consent_service,ad_placement,rewarded_outcome,native_ad_slots,ad_screen_probe,interstitial_cap_store,ad_debug_tools}.dart   # NEW, pure
      data/{admob_ad_service,ads_sdk,admob_ads_sdk,admob_ad_views,ump_consent_service,ads_settings_store,admob_manifest_source}.dart   # NEW, only google_mobile_ads importers
    billing/
      domain/{store_product,store_purchase,ownership_check,pro_state,pro_ownership_policy,pro_store}.dart   # NEW, pure
      data/in_app_purchase_pro_store.dart      # NEW, only in_app_purchase importer
      pro_service.dart, billing_providers.dart # NEW
    feature_gate/
      domain/unlock_policy.dart                # NEW pure (extracted)
      data/drift_feature_gate.dart             # delegates; Pro flag
    utils/effective_clock.dart                 # NEW shared effectiveNow
    settings/                                  # codec (+7 keys), AppSettings fields, repository setters
    reset/data/drift_app_reset_service.dart    # keep adsInstallAt
    widgets/locked_feature_overlay.dart        # watchAdLabel; comments updated
    l10n/ (via tool/l10n/phase0_strings.py)    # ads_*, premium_*, rewarded_*, locked_*, privacy_adChoices
  features/
    premium/                                   # NEW feature
      presentation/
        screens/premium_screen.dart            # PRM-01
        controllers/premium_controller.dart (+ state)
        rewarded_unlock_sheet.dart             # PRM-02 + PremiumRewardedUnlockPresenter
        controllers/rewarded_unlock_controller.dart (+ state)
        rewarded_offers.dart                   # FeatureKey → icon/title/explanation
    dashboard/presentation/screens/home_screen.dart          # native slot
    expense/presentation/screens/{transactions,transaction_detail,categories,accounts,budgets,reports,transaction_form}_screen.dart   # banners, natives, EXP-11 overlay, EXP-02 trigger
    habit/presentation/screens/{habits_today,habit_detail,archived_habits,habit_form}_screen.dart   # banners, native, chart overlay, HAB-02 trigger
    habit/presentation/widgets/freeze_card.dart               # watch-ad / Pro / debug buttons
    habit/presentation/controllers/habit_detail_controller.dart   # proOwned, addFreeze grant
    settings/presentation/screens/{settings,backup,export,themes}_screen.dart   # card, privacy row, dev reset, banners, SET-02 trigger, SET-03/04 rewarded
    settings/presentation/widgets/{privacy_section,theme_preview_card}.dart
pubspec.yaml                                   # google_mobile_ads 9.2.0, in_app_purchase 3.3.1, in_app_purchase_android
docs/CLAUDE.md                                 # ads/billing/premium rules (R16)
test/
  core/ads/{domain,data,widgets}/   core/billing/   core/feature_gate/unlock_policy_test.dart
  features/premium/   features/{dashboard,expense,habit,settings}/ (placements, triggers, locked states)
  app/bootstrap_ads_test.dart   android/manifest_test.dart   core/theme/no_hardcoded_style_test.dart (scans)
  helpers/fakes.dart                           # FakeAdService, FakeConsentService, FakeProStore, FakeRewardedUnlockPresenter, FakeAdScreenProbe
```

**Structure Decision**: This is the existing single Flutter project, using the user's folders:
- all ad code in `lib/core/ads/`, with the plugin only in `data/`
- billing in `lib/core/billing/`
- PRM-01 and PRM-02 in the new `lib/features/premium/`

Screens elsewhere reach ads only through `AppBannerAd`, `AppNativeAd`, `AdService`, and
`showRewardedUnlock`. The composition root binds every implementation.

## Complexity Tracking

| Item | Why needed | Simpler alternative rejected because |
| --- | --- | --- |
| `AdService` gains `loadBanner`/`loadNative` returning a plugin-free `AdView`, and `showRewarded` returns `RewardedOutcome` instead of `bool` | The ad widgets must render an `AdWidget` without importing the plugin (user rule, Constitution II). PRM-02 needs to tell an early close from a failure (clarification Q5) | Widgets importing `AdWidget` break the layering rule. A `bool` result can't drive the "Watch the whole ad" vs "not available" messages. The spec §11 line was updated |
| `showRewardedUnlock` in core delegating to a presenter bound to `features/premium` | Expense, habit, and settings must open PRM-02, but features can't import each other | Putting the PRM-02 UI in core contradicts the user's folder choice (`features/premium`). A route for PRM-02 contradicts spec §5 (bottom sheet) |
| Runtime App ID read-back through the `dailytrack/window` channel | Non-store prod builds without the ID must request no ads (clarification Q2), and only native code knows which App ID was merged | Parsing Flutter's `dart-defines` in Gradle is undocumented. Failing all prod builds breaks CI PR builds |
| Pro as the `removeAdsPurchased` flag, read by `UnlockPolicy`, instead of `purchase` unlock rows | Premium theme keys are open-ended, and refund removal (Q1) must be atomic | Rows per key need a theme catalog in core and a revoke-all step; the flag must exist anyway for SYS-01 |
| Relaxing the 003 scan "(e) expense never imports ad code" | EXP-01/03/04/06/11 must now place `AppBannerAd`/`AppNativeAd` (§11) | Keeping it would forbid the required placements; the stricter "no `core/ads/data/`, no plugin" scan keeps the intent |
| Erase all data keeps `adsInstallAt` | The spec edge case keeps the install time, so the 2-day rule can't be reset by erasing | A separate store outside the settings table adds a second persistence path for one value |
| No empty state on PRM-01 (constitution 1.0.1 allows this for fixed controls) | PRM-01 is a fixed set of controls whose data (the product) either loads or is unavailable | An empty state could never be reached; "unavailable" is the designed state |
| Constitution PATCH 1.0.3 (Principle VI wording, Principle IV test clarification) | The ad-free day is dropped (clarification), so "(Pro, ad-free day, tests)" is out of date; IV's "widget tests MUST use `NoAdsService`" needs an explicit carve-out for ad-behavior tests (analysis C1) | Leaving them creates doc conflicts; neither rule's intent changes |
| Ad-behavior widget tests bind `FakeAdService` / `FakeAdsSdk` instead of `NoAdsService` (constitution 1.0.3, IV) | The §11 and DSH-01 ACs, the "Ad" badge, animate-in, retry, and the Pro switch can only be observed with an ad that loads | Testing them only through unit tests would leave widget layout (0 dp, badge, placement) unverified |
