# Quickstart: Ads, Rewarded Unlocks, and Pro Purchase

How to prove this feature works. Design details are in [research.md](research.md),
[data-model.md](data-model.md), and [contracts/](contracts/).

## 1. Prerequisites

- Flutter 3.47.7 / Dart 3.13.5, an Android device or emulator with Google Play services (API 24+).
- `flutter pub get` after `google_mobile_ads: 9.2.0` and `in_app_purchase: 3.3.1` are added.
- **Dev builds need nothing else**: they use Google's test App ID and test ad unit IDs only.
- For purchase testing (§4.3), developer setup outside the repo:
  - an AdMob account and app, whose real App ID goes in `android/local.properties` as
    `admob.appId=…`, never committed
  - a Play Console app with the one-time product `pro_lifetime`
  - an internal testing track with a license tester account
  - an upload-signed build installed from that track

## 2. Quality gates (every task)

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format --set-exit-if-changed .
flutter test --exclude-tags golden      # Windows/macOS; goldens only on Linux CI
```

## 3. Focused test runs

```bash
flutter test test/core/ads/            # cap, session, unit IDs, slots, widgets, AdMob service with FakeAdsSdk
flutter test test/core/feature_gate/   # UnlockPolicy (expiry, clock rollback, Pro, debug)
flutter test test/core/billing/        # ProOwnershipPolicy, ProService with FakeProStore
flutter test test/features/premium/    # PRM-01, PRM-02
flutter test test/core/theme/no_hardcoded_style_test.dart   # plugin isolation scans
flutter test test/android/manifest_test.dart                # App ID placeholder, no real IDs
```

## 4. Manual device walkthrough

### 4.1 Consent and placements (dev flavor)

1. Uninstall, then run
   `flutter run --flavor dev --dart-define=UMP_DEBUG_GEOGRAPHY=eea --dart-define=UMP_TEST_DEVICE_ID=<id from logcat>`.
   **Expect**: the consent form appears over the splash before onboarding. Logcat shows no ad
   request before you answer.
2. Finish onboarding and add 5 habits and 40 transactions.
   **Expect** test ads labeled "Test Ad":
   - a banner on EXP-01, EXP-03, EXP-04, EXP-06, EXP-11, HAB-01, HAB-03, HAB-04, SET-01, SET-02
   - natives on DSH-01 (after the 2nd card), EXP-01 (after rows 8, 23, 38), EXP-08 (end), and
     HAB-01 (after the 4th card)
   - each native has an "Ad" badge top-left
   - nothing jumps under your finger while an ad loads
3. Turn airplane mode on and reopen EXP-01. **Expect** no banner space and no empty boxes.
4. Open More. **Expect** "Ad privacy choices", because of the EEA debug geography. Tap it and the
   form reopens.
5. Profile build on a mid-range device (about 4 GB RAM), consent already answered:
   `flutter run --flavor dev --profile --trace-startup`, then cold start 5 times. **Expect** the
   median `timeToFirstFrameMicros` plus Home data under 1.5 s (SC-009). Record the numbers.

### 4.2 Interstitial cap (dev flavor)

1. More → Developer → "Reset ad counters". Kill the app and start it again, so a new session
   begins and it is no longer the first session of the day.
2. Add 4 new expenses from Home's + button. **Expect** a test interstitial over Home only after
   the 4th add screen closes, never while the keypad shows.
3. Add 4 more right away. **Expect** no interstitial (3-minute gap).
4. Edit an existing expense 4 times. **Expect** no counting.
5. Create a new habit, and back up to a file then dismiss the snackbar, more than 3 minutes apart.
   **Expect** interstitials, up to 4 per day in total.

### 4.3 Rewarded unlocks (dev flavor, debug switch off)

| Step | Expect |
| --- | --- |
| EXP-11 → Trends → "Watch an ad to unlock for 24 hours" → watch fully | Trends, Accounts, Year, and Custom open; the HAB-03 chart opens too |
| Same, but close the test ad early | The sheet stays open with "Watch the whole ad to unlock" and a new ad loads |
| SET-03 → PDF → Watch an ad → full | Export starts at once; the next PDF export is locked again |
| SET-04 → tap Saffron → Watch → full | Saffron is applied and stays unlocked after restart |
| HAB-03 → "Watch an ad to get a freeze" ×2 | Freezes go 0 → 2, then the button is disabled |
| Airplane mode → any Watch | "Ad not available, try again later" within 8 s |

### 4.4 Pro purchase (prod release, internal testing track, license tester)

1. PRM-01 shows the local price. Buy with the test card. **Expect**:
   - all ads vanish at once
   - overlays disappear
   - the SET-01 card is hidden
   - PRM-01 shows "You have Pro"
2. Restart. **Expect** no ad requests in logcat (no `Ads` load lines) and no consent form.
3. Uninstall, reinstall, then PRM-01 → "Restore purchase". **Expect** Pro is restored.
4. Use the "slow test card, approves after a few minutes". **Expect** the pending message, then
   Pro on approval.
5. Refund in Play Console. Then:
   - First online start: Pro stays.
   - Second online start: Pro stays for that session (the removal is staged).
   - Third cold start: Pro is gone, and locks and ads return together.
   - Offline starts don't change anything.

### 4.5 Build checks

| Command | Expect |
| --- | --- |
| `flutter build appbundle --flavor prod --release` (no ID) | Builds with a warning; on device, no ads requested |
| `… -PstoreBuild=true` (no ID) | Fails: "AdMob App ID missing: …" |
| `flutter build apk --flavor dev --release` | Test App ID in the merged manifest |

## 5. Acceptance criteria → automated tests

| AC (source) | Test |
| --- | --- |
| §11 Cap: install age, 3-min gap, 4/day, counter reset | `test/core/ads/domain/interstitial_cap_test.dart` |
| §11 `NoAdsService`: no ad widget takes space | `test/core/ads/widgets/ad_widgets_no_ads_test.dart` + each placement screen test with `NoAdsService` (0 dp) |
| §11 No ad request before consent | `test/core/ads/data/admob_ad_service_test.dart` ("no loads until canRequestAds"), `test/app/bootstrap_ads_test.dart` |
| DSH-01 Native never above the first module card | `test/features/dashboard/home_native_ad_test.dart` (1 and 2 modules) |
| EXP-01 Period change updates list, totals, ads | `test/features/expense/transactions_native_ads_test.dart` |
| EXP-02 Interstitial never while the keypad or form is visible | `test/features/expense/transaction_form_interstitial_test.dart` (probe false on `/expenses/add`; trigger after pop) |
| EXP-11 Locked tabs: blurred preview + "Watch an ad to unlock for 24 hours" | `test/features/expense/reports_locked_test.dart` |
| SET-03 Cancelling the rewarded ad does not start the export | `test/features/settings/export_rewarded_test.dart` |
| SYS-01 Ads SDK not initialized when Remove Ads purchased | `test/app/bootstrap_ads_test.dart` |
| PRM-01 After purchase, no ad of any kind, including after restart | `test/core/billing/pro_service_test.dart` + `test/app/bootstrap_ads_test.dart` (restart with the flag: zero SDK calls) |
| PRM-01 Reinstall + "Restore purchase" restores Pro | `test/features/premium/premium_screen_test.dart` (FakeProStore owned) |
| PRM-02 Closing the ad early grants nothing | `test/features/premium/rewarded_unlock_sheet_test.dart` |
| PRM-02 Expiry after restart and clock rollback | `test/core/feature_gate/unlock_policy_test.dart` + `drift_feature_gate_test.dart` |
| Clarification Q1: Pro removed after 2 online "not owned" | `test/core/billing/pro_ownership_policy_test.dart` |
| US5 Dev and debug use test IDs only; no real IDs committed | `test/core/ads/domain/ad_unit_ids_test.dart`, `test/android/manifest_test.dart` |
