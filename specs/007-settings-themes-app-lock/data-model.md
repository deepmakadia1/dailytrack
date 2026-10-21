# Data Model: Settings, Themes, and App Lock (T3.1)

**Feature**: `specs/007-settings-themes-app-lock` · **Date**: 2026-10-21

**Schema**: unchanged at **v4**. There are no new tables or columns. The new persisted values are:
- rows in the existing key-value `settings` table (§1);
- entries in `flutter_secure_storage` (§2), which is never part of the Drift database or any backup.

No Drift migration is needed.

---

## 1. Settings keys

### New keys

These are added to `AppSettings` (`lib/core/settings/domain/app_settings.dart`) and `SettingsCodec`.
Each key decodes on its own and falls back to its default when it is missing, malformed, or outside
the allowed set (the existing codec rule).

| Key | JSON type | Allowed values | Default | Field | Setter |
| --- | --- | --- | --- | --- | --- |
| `dateFormat` | string | `dMMMy`, `ddMMy`, `mmddy`, `iso` | `dMMMy` | `String dateFormat` | `setDateFormat` |
| `dailySummaryTime` | string `HH:mm` (local) | `00:00`–`23:59` | `21:00` | `String dailySummaryTime` | `setDailySummaryTime` |
| `lockAfterSeconds` | int | `0`, `60`, `300` | `60` | `int lockAfterSeconds` | `setLockAfterSeconds` |
| `hideInRecents` | bool | | `false` | `bool hideInRecents` | `setHideInRecents` |
| `fontSize` | string | `default`, `large` | `default` | `String fontSize` | `setFontSize` |

### Existing keys that gain setters or validation

| Key | Change |
| --- | --- |
| `themeMode` | New `setThemeMode(String)`, allowed `system`/`light`/`dark`. An unknown value decodes as `system`, as it does today. |
| `selectedTheme` | New `setSelectedTheme(String id)`, where `id` is one of the 8 catalog ids (§4). An unknown id decodes as `default`. The stored value is kept even while the theme is locked (FR-020). |
| `firstDayOfWeek` | New `setFirstDayOfWeek(int)`, allowed `1`, `6`, `7`. Any other stored value decodes as `1`. |
| `lockEnabled` | New `setLockEnabled(bool)`. It is written only by `LockService`, after the credential (research R6). |
| `biometricEnabled` | New `setBiometricEnabled(bool)`. It is written only by `LockService`, after a successful prompt. |
| `notificationsEnabled`, `budgetAlertsEnabled`, `habitRemindersEnabled` | The setters already exist. They now get UI in SET-01. |
| `locale`, `currencyCode` | The setters already exist. They now get UI in SET-01. |

### Rules

- `setDailySummaryTime` rejects anything that is not two-digit `HH:mm` within range. The codec does
  the same on read.
- No setting stores a currency-converted amount. Changing `currencyCode` changes only formatting
  (SET-01 AC, FR-003).
- **Backup**: these keys belong to the settings section once T3.2 exists. The `lock.*` secure
  entries in §2 are never backed up.

## 2. Secure storage entries (`flutter_secure_storage`)

All keys are prefixed `lock.`. `LockService.reset()` deletes every `lock.*` key. Values are UTF-8
JSON.

### `lock.pin`: `PinRecord`

| Field | Type | Rules |
| --- | --- | --- |
| `v` | int | Record version, currently `1`. An unknown version counts as `credentialUnavailable`. |
| `alg` | string | `pbkdf2-sha256` |
| `iter` | int | Iteration count used for this hash. Default 120,000 (research R3). Verification uses the stored value. |
| `salt` | string | Base64 of 16 random bytes from `SecureRandom.safe`, new for every set or change. |
| `hash` | string | Base64 of the 32-byte derived key. |

The plain PIN is never stored, logged, or kept in state longer than the hashing call.

### `lock.lockout`: `LockoutState`

| Field | Type | Rules |
| --- | --- | --- |
| `failedAttempts` | int ≥ 0 | Consecutive wrong PINs since the last success. |
| `level` | int ≥ 0 | 0 means no lockout has happened yet. Level *k* ≥ 1 lasts `min(30 s × 2^(k−1), 900 s)`. |
| `lockedAtUtcMs` | int? | When the current or last lockout started. |
| `lockedUntilUtcMs` | int? | When it ends. Null means none has started. |

A missing or corrupt `lock.lockout` decodes as the initial state, unless `lock.pin` exists and the
read threw. A storage error counts as "locked out for the max length", so the lockout fails safe.

### State transitions (`LockoutPolicy`, research R4)

```text
Initial (failed=0, level=0)
  ── wrong PIN, failed+1 < 5 ──────────────▶ failed+1, level 0  (hint from failed ≥ 3: "N attempts left")
  ── wrong PIN, failed+1 = 5 ──────────────▶ Locked(level 1, 30 s)
Locked(level k)
  ── any PIN input ─────────────────────────▶ rejected, nothing counted (keypad disabled)
  ── biometric success ─────────────────────▶ Initial
  ── time ≥ lockedUntil ────────────────────▶ Cooldown(level k)
  ── clock moved back (now < lockedAt) ─────▶ re-anchored: lockedAt = now, lockedUntil = now + length(k)
Cooldown(level k)  (lockout over, level kept; UI warns "Next wrong PIN locks the app for length(k+1)")
  ── wrong PIN ─────────────────────────────▶ Locked(level k+1, length min(30 s·2^k, 15 min))
  ── correct PIN or biometric success ──────▶ Initial
```

