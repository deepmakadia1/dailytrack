# Feature Specification: Foundation (Phase 0)

**Feature Branch**: `001-foundation`

**Created**: 2026-10-13

**Status**: Draft

**Input**: User description: "Feature: Foundation. Implement Phase 0 (tasks T0.1 to T0.5) from docs/spec.md: dev and prod flavors, lints, the folder structure from §3, core theme tokens (AppTokens) and the shared widgets listed in §15.4, l10n setup for en/hi/gu, Drift AppDatabase with the settings table and migration tests, the TrackerModule interface and module registry, go_router with a StatefulShellRoute and 4 tabs (Home, Expenses, Habits, More) showing placeholder screens, plus screens SYS-01 Splash, SYS-02 Onboarding, and SET-06 Modules. Copy the acceptance criteria for these screens exactly from the spec."

**Source of truth**: `docs/spec.md` v1.0, sections 2, 3, 4 (settings table), 5, 6 (SYS-01, SYS-02), 10 (SET-06), 12 (Localization, Accessibility), 13 (Build flavors, Testing, CI), 14 (Phase 0: T0.1–T0.5), and 15 (UI/UX guidelines).

> **Note on scope and wording**: This is a platform-foundation feature. The master spec and the
> project constitution (Principle VII, "Locked Stack") already fix the technology choices, so
> some requirements below name project building blocks (flavors, `AppTokens`, `TrackerModule`,
> the settings store). They are named because the master spec mandates them, not as new design
> decisions. Everything else is described by observable behavior.

## Clarifications

### Session 2026-10-13

- Q: How should Phase 0 handle the SYS-01 criterion "First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once," given that the categories and accounts tables are only created in T1.1? → A: Option B. Move the categories and accounts tables and their seed data into Phase 0, so the criterion is fully tested now.
- Q: When a returning user has app lock turned on, where should Phase 0 send them, given that the SYS-03 Unlock screen and the PIN setup screen are only built in Phase 3? → A: Option A. If the lock setting is on, route to a placeholder `/lock` screen, and test both cases with a fake lock setting. T3.1 replaces the placeholder with the real SYS-03.
- Q: How should Phase 0 handle the SYS-01 criterion "Ads SDK is not initialized when Remove Ads is purchased," given that ads and purchases are only built in Phase 4? → A: Option A. Splash checks the `removeAdsPurchased` setting and starts ads through an ad-service interface that does nothing for now. A test with a fake confirms it is never called when the setting is true. T4.1 swaps in the real service.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - First-time setup through onboarding (Priority: P1)

A new user installs DailyTrack and opens it for the first time. They see a branded splash with no white flash. The app then takes them through a 4-step onboarding: pick a language (English, हिन्दी, ગુજરાતી), confirm a currency (INR preselected), choose which trackers to use (Expense and Habit, both on by default), and read a short privacy note with optional "Allow notifications" and "Set app lock" actions. Tapping "Get started" saves their choices and lands them on the Home tab.

**Why this priority**: Every user goes through this flow before they can use the app. Without it, nothing else is reachable, and language, currency, and module settings are prerequisites for all later phases.

**Independent Test**: Install fresh, complete onboarding with non-default choices (for example Gujarati, USD, Habit only), and confirm the Home tab appears in Gujarati and the choices are still there after the app restarts.

**Acceptance Scenarios** (SYS-02 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] Selected language persists and applies after app restart.
- [ ] Denying the notification permission does not block onboarding.
- [ ] User cannot turn off both modules.

**Additional scenarios** (derived from the SYS-02 Layout and Behavior):

