# Feature Specification: Settings, Themes, and App Lock (SET-01, SET-04, SET-05, SYS-03, SYS-04)

**Feature Branch**: `007-settings-themes-app-lock`

**Created**: 2026-10-21

**Status**: Draft

**Input**: User description: "Feature: Settings, themes, and app lock. Implement task T3.1 from docs/spec.md. Scope: SET-01 More / Settings tab (General, Appearance → SET-04, Modules → SET-06, Notifications with master toggle, daily summary time setting and budget alerts toggle, Security → SET-05, Data with Erase all data, Privacy with privacy policy and terms in an in-app web view, About with rate us, share app, send feedback, app version, open-source licenses; keep the dev-only unlock switch in a Developer section shown only in the dev flavor). SET-04 Themes: theme mode, 2 free and 6 premium seed-color themes with lock badges using FeatureGate, live preview card, font size; locked themes show LockedFeatureOverlay; the dev unlock switch unlocks them. SET-05 Security: app lock toggle, change PIN, biometric toggle, lock after, hide app content in recents app-wide. SYS-03 Unlock and SYS-04 Set / change PIN with a LockService: salted PIN hash in secure storage, biometric, lockout after 5 wrong attempts (30 s, doubling, max 15 min, survives restart), screenshots blocked on SYS-03, back button closes the app. Router redirects to SYS-03 on app start and on return from background after the lock-after time, then returns the user to where they were. Wire 'Set app lock' in SYS-02 step 4 to SYS-04. 'Forgot PIN?' offers erasing all data after typed confirmation. Out of scope: Drive restore in Forgot PIN, backup and export rows in SET-01, the daily summary notification itself, the premium banner card, PRM-01, 'Watch an ad' for themes, Ad privacy choices. Copy the acceptance criteria for SET-01, SYS-03, and SYS-04 exactly from the spec, except criteria about ads. Follow the UI/UX rules in §15."

**Source**: `docs/spec.md` §5 (startup flow, routes), §6 SYS-02, SYS-03, SYS-04, §10 SET-01, SET-04, SET-05, §12 (notifications, accessibility), §14 T3.1, §15 UI/UX guidelines.

## Clarifications

### Session 2026-10-21

- Q: After the first 30-second lockout ends, how many more wrong PINs start the next, doubled lockout? → A: Each further wrong PIN starts the next lockout (60 s, then 2, 4, 8, 15 min), until a successful unlock resets the count.
- Q: Should the Notifications section of the More tab also include a "Habit reminders" on/off toggle? → A: Yes, a Habit reminders toggle under Notifications, shown only when the Habit module is enabled.
- Q: While the PIN keypad is locked out after wrong guesses, should fingerprint or face unlock still work? → A: Yes; biometric unlock still works during a PIN lockout, and a successful biometric unlock resets the wrong-PIN count and lockout length.
- Q: If the app locks while the user is halfway through a form, should what they typed still be there after they unlock? → A: Yes; the same screen comes back with its back history and any unsaved input.
- Q: Where should the "Date format" setting apply? → A: Full dates everywhere follow it (e.g. transaction detail, form date fields, habit start dates); short list headers (`EEE, d MMM`) and "Today"/"Yesterday" stay unchanged.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Protect the app with a PIN (Priority: P1)

A user who keeps their spending private turns on app lock from Security (SET-05). They create a 4-digit PIN on the Set PIN screen (SYS-04) by entering it and then confirming it. If their phone supports fingerprint or face unlock, they are offered "Use fingerprint / face unlock." From then on, whenever they open the app, or come back to it after the chosen "Lock after" time, they see the Unlock screen (SYS-03) and must enter the PIN or use biometrics. After unlocking, they land exactly where they were.

**Why this priority**: App lock is the only part of this feature that protects user data. It is listed in the MVP scope (spec §1) and the startup flow (spec §5) already routes to it.

**Independent Test**: Turn on app lock with a PIN, background the app past the lock-after time, return, and confirm SYS-03 appears, the correct PIN unlocks to the same screen, and wrong PINs are rejected.

**Acceptance Scenarios**:

