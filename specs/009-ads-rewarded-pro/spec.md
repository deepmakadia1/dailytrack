# Feature Specification: Ads, Rewarded Unlocks, and Pro Purchase (§11, PRM-01, PRM-02)

**Feature Branch**: `009-ads-rewarded-pro`

**Created**: 2026-10-22

**Status**: Draft

**Input**: User description: "Feature: Ads, rewarded unlocks, and Pro purchase. Implement Phase 4 tasks T4.1 to T4.5 from docs/spec.md. Scope: core/ads (spec §11): AdService interface, AdMobAdService, NoAdsService, AdConfig with the global interstitial frequency cap, AdUnitIds read from --dart-define per flavor, and AppBannerAd and AppNativeAd widgets (adaptive banner, medium native template, retry with backoff, dispose, zero height on failure, animate in after load with no layout shift). Debug and dev builds always use Google's official Android test ad unit IDs and test App ID. The prod AdMob App ID goes into AndroidManifest through a Gradle manifestPlaceholder read from local.properties or an environment variable, never committed. Consent: UMP consent flow in SYS-01 before MobileAds.initialize, ads requested only when canRequestAds() is true, and 'Ad privacy choices' in SET-01 when required. Placements exactly as the §11 table: banners on the listed screens through the AppScaffold banner slot, natives on DSH-01, EXP-01, EXP-08, and HAB-01, interstitials after every 4th EXP-02 save, after a new habit save, and after a manual backup success, all through AdService.maybeShowInterstitial and the cap. PRM-02 rewarded unlock sheet and showRewardedUnlock(): advanced reports (24 h), one CSV or PDF export, one premium theme (permanent), one streak freeze (max 2 per habit), and an ad-free day (24 h). Wire every existing LockedFeatureOverlay and locked state to it, and grant rewards only in onUserEarnedReward. PRM-01 Pro purchase with in_app_purchase: one-time product pro_lifetime, price from Play Billing, restore purchase, acknowledgement, ownership check on every start, switching to NoAdsService, and permanent unlocks for all premium features. The premium banner card in SET-01 (hidden after purchase) and 'Get Pro' buttons in every locked state opening PRM-01. The dev-only unlock switch from earlier features stays, and a dev-only 'Reset ad counters' action helps test the frequency cap. Out of scope: app-open ads, mediation, Remote Config (later), and app-ads.txt (feature 009). Copy the acceptance criteria for §11, PRM-01, and PRM-02 exactly from the spec, plus the ad criteria skipped in earlier features (DSH-01 native position, EXP-02 interstitial, SYS-01 ads SDK not initialized after purchase). Follow the UI/UX rules in §15, especially §15.8 Ad UX rules."

**Source**: `docs/spec.md` §1 (revenue model), §2 (layer rule 5), §4 (`unlocks`, `habits.freezesAvailable`, settings `removeAdsPurchased` and ad consent status), §5 (PRM-01 and PRM-02 routes), §6 SYS-01, §7 DSH-01, §8 EXP-01, EXP-02, EXP-08, EXP-11, §9 HAB-01, HAB-02, HAB-03, §10 SET-01, SET-02, SET-03, SET-04, PRM-01, PRM-02, §11 (ads integration), §13 (flavors, Play compliance, testing), §14 T4.1–T4.5, §15 UI/UX guidelines (especially §15.4 `LockedFeatureOverlay`, §15.6 no layout shift, §15.8 ad UX rules).

**Numbering note**: The spec directory is `009` because `008` is taken by backup, export, notifications, and the widget. Where the input above says `app-ads.txt` comes in "feature 009", that means the later release feature (T5.2), not this one.

**Already built in earlier features** (reused, not rebuilt): the do-nothing ad service and its splash call guarded by `removeAdsPurchased` (001); the `AppScaffold` banner slot (001); the `unlocks` store, `FeatureGate`, latest-time-seen clock rule, and `LockedFeatureOverlay` with a disabled "Get Pro" and no "Watch an ad" (003); the locked states on EXP-11, HAB-03 (weekly chart and freeze card), SET-04 (premium themes), and SET-03 (exports) (003, 005, 007, 008); the dev-only "Unlock all features (debug)" switch and "Add a freeze (debug)" button (005, 007); SET-01 Privacy group and premium banner card placeholder (007).

## Clarifications

### Session 2026-10-22

