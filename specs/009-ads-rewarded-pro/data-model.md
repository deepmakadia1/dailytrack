# Data Model: Ads, Rewarded Unlocks, and Pro Purchase

Feature: `specs/009-ads-rewarded-pro` · Date: 2026-10-22 · Research: [research.md](research.md)

**No Drift schema change.** The database stays at v4, so this feature has no migration. New
state goes into the existing key-value `settings` table, the existing `unlocks` table, and the
existing `habits.freezesAvailable` column. A few values are held only in memory for the current
session.

---

## 1. Settings keys (`settings` table)

The codec is `lib/core/settings/data/settings_codec.dart`. The typed fields go in `AppSettings`
(freezed). Writes go through new `SettingsRepository` methods.

| Key | Type (JSON) | Default | Written by | Restorable (backup) | Erase all data |
| --- | --- | --- | --- | --- | --- |
| `removeAdsPurchased` | bool | `false` | `ProService` (purchase, restore, start-up check) | no | cleared |
| `proNotOwnedStreak` | int 0–2 | `0` | `ProService` start-up check (R13) | no | cleared |
| `proPurchasePending` | bool | `false` | `ProService` (pending/complete) | no | cleared |
| `proRemovalPending` | bool | `false` | `ProService` (2nd "not owned"); applied and cleared by the next bootstrap | no | cleared |
| `adConsentStatus` | text: `unknown`, `required`, `notRequired`, `obtained` | null | `UmpConsentService` mirror (display only) | no | cleared |
| `adsInstallAt` | int (UTC ms) | null → set on first bootstrap | `AdsSettingsStore` | no | **kept** (re-inserted in the erase transaction) |
| `adsLastInterstitialAt` | int (UTC ms) | null | `AdMobAdService` after a shown interstitial | no | cleared |
| `adsInterstitialDay` | text `yyyy-MM-dd` (local) | null | same, with the count | no | cleared |
| `adsInterstitialsToday` | int ≥ 0 | `0` | same | no | cleared |
| `adsLastSessionDay` | text `yyyy-MM-dd` (local) | null | `AdSession` on each new session | no | cleared |
| `rewardedDay` | text `yyyy-MM-dd` (local) | null | PRM-02 grant (FR-053) | no | cleared |
| `rewardedCounts` | JSON object `{featureKey: int}` for `rewardedDay` | `{}` | PRM-02 grant, inside the reward callback | no | cleared |

The existing keys `removeAdsPurchased`, `adConsentStatus`, and `latestSeenAt` get setters. The
other keys are new.

**New `SettingsRepository` methods**:
- `setProState({required bool owned, required int notOwnedStreak, required bool pending, bool
  removalPending = false})` writes all four in one transaction.
- `setAdConsentStatus(String)`
- `setAdsInstallAt(int)`
- `recordInterstitialShown({required int at, required String dayKey, required int countToday})`
- `setAdsLastSessionDay(String)`
- `resetAdCounters({required int installAt})` (dev tools)

**Rules**:
- None of these keys is in `BackupSettingsPolicy.restorableKeys`; a test asserts it (FR-025).
- `adsInstallAt` is set once and only ever lowered by the dev "Reset ad counters" (R15).
- Every timestamp is UTC ms; every day key is the local `yyyy-MM-dd` of the effective now.
- A `proNotOwnedStreak` greater than 2 never happens: the policy resets it to 0 when it reaches 2.

---

## 2. In-memory session state (not persisted)

| Value | Owner | Lifetime | Notes |
| --- | --- | --- | --- |
| `sessionStartedWithAds` | `AdsSessionGate` (bootstrap) | process | false when Pro was cached at cold start, or consent didn't allow ads; never flips back to true in the same process |
| `isFirstSessionOfDay` | `AdSession` | current session | Computed when a session starts (R9); set to false by dev reset |
| `expenseSaves` | `AdMobAdService` | current session | Counts new EXP-02 entries; reset when an interstitial is shown or a new session starts |
| `backgroundedAt` | `AdSession` | process | From `AppLifecycleListener`; decides the 30-min new-session rule |
| preloaded interstitial / rewarded | `AdMobAdService` | until shown or the service is disposed | At most one of each |

---

## 3. Domain types

### `core/ads/domain/` (pure Dart)