`LockService.verifyPin` persists the new state **before** it returns, so killing the app straight
after a wrong guess still counts it (SYS-03 AC "Lockout timer survives app restart").

## 3. Lock session (in memory, `LockSession` notifier)

| Field | Type | Rules |
| --- | --- | --- |
| `locked` | bool | True at a cold start when `settings.lockEnabled`. True after a resume that meets the lock-after rule. False after a successful unlock or PIN set. |
| `backgroundedAt` | `DateTime?` (UTC) | Set on `paused`/`hidden`, cleared on resume. |
| `externalActivity` | bool | Set by `expectExternalActivity()` and cleared on the next resume (research R15). |
| `pendingLocation` | `String?` | A notification target that arrived while locked. Opened after unlock, then cleared. |
| `mode` | enum `route`/`overlay` | `route`: the cold-start `/lock` route is showing. `overlay`: the resume lock is covering the app (research R7). |

The lock-on-resume rule (pure function `shouldLockOnResume`) locks when **all** of these hold:
1. `lockEnabled` is on.
2. The app was backgrounded (`backgroundedAt != null`).
3. One of these is true:
   - `lockAfterSeconds == 0`;
   - the elapsed time is negative (the clock moved back);
   - the elapsed time is ≥ `lockAfterSeconds`, unless it was an `externalActivity` that took ≤ 5 min;
   - it was an `externalActivity` that took more than 5 min.

## 4. Color theme catalog (`lib/core/theme/color_themes.dart`)

| `id` (stored) | Label key | Seed constant (`AppColors`) | Hex | Premium | Feature key |
| --- | --- | --- | --- | --- | --- |
| `default` | `theme_default` | `seed` (existing) | #0F766E | no | none |
| `indigo` | `theme_indigo` | `seedIndigo` | #4F46E5 | no | none |
| `saffron` | `theme_saffron` | `seedSaffron` | #D97706 | yes | `premiumTheme_saffron` |
| `forest` | `theme_forest` | `seedForest` | #15803D | yes | `premiumTheme_forest` |
| `rose` | `theme_rose` | `seedRose` | #E11D48 | yes | `premiumTheme_rose` |
| `midnight` | `theme_midnight` | `seedMidnight` | #1E3A8A | yes | `premiumTheme_midnight` |
| `ocean` | `theme_ocean` | `seedOcean` | #0369A1 | yes | `premiumTheme_ocean` |
| `mono` | `theme_mono` | `seedMono` | #525252 | yes | `premiumTheme_mono` |

- The feature key is `FeatureKey.premiumTheme(id)`, which already exists
  (`lib/core/feature_gate/domain/feature_key.dart`) and stores `premiumTheme_<id>` in `unlocks`.
- `effectiveColorTheme`: if the stored theme is free, or its gate says unlocked, use it; otherwise use
  `default`.
- The hex values are seeds only. The generated schemes must pass the contrast test in research R11.
  If a seed fails, it is adjusted in `app_colors.dart`, and this table and the test are updated with
  it.

## 5. Other value types

| Type | Where | Fields / values |
| --- | --- | --- |
| `LockStatus` | `core/security/domain` | `disabled`, `enabled`, `credentialUnavailable` |
| `UnlockResult` | `core/security/domain` | `success`, `wrong(attemptsLeft: int?, nextLockout: Duration?)`, `lockedOut(remaining: Duration)` |
| `BiometricAvailability` | `core/security/domain` | `none`, `notEnrolled`, `available` |
| `PinFlowMode` | `features/lock/presentation` | `set`, `change`, `disable` (route query `mode`) |
| `PinFlowStep` | `features/lock/presentation` | `current`, `enterNew`, `confirmNew`, `offerBiometric`, `done` |
| `FullDateFormat` | `core/utils/date_formats.dart` | `dMMMy`, `ddMMy`, `mmddy`, `iso` (patterns in research R13) |
| `FontSizeOption` | `core/theme` | `defaultSize` (1.0), `large` (×1.15, combined scale capped at 2.0) |
| `LockAfter` | `core/security/domain` | `immediately` (0), `oneMinute` (60), `fiveMinutes` (300) |

## 6. Erase all data (`AppResetService.eraseAll`, research R16)

| Step | Scope | Atomic | If it fails |
| --- | --- | --- | --- |
| 1 | Delete all rows in every Drift table (`allTables`, including `settings`, `unlocks`, and seed markers) | Yes, one transaction | Nothing changed; error and "Try again" |
| 2 | `TrackerModule.onEraseAll` for every registered module (Expense: `receipts/` folder; Habit: cancel reminders) | Best effort | Ignored (data rows are already gone) |
| 3 | `NotificationService.cancelAll()` | Best effort | Ignored |
| 4 | `LockService.reset()`: delete `lock.*` | Best effort | Ignored (`lockEnabled` is gone; the next set overwrites) |
| 5 | `LockSession.reset()`, then `ref.invalidate(bootstrapProvider)`: reseed and route to SYS-02 | n/a | Bootstrap failure shows the SYS-01 "Retry" |
