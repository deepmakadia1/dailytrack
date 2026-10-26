# Screen Contracts: Ads, Rewarded Unlocks, and Pro

Keys in `code font` are widget `Key`s used by tests. ARB key prefixes are in research R19.

---

## PRM-01 Premium (`lib/features/premium/presentation/screens/premium_screen.dart`)

- **Route**: `/premium` on the root navigator, a full-screen modal with a close (X) button. No
  banner, native, or interstitial ads (FR-009, FR-037).
- **Controller**: `PremiumController` (one Notifier) with state `PremiumState {phase, product?,
  error?}` and phases `loading | ready | unavailable | purchasing | pending | error | owned`
  (data-model.md §5).
- **Layout, top to bottom**:
  1. "DailyTrack Pro" headline (`headlineSmall`).
  2. Benefits list (`premium_benefits`): No ads, All themes, Advanced reports, Unlimited exports,
     Unlimited streak freezes up to the cap. Each row has an icon and text.
  3. Primary button `premium_buy`: "Get Pro for {price}".
     - Disabled with a spinner in `loading` or `purchasing`.
     - In `unavailable`, disabled with the text `premium_storeUnavailable` ("Store not available
       right now, try again later").
     - Hidden in `owned`.
  4. Text button `premium_restore`: "Restore purchase", always shown unless `owned`. Snackbars:
     `premium_restored` ("Pro restored"), `premium_restoreNotFound` ("No Pro purchase found for
     this Google account"), `premium_storeUnavailable`.
  5. Note `premium_accountNote`: "Your purchase is tied to your Google account."
- **States**:
  - `pending` → info card `premium_pending` ("Pro unlocks when the payment completes").
  - `error` → `ErrorState` text with "Try again".
  - `owned` → card `premium_owned` ("You have Pro. Thanks for your support.") and the benefits
    list.
  - Cancelled → back to `ready` with no message (US3-3).
- **Empty state**: none. This is a fixed-control screen (Complexity Tracking).

## PRM-02 Rewarded unlock sheet (`lib/features/premium/presentation/rewarded_unlock_sheet.dart`)

- **Shell**: `AppBottomSheet`, scrollable. No banner or native ads.
- **Layout**: feature icon (`CategoryAvatar` style, 40 dp circle), title, one-line explanation.
  - Primary `rewarded_watch`: "Watch a short ad". While loading it shows a spinner with semantics
    "Loading ad" and is disabled.
  - Secondary `rewarded_getPro`: "Get Pro instead".
  - Text `rewarded_notNow`: "Not now".
- **Titles**:

  | Key | Title |
  | --- | --- |
  | `advancedReports` | "Unlock advanced reports for 24 hours" |
  | `exportCsv` | "Unlock one CSV export" |
  | `exportPdf` | "Unlock one PDF export" |
  | `premiumTheme_{id}` | "Unlock the {theme} theme for good" |
  | `streakFreeze` | "Get 1 streak freeze for {habit}" |

- **Messages**:
  - `rewarded_unavailable`: "Ad not available, try again later", with "Try again" as the primary
    button.
  - `rewarded_closedEarly`: "Watch the whole ad to unlock", shown above the button while a new ad
    loads.
- **Result**: pops `true` only after an earned reward and a finished grant, or when Pro becomes
  owned while the sheet is open. Every other close pops `false`.

## Locked states (FR-032), shared `LockedFeatureOverlay`

`LockedFeatureOverlay` gains `watchAdLabel` (String?, default `locked_watchAd` "Watch an ad").
Both actions are now always supplied:

| Screen | Overlay key | Watch-ad label | Rewarded call | On `true` |
| --- | --- | --- | --- | --- |
| EXP-11 locked tab or period | `reports_locked` | "Watch an ad to unlock for 24 hours" | `advancedReports`, 24 h | gate stream reopens the tab |
| HAB-03 weekly chart | `weekly_chart_locked` | same | `advancedReports`, 24 h | chart shows |
| SET-03 locked format | `export_locked` | "Watch an ad to unlock one export" | `exportCsv` / `exportPdf` | `export()` starts at once |
| SET-04 locked theme | `theme_preview_locked` | "Watch an ad to unlock this theme" | `premiumTheme_{id}` | theme applied and stored |

"Get Pro" (`locked_getPro`, enabled) → `context.push(Routes.premium)`. With Pro owned or a live
unlock, the overlay is never built.

**SET-04 tap behavior**: tapping a locked theme previews it behind the overlay and opens PRM-02
once. "Not now" leaves the preview with both buttons.

## HAB-03 streak freeze card (`freeze_card.dart`)

| Condition | Buttons |
| --- | --- |
| Free user, freezes < 2 | `use_freeze` (as before) + `watch_ad_freeze` "Watch an ad to get a freeze" → `showRewardedUnlock(streakFreeze, grant: addFreeze(habitId), subjectName: habit.name)` |
| Free user, freezes = 2 | `watch_ad_freeze` disabled + `habit_freezeCapReached` text |
| Pro | `add_freeze_pro` "Add a freeze" (no ad), disabled at 2 |
| Dev, debug switch on | `add_freeze_debug` stays (any of the above) |

HAB-01 "Skip today" is unchanged.

## SET-01 More / Settings additions

- **Premium card** `premium_card`, the first item: "Remove ads and unlock everything" → `/premium`.
  Hidden while Pro is owned (FR-045).
- **Privacy section**: `ad_privacy_choices` "Ad privacy choices" → `consent.showPrivacyOptionsForm()`.
  Shown only while `privacyOptionsRequired` is true and Pro is not owned (FR-014).
- **Developer section** (dev only): `reset_ad_counters` "Reset ad counters" → snackbar "Ad
  counters reset" (FR-048).
- **Banner** `AppBannerAd` in `bannerSlot`.

## Ad placements (FR-015 to FR-018)

| Screen | File | Banner | Native |
| --- | --- | --- | --- |
| DSH-01 | `home_screen.dart` | — | `home_native` after `min(2, moduleCards)` module card slots |
| EXP-01 | `transactions_screen.dart` | ✓ | `transactions_native_{i}` at `nativeAdRowIndexes(rowCount)`, content state only |
| EXP-03 | `transaction_detail_screen.dart` | ✓ | — |
| EXP-04 | `categories_screen.dart` | ✓ | — |
| EXP-06 | `accounts_screen.dart` | ✓ | — |
| EXP-08 | `budgets_screen.dart` | — | `budgets_native` at the end of the content list |
| EXP-11 | `reports_screen.dart` | ✓ | — |
| HAB-01 | `habits_today_screen.dart` | ✓ | `habits_native` after the 4th scheduled card when ≥ 5, not in Reorder |
| HAB-03 | `habit_detail_screen.dart` | ✓ | — |
| HAB-04 | `archived_habits_screen.dart` | ✓ | — |
| SET-01 | `settings_screen.dart` | ✓ | — |
| SET-02 | `backup_screen.dart` | ✓ | — |

Every other screen has no ad widget, and a test scans `lib/` for `AppBannerAd(` / `AppNativeAd(`
uses against this table.

## Interstitial triggers (FR-019 to FR-023)

| Screen | When | Call |
| --- | --- | --- |
| EXP-02 | after `_close()` on save of a **new** entry; after "Save and add another" with `screenClosing: false` | `maybeShowInterstitial(ExpenseSaved(screenClosing: …))` |
| HAB-02 | after `_close()` on save in add mode | `maybeShowInterstitial(HabitCreated())` |
| SET-02 | when the success `SnackBar` of "Save backup file" or "Back up now" closes | `maybeShowInterstitial(ManualBackupSucceeded())` |