1. **Given** app lock is off, **When** the user turns on the App lock toggle in SET-05, **Then** SYS-04 opens on the "Enter new PIN" step; the toggle stays off until a PIN is saved.
2. **Given** the user entered a new PIN, **When** they enter a different PIN on the confirm step, **Then** the dots shake, the confirm step restarts, and no PIN is saved.
3. **Given** the user entered and confirmed the same PIN, **When** the device supports biometrics, **Then** a "Use fingerprint / face unlock" toggle is offered before finishing; **When** they finish, **Then** app lock is on and they return to SET-05.
4. **Given** app lock is on, **When** the app starts from closed, **Then** SYS-03 is shown before any app content.
5. **Given** app lock is on with "Lock after" set to 1 min, **When** the user leaves the app for 30 seconds and returns, **Then** no lock is shown; **When** they leave it for more than 1 minute and return, **Then** SYS-03 is shown.
6. **Given** the user was on a transaction detail screen when the app locked, **When** they enter the correct PIN, **Then** they return to that same transaction detail screen, and back still goes to the screen before it.
7. **Given** the user had typed an amount and a note in the add-expense form when the app locked, **When** they unlock, **Then** the form is still open with the same amount and note.
8. **Given** SYS-03 is shown, **When** the user presses the Android back button, **Then** the app closes; the lock is never bypassed.
9. **Given** biometric unlock is on and available, **When** SYS-03 opens, **Then** the system biometric prompt appears automatically; a successful scan unlocks the app; cancelling it leaves the PIN keypad ready, and the biometric key on the keypad shows the prompt again.

**SYS-03 acceptance criteria** (copied from docs/spec.md):

- [ ] Correct PIN unlocks and returns the user to the screen they were on before backgrounding.
- [ ] Lockout timer survives app restart.
- [ ] Screenshots are blocked on this screen (`FLAG_SECURE`).

**SYS-04 acceptance criteria** (copied from docs/spec.md):

- [ ] PIN cannot be set without matching confirmation.
- [ ] Disabling lock requires the current PIN.

---

### User Story 2 - Stop someone from guessing the PIN, and recover from a forgotten PIN (Priority: P1)

Someone who picks up the user's phone tries PINs at random. After 5 wrong attempts the keypad is disabled for 30 seconds, with a visible countdown. Each further lockout doubles the wait, up to 15 minutes, and closing or restarting the app does not reset it. A user who has truly forgotten their PIN taps "Forgot PIN?", learns that the PIN cannot be recovered, and can choose to erase all data after typing "DELETE", which returns the app to a fresh start.

**Why this priority**: Without lockout a 4-digit PIN can be brute-forced in minutes, and without a forgotten-PIN path a user could be locked out of the app permanently. Both are required for the lock in Story 1 to be safe to ship.

**Independent Test**: Enter 5 wrong PINs, confirm a 30-second lockout with a countdown, kill and restart the app during the lockout, and confirm the lockout continues. Then use "Forgot PIN?" to erase all data and confirm the app restarts at onboarding.

**Acceptance Scenarios**:

1. **Given** SYS-03 is shown, **When** the user enters a wrong PIN, **Then** the dots shake, the PIN is cleared, and a message says the PIN is wrong; after 3 or more wrong attempts it also says how many attempts are left before a lockout. Once a lockout has ended, the screen warns that the next wrong PIN locks the app again and for how long ("Next wrong PIN locks the app for 1:00").
2. **Given** 4 wrong attempts, **When** the user enters a 5th wrong PIN, **Then** the keypad is disabled for 30 seconds and a countdown shows the time left.
3. **Given** a 30-second lockout has ended, **When** the user enters one more wrong PIN, **Then** a 60-second lockout starts at once; each further wrong PIN after a lockout starts the next one, lasting 2, 4, 8 minutes, then 15 minutes for every lockout after that.
4. **Given** a lockout is running, **When** the user force-closes and reopens the app, **Then** SYS-03 still shows the lockout with the correct remaining time.
5. **Given** the user unlocks successfully (by PIN or biometric), **Then** the wrong-attempt count and the lockout length reset.
6. **Given** a PIN lockout is running and biometric unlock is on and available, **When** the user taps the biometric key and the scan succeeds, **Then** the app unlocks and the lockout is cleared.
7. **Given** SYS-03 is shown, **When** the user taps "Forgot PIN?", **Then** a sheet explains the PIN cannot be recovered and offers "Erase all data"; **When** they choose it, **Then** they must type "DELETE" before the erase button is enabled; **When** they confirm, **Then** all data, settings, and the PIN are removed and the app starts at onboarding (SYS-02).
8. **Given** the "Forgot PIN?" sheet is open, **When** the user cancels, **Then** nothing is erased and SYS-03 stays as it was, including any running lockout.