- Q: When Google Play, on an online start, reports that Pro is no longer owned (refund or chargeback), should Pro be removed? → A: Option C. Pro is removed only after 2 online starts in a row report it is not owned; one such report, an offline start, or a failed check never removes it.
- Q: Where does a free user start an ad-free day? → A: Nowhere. Free users get no ad-free day: it is dropped from the rewarded unlocks, and ads go away only with Pro. `docs/spec.md` §11, PRM-02, DSH-01, §4, and §15.8 must be updated to match (FR-052).
- Q: When an EXP-02 save (or a new habit save) closes back to Home, can the interstitial show on Home, given DSH-01 says "No interstitials on this screen"? → A: Option A. Yes, but only right after an EXP-02 or HAB-02 action closes back to Home; Home itself never triggers an interstitial.
- Q: What should a prod release build do when the production AdMob App ID is not supplied (e.g. CI on a pull request)? → A: Option B. Only builds meant for Play upload (signed with the upload key or marked as a store build) stop with a clear error; other prod release builds use the test App ID with a build warning and request no ads.
- Q: When does a new session start for the "never in the first session of the day" cap rule? → A: Option A. On a cold start, or when the app returns after at least 30 minutes in the background.
- Q: Which EXP-02 saves count toward the "every 4th save" interstitial counter? → A: Option B. Only new entries, including swipe-right duplicates and "Save and add another"; edits of existing entries do not count.
- Q: When the user closes the rewarded ad before earning the reward, what should the PRM-02 sheet do? → A: Option A. The sheet stays open with "Watch the whole ad to unlock", a new ad starts loading so the user can try again, and "Not now" and "Get Pro instead" stay available.
- Q: (/speckit-implement, 2026-10-22) Should rewarded unlocks have a daily limit, and what does it count? → A: 10 earned rewards per feature key per local day (`advancedReports`, `exportCsv`, `exportPdf`, each `premiumTheme_{name}` on its own, `streakFreeze`). After the 10th, PRM-02 shows that the daily limit is reached and offers only "Get Pro instead" and "Not now". The ad-free day stays dropped.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Ads that respect consent and never get in the way (Priority: P1)

A user in a region that requires ad consent opens DailyTrack for the first time. Before any ad is requested, the app shows Google's consent form; the user makes a choice and continues to Home. From then on they see a single bottom banner on reading screens (transactions list, reports, habits, settings) and a few native ads styled like app cards with a clear "Ad" badge. Ads slide in only after they load, never push content under the user's finger, and simply aren't there when they fail to load. Later the user changes their mind about ad tracking and opens "Ad privacy choices" in More to update it. A user outside such a region never sees a consent form and gets the same ad layout.

**Why this priority**: Ads are the app's main revenue (§1), and they may only run after consent is resolved (Constitution VI, Play policy). The shared ad service, consent flow, and banner and native components are the base for every other story.

**Independent Test**: On a dev build with a consent-test geography forced to the EEA, cold start and confirm the consent form appears and no ad request is made until it is resolved; then open each listed screen and confirm banner and native placements, the "Ad" badge, collapse on load failure, and no movement of on-screen content while an ad loads.

**Acceptance Scenarios**:

1. **Given** a first launch where consent is required, **When** splash runs, **Then** the consent form is shown before Home and no ad is requested until the user has answered it.
2. **Given** consent is not required (or was answered before), **When** splash runs, **Then** no form is shown and startup is not slowed by consent.
3. **Given** consent could not be checked (e.g. offline), **Then** startup continues without waiting, and ads are requested only if the previously stored consent allows it.
4. **Given** the privacy options requirement is reported, **Then** SET-01 Privacy shows "Ad privacy choices"; **When** tapped, **Then** the consent form opens again and the new choice applies to every later ad request; **Given** it is not required, **Then** the row is hidden.
5. **Given** EXP-01, EXP-03, EXP-04, EXP-06, EXP-11, HAB-01, HAB-03, HAB-04, SET-01, or SET-02, **Then** an adaptive banner is anchored at the bottom above the navigation bar (and below the FAB) once it loads; it takes no space before it loads and animates its height in over about 200 ms.
6. **Given** any add/edit form, lock, onboarding, PRM-01, or PRM-02, **Then** no banner or native ad is shown.
7. **Given** DSH-01, **Then** one native ad sits after the second module card (after the only card when one module is enabled) and never above the first module card.
8. **Given** EXP-01 with enough rows, **Then** native ads appear after row 8, then every 15 rows (after rows 23 and 38), with at most 3 per screen load; **When** the user changes the period, **Then** the list, totals, and ads update without leaving the screen.
9. **Given** EXP-08 with a category budget list, **Then** one native ad appears after the list.
10. **Given** HAB-01 for a day with 5 or more habits, **Then** one native ad appears after the 4th habit card; with 4 or fewer habits, **Then** none appears.
11. **Given** any native ad, **Then** it shows a visible "Ad" badge in its top-left corner, uses the app's card shape, and cannot be mistaken for a transaction row or habit card.
12. **Given** an ad fails to load, **Then** the app retries a limited number of times with growing waits, and while it has no ad the slot takes zero height with no empty box, placeholder, or error text.
13. **Given** a screen with ads is closed, **Then** its loaded ads are released and no further requests are made for it.

**§11 acceptance criteria** (copied from docs/spec.md):

- [ ] Unit tests cover the frequency cap: install-age rule, 3-minute gap, 4-per-day maximum, and counter reset.
- [ ] With `NoAdsService`, no ad widget occupies any space.
- [ ] No ad request is made before consent is resolved.

**DSH-01 acceptance criterion** (copied from docs/spec.md; deferred from feature 006):

- [ ] Native ad never appears above the first module card.

**EXP-01 acceptance criterion** (copied from docs/spec.md; the ads part was deferred from feature 002):

- [ ] Changing period updates the list, totals, and ads without leaving the screen.

---

### User Story 2 - Unlock a premium feature by watching a rewarded ad (Priority: P1)

