# Contract: Screens (T3.1)

Every screen has one Riverpod controller with a freezed state that handles loading, data, and error
explicitly. Every screen uses `AppScaffold`, `AppTokens`, and the shared widgets, with all strings in
ARB (en, hi, gu). Every screen follows §15.10. There are no ads on any screen in this feature.

## SET-01 Settings: `lib/features/settings/presentation/screens/settings_screen.dart`

**Controller**: `SettingsController`. Its state is `AsyncValue<SettingsViewData>` (settings, visible
module ids, app version, `canNotify`, `devTools`), and it has one write method per row.

| Section | Rows (in order) | Behavior |
| --- | --- | --- |
| General | Language · Currency · First day of week · Date format | Each opens an `AppBottomSheet` picker that shows the current value as subtitle, and writes when tapped. Currency uses the shared `CurrencyPickerList` (search). Language options: System default, English, हिन्दी, ગુજરાતી (native names, not translated). First day of week: Monday, Saturday, Sunday. Date format options show today's date in each format. |
| Appearance | Theme and colors | → `/more/themes` |
| Modules | Enable or reorder trackers | → `/more/modules` |
| Notifications | Notifications (master switch) · Daily summary time · Budget alerts (switch) · Habit reminders (switch, only when `habit` is visible) | Master off: the other rows are disabled and keep their values. After each switch: `onNotificationSettingsChanged` for the visible modules. Daily summary opens `showTimePicker` and shows the time with `MaterialLocalizations.formatTimeOfDay`. A "Notifications are blocked" note with "Open settings" appears when master is on and `canNotify == false`. |
| Security | App lock (subtitle On/Off) | → `/more/security` |
| Data | Erase all data (text in the `error` color) | `EraseAllDataFlow`: `ConfirmDialog` → `TypedConfirmDialog("DELETE")` → progress → `AppResetService.eraseAll()`. Failure: an `ErrorState` dialog with "Try again". |
| Privacy | Privacy policy · Terms | → `/more/web/privacy`, `/more/web/terms` |
| About | Rate us · Share app · Send feedback · App version (not tappable; "1.0.0 (1)") · Open-source licenses | See research R14. The feedback fallback dialog shows the support address with "Copy email". |
| Developer (dev flavor only, `debugToolsAvailableProvider`) | Unlock all features (debug) | Moved unchanged from `MorePlaceholderScreen` (keys `developer_section`, `debug_unlock_all`). |

**States**:
- Loading: a `SettingsSection` skeleton after 300 ms.
- Error: `ErrorState` + "Try again" (re-reads settings).
- Content: the list above.

No premium banner, backup or export rows, "Ad privacy choices", or banner slot.

## SET-04 Themes and appearance: `lib/features/settings/presentation/screens/themes_screen.dart`

**Controller**: `ThemesController`. State: `themeMode`, `selectedThemeId`, `previewThemeId`,
`unlocked: Map<String, bool>` (live from `colorThemeUnlockedProvider`), and `fontSize`.

Layout from top to bottom:
1. **`ThemePreviewCard`**: a sample dashboard made of a summary card, a progress bar, an amount, and
   a chip. It is rendered in `Theme(data: AppTheme.light/dark(seed: preview.seed))` for the
   effective brightness, with `AppTextScaler` for the selected font size.
   - If `previewThemeId` is locked, the card is wrapped in `LockedFeatureOverlay(onWatchAd: null,
     onGetPro: null, message: l10n.themes_lockedMessage)`.
2. **Theme mode**: a `ChipSelector` (single) with System, Light, and Dark. It writes immediately.
3. **Colors**: an adaptive grid (minimum tile 96 dp) of 8 tiles, each a swatch circle plus a name.
   - The selected tile has a check icon and the label "Selected".
   - Premium locked tiles have a lock icon (semantic label `premium_lockedLabel`) and a "Pro" chip.
   - Tapping a free or unlocked tile writes `selectedTheme` and sets the preview to it.
   - Tapping a locked tile sets only the preview (research R12).
4. **Font size**: a `ChipSelector` with Default and Large. It writes immediately.

Each tile is ≥ 48 dp with a semantic label such as "Saffron, Pro, locked" or "Indigo, selected".
After the debug unlock is turned on, the lock badges disappear live, with no reload.

## SET-05 Security: `lib/features/settings/presentation/screens/security_screen.dart`

**Controller**: `SecurityController`. State: `lockStatus`, `biometric: BiometricAvailability`,
`biometricEnabled`, `lockAfterSeconds`, `hideInRecents`.

| Row | Enabled when | Action |
| --- | --- | --- |
| App lock (switch) | always | Off → on: push `pinPath('set')`. The switch shows on only after the settings stream confirms it. On → off: push `pinPath('disable')`. |
| Change PIN | lock on | push `pinPath('change')`; success snackbar "PIN changed" |
| Use fingerprint / face unlock (switch) | lock on and `biometric == available` | `LockService.setBiometricEnabled`. A cancelled prompt leaves it off. When disabled, the subtitle explains why ("Turn on app lock first" / "Set up fingerprint or face unlock in your phone's settings"). |
| Lock after | lock on | A bottom sheet with radio options Immediately, After 1 minute, and After 5 minutes |
| Hide app content in recents (switch) | always | `setHideInRecents`. Subtitle: "Also blocks screenshots." |

## SYS-03 Unlock: `lib/features/lock/presentation/screens/unlock_screen.dart`