---

### User Story 3 - Manage app lock settings (Priority: P2)

From Security (SET-05), a user with app lock on can change their PIN, turn biometric unlock on or off, choose when the app locks (Immediately, after 1 min, after 5 min), and choose to hide app content in the recent-apps screen. Turning the lock off or changing the PIN always asks for the current PIN first.

**Why this priority**: These controls make the lock comfortable for daily use, but the lock works with its defaults without them.

**Independent Test**: With a PIN set, change the PIN, switch biometrics, change "Lock after", toggle hiding content in recents, and turn the lock off; confirm each change takes effect and the PIN is asked for where required.

**Acceptance Scenarios**:

1. **Given** app lock is on, **When** the user taps "Change PIN", **Then** SYS-04 asks for the current PIN, then a new PIN, then confirmation; the old PIN stops working and the new one works.
2. **Given** app lock is on, **When** the user turns the App lock toggle off, **Then** SYS-04 asks for the current PIN; only a correct PIN turns the lock off and removes the stored PIN.
3. **Given** a wrong current PIN is entered in SYS-04, **Then** it counts toward the same lockout as SYS-03.
4. **Given** app lock is off, **Then** Change PIN, Use biometric, and Lock after are shown disabled with a note that they need app lock.
5. **Given** the device has no biometrics set up, **Then** the Use biometric toggle is disabled with a short explanation.
6. **Given** the user turns Use biometric on, **Then** the system biometric prompt confirms it; cancelling leaves it off.
7. **Given** "Hide app content in recents" is on, **Then** the recent-apps preview of DailyTrack is blank on every screen and screenshots are blocked app-wide; **When** it is off, **Then** only SYS-03 blocks them.
8. **Given** "Lock after" is set to Immediately, **When** the user leaves the app for any length of time and returns, **Then** SYS-03 is shown.

---

### User Story 4 - Change general preferences from the More tab (Priority: P2)

A user opens the More tab (SET-01) and finds every setting grouped in a clear list: General (language, currency, first day of week, date format), Appearance, Modules, Notifications, Security, Data, Privacy, and About. They change the language to Gujarati and the whole app switches at once. They change the currency and every amount is shown with the new symbol, without changing the numbers. They set the week to start on Sunday and dates to a different format.

**Why this priority**: SET-01 is the home of every other setting and replaces the current placeholder tab, but each individual preference has a working default.

**Independent Test**: Open the More tab, change each General setting, restart the app, and confirm each change persisted and is applied across screens.

**Acceptance Scenarios**:

1. **Given** the More tab, **Then** the sections appear in this order: General, Appearance, Modules, Notifications, Security, Data, Privacy, About, and (dev flavor only) Developer. No backup, export, premium banner, ad privacy, or banner ad rows appear.
2. **Given** the user picks Gujarati in Language, **Then** the app's text switches to Gujarati immediately and stays Gujarati after restart; choosing "System default" follows the device language when supported, otherwise English.
3. **Given** a transaction of ₹1,250.00, **When** the user changes the currency to USD, **Then** it is shown as $1,250.00; the stored amount is unchanged and switching back shows ₹1,250.00 again.
4. **Given** the user sets First day of week to Sunday, **Then** week-based views (week strips, weekly reports, weekly habit frequency, weekday pickers) start on Sunday.
5. **Given** the user picks `dd/MM/yyyy`, **Then** a transaction dated 5 March 2026 shows "05/03/2026" on its detail screen, while list headers keep the `EEE, d MMM` form and "Today" and "Yesterday" stay relative.
6. **Given** the More tab in the dev flavor, **Then** a Developer section shows the "Unlock all features (debug)" switch; **Given** the prod flavor, **Then** the Developer section does not exist.

**SET-01 acceptance criteria** (copied from docs/spec.md; the ad criterion is excluded):

- [ ] Changing currency changes formatting only; stored amounts are not converted.

---

### User Story 5 - Personalize the look (Priority: P2)