- **`AdConfig`** (const): `installAgeDays 2`, `minGap 3 min`, `maxPerDay 4`,
  `savesPerInterstitial 4`, `sessionGap 30 min`, `rewardedTimeout 8 s`,
  `retryBackoff [30 s, 60 s, 120 s]`, `afterCloseDelay 400 ms`, `consentUpdateTimeout 5 s`,
  `nativeFirstRow 8`, `nativeEvery 15`, `nativeMaxPerLoad 3`, `habitsNativeMinCards 5`,
  `habitsNativeAfter 4`.
- **`AdUnitIds`**: `banner`, `native`, `interstitial`, `rewarded` (each `String?`); constants
  `test` and `none`; `fromEnvironment()`; `resolve(...)` (R3).
- **`AdTrigger`** (sealed): `ExpenseSaved(screenClosing: bool)`, `HabitCreated()`,
  `ManualBackupSucceeded()`.
- **`InterstitialCapState`** (freezed): `installAt` (DateTime UTC), `lastShownAt` (DateTime?),
  `dayKey` (String?), `shownToday` (int), `isFirstSessionOfDay` (bool), `expenseSaves` (int).
- **`CapDecision`** (sealed): `CapAllow` or `CapBlock(CapBlockReason)`. The reasons are
  `installAge`, `firstSession`, `gap`, `dailyMax`, `notEnoughSaves`, `notPreloaded`,
  `notOnReadingScreen`, `adsDisabled`. The last three are added by the service, not the pure cap.
- **`InterstitialCap`**: `check(state, {effectiveNow, todayKey, trigger})`,
  `afterShown(state, {now, todayKey})`, and `afterExpenseSave(state)`.
- **`AdSession`**: `start({required DateTime now, required String todayKey, String?
  lastSessionDayKey})` → `(isFirstSessionOfDay, newLastSessionDayKey)`;
  `isNewSession({required DateTime now, DateTime? backgroundedAt, required Duration gap})`.
- **`RewardedOutcome`** (enum): `earned`, `closedEarly`, `notReady`, `failed`.
- **`BannerPlacement` / `NativePlacement`** (enums): `NativePlacement.home`, `transactions`,
  `budgets`, `habits`. Banners have one placement (`bottom`).
- **`nativeAdRowIndexes(int rowCount, {first, every, max})`** → `List<int>` (pure, R8).
- **`ConsentService`** (interface) and **`ConsentResult`** `{bool canRequestAds, bool
  privacyOptionsRequired, ConsentStatusView status}`.
- **`AdScreenProbe`** (interface): `bool get canShowFullScreenAd`.
- **`InterstitialCapStore`** (interface): `load()`, `saveShown(...)`, `setInstallAtIfMissing(...)`,
  `setLastSessionDay(...)`, `resetForDebug(...)`.

### `core/feature_gate/domain/`

- **`UnlockPolicy.evaluate(key, unlocks, {effectiveNowMs, debugUnlockAll, proOwned})`** →
  `UnlockDecision {bool unlocked, int? nextExpiryMs}` (R12). Pro unlocks every key except
  `adFreeDay`.
- `FeatureKey`, `Unlock`, `UnlockSource`, and `UnlockRepository` are unchanged. `adFreeDay` stays
  defined (append-only) and is never granted.

### `core/billing/domain/` (pure Dart)

- **`StoreProduct`**: `id` (always `pro_lifetime`), `title`, `price` (a localized string, shown
  as-is).
- **`StorePurchase`**: `productId`, `status` (`purchased`, `pending`, `restored`, `error`,
  `canceled`), `needsCompletion` (bool), `errorCode` (String?).
- **`OwnershipCheck`** (enum): `owned`, `pending`, `notOwned`, `unavailable`.
- **`ProState`** (freezed): `owned` (bool), `notOwnedStreak` (int), `pending` (bool),
  `removalPending` (bool).
- **`ProOwnershipPolicy.apply(ProState, OwnershipCheck)`** → `ProState` (R13 table, §5 below).
- **`ProStore`** (interface): `purchaseUpdates`, `isAvailable()`, `loadProduct()`, `buy(product)`,
  `queryOwnership()`, `complete(purchase)`.

### `core/utils/effective_clock.dart`

- `DateTime effectiveNow(DateTime clockNow, int? latestSeenAtMs)` returns the later of the two,
  in UTC. It is shared by the cap and the unlock policy.

---

## 4. Unlock records (existing `unlocks` table, unchanged schema)