1. **Given** step 1 (Welcome) is showing, **When** the user taps the हिन्दी chip, **Then** every visible string on the screen switches to Hindi immediately, without leaving the step.
2. **Given** the device locale points to India, **When** the user reaches step 2, **Then** INR is preselected, and the list can be filtered by typing a currency name or code.
3. **Given** step 3 shows Expense and Habit both on, **When** the user turns one off and then tries to turn off the other, **Then** the second toggle stays on and the user is told that at least one module must stay on.
4. **Given** step 3, **Then** a "Coming soon" row shows Water and Period, and it cannot be turned on.
5. **Given** step 1 or 2, **When** the user taps "Skip", **Then** defaults are saved (device language if it is en/hi/gu, otherwise English; INR; both modules on), onboarding is marked done, and the user lands on Home.
6. **Given** steps 3 and 4, **Then** no "Skip" control is visible.
7. **Given** step 4, **When** the user taps "Get started", **Then** settings are saved, onboarding is marked done, and the user lands on Home (DSH-01 placeholder).
8. **Given** any onboarding step, **Then** no ad is shown.

---

### User Story 2 - Returning launch and startup routing (Priority: P1)

A returning user opens the app. The splash prepares local storage and settings and sends the user straight to the right first screen: Home if onboarding is done, onboarding if it isn't. If local storage cannot be opened, the user sees a clear error screen with a way to retry instead of a crash or a blank screen.

**Why this priority**: Fast and correct startup routing runs on every app open. It is the base for the app-lock and ads behavior added in later phases.

**Independent Test**: With onboarding already done, cold-start the app and confirm it lands on Home without showing onboarding. Simulate a storage failure and confirm the error screen with "Retry" appears.

**Acceptance Scenarios** (SYS-01 acceptance criteria, copied verbatim from `docs/spec.md`):

- [ ] First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once.
- [ ] Returning user with lock on lands on SYS-03; without lock lands on DSH-01.
- [ ] Ads SDK is not initialized when Remove Ads is purchased.

**Additional scenarios** (derived from the SYS-01 Behavior and States):

1. **Given** onboarding is not done, **When** the app starts, **Then** the user lands on SYS-02 Onboarding.
2. **Given** onboarding is done and lock is off, **When** the app starts, **Then** the user lands on the Home tab.
3. **Given** local storage fails to open, **When** the app starts, **Then** an error screen appears with a plain-language message and a "Retry" action, and "Retry" tries startup again.
4. **Given** any cold start, **Then** no app-open or interstitial ad is shown.
5. **Given** a launch, **Then** the splash shows the app logo centered on the theme background with the app name below it, with no white flash before it.

---

### User Story 3 - Moving between the four main tabs (Priority: P2)

A user who has finished onboarding sees a bottom navigation bar with four tabs: Home, Expenses, Habits, and More. Each tab shows a placeholder screen for now. Each tab remembers where the user was inside it when they switch away and back. Back on a tab root goes to Home, and back on Home exits the app.

**Why this priority**: The navigation shell is the frame every later screen plugs into. It must exist and behave correctly before any module screen can be built.

**Independent Test**: Switch across all four tabs and confirm each shows its placeholder in the selected language. Press back on the Expenses tab root and confirm the app returns to Home.

**Acceptance Scenarios**:

1. **Given** the user is on Home, **When** they tap each destination, **Then** the matching placeholder screen appears and the active tab shows a filled icon. Labels are always visible.
2. **Given** the user opened a pushed screen inside the More tab (for example SET-06 Modules), **When** they switch to Habits and back to More, **Then** they are still on SET-06.
3. **Given** the user is on a non-Home tab root, **When** they press system back, **Then** they go to Home. **Given** they are on Home, **When** they press back, **Then** the app exits.
4. **Given** the Habit module is disabled, **Then** the Habits tab is not shown. **Given** the Expense module is disabled, **Then** the Expenses tab is not shown.
5. **Given** the More placeholder, **Then** it offers an entry that opens SET-06 Modules.

---

### User Story 4 - Turning trackers on and off (SET-06 Modules) (Priority: P2)

From More, the user opens Modules and sees a reorderable list of trackers with toggles: Expense and Habit, plus Water and Period shown as "Coming soon" (disabled). They can turn a module off, which hides its tab and dashboard card without deleting any data, and reorder modules to change the order of dashboard cards and module tabs.