A user opens Theme and colors (SET-04). A live preview card at the top shows a sample dashboard. They switch between System, Light, and Dark mode, pick one of the color themes, and choose a larger font size; the preview and the app update at once. Two color themes (Default Teal, Indigo) are free; six premium themes (Saffron, Forest, Rose, Midnight, Ocean, Mono) show a lock badge. Tapping a locked theme shows it in the preview behind the locked-feature overlay instead of applying it. In the dev flavor, the "Unlock all features (debug)" switch unlocks the premium themes.

**Why this priority**: Visible personalization is valued by users and sets up premium themes for monetization later, but it does not affect data or core tracking.

**Independent Test**: Change theme mode, color theme, and font size and confirm the app updates immediately and after restart; confirm premium themes are locked until the dev unlock switch is turned on.

**Acceptance Scenarios**:

1. **Given** SET-04, **When** the user picks Dark, **Then** the whole app switches to dark mode immediately; System follows the device setting.
2. **Given** SET-04, **When** the user taps the free Indigo theme, **Then** the preview card and the app use Indigo at once, and it is still applied after restart.
3. **Given** premium themes are locked, **Then** each shows a lock badge; **When** the user taps Saffron, **Then** the preview card shows Saffron behind the locked-feature overlay, the app's theme does not change, and the overlay's "Get Pro" action is shown disabled (no "Watch an ad" action).
4. **Given** the dev flavor with "Unlock all features (debug)" on, **Then** the premium themes show no lock badge and can be applied like free themes.
5. **Given** a premium theme is applied and the debug unlock is turned off, **Then** the app shows Default Teal until the theme is unlocked again; turning the unlock back on restores the chosen premium theme.
6. **Given** the user picks Font size Large, **Then** text across the app gets larger on top of the system font scale, with no clipped or overflowing text at 200% system scale.
7. **Given** any theme or mode, **Then** only the seed color changes; layout, type styles, and income, expense, and warning colors stay the same.

---

### User Story 6 - Control notifications (Priority: P3)

In the Notifications section of SET-01, a user can turn all notifications off with one master toggle, set the time for the daily summary reminder (default 9:00 PM), and turn budget alerts and habit reminders on or off.

**Why this priority**: Notification preferences matter, but defaults are sensible, and the daily summary notification itself arrives in a later feature.

**Independent Test**: Turn the master toggle off and confirm no habit reminders or budget alerts fire; set a daily summary time and confirm it persists.

**Acceptance Scenarios**:

1. **Given** the master toggle is off, **Then** no notification of any kind is shown and the other notification rows are shown disabled with their values kept; **When** it is turned back on, **Then** those values apply again and habit reminders are rescheduled.
2. **Given** budget alerts are off, **When** spending crosses 80% or 100% of a budget, **Then** no alert is shown.
3. **Given** the user sets the daily summary time to 8:30 PM, **Then** the row shows 8:30 PM in the device's 12- or 24-hour style and keeps it after restart.
4. **Given** the Habit module is enabled and Habit reminders is turned off, **Then** no habit reminder fires, and each habit keeps its reminder times; **When** it is turned back on, **Then** reminders are rescheduled. **Given** the Habit module is disabled, **Then** the Habit reminders row is not shown.
5. **Given** the user turns notifications on but the system permission was denied, **Then** the section explains that notifications are blocked and offers to open the system settings.

---

### User Story 7 - Erase all data (Priority: P3)

A user who wants a fresh start taps "Erase all data" in the Data section. A dialog explains exactly what will be lost; after confirming, a second step asks them to type "DELETE". Only then is everything removed and the app restarts at onboarding.

**Why this priority**: Rarely used, but required for user control over their data and reused by "Forgot PIN?".

**Independent Test**: Seed transactions, habits, and settings; erase all data with the double confirmation; confirm the app starts at onboarding with no data, default settings, no PIN, and no scheduled notifications.

**Acceptance Scenarios**:

1. **Given** the user taps "Erase all data", **Then** a confirmation dialog lists what will be deleted (transactions, accounts, categories, budgets, recurring entries, habits and check-ins, settings, app lock) and says this cannot be undone.
2. **Given** they confirm the first dialog, **Then** a second step asks them to type "DELETE"; the erase button stays disabled until the text matches exactly.
3. **Given** they type "DELETE" and confirm, **Then** all user data and settings are removed, the PIN and lockout state are cleared, scheduled notifications are cancelled, and the app opens onboarding (SYS-02).
4. **Given** either step, **When** the user cancels, **Then** nothing is deleted.