| Reward | Row written | `expiresAt` | Used up by |
| --- | --- | --- | --- |
| Advanced reports | `advancedReports`, source `rewardedAd` | effective now + 24 h | expiry |
| One export | `exportCsv` or `exportPdf`, source `rewardedAd` | null | `consumeOne` after a file is created (feature 008) |
| Premium theme | `premiumTheme_{id}`, source `rewardedAd` | null (permanent) | never |
| Streak freeze | **no row**; `habits.freezesAvailable += 1` (max 2) via `HabitRepository.addFreeze` | — | "Use a freeze" / "Skip today" |
| Pro | **no row**; `removeAdsPurchased = true` | — | removed only by the 2-check rule |

Rows are written only inside the `onEarned` callback that runs from `onUserEarnedReward`
(FR-030).

---

## 5. State machines

### Pro ownership (start-up check, R13, clarification Q1)

| Current (owned, streak) | Check result | Next (owned, streak) | Pending |
| --- | --- | --- | --- |
| any | `owned` | (true, 0), clears `removalPending` | false |
| (o, s) | `pending` | (o, s) | true |
| (true, 0) | `notOwned` | (true, 1) | false |
| (true, 1) | `notOwned` | (true, 0) with **`removalPending = true`**: Pro stays for this session; the next bootstrap applies the removal | false |
| (false, s) | `notOwned` | (false, 0) | false |
| (o, s) | `unavailable` | (o, s) | unchanged |

"Restore purchase" applies only the `owned` row and never increments the streak.

**Applying a staged removal** (bootstrap step 3b′): if `proRemovalPending`, write
`setProState(owned: false, notOwnedStreak: 0, pending: false, removalPending: false)` before ads,
consent, or the gate are read. Locks and ads therefore return together, from that cold start on
(spec FR-041 and edge case; analysis I1).

### Purchase flow (PRM-01)

```text
loading ──product ok──▶ ready ──buy──▶ purchasing ──purchased──▶ owned (ack sent)
   │                      ▲               ├──pending──▶ pending ──later purchased──▶ owned
   └─no product/offline─▶ unavailable     ├──canceled──▶ ready (no message)
                          (Restore stays) └──error──▶ error ("Try again" → ready)
already owned at open ───────────────────────────────────────▶ owned
```

### PRM-02 sheet (R11, clarification Q5)

```text
open ─▶ loading ──ready (< 8 s)──▶ ready ──watch──▶ showing ──earned──▶ [grant] ─▶ closed(true)
          │                         ▲                 ├──closedEarly──▶ closedEarly ─▶ loading (retry)
          └──timeout/fail──▶ unavailable ──retry──┘  └──failed/notReady──▶ unavailable
any state ──Not now / swipe──▶ closed(false)
any state ──Get Pro instead──▶ closed(false) + push /premium
Pro becomes owned while open ──▶ closed(true)
```

### Ad slot (`AppBannerAd`, `AppNativeAd`)

```text
idle(0 dp) ─▶ loading(0 dp) ──loaded──▶ shown(animate 0 → h, 200 ms)
                 │ fail
                 ▼
             waiting(0 dp) ──after 30/60/120 s──▶ loading … ──3 fails──▶ gaveUp(0 dp)
any ──ads disabled / unmount──▶ disposed(0 dp)
```

### Interstitial check (per trigger, R9 and R10)

```text
trigger ─▶ ads enabled? ─▶ update saves ─▶ closing? ─▶ wait 400 ms ─▶ preloaded? ─▶ cap allows?
         ─▶ probe: foreground + unlocked + reading screen? ─▶ show ─▶ afterShown ─▶ preload next
(any "no" ends silently; the save counter is kept)
```

---

## 6. Validation rules (from the spec)

- **Cap**: block when `effectiveNow − installAt < 2 days`; when in the first session of the day;
  when `effectiveNow − lastShownAt < 3 min`; when `shownToday ≥ 4` on the same local day; and for
  an expense trigger when `expenseSaves < 4` (FR-020, FR-022).
- **Freezes**: `freezesAvailable` stays in 0..2. The rewarded and Pro "add" buttons are disabled
  at 2 (FR-034, FR-044).
- **Rewarded duration**: only `advancedReports` has a duration (24 h). Everything else is
  permanent or one-time.
- **Prices**: a store `price` string is shown verbatim; an empty or missing price is treated as
  store-unavailable.
- **Ad unit IDs**: in a prod release, an empty dart-define for a format means that format is
  disabled. A dev or debug build never reads them.