**Why this priority**: This lets users tailor the app and proves the module registry works end to end, which is the main extensibility promise of the architecture.

**Independent Test**: Disable Habit in SET-06, confirm the Habits tab disappears. Re-enable it and confirm the tab returns. Reorder Habit above Expense and confirm the tab order changes.

**Acceptance Scenarios** (SET-06 has no acceptance-criteria list in `docs/spec.md`; these are derived from its Layout and Behavior):

1. **Given** both modules are enabled, **When** the user disables Habit, **Then** the Habits tab and the Habit dashboard card are hidden, the module's disable hook runs (which cancels its notifications once they exist), and no Habit data is deleted.
2. **Given** only one module is enabled, **When** the user tries to disable it, **Then** the toggle stays on and the user is told that at least one module must stay enabled.
3. **Given** the list, **When** the user drags Habit above Expense, **Then** the order is saved, and the module tabs and dashboard cards follow the new order after navigating back and after an app restart.
4. **Given** the list, **Then** Water and Period appear as "Coming soon", cannot be toggled, and cannot be reordered.
5. **Given** a disabled module, **When** the user re-enables it, **Then** its tab and card reappear and its enable hook runs.

---

### User Story 5 - A safe, consistent base for later phases (Priority: P3)

As the maintainer, I need the project set up so every later phase starts from the same base. Separate dev and prod builds can be installed side by side. Lint rules enforce a zero-warnings policy. The folder layout matches the master spec. Shared design tokens and shared UI components exist. All three languages are wired up. Local storage has a settings store with tested migrations. A module contract and registry let new trackers be added without editing existing ones. CI checks every pull request.

**Why this priority**: Users don't see this directly, but every following phase depends on it. It ranks below the user-visible flows because those flows exercise and prove most of it.

**Independent Test**: Build and install both dev and prod variants on one device. Run the quality gates (code generation, analyze, format check, tests) and confirm all pass. Confirm the migration tests and shared-widget tests run in CI.

**Acceptance Scenarios**:

1. **Given** the project, **When** the dev and prod variants are built, **Then** both install side by side (dev uses a `.dev` application ID suffix and shows the debug banner), and dev never contains real ad unit IDs.
2. **Given** a pull request, **When** CI runs, **Then** it runs analyze, the format check, all tests, and a release App Bundle build, and fails if any step fails.
3. **Given** the settings store, **When** the schema version changes in the future, **Then** the migration test harness verifies upgrades from every earlier schema version. In Phase 0 it verifies creating the version 1 schema.
4. **Given** each shared component in §15.4, **Then** it has widget tests and light/dark golden tests, and reads all colors, spacing, sizes, and text styles from `AppTokens` and the theme.
5. **Given** any user-facing string added in this feature, **Then** it exists in English, Hindi, and Gujarati, and uses placeholders instead of concatenation.

---

### Edge Cases

- **Unsupported device language**: if the device locale is not en, hi, or gu, onboarding defaults to English.
- **Language change mid-onboarding**: switching language on step 1 must not reset the user's progress or other choices.
- **App killed during onboarding**: onboarding is marked done only when "Get started" or "Skip" completes. If the app is killed earlier, the next launch starts onboarding again.
- **Notification permission denied or permanently denied**: onboarding continues normally. On Android 12 and lower, where no runtime permission exists, the button does not block anything.
- **Currency search with no matches**: shows a text-only "No matches" message with a way to clear the search.
- **Storage init failure on splash**: show the error state, never a blank screen or crash. Retry can be tapped repeatedly.
- **Last enabled module**: SET-06 and onboarding step 3 must both refuse to disable it.
- **Disabled module and an existing deep link or route**: navigation to a disabled module's tab route redirects to Home.
- **200% font scale and 360 dp width**: onboarding, splash error, SET-06, and placeholders render without clipping or overflow, including in Hindi and Gujarati, where text can run about 30% longer.
- **Settings value unreadable or corrupted**: fall back to that setting's default instead of failing startup.