---

### User Story 8 - Privacy, help, and app information (Priority: P3)

From the Privacy and About sections, a user can read the privacy policy and terms inside the app, rate the app, share it with a friend, send feedback by email, see the app version, and view open-source licenses.

**Why this priority**: Required for Play Store compliance (privacy policy linked in SET-01, spec §13) and useful for feedback, but not part of daily use.

**Independent Test**: Tap each Privacy and About row and confirm the expected page, sheet, or app opens.

**Acceptance Scenarios**:

1. **Given** the user taps Privacy policy or Terms, **Then** the page opens in an in-app web view with a back button; **Given** no internet, **Then** a plain-language error with "Try again" is shown.
2. **Given** the user taps Rate us, **Then** the store's in-app review prompt is requested; if it cannot be shown, the app's store page opens instead.
3. **Given** the user taps Share app, **Then** the system share sheet opens with a short message and the store link.
4. **Given** the user taps Send feedback, **Then** an email draft opens addressed to the support address, with app version, Android version, device model, and device language filled in, and no financial, habit, or settings data; if no email app exists, a message shows the support address.
5. **Given** the About section, **Then** it shows the app version and build number, and "Open-source licenses" opens the list of licenses for bundled packages.

---

### User Story 9 - Set app lock during onboarding (Priority: P3)

On the last onboarding step, a new user taps "Set app lock", creates a PIN on SYS-04, and returns to the onboarding step to finish with "Get started."

**Why this priority**: A convenient shortcut; the same result is available from SET-05 later.

**Independent Test**: Go through onboarding, tap "Set app lock", set a PIN, return, tap "Get started", restart the app, and confirm SYS-03 appears.

**Acceptance Scenarios**:

1. **Given** onboarding step 4, **Then** a "Set app lock" button is shown next to "Allow notifications".
2. **Given** the user taps "Set app lock" and saves a PIN, **Then** they return to step 4, which now shows that app lock is on, and are not asked to unlock right away.
3. **Given** the user backs out of SYS-04 without saving, **Then** they return to step 4 with app lock off.

---

### Edge Cases

- The app is locked while the user is in the middle of a form (e.g. adding an expense): after unlocking, the form and its unsaved input are still there.
- The user opens the app from a notification or the home screen widget while lock is on: SYS-03 comes first, then the screen the notification or widget targets.
- On a cold start there is no previous screen: after unlocking, the user lands on the screen the startup flow would have shown (Home), or on a notification's target.
- The device's biometric enrolment is removed or changed after biometric unlock was turned on: the automatic prompt is skipped and the PIN keypad is used; SET-05 shows the toggle as unavailable.
- A biometric unlock is attempted during a PIN lockout: biometric unlock still works, because the system applies its own attempt limits; a successful biometric unlock resets the wrong-PIN count.
- The device clock is moved backward during a lockout: the lockout does not end early and is never extended past its original length.
- Lockout is reached while changing or turning off the PIN in SYS-04: SYS-04 shows the same countdown and blocks input.
- The user turns on app lock but leaves SYS-04 without confirming: no PIN is saved and the toggle stays off.
- The secure storage holding the PIN cannot be read (e.g. after a device restore to a new phone): the app treats lock as unavailable, shows SYS-03 with only "Forgot PIN?" usable, and explains why.
- Rotating the phone or switching apps during PIN entry clears the partly entered PIN.
- A premium theme is stored as selected but is not unlocked (e.g. unlock removed): the app shows Default Teal and SET-04 marks the stored theme as locked.
- Changing language while on SET-01 keeps the user on SET-01 at the same scroll position.
- "Hide app content in recents" is turned off while app lock is on: SYS-03 itself still blocks screenshots and recents previews.
- The user turns off the master notification toggle: existing scheduled reminders are cancelled, not just hidden.
- Erase all data fails part-way: nothing is deleted (all or nothing) and an error with "Try again" is shown.
- Text in Hindi and Gujarati is up to 30% longer: all rows, dialogs, and the keypad screen fit at 360 dp wide and 200% font scale.

## Requirements *(mandatory)*

### Functional Requirements

**SET-01 More / Settings**