**Controller**: `UnlockController`. State: `entered` (0–4 digits, never the digits themselves in
semantics), `error` (wrong with `attemptsLeft?`), `lockoutRemaining`, `biometricShown`, and `status`.

- **Layout**: app logo, "Enter PIN", `PinDots(4)`, an error or lockout line (a live region), and
  `PinKeypad`. The biometric key is shown only when biometric is on and available, and the status is
  not `credentialUnavailable`. Below the keypad is a "Forgot PIN?" `TextButton`.
- **On open**: registers `unlockVisible` (`FLAG_SECURE`), and shows the biometric prompt
  automatically once if allowed (also during a lockout).
- **On the 4th digit**: `LockService.verifyPin`:
  - success → light haptic, then either `router.go(from)` (route mode) or `session.unlocked()`
    (overlay mode), followed by the pending location if there is one;
  - wrong → shake (unless `disableAnimations`), then clear;
  - lockedOut → disable the keys and show the countdown "Try again in 0:28". A 1 s ticker re-reads
    `lockoutRemaining`.
- **`credentialUnavailable`**: the keypad is hidden. An explanation is shown, and "Forgot PIN?" is
  the only action.
- **Forgot PIN?**: an `AppBottomSheet` with the "can't be recovered" text, "Erase all data"
  (`EraseAllDataFlow`), and "Cancel". Cancel leaves the lockout untouched.
- **Back**: in route mode, `PopScope(canPop: false, onPopInvokedWithResult: SystemNavigator.pop)`; in
  overlay mode, the `LockAwareBackButtonDispatcher`.
- **States**: loading (the status read; the keypad is disabled until it arrives), error (a storage
  read failure shows the explanation plus "Forgot PIN?"), and content.

## SYS-04 Set / change PIN: `lib/features/lock/presentation/screens/pin_screen.dart`

**Controller**: `PinController(mode)`. State: `step: PinFlowStep`, `entered`, `firstEntry` (kept only
in memory until confirmed), `error`, `lockoutRemaining`, `biometricOffer`.

| Mode | Steps |
| --- | --- |
| `set` | enterNew → confirmNew → (offerBiometric, if available) → done |
| `change` | current → enterNew → confirmNew → done |
| `disable` | current → done (lock off) |

- A confirm mismatch shakes, clears, and stays on confirmNew (FR-038, US1-2).
- A wrong current PIN counts toward the shared lockout. During a lockout, the keypad shows the
  countdown (spec edge case).
- On `offerBiometric`, a `SwitchListTile` "Use fingerprint / face unlock" and a "Done" button
  (primary). Turning the switch on shows the prompt.
- On `done`: in set mode, `LockService.setPin` + `session.unlocked()`. The screen pops `true` with a
  snackbar ("App lock is on", "PIN changed", or "App lock is off").
- Back or leaving before done pops `false` and discards everything (FR-041). `firstEntry` is cleared
  in `dispose`.
- The title follows the step: "Enter current PIN", "Enter new PIN", "Confirm new PIN".
- Rotating or backgrounding clears the partial entry (spec edge case).

## Shared within `features/lock/presentation/widgets/`

- `PinDots`: 4 dots, filled for each entered digit. The `shake()` animation is about 300 ms (skipped
  with `disableAnimations`). Semantics: "2 of 4 digits entered".
- `PinKeypad`: a 3 × 4 grid with keys ≥ 64 dp (min 48). Digits are rendered `ExcludeSemantics` with
  labels "1"…"9", "0", "Delete", "Use fingerprint". A light haptic on each key. Disabled while locked
  out or verifying.

## SYS-02 Onboarding step 4 (change): `lib/features/onboarding/presentation/widgets/privacy_step.dart`

- A new `OutlinedButton.icon` "Set app lock" (key `onboarding_set_app_lock`) appears under "Allow
  notifications". It pushes `Routes.pinPath('set')`.
- When `settings.lockEnabled`, a status row with a check icon says "App lock is on", and the button
  reads "Change PIN" (which pushes `change`).
- "Get started" is unchanged. Because the session was marked unlocked, no SYS-03 appears afterwards.

## Web page: `lib/features/settings/presentation/screens/web_page_screen.dart`

`AppScaffold` with the title "Privacy policy" or "Terms" and a back button. Body: a `WebViewWidget`
with a `LinearProgressIndicator` while loading. On a load error or no connection: `ErrorState`
("Couldn't load this page. Check your connection and try again.") + "Try again". Off-host navigation
is blocked and opened externally.

## Shared core widgets (new)

- `SettingsSection` (`lib/core/widgets/settings_section.dart`): a section header (`titleSmall`, the
  primary color, a semantics header) and its tiles, with 8 dp grouping.
- `TypedConfirmDialog` (`lib/core/widgets/typed_confirm_dialog.dart`): title, consequence text, a
  `TextField` (no autocorrect, `textCapitalization.characters`), and a destructive button enabled only
  when the text equals the required word exactly.
- `EraseAllDataFlow` (`lib/core/widgets/erase_all_data_flow.dart`): the two-step flow plus progress,
  calling `AppResetService`. It is used by SET-01 and "Forgot PIN?".
- `CurrencyPickerList` (`lib/core/widgets/currency_picker_list.dart`): moved from onboarding's
  `currency_step.dart` with its tests. Onboarding now uses the core widget.