## Requirements *(mandatory)*

### Functional Requirements

**Build, quality, and structure (T0.1)**

- **FR-001**: The project MUST provide two build variants that install side by side: `dev` (debug banner, application ID suffix `.dev`, "DailyTrack Dev" label) and `prod` (no suffix). Phase 0 contains no ad unit IDs at all, and the repository MUST NOT contain any ad unit ID other than Google's published test IDs. The flavor-specific ad IDs (test IDs for `dev`, real IDs supplied at build time from CI secrets for `prod`) are wired in T4.1 through the same flavor configuration.
- **FR-002**: The project MUST enforce a strict lint rule set with a zero-warnings policy.
- **FR-003**: The source tree MUST follow the folder structure in `docs/spec.md` §3 (`app/`, `core/` subfolders, `features/` with `data`/`domain`/`presentation` layering, `test/` mirroring `lib/`, `integration_test/`).
- **FR-004**: A CI workflow MUST run on every pull request: code generation, analyze, format check, all tests, and a release App Bundle build.

**Core theme, utilities, widgets, and localization (T0.2)**

- **FR-005**: The app MUST define one theme-extension token set (`AppTokens`) holding the §15.2 color roles (seed, income, expense, warning, success, habitDone, adBadge) for light and dark, the type scale, the spacing scale (4–48 dp), radii, icon sizes, minimum touch target, and max content width. Hex values MUST appear in exactly one colors file.
- **FR-006**: The theme MUST be Material 3 generated from the teal seed #0F766E, with tonal surfaces instead of shadows, and support light and dark modes.
- **FR-007**: Money and date utilities MUST be provided with unit tests. Money is formatted from integer minor units, INR uses Indian digit grouping (12,34,567.00), and the sign is shown. Date helpers convert between UTC epoch milliseconds and local `yyyy-MM-dd` date keys.
- **FR-008**: Every shared component in §15.4 MUST exist in the shared widgets folder with widget tests and golden tests: AppScaffold, AmountText, CategoryAvatar, SummaryCard, ProgressBarStatus / ProgressRing, PeriodSelector, ChipSelector, NumericKeypad, AppBottomSheet, EmptyState, ErrorState, SkeletonList / SkeletonCard, UndoSnackBar, ConfirmDialog, LockedFeatureOverlay.
- **FR-009**: Shared components MUST read colors, sizes, spacing, and text styles only from the theme and `AppTokens`. They MUST meet 48×48 dp touch targets, give icon buttons semantic labels, and never show status by color alone.
- **FR-010**: Localization MUST be set up for English, Hindi, and Gujarati, with feature-prefixed keys, placeholders and plurals instead of concatenation, and bundled Noto Sans, Noto Sans Devanagari, and Noto Sans Gujarati fonts.

**Local storage and settings (T0.3)**

- **FR-011**: The app MUST have a local database with a key-value settings table (`key` text primary key, `value` JSON text) covering at least: locale, currency code, theme mode, enabled modules (with order), onboarding done, lock enabled, and `removeAdsPurchased`. The full key list is in `docs/spec.md` §4.
- **FR-012**: A migration test harness MUST exist that verifies the current schema and is ready to verify upgrades between versions. Every future schema change MUST add a migration and a migration test.
- **FR-013**: Settings MUST be read and written through a settings repository interface. Screens MUST NOT access storage directly.

**Modules and navigation (T0.4)**