- **FR-001**: The More tab MUST show a grouped settings list in this order: General, Appearance, Modules, Notifications, Security, Data, Privacy, About, and, only in the dev flavor, Developer.
- **FR-002**: General MUST offer Language (System default, English, हिन्दी, ગુજરાતી), Currency (the same searchable list of 30 currencies as onboarding), First day of week (Monday, Saturday, Sunday), and Date format, each showing its current value and applying immediately.
- **FR-003**: Changing currency MUST change only how amounts are formatted; stored amounts MUST NOT be converted.
- **FR-004**: Changing First day of week MUST apply to every week-based view in all enabled modules.
- **FR-005**: Date format MUST offer at least `d MMM yyyy`, `dd/MM/yyyy`, `MM/dd/yyyy`, and `yyyy-MM-dd`, applied to every full date in all modules (e.g. transaction detail, date fields in forms, habit start dates, report period labels that show a full date). Short list headers (`EEE, d MMM`) and relative dates ("Today", "Yesterday") MUST stay unchanged.
- **FR-006**: Appearance MUST open SET-04; Modules MUST open SET-06; Security MUST open SET-05.
- **FR-007**: Notifications MUST offer a master toggle, a Daily summary reminder time (default 9:00 PM), a Budget alerts toggle, and a Habit reminders toggle that is shown only while the Habit module is enabled. Turning Habit reminders off MUST cancel all habit reminders without changing each habit's own reminder times; turning it on MUST reschedule them. When the master toggle is off, every notification MUST be cancelled and suppressed, and the other rows MUST be disabled while keeping their values.
- **FR-008**: This feature MUST store the Daily summary time only; it MUST NOT schedule the daily summary notification.
- **FR-009**: When notifications are on but the system permission is denied, the Notifications section MUST say so and offer to open the system notification settings.
- **FR-010**: Data MUST offer Erase all data only; backup and export rows MUST NOT be shown.
- **FR-011**: Privacy MUST offer Privacy policy and Terms, each opened in an in-app web view with an error state and "Try again" when the page cannot load. "Ad privacy choices" MUST NOT be shown.
- **FR-012**: About MUST offer Rate us (in-app review, falling back to the store page), Share app (system share sheet with the store link), Send feedback (email draft with app version, OS version, device model, and device language; no app data or settings), App version (version and build number), and Open-source licenses.
- **FR-013**: The Developer section MUST exist only in the dev flavor and MUST contain the existing "Unlock all features (debug)" switch with its current behavior.
- **FR-014**: The premium banner card and banner ad slot MUST NOT be shown on SET-01 in this feature.

**SET-04 Themes and appearance**

- **FR-015**: SET-04 MUST offer theme mode System, Light, and Dark, applied app-wide immediately and persisted.
- **FR-016**: SET-04 MUST show a grid of 8 color themes: free Default Teal and Indigo; premium Saffron, Forest, Rose, Midnight, Ocean, and Mono. Each theme MUST change only the seed color of the Material 3 scheme; layout, typography, and semantic colors (income, expense, warning, success) MUST NOT change.
- **FR-017**: Whether a premium theme is available MUST be decided by the existing feature gate using a per-theme key, and MUST update live when the gate's answer changes (including the dev unlock switch).
- **FR-018**: Locked premium themes MUST show a lock badge with a text label (not color alone). Tapping a locked theme MUST show it in the live preview card behind the shared locked-feature overlay with "Get Pro" disabled and no "Watch an ad" action, and MUST NOT apply it.
- **FR-019**: A live preview card at the top of SET-04 MUST show a sample dashboard in the currently previewed mode, theme, and font size.
- **FR-020**: If the stored theme is a premium theme that is not unlocked, the app MUST display Default Teal while keeping the stored choice, and MUST restore it when it becomes unlocked again.
- **FR-021**: SET-04 MUST offer Font size Default and Large; Large MUST scale app text on top of the system font scale and MUST be persisted.

**SET-05 Security**

- **FR-022**: SET-05 MUST offer an App lock toggle, Change PIN, Use biometric toggle, Lock after (Immediately, 1 min, 5 min; default 1 min), and Hide app content in recents.
- **FR-023**: Turning App lock on MUST open SYS-04 in set mode; the lock MUST be on only after a PIN is confirmed and saved.
- **FR-024**: Turning App lock off MUST require the current PIN; on success the stored PIN and biometric preference MUST be removed.
- **FR-025**: Change PIN, Use biometric, and Lock after MUST be disabled with an explanation while app lock is off; Use biometric MUST be disabled with an explanation when the device has no usable biometrics.
- **FR-026**: Turning Use biometric on MUST require a successful system biometric prompt.
- **FR-027**: Hide app content in recents MUST, when on, blank the app's recent-apps preview and block screenshots on every screen; when off, only SYS-03 MUST block them.