A free user opens Reports and taps the locked Trends tab. The blurred preview offers "Watch an ad to unlock for 24 hours" and "Get Pro". They tap "Watch an ad"; a bottom sheet explains "Unlock advanced reports for 24 hours" with "Watch a short ad", "Get Pro instead", and "Not now". The button shows a spinner while the ad loads, then plays it. When they finish the ad, Trends, Accounts, Year, Custom, and older periods open right away, and on HAB-03 the weekly chart opens too, for 24 hours, even across restarts. If they close the ad early, nothing is unlocked. The same sheet is used to unlock one CSV or PDF export, one premium theme for good, and one streak freeze for a habit. There is no ad-free day reward; only Pro removes ads.

**Why this priority**: Rewarded unlocks are the free path to every premium feature and the second ad revenue stream; every locked state built in earlier features waits on this sheet.

**Independent Test**: With a fake ad service that can be told to earn, close early, fail, or time out, open each locked state, go through the sheet, and confirm the right unlock (key, duration, and target) is written only on an earned reward, the locked state clears immediately, and the unlock survives a restart and a backwards clock change.

**Acceptance Scenarios**:

1. **Given** any locked state, **When** the user taps "Watch an ad", **Then** the PRM-02 sheet opens with the feature's icon, a title stating exactly what they get and for how long, a one-line explanation, "Watch a short ad", "Get Pro instead", and "Not now". No ad plays until the user taps "Watch a short ad".
2. **Given** the sheet opens, **Then** one rewarded ad starts loading and the primary button shows a spinner until it is ready; **Given** it is not ready within 8 seconds or cannot load, **Then** the button area shows "Ad not available, try again later" and the user can try again or choose another option.
3. **Given** the user watches until the reward is earned, **Then** the unlock is recorded, the sheet closes, the caller is told it succeeded, and the locked content opens immediately.
4. **Given** the user closes the ad before the reward is earned, **Then** nothing is recorded, the content stays locked, and the sheet stays open with "Watch the whole ad to unlock" while a new ad loads (spinner and 8-second timeout as in scenario 2), so the user can try again, choose "Get Pro instead", or tap "Not now".
5. **Given** advanced reports are unlocked by a reward, **Then** EXP-11 advanced tabs and periods and the HAB-03 weekly chart are open for 24 hours from the reward, then lock again, including across app restarts and if the device clock is moved backwards.
6. **Given** the export format the user picked in SET-03 is locked, **When** they earn the reward, **Then** one export of that format is unlocked and the export starts at once; **When** they cancel the ad, **Then** the export does not start. The one-time unlock is used up only when a file is created (feature 008 rule).
7. **Given** the user taps a locked premium theme in SET-04, **When** they earn the reward, **Then** that theme is unlocked permanently and applied; other premium themes stay locked.
8. **Given** a habit with fewer than 2 freezes, **When** the user taps "Watch an ad to get a freeze" on HAB-03 and earns the reward, **Then** that habit gets 1 more freeze; **Given** it already has 2, **Then** the button is disabled with a label saying the maximum of 2 is reached, and no ad can be watched for it.
9. **Given** "Get Pro instead" or "Get Pro" in any locked state, **When** tapped, **Then** PRM-01 opens.
10. **Given** "Not now" or a swipe down, **Then** the sheet closes, the caller is told it failed, and nothing changes.
11. **Given** the user already earned 10 rewards today for this feature key, **When** PRM-02 opens, **Then** no ad loads, the sheet says the daily limit is reached and to try again tomorrow, and only "Get Pro instead" and "Not now" are offered; other feature keys are unaffected, and the count starts again on the next local day (a device clock moved backwards never resets it).

**PRM-02 acceptance criteria** (copied from docs/spec.md):

- [ ] Closing the ad early grants nothing.
- [ ] Unlock expiry is respected after app restart. If the device clock is moved backwards, expired unlocks stay expired (store the latest time ever seen and use the later of that and the current time).

**EXP-11 acceptance criterion** (copied from docs/spec.md; the "Watch an ad" part was deferred from feature 003):

- [ ] Locked tabs show a blurred preview and a "Watch an ad to unlock for 24 hours" button.

**SET-03 acceptance criterion** (copied from docs/spec.md; deferred from feature 008):

- [ ] Cancelling the rewarded ad does not start the export.

---

### User Story 3 - Buy Pro once and never see an ad again (Priority: P1)

A user who likes the app taps the premium card in More ("Remove ads and unlock everything") or "Get Pro" on any locked feature. PRM-01 shows "DailyTrack Pro", the benefits (No ads, All themes, Advanced reports, Unlimited exports, Unlimited streak freezes up to the cap), a price button with the real local price from Google Play, "Restore purchase", and a note that the purchase is tied to their Google account. They buy it. All ads vanish at once, every locked feature opens, and the premium card in More disappears. After a restart, and later after reinstalling on a new phone and tapping "Restore purchase", Pro is still theirs and no ad is ever requested.

**Why this priority**: Pro is the one-time revenue path and the promise that ads go away for good; it must work flawlessly offline and across reinstalls (Play requires acknowledgement and restore).

**Independent Test**: With a fake store, buy, cancel, fail, leave pending, and restore the `pro_lifetime` product; confirm the ad service switches to no ads with zero ad requests (including after restart), all gated features open, acknowledgement happens, and the start-up ownership check behaves online and offline.

**Acceptance Scenarios**:

1. **Given** PRM-01 opens online, **Then** the price button shows the store's localized price for the one-time product; **Given** the store is not reachable, **Then** the button is disabled with "Store not available right now, try again later" and "Restore purchase" stays available.
2. **Given** the user completes the purchase, **Then** Pro is saved, all loaded ads are released, no new ad is requested, every ad slot disappears without an empty box, all premium features unlock permanently, PRM-01 shows a "You have Pro" state, and the purchase is acknowledged.
3. **Given** the user cancels the store's purchase dialog, **Then** nothing changes and no error is shown.
4. **Given** the purchase fails, **Then** a plain-language error is shown with a way to try again, and nothing changes.
5. **Given** the payment is pending (e.g. a slow payment method), **Then** PRM-01 says Pro will unlock when the payment completes; **When** it completes later (even on a later start), **Then** Pro is granted and acknowledged.
6. **Given** a reinstall or new phone with the same Google account, **When** the user taps "Restore purchase", **Then** Pro is restored; **Given** no purchase is found, **Then** a message says no Pro purchase was found for this Google account.
7. **Given** every app start, **Then** ownership is checked with the store; **Given** the device is offline, **Then** the saved Pro state is trusted.
8. **Given** Pro is owned, **Then** the SET-01 premium banner card is hidden, "Get Pro" buttons and rewarded options are gone because nothing is locked, and the ads SDK is not started on the next cold start.
9. **Given** Pro is owned, **Then** the HAB-03 freeze card lets the user add a freeze without an ad, up to 2 stored per habit.
10. **Given** a purchase that was never acknowledged (e.g. the app closed right after paying), **When** the app next starts, **Then** it is acknowledged.
11. **Given** Pro is owned and one online start's check reports it is not owned (e.g. refunded), **Then** Pro stays; **Given** the next online start also reports it is not owned, **Then** Pro stays for the rest of that session, and from the next cold start Pro is removed, its permanent unlocks are revoked, and ads return; **Given** an "owned" result in between, **Then** the count of "not owned" reports goes back to zero; **Given** an offline start or a failed check in between, **Then** the count is left unchanged.

**PRM-01 acceptance criteria** (copied from docs/spec.md):

- [ ] After purchase, no ad of any kind is requested again, including after restart.
- [ ] Reinstalling and tapping "Restore purchase" restores Pro.

**SYS-01 acceptance criterion** (copied from docs/spec.md; deferred from feature 001):

- [ ] Ads SDK is not initialized when Remove Ads is purchased.

---

### User Story 4 - Interstitials only after a finished action, within a strict cap (Priority: P2)

A regular user logs expenses all evening. After every 4th saved transaction, once the add screen has closed and they are back on a list, a full-screen ad may appear, but never while they are typing, never more than once every 3 minutes, never more than 4 times a day, never in their first 2 days after installing, and never in the first session of the day. Creating a new habit and finishing a manual backup can also be followed by an interstitial under the same cap.

**Why this priority**: Interstitials add revenue but are the most intrusive format; they depend on the ad service (Story 1) and must be perfectly capped before release.

**Independent Test**: Unit-test the cap with an injected clock (install age, first session of the day, 3-minute gap, 4-per-day maximum, counter reset). Widget-test that EXP-02, HAB-02, and SET-02 call the trigger only after their screen or dialog has closed, using a fake ad service.

**Acceptance Scenarios**:

1. **Given** fewer than 2 days since install, **Then** no interstitial is shown.
2. **Given** the user's first session of the local day, **Then** no interstitial is shown in that session.
3. **Given** an interstitial was shown less than 3 minutes ago, or 4 were shown today, **Then** no interstitial is shown.
4. **Given** all cap rules allow it, **When** the 4th new EXP-02 entry saved in the session closes the screen (edits don't count), **Then** an interstitial is shown after the screen has closed, including when it closes back to Home (DSH-01); the save counter resets only when an interstitial is actually shown, so if the cap blocks it, the next save that closes the screen tries again.
5. **Given** the user saves a new habit in HAB-02 (not an edit), **When** the screen has closed, **Then** an interstitial may be shown under the cap.
6. **Given** a manual backup succeeds in SET-02, **When** the user closes the success message, **Then** an interstitial may be shown under the cap.
7. **Given** an interstitial is shown, **Then** the next one is preloaded; **Given** none is preloaded when a trigger fires, **Then** nothing is shown and the user is never kept waiting.
8. **Given** the user has already moved into another form, lock screen, PRM screen, or the app is in the background when a trigger fires, **Then** no interstitial is shown.
9. **Given** any cold start or the check-in of a habit, **Then** no interstitial is shown.

**EXP-02 acceptance criterion** (copied from docs/spec.md; deferred from feature 002):

- [ ] Interstitial never appears while the keypad or form is visible.

---

### User Story 5 - Developers can test ads safely (Priority: P3)

A developer runs a dev or debug build and every ad is a Google test ad, so they can never generate invalid traffic on the real account. The production App ID and ad unit IDs are never in the repository; a prod release build gets them from the developer's machine or CI secrets. In a dev build, More shows "Unlock all features (debug)" as before and a new "Reset ad counters" action, so the frequency cap can be tested in minutes instead of days.

**Why this priority**: Required for safe development and for Play/AdMob policy, but it doesn't change what users see.

**Independent Test**: Build dev and prod-debug variants and confirm only Google test IDs are used; build prod release with and without the production values supplied and confirm the outcome; in a dev build, use "Reset ad counters" and confirm an interstitial can be triggered immediately.

**Acceptance Scenarios**:

1. **Given** any dev-flavor build or any debug build, **Then** only Google's official Android test App ID and test ad unit IDs are used, whatever is supplied at build time.
2. **Given** a prod release build, **Then** the AdMob App ID comes from an untracked local properties file or an environment variable, and the ad unit IDs come from build-time values; none of these appear in any committed file.
3. **Given** a build meant for Play upload without the production App ID, **Then** the build stops with a clear message naming the missing value; **Given** any other prod release build without it (e.g. CI on a pull request), **Then** the build succeeds with a warning, uses the test App ID, and the app requests no ads.
4. **Given** a prod release build missing an ad unit ID for a format, **Then** that format requests no ads and takes no space.
5. **Given** a dev build, **When** the developer taps "Reset ad counters", **Then** the save counter, today's interstitial count, the last-shown time, and the first-session-of-the-day mark are cleared and the install-age rule is treated as met, and a confirmation is shown; **Given** a prod build, **Then** the action does not exist.
6. **Given** a dev build with "Unlock all features (debug)" on, **Then** all gated features are open as before, ads still show (so ads remain testable), and the HAB-03 "Add a freeze (debug)" button stays.

---

### Edge Cases

- **Pro bought while an ad is on screen**: banners and natives collapse at once without layout jumps under the user's finger (§15.6); a preloaded interstitial is discarded.
- **Pro removed after 2 "not owned" checks while the app is open**: the current session keeps no ads; ads and locks return from the next cold start, so nothing changes under the user mid-task.
- **Advanced reports already unlocked**: no locked state shows, so no reward can be earned twice; a new reward after expiry starts a fresh 24 hours.
- **Daily limit reached**: PRM-02 explains the limit and loads no ad; changing the device clock backwards cannot unlock more rewards that day.
- **Reward earned but the app is killed before the ad closes**: the unlock written at reward time stays.
- **Reward earned while the caller screen was left** (e.g. app re-locked during the ad): the unlock is kept; the export does not start until the user returns and taps Export again.
- **App lock and full-screen ads**: watching a rewarded or interstitial ad does not count as leaving the app, so it never starts the app lock's lock-after timer.
- **Consent declined**: if the consent SDK still permits ad requests (e.g. limited ads), ads load; if not, all ad slots take no space and rewarded sheets show "Ad not available" with "Get Pro instead".
- **Consent form fails to load or the user is offline at first launch**: startup continues to Home; consent is retried on the next start.
- **Pro bought while PRM-02 is open**: the sheet closes and the feature is unlocked.
- **Purchase completes while the app is closed or on another device**: the next start's ownership check grants Pro.
- **Erase all data** removes rewarded and debug unlocks and the stored Pro flag (feature 007); the next online start restores Pro from the store, and the install time used by the cap is kept.
- **Restoring a backup** never changes Pro, unlocks, consent, or ad counters (feature 008).
- **Device clock moved backwards**: unlock expiry and the 3-minute and per-day interstitial rules use the later of the current time and the latest time ever seen.
- **Local day changes during a session**: the per-day count resets at local midnight; the session continues and is not treated as the first session of the new day.
- **EXP-01 short list**: with 8 or fewer rows, no native ad appears; natives do not appear in loading, empty, "No matches", or error states on any screen.
- **DSH-01 with every module card hidden or only one**: the native ad goes after the only card; with no module card it does not appear.
- **Screen width under 360 dp, 200% font, Hindi/Gujarati**: the PRM-01 benefit list, price button, and PRM-02 sheet fit without clipping; the "Ad" badge stays readable.
- **Store returns no price** (product not set up or unavailable in the region): the price button is disabled with the store-unavailable message.
- **Rapid taps on "Watch a short ad" or the price button**: only one ad is shown or one purchase flow is started.

## Requirements *(mandatory)*

### Functional Requirements

**Ad service and configuration (T4.1)**

- **FR-001**: All ad behaviour MUST go through one shared ad service with: initialize, whether ads are enabled (current value and a stream of changes), preload an interstitial, maybe show an interstitial for a trigger, and show a rewarded ad for a feature key. Screens MUST use only this service and the shared banner and native components (spec §2 rule 5, Constitution VI).
- **FR-002**: There MUST be a real ad implementation and a no-ads implementation. The no-ads implementation MUST be used when Pro is owned and in widget tests; switching between them MUST happen at runtime without a restart.
- **FR-003**: All frequency cap values (install-age days 2, minimum gap 3 minutes, daily maximum 4, EXP-02 saves per interstitial 4) and the rewarded load timeout (8 seconds) MUST live in one ad configuration so they can be tuned later without code changes elsewhere.
- **FR-004**: Ad unit IDs MUST be supplied per build flavor at build time. Dev-flavor builds and all debug builds MUST use only Google's official Android test App ID and test ad unit IDs. Release ad unit IDs and the production App ID MUST NOT be committed to the repository.
- **FR-005**: The production AdMob App ID MUST reach the Android manifest through a build placeholder read from an untracked local properties file or an environment variable. A build meant for Play upload (signed with the upload key or marked as a store build) without it MUST fail with a clear message naming the missing value; any other prod release build without it (e.g. CI on a pull request) MUST use the test App ID, print a build warning, and request no ads at runtime.
- **FR-006**: The banner component MUST request an adaptive banner sized to the screen width, and the native component MUST use the medium template styled with app tokens and the card shape (§15.2, §15.8).
- **FR-007**: Banner and native components MUST take zero height until an ad has loaded, then animate their height in over about 200 ms (instantly when the system "Remove animations" setting is on), retry failed loads a limited number of times with increasing waits, release their ad when removed, and collapse to zero height on final failure.
- **FR-008**: Every native ad MUST show a visible "Ad" badge (`labelSmall` on `adBadge`) in its top-left corner, and every ad MUST keep at least 8 dp from any tappable control and MUST NOT sit directly next to a FAB, Save button, or check button (§15.8).
- **FR-009**: No banner or native ad MUST appear on add/edit forms, lock, onboarding, PRM-01, or PRM-02.
- **FR-010**: No financial or habit data MUST be sent to the ad SDK, including as targeting keywords; child-directed treatment MUST stay unspecified.

**Consent (T4.1)**

- **FR-011**: SYS-01 MUST request a consent information update and, when required, show the consent form before the ads SDK is initialized; the ads SDK MUST be initialized only after consent is resolved and only when Pro is not owned.
- **FR-012**: No ad of any format MUST be requested unless the consent SDK reports that ads can be requested.
- **FR-013**: Consent checking MUST NOT block startup when offline or failing; the app MUST continue to Home and rely on the stored consent.
- **FR-014**: SET-01 Privacy MUST show "Ad privacy choices" whenever the consent SDK reports a privacy options requirement and Pro is not owned; tapping it MUST reopen the consent form.

**Placements (T4.2)**

- **FR-015**: Banners MUST appear through the shared scaffold's banner slot on exactly EXP-01, EXP-03, EXP-04, EXP-06, EXP-11, HAB-01, HAB-03, HAB-04, SET-01, and SET-02, anchored at the bottom above the navigation bar with the FAB above them.
- **FR-016**: Native ads MUST appear on exactly: DSH-01 after the second module card (after the only card when one is shown; never above the first module card); EXP-01 after row 8 and then every 15 rows, at most 3 per screen load; EXP-08 after the category budgets list; HAB-01 after the 4th habit card only when the selected day lists 5 or more habits.
- **FR-017**: Native ads MUST appear only in a screen's content state, not in loading, empty, filtered-empty, or error states.
- **FR-018**: DSH-01 MUST NOT trigger an interstitial of its own; an interstitial MAY appear over Home only right after an EXP-02 save or a new HAB-02 habit closes back to Home (FR-023). EXP-02 MUST show no banner or native ads; habit check-in MUST never trigger an ad.

**Interstitials and frequency cap (T4.3)**

- **FR-019**: Interstitials MUST be requested only through the ad service's "maybe show" operation with one of three triggers: EXP-02 save, new habit saved in HAB-02, manual backup success in SET-02 (local file or Google Drive).
- **FR-020**: The global cap MUST block an interstitial when: fewer than 2 days have passed since install; the current session is the user's first session of the local day; less than 3 minutes have passed since the last interstitial; or 4 have been shown on the current local day.
- **FR-021**: A session MUST start at a cold start or when the app returns to the foreground after at least 30 minutes in the background.
- **FR-022**: Saves of new EXP-02 entries (including swipe-right duplicates and "Save and add another") MUST be counted per session; edits of existing entries MUST NOT count; when the count is 4 or more and the screen closes after a save, the trigger fires; the counter MUST reset only after an interstitial is actually shown.
- **FR-023**: Each trigger MUST fire only after its screen has closed (EXP-02, HAB-02) or its success message has been dismissed (SET-02), and an interstitial MUST be shown only when the app is in the foreground and the user is on a reading screen (not a form, lock, onboarding, or PRM screen). Home (DSH-01) counts as a reading screen only for the EXP-02 and HAB-02 triggers, when that screen closed back to Home.
- **FR-024**: An interstitial MUST be shown only if one is already preloaded; the next one MUST be preloaded after one is shown. The app MUST never wait for an interstitial to load.
- **FR-025**: The install time, last-shown time, per-day count and its date, and first-session-of-the-day mark MUST be stored locally, MUST NOT be backed up or restored, and MUST use the later of the current time and the latest time ever seen.
- **FR-026**: No app-open ad and no interstitial MUST be shown on cold start.

**Rewarded unlocks, PRM-02 (T4.4)**

- **FR-027**: There MUST be one reusable rewarded-unlock operation taking the feature key and optional duration, which opens PRM-02 and reports true only when the reward was earned.
- **FR-028**: PRM-02 MUST be a bottom sheet with the feature's icon, a title naming what is unlocked and for how long, a one-line explanation, "Watch a short ad", "Get Pro instead" (opens PRM-01), and "Not now".
- **FR-029**: Opening PRM-02 MUST start loading exactly one rewarded ad; the primary button MUST show a spinner until it is ready; after 8 seconds without an ad, or on load failure, it MUST show "Ad not available, try again later" and allow a retry. Rewarded ads MUST be loaded only when PRM-02 opens.
- **FR-030**: An unlock MUST be written only when the ad reports the reward was earned. Closing early, load failure, timeout, or "Not now" MUST write nothing. After an early close the sheet MUST stay open, show "Watch the whole ad to unlock", and load a new ad for a retry; the caller is told the result only when the sheet finally closes.
- **FR-031**: Rewards MUST be: advanced reports for 24 hours; one export of the selected format (CSV or PDF); the selected premium theme permanently; one streak freeze for the selected habit, never above 2 stored. There is no ad-free day reward.
- **FR-032**: Every existing locked state MUST offer "Watch an ad" (opening PRM-02 for its feature) and an enabled "Get Pro" (opening PRM-01): EXP-11 locked tabs and periods ("Watch an ad to unlock for 24 hours"), the HAB-03 weekly chart, SET-03 locked export, SET-04 locked themes ("Watch an ad to unlock this theme permanently"), and the HAB-03 freeze card ("Watch an ad to get a freeze").
- **FR-033**: After an earned reward the locked content MUST open without leaving the screen: advanced content shows, the export starts, the theme is applied, or the habit's freeze count goes up.
- **FR-034**: The HAB-03 "Watch an ad to get a freeze" button MUST be disabled with an explanation when the habit already has 2 freezes. HAB-01 "Skip today" keeps its existing rule (disabled with "No freezes left").
- **FR-035**: Free users MUST NOT be offered an ad-free day anywhere; ads are removed only by Pro. The existing `adFreeDay` unlock key stays in the stored key list (append-only) but MUST NOT be granted or read to turn ads off.
- **FR-036**: Unlock expiry MUST be respected after restart and when the device clock is moved backwards (latest-time-seen rule, existing in the feature gate).
- **FR-053**: Each feature key MUST allow at most 10 earned rewards per local day (clarification, 2026-10-22). The count is kept per key and per local day in settings (never backed up), uses the later of the clock and the latest time ever seen, is raised only inside the reward callback, and PRM-02 MUST check it before loading an ad.

**Pro purchase, PRM-01 (T4.5)**

- **FR-037**: PRM-01 MUST show "DailyTrack Pro", the benefit list (No ads, All themes, Advanced reports, Unlimited exports, Unlimited streak freezes up to the cap), a purchase button with the localized price from Google Play for the one-time product `pro_lifetime`, "Restore purchase", and a note that the purchase is tied to the Google account. It MUST be a full-screen modal with no ads.
- **FR-038**: PRM-01 MUST handle loading, store-unavailable, purchasing, pending, cancelled, failed, success, and already-owned states with plain-language messages and one next step each.
- **FR-039**: On purchase success the app MUST: save Pro as owned; switch to the no-ads implementation; release all loaded ads and stop loading new ones; remove all ad slots without empty boxes; unlock every premium feature permanently; acknowledge the purchase.
- **FR-040**: Any purchase not yet acknowledged MUST be acknowledged on the next start, well within Google Play's 3-day limit.
- **FR-041**: On every app start the app MUST check ownership with the store when online; when offline it MUST trust the saved Pro state. Pro MUST be removed only after 2 online starts in a row report it is not owned; an "owned" result resets that count, and offline or failed checks leave it unchanged. Removal revokes purchase-sourced unlocks and takes effect from the next cold start (User Story 3 scenario 11).
- **FR-042**: "Restore purchase" MUST query the store and grant Pro when owned, or say no purchase was found for this Google account.
- **FR-043**: With Pro owned, the ads SDK MUST NOT be initialized on cold start and no ad of any format MUST be requested, including after restart.
- **FR-044**: With Pro owned, the HAB-03 freeze card MUST let the user add a freeze without an ad, up to 2 per habit.
- **FR-045**: SET-01 MUST show the premium banner card "Remove ads and unlock everything" (opening PRM-01) while Pro is not owned and hide it once owned.
- **FR-046**: Only one purchase flow and one rewarded ad MAY be in progress at a time; repeated taps MUST be ignored.

**Developer tools (dev builds only)**

- **FR-047**: The dev-only "Unlock all features (debug)" switch MUST keep working as before; it MUST NOT turn ads off. The HAB-03 "Add a freeze (debug)" button stays while the switch is on.
- **FR-048**: Dev builds MUST offer a "Reset ad counters" action in SET-01 that clears the save counter, the daily count, the last-shown time, and the first-session mark, and treats the install-age rule as met. It MUST NOT exist in prod builds.

**Cross-cutting**

- **FR-049**: All new user-facing text (PRM-01, PRM-02, overlay actions, store and ad messages, "Ad privacy choices", dev actions) MUST be in English, Hindi, and Gujarati with placeholders and plurals, never concatenation.
- **FR-050**: PRM-01 and PRM-02 MUST meet §15: tokens and shared components only, 48 dp targets, semantic labels, 200% font scale and 360 dp width without clipping, light and dark themes, one primary action, sentence case, verb-first buttons.
- **FR-051**: Every acceptance criterion copied above MUST have at least one automated test; widget tests MUST use fake repositories, a fake store, and the no-ads or a fake ad service; frequency cap tests MUST use an injected clock.
- **FR-052**: Where `docs/spec.md` says "until PRM-02 exists" or "until rewarded ads exist" (SET-03, SET-04, HAB-03, EXP-11) or refers to `app-ads.txt` timing, the spec MUST be updated to the final behaviour in this feature's plan (Constitution I). The plan MUST also remove the ad-free day from `docs/spec.md` (§11 Rewarded row and `NoAdsService` line, PRM-02, DSH-01 Ads, §15.8, and the §4 `adFreeDay` key note) record the Pro removal rule in PRM-01, and reword DSH-01 Ads to allow the EXP-02/HAB-02 interstitial when those screens close back to Home; Constitution VI names "ad-free day" in its `NoAdsService` rule and needs a PATCH amendment.

### Key Entities

- **Ad configuration**: The tunable numbers for the interstitial cap and rewarded timeout (install-age days, minimum gap, daily maximum, saves per interstitial, rewarded timeout).
- **Ad unit IDs**: Per-flavor identifiers for the App, banner, native, interstitial, and rewarded formats; test values in dev and debug builds, build-time values in prod release.
- **Interstitial cap state**: Install time, last interstitial time, today's count and its local date, the first-session-of-the-day mark, session start, and the EXP-02 save counter. Local only; not backed up.
- **Consent state**: Whether consent is required, whether ads can be requested, and whether privacy options must be offered; owned by the consent SDK, with the app's stored ad consent status in settings.
- **Unlock** (existing): Feature key (advancedReports, exportCsv, exportPdf, premiumTheme_{name}, streakFreeze; adFreeDay kept but unused), optional expiry, source (rewarded ad or purchase).
- **Rewarded offer**: What PRM-02 shows for a feature key: icon, title, explanation, and duration.
- **Rewarded daily count**: Local day and, per feature key, how many rewards were earned that day (limit 10). Local only; not backed up.
- **Pro ownership**: Whether `pro_lifetime` is owned (`removeAdsPurchased`), whether it is acknowledged, whether a purchase is pending, and how many online starts in a row reported it not owned (0–2), and whether a removal is waiting for the next cold start. Local only; not backed up.
- **Habit freezes** (existing): `freezesAvailable`, 0–2 per habit.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: In automated tests, 0 ad requests are made before consent is resolved, and 0 ad requests of any format are made after a Pro purchase, across at least 3 subsequent restarts.
- **SC-002**: With ads off (Pro or tests), every ad slot on every listed screen measures 0 dp.
- **SC-003**: While an ad loads or fails, content under the user's finger moves 0 dp; ads only appear by animating their own height in.
- **SC-004**: In cap tests over a simulated week, no day has more than 4 interstitials, no two are less than 3 minutes apart, none occurs in the first 2 days after install or in a first session of the day, and none appears while a form, lock, onboarding, or PRM screen is visible.
- **SC-005**: Every locked state (5 kinds) offers both "Watch an ad" and "Get Pro", and 100% of early-closed rewarded ads grant nothing.
- **SC-006**: PRM-02 shows either a playable ad or "Ad not available, try again later" within 8 seconds of opening, every time.
- **SC-007**: After a successful purchase, all ads disappear and all premium features open within 1 second, without a restart.
- **SC-008**: "Restore purchase" restores Pro on a fresh install with the same Google account in one tap.
- **SC-009**: Cold start to Home stays under 1.5 s on a mid-range device when consent is not required (the consent form, when required, is excluded).
- **SC-010**: No production ad unit ID or production App ID is found in the repository, and dev and debug builds request only test ads.

## Assumptions

- **First session of the day**: the first session (FR-021, Clarifications) that starts on a local day. A shorter trip to the background, including a full-screen ad, continues the same session.
- **Counting saves**: with "Save and add another" the screen stays open, so the interstitial check runs only when the screen finally closes.
- **Manual backup**: both "Save backup file" and Drive "Back up now" count; auto backups never trigger ads.
- **Install time** is recorded on first launch, kept through Erase all data, and not part of backups. For installs that predate this feature, the first start after updating counts as the install time.
- **Reset ad counters** (dev only) treats the install-age rule as met so the cap can be tested without waiting 2 days.
- **Debug switch and ads**: "Unlock all features (debug)" unlocks features but keeps ads on, so ad behaviour stays testable.
- **Pro and freezes**: "Unlimited streak freezes up to the cap" means a Pro user can add freezes without an ad whenever the habit has fewer than 2.
- **Pro and consent**: Pro users are not shown the consent form or "Ad privacy choices", because the ads SDK is never started for them.
- **Retries**: banner and native loads retry up to 3 times with waits of roughly 30 s, 60 s, and 120 s, then stay collapsed until the screen is opened again.
- **Price** is shown exactly as the store formats it; the app never hard-codes a price.
- **Purchase is per Google account** on Google Play; no server-side receipt validation in MVP.
- **Out of scope**: the ad-free day reward (dropped, Clarifications Q2), app-open ads, mediation, Remote Config, `app-ads.txt` (T5.2), iOS ads and purchases, subscriptions, and any server.
- **Dependencies**: features 001–008 as listed under "Already built"; the AdMob account, the `pro_lifetime` product in Play Console, and an internal testing track are set up by the developer outside this repository.