- **FR-014**: A tracker module contract MUST define: id, display name, icon, owned routes, dashboard card, quick-add action, backup section, and enable/disable hooks (`docs/spec.md` §3).
- **FR-015**: A module registry MUST list the available tracker modules. In Phase 0 these are placeholder Expense and Habit modules that implement the contract. Water and Period appear only as "Coming soon" entries and are not real modules.
- **FR-016**: Navigation MUST use a stateful shell with a bottom navigation bar of up to 4 destinations: Home, the enabled module tabs (Expenses, Habits), and More. With both modules enabled there are exactly 4. A disabled module's tab is hidden (FR-018). Each tab keeps its own back stack, labels are always visible, and the active tab uses a filled icon.
- **FR-017**: All route paths and names MUST be defined in one routes file, using the paths in `docs/spec.md` §5 (`/splash`, `/onboarding`, `/home`, `/expenses`, `/habits`, `/more`, `/more/modules`, and `/lock` as a placeholder). Module tab routes MUST come from the registry.
- **FR-018**: Module tabs MUST be shown only for enabled modules, in the order set in SET-06. Home is always first and More is always last.
- **FR-019**: Each tab MUST show a placeholder screen with a localized title. The More placeholder MUST include an entry to SET-06.
- **FR-020**: The router MUST redirect: to onboarding until onboarding is done, then to `/lock` when the lock setting is on, and to Home for routes that belong to a disabled module. Redirecting again when the app comes back from the background (the §5 timeout rule) is part of T3.1.

**Screens (T0.5)**

- **FR-021**: SYS-01 Splash MUST open storage, run migrations, and load settings, then route per the §5 startup flow. On storage failure it MUST show the error state with "Retry". It MUST NOT show any ad. It MUST use the native Android 12+ splash so there is no white flash.
- **FR-022**: SYS-02 Onboarding MUST implement the 4 steps, Skip on steps 1–2, instant language switching, the searchable currency list with locale-based preselection, the module toggles with the at-least-one rule, the "Coming soon" row, the notification permission request on Android 13+, and "Get started", all as described in `docs/spec.md` SYS-02.
- **FR-023**: SET-06 Modules MUST show a reorderable list of Expense and Habit with toggles, plus Water and Period as disabled "Coming soon" rows. Disabling MUST hide the tab and dashboard card, call the module's disable hook, and keep its data. At least one module MUST stay enabled. Order MUST control dashboard card order and module tab order.
- **FR-024**: Every screen in this feature MUST implement loading, empty (where applicable), error, and content states, and MUST pass the §15.10 design review checklist.
- **FR-025**: Phase 0 MUST create the `categories` and `accounts` tables, with the fields in `docs/spec.md` §4, the shared `id`/`createdAt`/`updatedAt` fields, and nullable `deletedAt`. Both tables MUST be covered by the migration test harness. These tables are moved forward from T1.1. On first launch, SYS-01 MUST seed exactly 12 expense categories, 5 income categories (`isDefault` = true, names stored as l10n keys and translated in en/hi/gu), and one "Cash" account (type cash, opening balance 0). It MUST record that seeding is done, so that later launches, retries after a failed start, and app restarts never seed again or create duplicates.
- **FR-026**: When onboarding is done, SYS-01 MUST read the lock-enabled setting. If it is on, the user MUST be routed to the `/lock` route (SYS-03). If it is off, the user MUST be routed to `/home` (DSH-01). In Phase 0, `/lock` shows a placeholder SYS-03 screen: full screen, no back navigation, no ads, localized title. T3.1 replaces it with the real Unlock screen without changing the routing rule. Both branches MUST be covered by tests that use a fake settings value, because no Phase 0 screen can turn the lock on.
- **FR-027**: Phase 0 MUST define the ad-service contract in the shared ads area, with an initialize operation. The Phase 0 implementation does nothing and adds no ads SDK dependency. SYS-01 MUST call initialize only when the `removeAdsPurchased` setting is false, and MUST NOT call it when the setting is true. Both cases MUST be tested with a fake ad service. Consent (UMP) ordering and the real SDK come in T4.1, behind the same contract and without changing SYS-01's gating rule.

### Key Entities