**SYS-03 Unlock**

- **FR-028**: SYS-03 MUST show the app logo, "Enter PIN" title, 4 PIN dots, a numeric keypad (1–9, biometric key, 0, backspace), and a "Forgot PIN?" link. The biometric key MUST appear only when biometric unlock is on and available.
- **FR-029**: If biometric unlock is on and available, SYS-03 MUST show the system biometric prompt automatically when it opens.
- **FR-030**: The PIN MUST be verified against a salted, slow hash kept in the device's secure storage; the plain PIN MUST never be stored or logged.
- **FR-031**: After 5 wrong PIN attempts, PIN input MUST be blocked for 30 seconds with a visible countdown; after that, each further wrong PIN MUST start a new lockout that doubles the previous duration, up to a maximum of 15 minutes (30 s, 60 s, 2, 4, 8, 15, 15 … minutes). A successful unlock, by PIN or biometric, MUST reset the count and duration. Biometric unlock MUST remain available during a PIN lockout.
- **FR-032**: The wrong-attempt count and any running lockout MUST be persisted and MUST survive app restart; moving the device clock backward MUST NOT shorten or indefinitely extend a lockout.
- **FR-033**: SYS-03 MUST block screenshots and blank its recent-apps preview at all times.
- **FR-034**: The Android back button on SYS-03 MUST close the app and MUST NOT reveal any other screen.
- **FR-035**: "Forgot PIN?" MUST explain that the PIN cannot be recovered and MUST offer Erase all data, protected by typing "DELETE"; it MUST NOT offer restoring from a backup in this feature.
- **FR-036**: SYS-03 MUST show no ads.

**SYS-04 Set / change PIN**

- **FR-037**: SYS-04 MUST use the same keypad as SYS-03 and support three modes: set (new PIN, confirm), change (current PIN, new PIN, confirm), and turn off (current PIN).
- **FR-038**: A mismatch on the confirm step MUST shake the dots and restart the confirm step; no PIN MUST be saved without a matching confirmation.
- **FR-039**: Wrong current-PIN entries in SYS-04 MUST count toward the same lockout as SYS-03.
- **FR-040**: After a first-time PIN setup, SYS-04 MUST offer "Use fingerprint / face unlock" when the device supports it.
- **FR-041**: Leaving SYS-04 before finishing MUST discard the partial entry and leave the previous lock state unchanged.

**Routing and lock lifecycle**

- **FR-042**: When app lock is on, the app MUST show SYS-03 before any app content on start, after onboarding is done.
- **FR-043**: When the app returns from the background and the time away is equal to or longer than the "Lock after" setting (any time for Immediately), the app MUST show SYS-03 before any app content.
- **FR-044**: After a successful unlock, the user MUST return to the exact screen and navigation history they had, including unsaved form input. Locking on resume MUST NOT close, reset, or rebuild the screens that were open; SYS-03 covers them until unlock. On a cold start, they MUST land where the startup flow (or the opening notification or widget) would have taken them.
- **FR-045**: While the app is locked, no other screen MUST be reachable by deep link, notification tap, or navigation.

**Onboarding**

- **FR-046**: SYS-02 step 4 MUST show a "Set app lock" button that opens SYS-04 in set mode and returns to step 4, which then shows whether app lock is on. The user MUST NOT be asked to unlock until the next lock event.

**Erase all data**

- **FR-047**: Erase all data (from SET-01 or "Forgot PIN?") MUST require two confirmations: a dialog stating what will be deleted and that it cannot be undone, then typing "DELETE" exactly before the erase button is enabled.
- **FR-048**: Erasing MUST remove all module data, settings, unlocks, the PIN, biometric preference, and lockout state, MUST cancel all scheduled notifications, and MUST then open SYS-02 onboarding. It MUST be all-or-nothing: if it fails, nothing is deleted and an error with "Try again" is shown.

**Cross-cutting**

- **FR-049**: Every setting in this feature MUST persist across app restarts.
- **FR-050**: All screens in this feature MUST follow the §15 UI/UX rules, including the §15.10 design review checklist: shared tokens and components only, loading, empty, error, and content states, 48 dp touch targets with semantic labels, no clipping at 200% font scale on a 360 dp screen, light and dark mode, and all text from translation files in English, Hindi, and Gujarati.

### Key Entities

- **Lock credential**: The salted hash of the user's 4-digit PIN and its salt, kept only in the device's secure storage. Exists only while app lock is on.
- **Lockout state**: Number of consecutive wrong PIN attempts, the current lockout length, and when the current lockout ends. Persisted so it survives restarts; reset on successful unlock or erase.
- **Security preferences**: App lock on/off, biometric unlock on/off, lock-after duration (Immediately, 1 min, 5 min), hide content in recents on/off.
- **Appearance preferences**: Theme mode (System, Light, Dark), selected color theme (one of 8), font size (Default, Large).
- **General preferences**: Language, currency code, first day of week, date format.
- **Notification preferences**: Master switch, daily summary time, budget alerts on/off, habit reminders on/off.
- **Color theme**: Name, seed color, and whether it is free or premium (premium themes are gated by a per-theme unlock key).
- **Lock session**: In-memory record of whether the app is currently unlocked, when it went to the background, and the location to return to after unlocking.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: With app lock on, no app content is ever visible before a successful unlock, on start or after the lock-after time, in 100% of tested start, resume, notification, and widget paths.
- **SC-002**: A user can unlock with the correct PIN in under 3 seconds, and the biometric prompt appears within 1 second of SYS-03 opening.
- **SC-003**: After unlocking, the user is on the same screen with the same unsaved input in 100% of tested resume cases.
- **SC-004**: After 5 wrong PINs, no further PIN is accepted until the lockout ends, including across app restarts; lockout lengths follow 30 s, 60 s, 2, 4, 8, 15, 15 minutes.
- **SC-005**: A user can turn on app lock from SET-05 in 4 taps or fewer plus PIN entry, and reach any settings screen from the More tab in 1 tap.
- **SC-006**: Theme mode, color theme, font size, and language changes are visible across the app within 300 ms, without restarting the app.
- **SC-007**: Every setting changed in this feature has the same value after the app is force-closed and reopened.
- **SC-008**: After Erase all data, the app opens onboarding with zero user records, default settings, no PIN, and no scheduled notifications.
- **SC-009**: Screenshots and recent-apps previews show no app content on SYS-03 always, and on every screen when "Hide app content in recents" is on.
- **SC-010**: All new screens render without clipping or overflow at 200% font scale on a 360 dp-wide screen, in English, Hindi, and Gujarati, in light and dark mode.

## Assumptions

- The PIN is exactly 4 digits, matching the 4 PIN dots in SYS-03.
- "Lock after" defaults to 1 min, matching the 60-second default in spec §5; returning after exactly the chosen time locks.
- The lock is on only while a PIN exists; biometric unlock is always a convenience on top of the PIN, never a replacement.
- The lockout protects against casual guessing; moving the device clock forward to shorten a lockout is not defended against, because doing so requires an already-unlocked device.
- The typed confirmation word is "DELETE" in every language and is case-sensitive; the instructions around it are translated.
- Erase all data also removes rewarded or debug unlocks; a future Pro purchase is restored from the store, not from local data.
- Erasing all data from "Forgot PIN?" uses the same erase as SET-01; restoring from Google Drive in "Forgot PIN?" comes in a later feature.
- First day of week offers Monday, Saturday, and Sunday, covering the common choices for the target users; the default stays Monday.
- Date format default is `d MMM yyyy`.
- Font size Large adds about 15% on top of the system font scale.
- The privacy policy and terms are hosted at public URLs configured per build; their content is not part of this feature.
- The support email address and store link are configured per build.
- Premium theme seed colors are chosen to pass WCAG AA in both light and dark mode; Mono uses a neutral grey seed.
- Unlocking premium themes by rewarded ad or Pro purchase arrives in a later feature (PRM-01, PRM-02); until then they can only be unlocked with the dev-flavor debug switch.
- The daily summary notification itself, backup and export rows, the premium banner card, banner ads, and "Ad privacy choices" are out of scope and arrive in later features.
- The existing routing rule that sends a locked user to SYS-03 at startup is kept and extended, not replaced.