- **Setting**: one user preference as a key and a JSON value (for example locale = "gu", currencyCode = "INR", enabledModules = ["habit", "expense"], onboardingDone = true). Unknown or unreadable values fall back to defaults.
- **Tracker module**: a self-contained tracker (Expense, Habit, later Water and Period). It has an id, a display name, an icon, its own routes, a dashboard card, a quick-add action, a backup section, and enable/disable hooks.
- **Category**: an expense or income category (name, type, icon, color, isDefault, isArchived, sortOrder). Default categories are seeded once and their names are l10n keys. Moved forward from T1.1.
- **Account**: a place money is held, such as "Cash" (name, type, opening balance in minor units, icon, color, isArchived, sortOrder). One Cash account is seeded once. Moved forward from T1.1.
- **Module registry**: the ordered list of available modules. Combined with the enabled-modules setting, it decides which tabs and dashboard cards appear and in what order.
- **Design tokens (`AppTokens`)**: the single source for semantic colors, type, spacing, shapes, and sizes, in light and dark variants.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A first-time user completes onboarding in under 30 seconds (§SYS-02 purpose). Using "Skip", they reach Home in 2 taps or fewer.
- **SC-002**: A returning user goes from cold start to the Home tab in under 1.5 seconds on a mid-range device (4 GB RAM).
- **SC-003**: 100% of acceptance criteria listed in this spec have at least one automated test, and all tests pass.
- **SC-004**: The quality gates report zero analyzer warnings, zero format differences, and zero failing tests.
- **SC-005**: 100% of user-facing strings in this feature exist in all three languages. No screen in this feature clips or overflows at 200% font scale on a 360 dp-wide screen, in any of the three languages.
- **SC-006**: The selected language, currency, and module choices survive 100% of app restarts in testing.
- **SC-007**: Both dev and prod variants install side by side on the same device, and the dev variant contains zero real ad unit IDs.
- **SC-008**: Adding a hypothetical third module requires changes only in its own folder plus one registry entry, with zero edits to the Expense or Habit folders. This can be checked by review against the module contract.

## Assumptions

- **T0.1–T0.5 taken as a whole**: the request lists most Phase 0 items. Two items in T0.1/T0.2 that it doesn't name, the CI workflow and money/date utilities with unit tests, are included because they are part of those tasks. `AmountText` also needs the money formatter.
- **Placeholder modules**: Expense and Habit in Phase 0 are minimal `TrackerModule` implementations (tab route, placeholder dashboard card, no-op hooks). The exception is the `categories` and `accounts` tables and their seed data, which move forward into Phase 0 (FR-025). T1.1 keeps transactions, DAOs, and repositories. All other tables and screens come in Phases 1–2.
- **Default category set**: `docs/spec.md` doesn't list the names of the 12 expense and 5 income default categories. The plan proposes the list in `research.md` R7. `docs/spec.md` §4 should be updated to record it, because the spec is the source of truth.
- **Dashboard cards**: Home is a placeholder in Phase 0. "Hides its dashboard card" is checked by the Home placeholder listing enabled modules' placeholder cards in order.
- **Tab order with reordering**: the four destinations are Home, then enabled module tabs in SET-06 order, then More. With both modules on and default order, this is Home, Expenses, Habits, More.
- **"Set app lock" in onboarding**: SYS-04 is built in Phase 3. In Phase 0 the button is hidden. It is added in T3.1. This avoids a dead-end button.
- **Splash "Restore from backup"**: backup is built in Phase 3 (T3.2). In Phase 0 the splash error state offers "Retry" only. "Restore from backup" is added in T3.2.
- **Notification permission**: onboarding only requests the OS permission in Phase 0. Notification scheduling comes in later phases.
- **Currency list**: a curated subset of 30 ISO 4217 currencies with localized names (research R5). Preselection uses the device region (India → INR, otherwise INR as the spec default). Changing currency affects formatting only.
- **UMP consent**: the consent flow is built in Phase 4 (T4.1). In Phase 0, splash does no consent request. The ad service in Phase 0 is a do-nothing stand-in (FR-027).
- **SET-06 "basic"**: T0.5 marks SET-06 as basic. Phase 0 covers toggles, the at-least-one rule, reordering, and "Coming soon". Real notification cancelling is wired when the modules gain notifications.
- **Platform**: Android first (min API 24). Code stays iOS-ready but is not tested on iOS.
