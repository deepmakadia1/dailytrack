# DailyTrack — Screen-by-Screen Spec (Flutter, MVP: Expense + Habit)

Version 1.0 · October 13, 2026

**Changes:** 2026-10-14: EXP-01 amount search, EXP-02 category order and payment mode defaults, EXP-05 name uniqueness, and EXP-06 last active account clarified (feature `specs/002-expense-core`, clarifications Q2–Q5). 2026-10-15: EXP-11 free report periods, EXP-02 budget alerts limited to the current month, EXP-02 Repeat when editing an entry, EXP-10 turning Repeat off in rule-edit mode, and EXP-09 alert re-arming after a limit change clarified (feature `specs/003-budgets-recurring-reports`, clarifications Q1–Q5); §4 budgets uniqueness and alert reset, recurring_rules `toAccountId` and `anchorAt`, and unlocks `featureKey` stored as text (feature `specs/003-budgets-recurring-reports`, plan). 2026-10-17: EXP-02 keypad hides when the user scrolls the form and shows again only when the amount is tapped (feature `specs/004-keypad-hide-on-scroll`). 2026-10-18: HAB-01 "Skip today" uses a freeze on today, and the HAB-03 "not today" rule covers only the freeze card; freezes can be added from a dev-only debug button until rewarded ads exist (feature `specs/005-habit-module`, clarifications Q1–Q2); §4 habits gain `remindOnlyIfNotDone`, `archivedAt`, `freezesAvailable`, and `celebratedMilestones`, the new `habit_schedules` table keeps schedule and target history, and the streak rules for freezes, unscheduled days, and start dates are spelled out (feature `specs/005-habit-module`, plan). 2026-10-19: DSH-01 daily insight rotation (stored daily pick, never yesterday's when another applies), insight tap opens the related screen, Coming soon card dismissal with Undo, and transfers in Recent transactions clarified (feature `specs/006-home-dashboard`, clarifications Q1–Q4); §3 `TrackerModule` gains optional `dashboardSections()`, `insights()`, and `appBarBadge()`, and `quickAddAction()` becomes `quickAddActions()` returning a list; §4 settings gain the daily insight pick and Coming soon dismissal (feature `specs/006-home-dashboard`, plan). 2026-10-21: SYS-03 lockout escalates on each wrong PIN after the first lockout and biometric unlock stays available during a lockout; §5 re-locking on resume keeps the open screens and unsaved input; SET-01 Notifications gains a Habit reminders toggle; SET-01 Date format applies to full dates only (feature `specs/007-settings-themes-app-lock`, clarifications Q1–Q5); §4 settings gain date format, daily summary time, lock-after, hide-in-recents, and font size; SET-04 locked themes show `LockedFeatureOverlay` until PRM-02 exists (feature `specs/007-settings-themes-app-lock`, plan); §4 and §15.6/§15.10 note the erase-all and fixed-control empty-state exceptions from constitution 1.0.1 (feature `specs/007-settings-themes-app-lock`, analysis). 2026-10-21: SET-02 auto backups rotate at 5 while manual Drive backups are kept until the user deletes them, and the backup password is saved in secure storage; SET-03 one-time export unlocks are used up only by a created file; §12 widget checks never undo a check-in (feature `specs/008-backup-export-notifications-widget`, clarifications Q1–Q4); SET-02 backup file layout (JSON, zip with receipts, encrypted envelope), restorable settings, and SYS-01 restore into a fresh database; SET-05 "Show data on widget"; §12 "Mark done" day rule, snooze, daily summary refresh, and rescheduling triggers; §4 backup, widget, and time zone settings; rewarded-ads references renamed from "feature 008" to the rewarded-ads feature (T4.4) (feature `specs/008-backup-export-notifications-widget`, plan). 2026-10-22: the ad-free day reward is dropped (ads go away only with Pro); Pro is removed only after 2 online starts in a row report it not owned; the EXP-02 and HAB-02 interstitials may appear over Home when those screens close back to it; only builds meant for Play upload need the production AdMob App ID; a session starts on cold start or after 30 minutes in the background; only new EXP-02 entries count toward the interstitial counter; PRM-02 stays open after an early-closed ad; rewarded unlocks are limited to 10 per feature key per local day (feature `specs/009-ads-rewarded-pro`, clarifications); §4 `adFreeDay` kept but unused and new ads and Pro settings keys; §11 `AdService` shape, App ID placeholder, and rewarded grants; SET-02, SET-03, SET-04, HAB-03, PRM-01, PRM-02, and §15.8 updated for rewarded ads and Pro (feature `specs/009-ads-rewarded-pro`, plan). 2026-10-23: new section 16, Google account and cloud backup (ACC-01 Account, ACC-02 Restore choice, ACC-03 Sign out, auto backup while signed in, the last-backup-wins conflict rule, Drive backup metadata, Android Auto Backup); §1 scope, §2 SYS-02 "Restore with Google", §4 account and device settings, §5 routes, SET-01 Account row, SET-02 Drive card, §12 Backup notifications, and §13 offline and data safety updated to match. 2026-10-23 (later): SET-02 and §16 auto backups rotate by day (today's newest plus the newest of each of the 5 most recent earlier days); ACC-02 saves a 7-day safety copy before replacing a phone's data, restored from SET-02 "Restore previous phone data"; restoring an encrypted backup turns "Encrypt backup" on with that password (feature `specs/010-google-account-backup`, clarifications Q1–Q3); §4 `dataChangedSinceBackup` replaced by a change counter kept by SQLite triggers, plus `autoBackupPauseNotified`, `finishSetupPending`, and a settings copy of `deviceId` that detects an Android restore; §16 empty-phone guard, include-list Android backup rules, and pre-feature backups' device names; §14 T3.5 (feature `specs/010-google-account-backup`, plan and analysis). 2026-10-27: new startup and login flow: Splash → Intro (first launch only) → new AUTH-01 Login (Google or guest) → Home, with the `authMode` setting, its router redirect, and the migration of existing installs; SYS-02 renamed Intro, without "Restore with Google" or "Set app lock"; the "Finish setting up" sheet now follows every login; SET-01 account card (guest and Google states) replaces the Account row; guest sign-in from More; new ACC-04 Log out of guest; ACC-03 sign-out opens AUTH-01; the "Backed up to Google" label (never "Synced"); §1, §2, §3, §4, §5, SYS-01, SET-02, §11, §12, §13, §14 T3.6 and the T3.5 interim note, §15.5, and §16 updated to match (feature `specs/011-login-guest-mode`). 2026-10-27 (later): Erase all data (SET-01, SYS-03, ACC-03) keeps onboarding done and the device preferences ACC-04 keeps, and opens Home (AUTH-01 after ACC-03), never Intro (feature `specs/011-login-guest-mode`, clarification Q1); a guest's successful SYS-03 "Forgot PIN?" restore leaves them signed in with Google (clarification Q2); the SET-01 account card keeps the last successful backup state while waiting for Wi-Fi or offline (clarification Q3); §3 AUTH-01 moves to `features/auth/` (feature `specs/011-login-guest-mode`, plan); §4 Erase all data also keeps ad consent and the Pro state (feature `specs/011-login-guest-mode`, analysis I2).

## 1. Overview and scope

The MVP is an offline-first Flutter app (working name **DailyTrack**) with two modules, Expense and Habit, built so Water and Period trackers can be added later as new feature folders without touching existing ones. Revenue comes from AdMob (banner, native, interstitial, rewarded) plus an optional one-time "Remove Ads" purchase.

**Target users:** Indian Android users, 18–45, who want a fast daily log of spending and habits. Languages at launch: English, Hindi, Gujarati. Currency default: INR (₹), user-changeable.

**MVP in scope**

- Intro (onboarding), login (Google or guest), app lock (PIN + biometric), home dashboard
- Expense: add/edit, list with filters, categories, accounts/wallets, monthly budgets, recurring entries, reports
- Habit: create/edit, daily check-in, frequency rules, streaks, heatmap, reminders
- Settings, themes (light/dark + premium colors), backup/restore (local file + Google Drive), CSV/PDF export
- Login on first start (AUTH-01): with a Google account, for automatic Drive backup and restore on a new or reset phone, or as a guest, whose data stays only on this phone; a guest can sign in with Google later or log out, which deletes their data (section 16). The app works fully as a guest
- AdMob with consent (UMP), frequency caps, rewarded unlocks, Remove Ads IAP

**Out of scope for MVP (planned later)**

- Water tracker and Period tracker modules (Phase 3)
- Live multi-device sync (each phone backs up its own data, labeled "Backed up to Google," never "Synced") and merging data from two phones (a restore always replaces this phone's data), sign-in methods other than Google, SMS-based auto expense detection, multi-user/family sharing
- iOS release (the code stays iOS-ready, but no iOS testing in MVP)

**How to use this spec with Claude Code (SDD)**

1. Keep this file in the repo as `docs/spec.md`. Split sections 6–10 into `docs/screens/<screen_id>.md` if you prefer one file per task.
2. Keep `CLAUDE.md` at the repo root pointing to `docs/spec.md`, with the architecture rules from section 2 and the folder rules from section 3 as hard constraints.
3. Build phase by phase using section 14. For each task, ask Claude Code to: read the screen spec, write a short plan, implement, write tests, run `flutter analyze` and `flutter test`, then stop for review.
4. Every screen below has a stable **Screen ID** (e.g. `EXP-02`). Use these IDs in prompts, commit messages, and test names so the spec and code stay traceable.
5. When behavior changes, update the spec first, then the code. The spec is the source of truth.

## 2. Tech stack and architecture

The app uses feature-first clean architecture: each feature owns its presentation, domain, and data layers, and features talk to each other only through the domain interfaces in `core/` or through routes. Use the latest stable version of each package at project start and lock them in `pubspec.lock`.

| Concern | Choice | Notes |
| --- | --- | --- |
| Framework | Flutter (stable), Dart 3 | Android first; keep code iOS-ready |
| State management + DI | `flutter_riverpod` + `riverpod_generator` | Notifier/AsyncNotifier per screen; providers are the DI container |
| Routing | `go_router` | Typed routes, ShellRoute for bottom nav, redirect for onboarding, login, and app lock |
| Local database | `drift` (SQLite) | Offline-first, typed queries, migrations, reactive streams |
| Models | `freezed` + `json_serializable` | Immutable entities, JSON for backup files |
| Ads | `google_mobile_ads` | Includes UMP consent API |
| In-app purchase | `in_app_purchase` | One-time "Remove Ads" product |
| Notifications | `flutter_local_notifications` + `timezone` | Habit and budget reminders |
| Background jobs | `workmanager` | Recurring transactions, daily reminder reschedule |
| Security | `local_auth`, `flutter_secure_storage` | Biometric unlock, hashed PIN storage |
| Charts | `fl_chart` | Pie, bar, line charts |
| Localization | `flutter_localizations` + `intl` (ARB, gen-l10n) | en, hi, gu |
| Backup | `google_sign_in` + `googleapis` (Drive appDataFolder), `file_picker`, `share_plus` | JSON backup, optional encryption |
| Export | `csv`, `pdf` + `printing` | CSV and PDF reports |
| Home widget | `home_widget` | Today summary widget |
| Crash + analytics | `firebase_crashlytics`, `firebase_analytics` | No personal data in events: automatic Analytics events only (no custom events, user ID, or user properties); crash reports carry the error type and stack trace, never the message. Prod release builds only; config comes from build defines and is never committed |
| Testing | `flutter_test`, `mocktail`, `integration_test` | Unit, widget, and integration tests |
| Lints | `very_good_analysis` (or `flutter_lints`) | Zero warnings policy |

**Layer rules (hard constraints, also listed in `CLAUDE.md`)**

1. `presentation` may depend on `domain` only. It never imports Drift, `google_mobile_ads`, or any `data/` file directly.
2. `domain` is pure Dart: entities, repository interfaces, use cases. No Flutter imports.
3. `data` implements domain repositories using Drift DAOs, mappers, and services.
4. A feature never imports another feature's internals. Shared needs go into `core/` (e.g. `core/ads`, `core/notifications`) or are exposed through a domain interface.
5. All ad code lives behind an `AdService` interface in `core/ads`. Screens request ads only through provided widgets (`AppBannerAd`, `AppNativeAd`) and `AdService` methods, so ads can be disabled globally after a Remove Ads purchase.
6. All money is stored as integer minor units (paise) in an `int` column, never `double`.
7. All dates are stored in UTC as epoch milliseconds; habit check-ins use a local `yyyy-MM-dd` date key so streaks don't break across time zones.
8. Every user-facing string comes from ARB files. No hard-coded text in widgets.
9. Each screen has one controller (Riverpod Notifier) exposing an immutable `State` class with `loading`, `data`, and `error` handled explicitly.

## 3. Project folder structure

Adding the Water or Period tracker later means adding one folder under `lib/features/`, one set of Drift tables, one entry in the module registry, and its routes. Nothing in `expense/` or `habit/` should change.

```
lib/
  main.dart                      # bootstrap: init DB, ads, notifications, run app
  app/
    app.dart                     # MaterialApp.router, theme, locale
    router/
      app_router.dart            # go_router config, redirects (onboarding, login, lock)
      routes.dart                # route names + paths (single source)
    module_registry.dart         # list of enabled TrackerModules
  core/
    ads/                         # AdService, AdUnitIds, AppBannerAd, AppNativeAd, frequency cap
    billing/                     # PurchaseService (Remove Ads)
    database/                    # AppDatabase (Drift), migrations, shared tables
    notifications/               # NotificationService, channel config
    security/                    # LockService (PIN hash, biometric)
    backup/                      # BackupService (export/import JSON, Drive)
    settings/                    # SettingsRepository (key-value prefs)
    theme/                       # AppTheme, color tokens, premium themes
    l10n/                        # ARB files: app_en.arb, app_hi.arb, app_gu.arb
    utils/                       # money formatter, date utils, result type
    widgets/                     # shared UI: EmptyState, AppScaffold, ConfirmDialog
    module/
      tracker_module.dart        # abstract class every tracker module extends
      insight.dart               # Insight: one localized rule-based tip (pure Dart)
      insight_source.dart        # InsightSource: a module's insight rules
      dashboard_section.dart     # DashboardSection: an extra Home section
  features/
    onboarding/                  # SYS-02 Intro
    auth/                        # AUTH-01 Login (Google or guest)
    account/                     # SET-01 account card, ACC-01–ACC-04
    lock/
    dashboard/                   # home; pulls summary cards from each module
    expense/
      data/                      # tables, daos, repository_impl, mappers
      domain/                    # entities, repositories (abstract), usecases
        insights/                # pure insight rules (no Flutter imports)
      presentation/
        screens/                 # one file per screen (EXP-01 ...)
        widgets/
        controllers/             # Riverpod notifiers + state classes
        insights/                # InsightSource: reads data, localizes the rules' facts
      expense_module.dart        # extends TrackerModule
    habit/                       # same shape as expense/
    settings/
    premium/                     # rewarded unlocks, Remove Ads screen
  # later: features/water/, features/period/
test/                            # mirrors lib/ structure
integration_test/
docs/
  spec.md
  screens/
```

**TrackerModule contract** (in `core/module/tracker_module.dart`). It is an abstract class, so the optional members have defaults; modules use `extends TrackerModule` and keep `const` constructors. Each module exposes:

- `id` and display name/icon, used in the dashboard and settings
- `routes`: the go_router routes it owns
- `dashboardCard()`: a widget the Home screen shows for that module
- `quickAddActions()`: the entries this module adds to the global + menu (Expense: Add expense, Add income; Habit: Check in habit)
- Optional, with empty defaults so new modules need not implement them: `dashboardSections()` (extra Home sections below the cards, e.g. Expense's Recent transactions), `insights()` (the module's rule-based insight source for the Home insight card), `appBarBadge()` (a Home app bar badge, e.g. Habit's streak flame)
- `quickAddActions()` defaults to an empty list too
- `backupSection()`: export/import of its own tables as a JSON section
- `onEnable()` / `onDisable()`: schedule or cancel its notifications

**Insights** (`core/module/insight.dart`, `insight_source.dart`):

- `Insight { ruleId, text, location?, semanticLabel? }`. `ruleId` is stable across releases, unique app-wide, and prefixed with the module id (`expense.categoryVsLastMonth`). `text` is already localized. `location` is the route opened on tap (null means not tappable); `semanticLabel` falls back to `text`.
- `InsightSource.ruleIds`: every rule the module may return, in its fixed rotation order, with no duplicates.
- `InsightSource.evaluate(read)`: the applicable insights only, at most one per rule id, each id in `ruleIds`. It reads only local data, makes no network calls, and never throws (a failing rule is skipped).
- The rules themselves are pure Dart with an injected `Clock` under `features/<module>/domain/insights/`, and return unlocalized facts. Expense: `expense.categoryVsLastMonth`, `expense.budgetOnTrack`, `expense.budgetNearLimit`. Habit: `habit.nextMilestone`, `habit.bestThisWeek`, `habit.comeback`.

The dashboard, backup, and settings screens loop over the registry, so they never import a module directly. A disabled module contributes nothing to Home. Users can turn modules on or off in Settings.

## 4. Data model (Drift tables)

All tables use a `TEXT` UUID primary key `id`, plus `createdAt` and `updatedAt` (UTC epoch ms). User data tables also have a nullable `deletedAt` for soft delete, so undo works and backups stay consistent. The one exception is the user-confirmed "Erase all data" (SET-01, SYS-03, and the same erase in ACC-03 and ACC-04 "Log out of guest"), which removes every row permanently. Money is `int` minor units (₹10.50 = 1050).

**accounts**

| Field | Type | Notes |
| --- | --- | --- |
| name | text | "Cash", "SBI Savings", "Paytm" |
| type | enum AccountType | cash, bank, upi, card, wallet |
| openingBalanceMinor | int | Balance = opening + income − expense ± transfers |
| iconKey, colorHex | text | From a fixed icon/color set |
| isArchived | bool | Hidden from pickers, kept in history |
| sortOrder | int | Drag to reorder |

**categories**

| Field | Type | Notes |
| --- | --- | --- |
| name | text | Default names are l10n keys; user-created ones are plain text |
| type | enum CategoryType | expense, income |
| iconKey, colorHex | text | |
| isDefault | bool | Seeded on first launch; can be hidden but not deleted |
| isArchived | bool | |
| sortOrder | int | |

**Default seed (first launch, exactly once):** Expense (12): food, groceries, transport, fuel, shopping, bills, rent, health, education, entertainment, travel, other. Income (5): salary, business, gift, interest, other. Account: Cash (type cash, opening balance 0). Names are l10n keys (`expense_cat_<slug>`, `income_cat_<slug>`, `expense_account_cash`).

**transactions**

| Field | Type | Notes |
| --- | --- | --- |
| type | enum TxnType | expense, income, transfer |
| amountMinor | int | Always positive; sign comes from type |
| accountId | FK accounts | Source account |
| toAccountId | FK accounts, nullable | Only for transfer |
| categoryId | FK categories, nullable | Null for transfer |
| paymentMode | enum PaymentMode | cash, upi, card, netBanking, other |
| note | text, nullable | Max 200 chars |
| occurredAt | int (UTC ms) | User-chosen date and time |
| receiptPath | text, nullable | Local file path in app storage |
| recurringRuleId | FK recurring_rules, nullable | Set when auto-created |

Indexes: `(occurredAt)`, `(categoryId, occurredAt)`, `(accountId, occurredAt)`.

**budgets**

| Field | Type | Notes |
| --- | --- | --- |
| categoryId | FK categories, nullable | Null = overall monthly budget |
| monthKey | text `yyyy-MM` | Unique with categoryId among non-deleted budgets: one budget per category, and one overall budget, per month |
| limitMinor | int | |
| rollover | bool | Copy to next month automatically |
| alert80SentAt, alert100SentAt | int, nullable | Prevents repeat alerts; cleared when a limit change makes that threshold unmet (EXP-09) |

**recurring_rules**

| Field | Type | Notes |
| --- | --- | --- |
| templateType, amountMinor, accountId, toAccountId, categoryId, paymentMode, note | as transactions | Template for generated entries; `toAccountId` only for transfers |
| frequency | enum Frequency | daily, weekly, monthly, yearly |
| interval | int | Every N periods |
| anchorAt | int (UTC ms) | First occurrence; later dates are computed from it, so a rule on the 31st returns to the 31st after a shorter month |
| nextRunAt | int (UTC ms) | Worker creates entries up to now, then advances |
| endAt | int, nullable | |
| isActive | bool | |

**habits**

| Field | Type | Notes |
| --- | --- | --- |
| name | text | Max 40 chars |
| iconKey, colorHex | text | |
| kind | enum HabitKind | yesNo, count |
| targetValue | int | 1 for yesNo; e.g. 20 for "20 pages" |
| unit | text, nullable | "pages", "min", "steps" |
| scheduleType | enum ScheduleType | daily, specificWeekdays, timesPerWeek |
| weekdaysMask | int | Bitmask Mon=1 … Sun=64 |
| timesPerWeek | int, nullable | |
| reminderTimes | text (JSON list of `HH:mm`) | 0–3 reminders |
| remindOnlyIfNotDone | bool | "Remind me only if not done yet" (default true) |
| startDateKey | text `yyyy-MM-dd` | |
| isArchived | bool | |
| archivedAt | int (UTC ms), nullable | Shown in HAB-04; cleared on restore |
| sortOrder | int | |
| freezesAvailable | int | 0–2 stored streak freezes |
| celebratedMilestones | int | Bitmask over 7, 21, 30, 50, 100, 365; a milestone sheet is shown once per bit |

The schedule and target columns above hold the habit's current settings. Their history is kept in `habit_schedules`, so a change applies from its change date onward (HAB-02).

**habit_schedules**

| Field | Type | Notes |
| --- | --- | --- |
| habitId | FK habits | |
| effectiveFromKey | text `yyyy-MM-dd` | Local date the version takes effect; unique with habitId among non-deleted rows |
| scheduleType, weekdaysMask, timesPerWeek, targetValue | as habits | The settings in effect from that date |

**habit_entries**

| Field | Type | Notes |
| --- | --- | --- |
| habitId | FK habits | |
| dateKey | text `yyyy-MM-dd` | Local date; unique with habitId |
| value | int | 1 for done (yesNo), or count achieved |
| isFreeze | bool | Streak freeze day (from rewarded ad) |
| note | text, nullable | Max 200 chars |

**unlocks** (rewarded and purchased features)

| Field | Type | Notes |
| --- | --- | --- |
| featureKey | text (FeatureKey) | exportCsv, exportPdf, premiumTheme_{name}, advancedReports, adFreeDay, streakFreeze; stored as text because `premiumTheme_{name}` carries a theme name. `adFreeDay` is kept (append-only) but never granted (feature `specs/009-ads-rewarded-pro`); a rewarded streak freeze adds to `habits.freezesAvailable` instead of writing a row |
| expiresAt | int, nullable | Null = permanent |
| source | enum UnlockSource | rewardedAd, purchase. Pro is read from `removeAdsPurchased`, so purchase rows are not written |

**settings** is a key-value table (`key` text PK, `value` text JSON) for: locale, currency code, theme mode, selected theme, first day of week, lock enabled, biometric enabled, enabled modules, onboarding done, ad consent status, last backup time, `removeAdsPurchased`, the Home daily insight pick (`dailyInsightDate` local `yyyy-MM-dd` + `dailyInsightId`, written together), whether the Home Coming soon card was dismissed (`homeComingSoonDismissed`), date format (`dateFormat`, full dates only), daily summary time (`dailySummaryTime`, local `HH:mm`), lock after (`lockAfterSeconds`: 0, 60, 300), hide app content in recents (`hideInRecents`), font size (`fontSize`: default, large), backup state (`lastBackupLocation`: device, drive; `lastBackupSizeBytes`; `lastAutoBackupAt`; `backupAccountEmail`; `autoBackupFrequency`: off, daily, weekly; `autoBackupWifiOnly`; `backupEncrypt`; `backupIncludeReceipts`; `autoBackupFailures`; `autoBackupFailureNotified`; `backupLeaseUntil`), `showDataOnWidget`, the last seen device time zone (`deviceTimeZoneId`), interstitial cap state (`adsInstallAt`, kept by Erase all data; `adsLastInterstitialAt`; `adsInterstitialDay` + `adsInterstitialsToday`; `adsLastSessionDay`), and Pro checks (`proNotOwnedStreak`, `proPurchasePending`, `proRemovalPending`: a removal staged until the next cold start), and the Google account and cloud backup state (section 16): `backupAccountEmail` is the signed-in Google account (empty when signed out), plus `accountDisplayName`, `accountPhotoUrl`, the change counter (`dataChangeCounter`, raised by SQLite triggers on every write to a backed-up table or a restorable preference, never written by app code; `backedUpChangeCounter`, the counter value captured in the last successful backup or restore; data has changed since the last backup while the two differ), `lastBackgroundBackupAt` (UTC ms the last background backup was requested, for the 15-minute limit), `lastKnownDriveBackupAt` + `lastKnownDriveBackupDeviceId` (the newest Drive backup this phone made, restored, or chose to keep its own data over; used by the conflict rule), `autoBackupPausedByConflict` + `autoBackupPauseNotified` (the pause notice was shown for this pause), `finishSetupPending` (show the "Finish setting up" sheet once on Home, after a login or an Android Auto Backup restore), and a copy of `deviceId` (see Device identity). The sign-in mode is `authMode`: `none` (no login chosen yet; the router opens AUTH-01), `guest` (data only on this phone), or `google` (signed in, `backupAccountEmail` set); new installs start at `none`. An install updated from a version without `authMode` gets `guest` if onboarding is done, or `google` if onboarding is done and `backupAccountEmail` is set; otherwise it stays `none` (migrated once by SYS-01 before routing). `authMode` is never backed up or restored. Erase all data keeps `authMode` and the account keys, `deviceId`, `lastKnownDriveBackup*`, and the auto backup settings, and resets both change counters to 0. It also keeps ad consent, the Pro state (`removeAdsPurchased` and the Pro check keys), onboarding done, and the device preferences that ACC-04 keeps (language, currency, theme mode and selected theme, enabled modules and their order; a premium theme from a rewarded unlock falls back to Default Teal unless Pro is owned), so Intro is never shown again: afterwards the app opens Home, or AUTH-01 when `authMode` is `none` (ACC-03 "Remove data from this phone") (feature `specs/011-login-guest-mode`, clarification Q1). Only user preferences are restored from a backup (SET-02). The PIN hash and lockout state are not in this table; they live in `flutter_secure_storage`, as does the backup encryption password (`backup.password`).

**Device identity:** `deviceId` (a random UUID made on the first start) and nothing else device-specific is kept in a small file in Android's no-backup folder (`Context.getNoBackupFilesDir()`), so neither a Drive restore nor Android Auto Backup ever copies one phone's ID to another. A copy is also stored in this table as `deviceId` (never restored from a Drive backup). It travels with the database when Android restores it, so a copy without the file means "this database came from Android Auto Backup or device transfer" (§16). An install updated from a version without device IDs has neither, and simply gets a new ID. The device name shown in backups is read from the system at backup time (manufacturer + model, e.g. "Xiaomi Redmi Note 12") and is not stored.

**Business rules for streaks.** A habit's current streak counts back from today over scheduled days only. A scheduled day breaks the streak if it has no entry reaching `targetValue` and no freeze. Today never breaks the streak until the day is over. For `timesPerWeek`, the streak counts consecutive weeks where the target was met. Each day is judged with the schedule and target in effect on that date (`habit_schedules`). Days before `startDateKey` are not scheduled. A freeze day keeps the streak unbroken but does not add to it, and is left out of completion rate. Completions on unscheduled days count toward total completions but not toward the streak (feature `specs/005-habit-module`).

## 5. Navigation map and routes

The app has a bottom navigation bar with four tabs (Home, Expenses, Habits, More) inside a go_router `StatefulShellRoute`, so each tab keeps its own back stack. Add/edit screens open full-screen above the shell; pickers and small forms open as bottom sheets.

**Startup flow**

1. `SYS-01` Splash initializes the database, settings, consent, and ads SDK, and migrates `authMode` for installs updated from an earlier version (section 4).
2. If onboarding is not done → `SYS-02` Intro (first launch only), which ends by opening `AUTH-01`.
3. Else if `authMode` is `none` → `AUTH-01` Login.
4. Else if app lock is enabled → `SYS-03` Unlock.
5. Else → `DSH-01` Home.
6. Leaving `AUTH-01` (Google or guest) goes to `SYS-03` first if app lock is enabled (a phone that kept its data after sign-out), else to `DSH-01`. App lock always applies after login.
7. When the app returns from background after more than 60 seconds (configurable: immediately, 1 min, 5 min), the router redirects to `SYS-03` if lock is enabled and `authMode` is not `none`. Re-locking on resume covers the open screens instead of replacing them, so after unlocking the user is on the same screen with the same back history and unsaved input.

**Router redirect:** if onboarding is not done, every route except `/splash` redirects to `/onboarding`. If onboarding is done and `authMode` is `none`, every route except `/splash` and `/login` redirects to `/login` (AUTH-01). `/login` redirects to Home (through `SYS-03` when locked) once `authMode` is `guest` or `google`. Setting `authMode` to `none` (ACC-03 Sign out, ACC-04 Log out of guest) therefore lands on AUTH-01 with the back stack cleared.

| Screen ID | Screen | Route | Opens as |
| --- | --- | --- | --- |
| SYS-01 | Splash | `/splash` | Full screen |
| SYS-02 | Intro (onboarding) | `/onboarding` | Full screen |
| AUTH-01 | Login | `/login` | Full screen, no back |
| SYS-03 | Unlock | `/lock` | Full screen, no back |
| SYS-04 | Set / change PIN | `/settings/security/pin` | Full screen |
| DSH-01 | Home dashboard | `/home` | Tab 1 |
| EXP-01 | Transactions list | `/expenses` | Tab 2 |
| EXP-02 | Add / edit transaction | `/expenses/add`, `/expenses/:id/edit` | Full screen modal |
| EXP-03 | Transaction detail | `/expenses/:id` | Push |
| EXP-04 | Categories | `/expenses/categories` | Push |
| EXP-05 | Add / edit category | — | Bottom sheet |
| EXP-06 | Accounts | `/expenses/accounts` | Push |
| EXP-07 | Add / edit account | — | Bottom sheet |
| EXP-08 | Budgets | `/expenses/budgets` | Push |
| EXP-09 | Set budget | — | Bottom sheet |
| EXP-10 | Recurring transactions | `/expenses/recurring` | Push |
| EXP-11 | Reports | `/expenses/reports` | Push |
| HAB-01 | Habits (today) | `/habits` | Tab 3 |
| HAB-02 | Add / edit habit | `/habits/add`, `/habits/:id/edit` | Full screen modal |
| HAB-03 | Habit detail | `/habits/:id` | Push |
| HAB-04 | Archived habits | `/habits/archived` | Push |
| SET-01 | More / Settings | `/more` | Tab 4 |
| SET-02 | Backup and restore | `/more/backup` | Push |
| SET-03 | Export data | `/more/export` | Push |
| SET-04 | Themes and appearance | `/more/themes` | Push |
| SET-05 | Security | `/more/security` | Push |
| SET-06 | Modules | `/more/modules` | Push |
| ACC-01 | Account | `/more/account` | Push |
| ACC-02 | Restore choice | — | Bottom sheet |
| ACC-03 | Sign out | — | Bottom sheet |
| ACC-04 | Log out of guest | — | Dialog (`ConfirmDialog`) |
| PRM-01 | Premium / Remove Ads | `/premium` | Full screen modal |
| PRM-02 | Rewarded unlock prompt | — | Bottom sheet (shared component) |

Keep all paths and names in `app/router/routes.dart`. Each module adds its routes through `TrackerModule.routes`, so Water and Period later get `/water/...` and `/period/...` without editing the router file beyond the registry.

## 6. Shared screens

Every screen spec in sections 6–10 and 16 follows the same template: **Purpose**, **Layout** (top to bottom), **Behavior**, **States** (loading, empty, error), **Ads**, and **Acceptance criteria**. Claude Code should turn each acceptance criterion into at least one widget or unit test. All screens also follow the UI/UX guidelines in section 15, which apply even where a screen spec doesn't repeat them.

### SYS-01 Splash

**Purpose:** Initialize services and route the user to the right first screen.

**Layout:** App logo centered on the theme background, small app name below. Use the native Android 12+ splash API (`flutter_native_splash`) so there is no white flash.

**Behavior:**

- In parallel: open Drift database and run migrations, load settings, init `NotificationService`, request UMP consent info update.
- After consent is resolved (or skipped if not required), call `MobileAds.instance.initialize()` only if ads can be shown (`removeAdsPurchased == false`).
- Seed default categories and a "Cash" account on first launch only.
- Before routing, migrate `authMode` once for an install updated from a version without it (section 4).
- Route per the startup flow in section 5. Target: under 1.5 s on a mid-range device.

**States:** If database init fails, show an error screen with "Retry" and "Restore from backup" options ("Restore from backup" is added in T3.2; Phase 0 offers Retry only).

**Ads:** None. Never show an app-open or interstitial ad on cold start.

**Acceptance criteria:**

- [ ] First launch seeds 12 expense categories, 5 income categories, and one Cash account, exactly once.
- [ ] Returning user with `authMode` guest or google and lock on lands on SYS-03; without lock lands on DSH-01.
- [ ] Onboarding done with `authMode` none lands on AUTH-01, even with app lock on.
- [ ] An updated install with onboarding done and no `authMode` gets `guest`, or `google` when a Google account is signed in, and never sees AUTH-01.
- [ ] Ads SDK is not initialized when Remove Ads is purchased.

### SYS-02 Intro

**Purpose:** Set language, currency, and modules in under 30 seconds, and explain the value. Shown on first launch only. Login and app lock come after it (AUTH-01).

**Layout:** A 4-step `PageView` with a progress indicator and "Skip" (top right) on steps 1–2.

1. **Welcome:** Illustration, headline "Track money and habits in one place," language selector chips (English, हिन्दी, ગુજરાતી). Changing language updates the UI instantly.
2. **Currency:** Searchable list of 30 common ISO 4217 currencies, INR preselected based on device locale.
3. **Choose modules:** Two toggle cards, Expense and Habit, both on by default. At least one must stay on. A "Coming soon" row shows Water and Period (disabled).
4. **Reminders and privacy:** Explain that data is kept on this phone, and that the next step lets the user back it up with Google or continue as a guest. Button: "Allow notifications" (requests `POST_NOTIFICATIONS` on Android 13+). Primary button "Get started."

**Behavior:**

- "Get started" saves settings, marks onboarding done, and opens AUTH-01, replacing Intro so back can't return to it. Skip uses defaults (device language if supported, else English; INR; both modules on) and also opens AUTH-01.
- Intro offers no sign-in, restore, or app lock. A user coming from another phone restores from AUTH-01 "Continue with Google," and app lock is offered after login (AUTH-01 "Finish setting up").

**Ads:** None.

**Acceptance criteria:**

- [ ] Selected language persists and applies after app restart.
- [ ] Denying the notification permission does not block onboarding.
- [ ] User cannot turn off both modules.
- [ ] "Get started" and Skip both mark onboarding done and open AUTH-01; back on AUTH-01 never returns to Intro.
- [ ] Intro shows no "Restore with Google" or "Set app lock" option.
- [ ] Closing the app during Intro shows Intro again on the next start; closing it on AUTH-01 shows AUTH-01, not Intro.

### AUTH-01 Login

**Purpose:** Let the user choose how to keep their data before using the app: signed in with Google, so it is backed up and can come back on a new phone, or as a guest, with data only on this phone.

**Layout:** Full screen, no app bar, no back arrow, content centered.

1. App logo (as on SYS-01) and app name.
2. Value message: title "Keep your data safe" and one line "Sign in with Google to back up your expenses and habits and get them back on a new phone."
3. Primary button "Continue with Google."
4. Secondary button "Continue as guest."
5. Note in `bodySmall`: "As a guest, your data stays only on this phone."
6. Inline error area under the buttons (hidden until sign-in is cancelled or fails), with a "Try again" action.

**Behavior:**

- Opens after Intro, after ACC-03 Sign out, after ACC-04 Log out of guest, and on any start with onboarding done and `authMode` none (section 5). Android back closes the app; it never returns to Intro or to the screens before a sign-out.
- **Continue with Google:** opens Google Sign-In (account chooser and scope consent, section 16) and saves the account keys on success. Then it runs the ACC-02 restore check (section 16):
  - Account has a backup and this phone has no user data (a fresh install, or after Remove data or Log out of guest): the newest backup is restored at once behind a full-screen progress view ("Restoring your data…"), with no choice sheet. An encrypted backup first asks for its password. Language, currency, and modules come from the backup. Restore purchase (PRM-01) runs in the background, without UI unless Pro is found ("Pro restored").
  - Account has a backup and this phone has user data (kept after ACC-03 Sign out): ACC-02 opens and can't be dismissed, so the user restores or keeps this phone's data.
  - Account has no backup: nothing is restored.
  - Then it sets `authMode = google`, sets Auto backup to Daily if it was Off, starts auto backup (a first backup runs right away when the account had no backup or the user kept this phone's data), and goes to Home.
- **Continue as guest:** sets `authMode = guest` and goes to Home. No sign-in, Drive, or other network request is made, and nothing leaves the phone. Data already on the phone (kept after ACC-03) stays and is used as the guest's data.
- **Sign-in cancelled or failed:** stays on AUTH-01 with `authMode` none and nothing written. The inline error says "Sign-in was cancelled. Try again or continue as a guest." or "Couldn't sign in. Check your connection and try again." "Try again" reopens Google Sign-In; "Continue as guest" stays available.
- **Offline:** "Continue with Google" shows the inline error "You're offline. Connect to the internet to sign in with Google, or continue as a guest." with "Try again," and writes nothing. "Continue as guest" works fully offline.
- **Restore fails after sign-in** (download, decrypt, or validation error, or the connection drops): "Couldn't restore. Your data on this phone wasn't changed." with "Try again" and "Continue without restoring." "Continue without restoring" finishes the Google path with this phone's data as it is (`authMode = google`); the empty-phone guard (section 16) keeps auto backup from replacing the account's backup with an empty one, and ACC-01 "Restore" stays available.
- **After login (either path):** if app lock is off, Home shows the "Finish setting up" bottom sheet once (`finishSetupPending`): "Set app lock" (→ SYS-04), "Allow notifications" (only on Android 13+ when the permission isn't granted), and "Not now." Any choice, or dismissing the sheet, clears the flag; it is not shown again until the next login. With app lock on, leaving AUTH-01 goes through SYS-03 first and the sheet is not shown.

**States:**

- Signing in: progress on "Continue with Google," both buttons disabled.
- Restoring: full-screen progress view, as above.
- Error: the inline error area (sign-in) or the restore error view (restore); the screen never shows a stack trace or code.
- No loading or empty state: the screen is a fixed set of controls and reads no data (constitution V; the feature plan says so).

**Ads:** None, ever. No interstitial may appear over this screen (section 11).

**Acceptance criteria:**

- [ ] On a fresh install, Intro opens AUTH-01; back on AUTH-01 closes the app and never shows Intro.
- [ ] "Continue as guest" sets `authMode = guest` and opens Home without any sign-in, Drive, or network call (a fake sign-in and Drive client record zero calls), online and offline.
- [ ] "Continue with Google" on an account with no backup sets `authMode = google`, turns Auto backup to Daily if it was Off, runs a first backup, and opens Home.
- [ ] "Continue with Google" on an account with a backup and no user data on the phone restores the newest backup without a choice sheet and opens Home with the backup's data, language, currency, and modules; Restore purchase runs.
- [ ] "Continue with Google" with user data on the phone opens ACC-02 before Home, and the sheet can't be dismissed without a choice.
- [ ] Cancelled or failed sign-in stays on AUTH-01 with the inline error and "Try again"; `authMode` stays none and no data or account key is written.
- [ ] Offline, "Continue with Google" shows the offline inline error and writes nothing, and "Continue as guest" still opens Home.
- [ ] A failed restore after sign-in leaves this phone's data unchanged and offers "Try again" and "Continue without restoring."
- [ ] After login on either path with app lock off, the "Finish setting up" sheet appears once on Home and not again after a restart.
- [ ] With app lock on (data kept after sign-out), leaving AUTH-01 on either path shows SYS-03 before Home.
- [ ] No ad is requested while AUTH-01 is open.

### SYS-03 Unlock

**Purpose:** Protect the app with a PIN or biometric.

**Layout:** App logo, "Enter PIN" title, 4 PIN dots, numeric keypad (1–9, biometric icon, 0, backspace), "Forgot PIN?" link.

**Behavior:**

- If biometric is enabled and available, show the system biometric prompt automatically on open.
- PIN is verified against a salted hash (PBKDF2 or Argon2) in `flutter_secure_storage`. Never store the plain PIN.
- After 5 wrong attempts, lock input for 30 s. After that, each further wrong PIN starts the next lockout at double the previous length (60 s, 2, 4, 8 min, then 15 min max). A successful unlock (PIN or biometric) resets the count. Biometric unlock stays available during a lockout. The lockout state is kept in `flutter_secure_storage`, so it survives restart.
- "Forgot PIN?" explains the PIN cannot be recovered and offers to reset the app by restoring from a Google Drive backup after Google sign-in, or erasing all data after a typed confirmation. A guest whose restore succeeds stays signed in (`authMode = google`, Auto backup Daily if it was Off); a cancelled sign-in or failed restore keeps them a guest (feature `specs/011-login-guest-mode`, clarification Q2).
- Android back button closes the app; it never bypasses the lock.

**Ads:** None, ever.

**Acceptance criteria:**

- [ ] Correct PIN unlocks and returns the user to the screen they were on before backgrounding.
- [ ] Lockout timer survives app restart.
- [ ] Screenshots are blocked on this screen (`FLAG_SECURE`).

### SYS-04 Set / change PIN

**Purpose:** Create, change, or turn off the PIN.

**Layout:** Same keypad as SYS-03. Steps: enter current PIN (when changing), enter new PIN, confirm new PIN. After first setup, a toggle offers "Use fingerprint / face unlock" if the device supports it.

**Behavior:** Mismatch on confirm shakes the dots and restarts the confirm step. Turning off the lock requires the current PIN.

**Acceptance criteria:**

- [ ] PIN cannot be set without matching confirmation.
- [ ] Disabling lock requires the current PIN.

## 7. Home dashboard

### DSH-01 Home

**Purpose:** Show today's status for every enabled module at a glance and offer one-tap logging. This is the most-opened screen, so it must load from local data in under 300 ms.

**Layout (scrollable, top to bottom):**

1. **App bar:** Greeting by time of day ("Good morning") and today's date. Right side: streak flame icon with the best active habit streak (taps to HAB-01).
2. **Expense summary card** (from `ExpenseModule.dashboardCard()`): "Spent today" amount, "This month" spent vs overall budget with a progress bar (green under 80%, amber 80–100%, red over 100%), and a "+ Expense" chip. Tap opens EXP-01.
3. **Habit summary card** (from `HabitModule.dashboardCard()`): progress ring "3 of 5 done today," then a horizontal list of today's scheduled habits as round check buttons. Tapping a check marks it done (yes/no) or opens a +1 / custom value popup (count habits). Long-press opens HAB-03.
4. **Native ad slot** (`AppNativeAd`, medium template, styled like a card with an "Ad" label). Placed after the second card, never at the top.
5. **Recent transactions:** Last 5 entries with category icon, note, account, and amount. "See all" opens EXP-01.
6. **Insight card:** One rule-based tip, for example "Food spending is 20% higher than last month" or "You're 2 days away from a 30-day streak." Rotates daily. Generated locally from simple rules, no network.
7. **Coming soon card:** Water and Period trackers (dismissible). Later replaced by their own dashboard cards.

**Floating action button:** A single + button. Tapping opens a small menu with "Add expense," "Add income," and "Check in habit," built from each enabled module's `quickAddActions()`, in module order. It hides while scrolling down.

**Behavior:**

- All cards listen to Drift streams, so changes made elsewhere appear instantly.
- Pull-to-refresh recomputes insights only.
- The day's insight pick (local date + insight id) is stored. On a new day Home picks the next applicable insight after yesterday's in a fixed rule order, cycling, and never yesterday's when another applies. If no rule applies, a general starter tip shows.
- Tapping the insight card opens its related screen (e.g. a spending tip opens EXP-11, a budget tip opens EXP-08, a streak tip opens HAB-03 for that habit). The starter tip is not tappable.
- Recent transactions include transfers, shown as in EXP-01 (neutral amount, "From → To").
- Dismissing the Coming soon card shows Undo for 5 seconds; after that it stays hidden.
- Cards appear in the order of enabled modules; users can reorder them in SET-06.

**States:**

- Empty (first day): each card shows a friendly empty state with one action ("Add your first expense," "Create your first habit").
- If a module is disabled, its card is hidden.

**Ads:** One native ad only. This screen never triggers an interstitial; the EXP-02 and HAB-02 interstitials may appear over Home only right after those screens close back to it (section 11). Hide the ad slot when Remove Ads is active.

**Acceptance criteria:**

- [ ] Marking a habit done from Home updates the ring, the habit list, and the streak icon without reload.
- [ ] Budget bar color changes at 80% and 100% thresholds.
- [ ] Native ad never appears above the first module card.
- [ ] Screen renders correctly with only one module enabled.

## 8. Expense module screens

### EXP-01 Transactions list (Expenses tab)

**Purpose:** Browse, search, and filter all transactions for a period.

**Layout:**

1. **App bar:** Title "Expenses," search icon, filter icon, overflow menu (Categories, Accounts, Budgets, Recurring, Reports).
2. **Period selector:** `< October 2026 >` with arrows; tapping the label opens a picker for Day, Week, Month, Year, or Custom range. Default: current month.
3. **Summary strip:** Income, Expense, Net for the period (income green, expense red).
4. **Active filter chips** (if any): category, account, payment mode, type, amount range. Each chip has an × to remove it.
5. **Grouped list:** Sticky date headers ("Today," "Yesterday," "Mon, 12 Oct") with that day's total. Each row: category icon in a colored circle, category name, note (one line, ellipsized), account + payment mode in small text, amount right-aligned.
6. **Native ad** after the 8th row, then every 15 rows, maximum 3 per screen load.
7. **Banner ad** anchored at the bottom above the nav bar (`AppBannerAd`, standard 320×50 size).
8. **FAB:** + opens EXP-02 with type Expense.

**Behavior:**

- Tap row → EXP-03. Swipe left → delete with a 5-second "Undo" snackbar (soft delete). Swipe right → duplicate into EXP-02 with today's date.
- Search matches note, category name (default categories by their name in the current language), and amount, debounced 300 ms. An amount matches exactly, or as a prefix of the whole-rupee digits when the query has no decimal point ("12" finds ₹12, ₹120, ₹1,250; "12.5" finds only ₹12.50).
- List is paginated by 50 rows using Drift `limit/offset` and a reactive stream.
- Filters are kept while the app is open and reset on restart.

**States:** Loading shimmer; empty period shows illustration and "No transactions in October" with an "Add expense" button; no search results shows "No matches" with a "Clear filters" button.

**Acceptance criteria:**

- [ ] Totals in the summary strip always equal the sum of visible rows (transfers excluded).
- [ ] Undo restores a deleted row in its original position.
- [ ] Changing period updates the list, totals, and ads without leaving the screen.

### EXP-02 Add / edit transaction

**Purpose:** Log a transaction in under 5 seconds. Speed is the main design goal.

**Layout:**

1. **Top segmented control:** Expense · Income · Transfer.
2. **Amount field:** Large, auto-focused, with currency symbol and a custom numeric keypad (digits, decimal, backspace, and a small calculator for + − × ÷). Shows formatted Indian grouping (₹1,25,000).
3. **Category grid:** 4-column grid of icons for the selected type, ordered by how often the user picks each category, with the EXP-04 order as the tiebreak and as the whole order when there is no history. "+ New" is at the end (opens EXP-05). Hidden for Transfer.
4. **Account picker chip** (default: last used). For Transfer, "From" and "To" chips.
5. **Payment mode chips:** Cash, UPI, Card, Net banking, Other. Default from the account type: Cash → Cash, Bank → Net banking, UPI wallet → UPI, Card → Card, Wallet → Other.
6. **Date and time chip:** Default now; opens date and time pickers.
7. **Note field:** Optional, 200 chars, with recent-note suggestions.
8. **Attach receipt:** Camera or gallery; image is compressed (max 1280 px, JPEG 80%) and stored in app storage.
9. **Repeat toggle:** Off by default. When on, choose Daily, Weekly, Monthly, Yearly and an optional end date; creates a `recurring_rule`. Also shown when editing an entry that is not linked to a rule: saving with Repeat on makes that entry the rule's first occurrence and creates any occurrences already due; Undo removes the rule and those entries and reverts the edit. Hidden when editing an entry linked to a rule.
10. **Save button** (sticky bottom). In edit mode, a delete icon in the app bar.

**Validation:** Amount > 0 and ≤ 99,99,99,999; category required for Expense/Income; From and To must differ for Transfer. Errors show inline under the field.

**Behavior:**

- "Save" closes the screen and shows a snackbar "Saved · Undo." A long-press on Save offers "Save and add another."
- After saving an expense dated in the current month, check that category's budget and the overall budget; trigger a local notification at 80% and 100% (once each per month). Expenses dated in other months, including recurring entries generated for past months, update those budgets but send no notification.
- Unsaved changes trigger a "Discard changes?" dialog on back.
- **Keypad visibility** (user story: *As a user entering a transaction, I want the keypad to get out of the way when I scroll, so that I can see the rest of the form*): the keypad shows when a new entry opens and whenever the amount is tapped. It hides when the user starts scrolling the form by touch, on Done, and when the note field is tapped. Once hidden it shows again only when the amount is tapped; scrolling back up or tapping other controls does not show it. Hiding it keeps the typed amount or calculation and is not an unsaved change. Scrolls started by the app itself do not hide it.

**Ads:** No banner or native ads on this screen. After every 4th new entry saved in a session (new entries, duplicates, and "Save and add another" count; edits don't), request an interstitial **after** the screen closes, subject to the global frequency cap (section 11).

**Acceptance criteria:**

- [ ] A new expense can be saved with amount + category only in 3 taps after typing the amount.
- [ ] Amount is stored in paise without rounding errors (e.g. 10.10 → 1010).
- [ ] Scrolling the form hides the keypad without changing the amount; only tapping the amount shows it again.
- [ ] Budget alert fires once at 80% and once at 100% per category per month.
- [ ] Interstitial never appears while the keypad or form is visible.

### EXP-03 Transaction detail

**Layout:** Large amount, type badge, category with icon, account, payment mode, date and time, note, receipt thumbnail (tap for full-screen zoom), and "Created from recurring rule" link if applicable. Actions: Edit, Duplicate, Delete, Share (as text).

**Ads:** Banner at bottom.

**Acceptance criteria:**

- [ ] Deleting returns to EXP-01 with Undo available.

### EXP-04 Categories

**Layout:** Tabs Expense / Income. Reorderable list (drag handle) with icon, name, and this month's total. Hidden default categories appear in a collapsed "Hidden" section. FAB + opens EXP-05.

**Behavior:** Tap → EXP-05 edit. Default categories can be renamed and hidden but not deleted. Deleting a custom category that has transactions requires choosing a replacement category to move them to.

**Ads:** Banner at bottom.

### EXP-05 Add / edit category (bottom sheet)

**Fields:** Name (required, max 30, unique per type: compared case-insensitively, ignoring surrounding spaces and treating repeated inner spaces as one, including the English, Hindi, and Gujarati names of default categories that have not been renamed), icon picker (grid of about 80 Material icons grouped by theme), color picker (16 preset colors), type (fixed when editing).

**Acceptance criteria:**

- [ ] Duplicate names within the same type are rejected with an inline error.

### EXP-06 Accounts

**Layout:** Total balance card at top (sum of non-archived accounts). List of accounts with icon, name, type, and current balance (negative balances in red). "Archived" section collapsed at bottom. FAB + opens EXP-07.

**Behavior:** Tap → filtered EXP-01 for that account. Long-press → edit or archive. An account with transactions can be archived but not deleted. The last non-archived account cannot be archived or deleted, and the user is told why.

**Ads:** Banner at bottom.

### EXP-07 Add / edit account (bottom sheet)

**Fields:** Name (required), type (Cash, Bank, UPI wallet, Card, Wallet), opening balance (can be negative for cards), icon, color.

### EXP-08 Budgets

**Layout:**

1. Month selector `< October 2026 >`.
2. **Overall budget card:** limit, spent, remaining, progress bar, and "₹X per day left for N days."
3. **Category budgets list:** each row shows category, spent / limit, progress bar with color thresholds.
4. **Categories without budget** section with "Set budget" buttons.
5. Native ad after the category list.

**Behavior:** Tap a row or "Set budget" → EXP-09. Overflow menu: "Copy last month's budgets." Budgets with `rollover = true` are created automatically on the first app open of a new month.

**States:** Empty → explanation and "Set monthly budget" button.

**Acceptance criteria:**

- [ ] "Per day left" uses remaining days including today.
- [ ] Copy last month does not overwrite budgets already set for this month.

### EXP-09 Set budget (bottom sheet)

**Fields:** Category (or "Overall"), amount, "Repeat every month" toggle (rollover). Delete button when editing.

**Behavior:** Saving a new limit clears the 80% or 100% alert marker for any threshold that is no longer reached under the new limit, so that alert can fire once more. Markers for thresholds still reached stay set, so lowering a limit never repeats an alert already sent.

### EXP-10 Recurring transactions

**Layout:** List of active rules: icon, note or category, amount, frequency text ("Every month on 5th"), next date. Paused rules in a separate section.

**Behavior:** Tap → edit (opens EXP-02 in rule-edit mode). Saving in rule-edit mode changes future occurrences only; saving with Repeat turned off deletes the rule (soft delete, with Undo) and keeps its generated entries. Swipe actions: Pause/Resume, Delete. A `workmanager` daily job (plus a check on every app open) generates due transactions up to now and advances `nextRunAt`. Generated entries show a small repeat icon in EXP-01.

**Acceptance criteria:**

- [ ] A monthly rule on the 31st runs on the last day of shorter months.
- [ ] If the app was not opened for 3 months, all missed entries are created once, with correct dates, and no duplicates.

### EXP-11 Reports

**Layout:**

1. Period selector (Month default; Week, Year, Custom).
2. **Tabs:** Overview · Categories · Trends · Accounts.
3. **Overview:** income vs expense bar for the period, net savings, savings rate %, average daily spend, top 3 categories.
4. **Categories:** donut chart of expense by category; tapping a slice highlights it and lists that category's transactions below.
5. **Trends:** line chart of daily (or monthly for Year) spending, with the previous period as a dashed comparison line.
6. **Accounts:** spending by account and by payment mode (bar chart).
7. Banner at bottom.

**Free vs unlocked:** Overview and Categories for the current and previous month, and for any week that overlaps either of them, are free. Trends, Accounts, Year, Custom range, and older months and weeks are **advanced reports**, unlocked by watching a rewarded ad (PRM-02) for 24 hours, or permanently with Remove Ads / Premium.

**Actions:** "Export this report" → SET-03 with period prefilled.

**Acceptance criteria:**

- [ ] Locked tabs show a blurred preview and a "Watch an ad to unlock for 24 hours" button. *(Feature 003: the blurred preview is built and tested; the "Watch an ad" button arrives with rewarded ads in the rewarded-ads feature (T4.4), which checks this box.)*
- [ ] Chart totals match the EXP-01 summary strip for the same period.

## 9. Habit module screens

### HAB-01 Habits (today)

**Purpose:** Check in today's habits quickly and see progress.

**Layout:**

1. **App bar:** Title "Habits," overflow menu (Archived habits, Reorder).
2. **Week strip:** 7 day circles (Mon–Sun) for the current week, each showing a mini completion ring. Tapping a past day switches the list to that date for back-filling (up to 7 days back; older edits from HAB-03 only). Future days are disabled.
3. **Progress header:** "3 of 5 done" with a linear progress bar for the selected day.
4. **Habit list** for the selected day, scheduled habits first, then "Not scheduled today" (collapsed). Each card: icon in colored circle, name, schedule text ("Daily," "Mon, Wed, Fri," "3× per week · 1 left"), current streak with flame, and a check control on the right:
    - Yes/no habit: circular check button; tap toggles done.
    - Count habit: shows `12 / 20 pages` with + button; tap + adds 1, long-press opens a number entry dialog.
5. **Native ad** after the 4th habit card (only if there are 5 or more habits).
6. **Banner ad** at the bottom.
7. **FAB:** + opens HAB-02.

**Behavior:**

- Completing a habit plays a short check animation and light haptic. Reaching a milestone streak (7, 21, 30, 50, 100, 365) shows a celebration bottom sheet with a "Share streak" button that renders a shareable image card.
- Completing all of today's habits shows a one-line "All done for today" banner.
- Long-press a card → menu: Edit, Add note for today, Skip today (counts as freeze only if a freeze is available; this is the only way to freeze today, and the item is disabled with "No freezes left" when there is none), Archive.
- Drag to reorder from the overflow "Reorder" mode.

**States:** Empty → illustration, "Build your first habit," and template chips (Drink water, Read, Walk, Meditate, Wake up early, Study) that prefill HAB-02.

**Ads:** Banner + one native as above. No interstitial on check-in; check-in must stay instant.

**Acceptance criteria:**

- [ ] Toggling a yes/no habit creates or deletes the `habit_entries` row for that date key.
- [ ] Streak updates immediately after check-in and matches the rules in section 4.
- [ ] Back-filling yesterday restores a broken streak.
- [ ] Milestone sheet appears once per milestone per habit.

### HAB-02 Add / edit habit

**Layout (single scroll form):**

1. **Name** (required, max 40) with suggestions from templates.
2. **Icon and color** pickers (same components as EXP-05).
3. **Goal type:** segmented "Yes / No" or "Count." For Count: target number + unit text ("pages," "minutes," "glasses").
4. **Schedule:** Every day · Specific days (weekday chips) · X times per week (stepper 1–6).
5. **Reminders:** Up to 3 times; "+ Add reminder" opens a time picker. Toggle "Remind me only if not done yet" (default on).
6. **Start date** (default today).
7. **Save** (sticky). In edit mode: Archive and Delete in the app bar overflow.

**Behavior:**

- Saving schedules or reschedules local notifications through `NotificationService` with a stable notification ID per habit + reminder index.
- Changing the schedule never deletes past entries; streaks are recalculated using the new schedule from the change date onward.
- Delete asks for confirmation and removes the habit and its entries (soft delete, restorable for 30 days via backup only). Archive keeps history and stops reminders.

**Ads:** None on the form. After saving a **new** habit, interstitial is allowed subject to the frequency cap (counts toward the same session counter as EXP-02).

**Acceptance criteria:**

- [ ] "Specific days" requires at least one weekday.
- [ ] Reminders fire at the set local time, including after a device reboot (`RECEIVE_BOOT_COMPLETED` reschedule).
- [ ] "Remind only if not done" suppresses the notification when today's entry already meets the target.

### HAB-03 Habit detail

**Layout:**

1. **Header:** icon, name, schedule text, Edit button.
2. **Stat tiles (2×2):** Current streak, Best streak, Completion rate (last 30 days), Total completions.
3. **Calendar view:** month grid with done days filled in the habit color, freeze days with a snowflake, missed scheduled days with a faint outline. Swipe for previous months. Tap a day to toggle or edit value and note.
4. **Year heatmap:** GitHub-style 53×7 grid for the last 12 months, color intensity by value/target.
5. **Weekly bar chart** of completions for the last 12 weeks (locked behind advanced reports, same unlock as EXP-11).
6. **Notes list:** entries with notes, newest first.
7. **Streak freeze card:** "Freezes available: 1." Button "Watch an ad to get a freeze" (PRM-02). Max 2 stored freezes per habit.
8. **Banner ad** at the bottom.

**Behavior:** Using a freeze on a missed past day (within the last 3 days) marks it `isFreeze = true` and restores the streak. The freeze card never freezes today; today is frozen only through HAB-01 "Skip today". "Watch an ad to get a freeze" opens PRM-02 and adds 1 freeze to this habit when the reward is earned; it is disabled at 2 freezes. Pro users get "Add a freeze" without an ad, up to 2. Dev builds with "Unlock all features (debug)" on also show "Add a freeze (debug)". Share button renders the heatmap as an image.

**Acceptance criteria:**

- [ ] Completion rate counts only scheduled days.
- [ ] A freeze cannot be applied to today or to a day older than 3 days.
- [ ] Heatmap renders 365 days in under 100 ms (precompute in the controller).

### HAB-04 Archived habits

**Layout:** List of archived habits with name, archive date, and best streak. Actions: Restore (reschedules reminders) and Delete permanently (with confirmation).

**Ads:** Banner at bottom.

## 10. Settings, backup, themes, and premium screens

### SET-01 More / Settings (tab 4)

**Layout (grouped list):**

1. **Account card** (always first; it replaces the former Account row). Its state follows `authMode`:
    - **Guest:** a person icon in a `CategoryAvatar`, "Guest · Data saved only on this phone," and a primary "Sign in with Google" button that starts guest sign-in (section 16). The card itself is not tappable.
    - **Google:** profile photo (initial in a `CategoryAvatar` if there is no photo), name, email, and a status line: "Backed up to Google · 5 min ago" (relative time of the last successful Drive backup), "Backing up…," "Not backed up yet," or "Backup paused" / "Backup failed" in `warning` color with an icon. While a backup waits for Wi-Fi or the phone is offline, the card keeps the last successful state; those details show on ACC-01 only (feature `specs/011-login-guest-mode`, clarification Q3). Tapping the card opens ACC-01.
2. **Premium banner card** (hidden after purchase): "Remove ads and unlock everything" → PRM-01.
3. **General:** Language, Currency, First day of week, Date format.
4. **Appearance:** Theme and colors → SET-04.
5. **Modules:** Enable or reorder trackers → SET-06.
6. **Notifications:** Master toggle, Daily summary reminder time (default 9:00 PM, "Did you log today's expenses?"), Budget alerts toggle, Habit reminders toggle (shown only while the Habit module is enabled).
7. **Security:** App lock → SET-05.
8. **Data:** Backup and restore → SET-02, Export data → SET-03, Erase all data (double confirmation, typed "DELETE"), and, in the guest state only, "Log out of guest" (`error` color text) → ACC-04. Erase all data removes data from this phone only; it does not sign out, change `authMode`, or delete Drive backups. It keeps onboarding done and the device preferences (section 4) and then opens Home, never Intro.
9. **Privacy:** "Ad privacy choices" (reopens UMP consent form when required), Privacy policy (in-app web view), Terms.
10. **About:** Rate us (Play in-app review API), Share app, Send feedback (email intent with device info), App version, Open-source licenses.
11. Banner ad at bottom.

The status line always says "Backed up to Google," never "Synced": each phone backs up its own data, and live multi-device sync is out of scope (section 16).

**Acceptance criteria:**

- [ ] Changing currency changes formatting only; stored amounts are not converted.
- [ ] "Ad privacy choices" is visible whenever the UMP SDK reports a privacy options requirement.
- [ ] The account card is the first item. As a guest it shows "Guest · Data saved only on this phone" and "Sign in with Google," which starts guest sign-in; signed in with Google it shows the name, email, photo (or initial), and "Backed up to Google" with the last backup's relative time, and opens ACC-01.
- [ ] "Log out of guest" appears in the Data group only in the guest state and opens ACC-04.
- [ ] No text on this screen says "Synced" or "Sync."

### SET-02 Backup and restore

**Layout:**

1. **Last backup** info: date, time, location, size.
2. **Google Drive backup card:** as a guest, "Sign in with Google" (guest sign-in, section 16); signed in, the account email (tap → ACC-01), "Back up now," and an "Auto backup" selector (Off, Daily, Weekly; Wi-Fi only toggle). Signing in sets Auto backup to Daily if it was Off; while it is not Off, backups also run when the app goes to the background (section 16).
3. **Local backup card:** "Save backup file" (system file picker / share sheet) and "Restore from file."
4. **Encrypt backup** toggle with a password (AES-GCM via a key derived from the password). Warn that a lost password cannot be recovered.
5. **Restore from Google Drive:** lists available backups with dates.

**Behavior:**

- Backup format: one file named `dailytrack_backup_<yyyyMMdd_HHmm>`. Without receipts it is JSON (`.json`) with `{format, schemaVersion, appVersion, createdAt, modules: {expense: {...}, habit: {...}}, settings: {...}}`; with "Include receipt images" on it is a zip (`.zip`) holding `backup.json` and `receipts/`; with "Encrypt backup" on, either one is wrapped in an encrypted envelope (`.dtbk`: AES-256-GCM, key from PBKDF2-HMAC-SHA256 of the password, salt and parameters in the header). Each module writes and reads its own section through `TrackerModule.backupSection()`.
- Only user preferences are in `settings` (language, currency, first day of week, date format, theme, font size, modules, notification preferences, Home preferences). Lock, PIN, Google account, sign-in mode (`authMode`), backup and widget settings, ad consent, purchase state, and unlocks are never backed up or restored.
- The backup password is saved only in secure storage, so auto backups encrypt without asking; Erase all data removes it.
- The Drive list labels each backup Manual or Auto, shows the device name and counts from its metadata (section 16), and offers Delete (with confirmation). Restoring from this list follows the same rules as ACC-02.
- Restore validates `schemaVersion`, runs migrations if older, shows a summary ("1,240 transactions, 8 habits"), and asks "Replace current data?" before writing in a single DB transaction.
- Auto backup runs through `workmanager`. After each successful auto backup, Drive keeps today's newest auto backup plus the newest auto backup of each of the 5 most recent earlier local days that had one (at most 6), and deletes the other auto backups in that account, whichever phone made them; manual Drive backups are never deleted automatically (feature `specs/010-google-account-backup`, clarification Q1). After 3 failed auto backups in a row, the Backup notification is shown once until a backup succeeds.
- "Restore previous phone data" appears only while a safety copy exists (a copy of this phone's data saved just before a restore from the Google account replaced it, §16 ACC-02). It shows the copy's date and counts, restores it with the same summary and "Replace current data?" confirmation, and the copy is deleted after a successful restore or after 7 days.
- After any successful restore of an encrypted backup (Drive or local file), "Encrypt backup" is turned on and the password that opened it is saved in secure storage, so later backups stay encrypted (clarification Q2). A failed or cancelled restore saves nothing.
- If the database cannot be opened at startup (SYS-01), "Restore from backup" moves the broken database aside and restores into a fresh one.

**Ads:** Banner at bottom. Interstitial allowed after a successful manual backup ("Save backup file" or Drive "Back up now") once its success message closes, subject to the cap. Auto backups never trigger ads.

**Acceptance criteria:**

- [ ] Backup → erase → restore produces identical data (verified by an integration test comparing row counts and checksums).
- [ ] A failed restore leaves existing data untouched.
- [ ] Restoring a backup from an older schema version succeeds.

### SET-03 Export data

**Layout:** Data type (Transactions, Habits), period picker, format (CSV, PDF), filters (accounts, categories) for transactions, "Export" button.

**Behavior:**

- **CSV:** UTF-8 with BOM (so Excel shows ₹ and Indian scripts correctly). Columns for transactions: Date, Time, Type, Category, Account, Payment mode, Amount, Note.
- **PDF:** cover summary (period, totals, category donut as image), then a transaction table. Uses a bundled Noto font that supports Devanagari and Gujarati.
- Output opens the share sheet.
- **Unlock:** each export requires either an active `exportCsv`/`exportPdf` unlock (rewarded ad grants one export) or Remove Ads. A one-time unlock is used up only when the file is created; a failed, cancelled, or empty export keeps it. A locked export shows `LockedFeatureOverlay` with "Watch an ad" (PRM-02 grants one export of the selected format, and the export then starts) and "Get Pro" (PRM-01).
- **Habits:** CSV columns Date, Habit, Value, Target, Unit, Status (Done, Partial, Freeze), Note; the PDF shows a summary with each habit's completion rate, then a table of check-ins.
- Opened from EXP-11 "Export this report", the screen starts on Transactions with the report's period.

**Acceptance criteria:**

- [ ] Gujarati and Hindi notes render correctly in both CSV (opened in Excel) and PDF.
- [ ] Cancelling the rewarded ad does not start the export.

### SET-04 Themes and appearance

**Layout:** Theme mode (System, Light, Dark). A grid of color themes: 2 free (Default Teal, Indigo) and 6 premium (e.g. Saffron, Forest, Rose, Midnight, Ocean, Mono) with a lock badge. Live preview card at top showing a sample dashboard. Font size option (Default, Large).

**Behavior:** Tapping a locked theme previews it behind `LockedFeatureOverlay` without applying it and opens PRM-02 ("Watch an ad to unlock this theme permanently"); an earned reward unlocks and applies that theme. The overlay keeps "Watch an ad" and "Get Pro" if the sheet is dismissed. Themes use Material 3 `ColorScheme.fromSeed`.

### SET-05 Security

**Layout:** App lock toggle (→ SYS-04 when turning on), Change PIN, Use biometric toggle, Lock after (Immediately, 1 min, 5 min), Hide app content in recents toggle (`FLAG_SECURE` app-wide), Show data on widget toggle (enabled only while app lock is on; off by default).

### SET-06 Modules

**Layout:** Reorderable list of modules with toggles: Expense, Habit. Water and Period shown as "Coming soon" (disabled). Order controls the dashboard card order and the bottom nav tab order.

**Behavior:** Disabling a module hides its tab and dashboard card and cancels its notifications, but keeps its data. At least one module must stay enabled.

### PRM-01 Premium / Remove Ads

**Layout:** Headline "DailyTrack Pro," a benefit list (No ads, All themes, Advanced reports, Unlimited exports, Unlimited streak freezes up to the cap), price button pulled from Play Billing (one-time product `pro_lifetime`), "Restore purchase" link, and a short note that purchase is tied to the Google account.

**Behavior:**

- On purchase success: set `removeAdsPurchased = true`, dispose all loaded ads, stop the ads SDK from loading new ads, and grant permanent unlocks.
- Verify ownership on every app start with `queryPastPurchases` (offline: trust the cached flag). Pro is removed only after 2 online starts in a row report it not owned (an "owned" result resets the count; offline or failed checks leave it); removal takes effect from the next cold start.
- A pending payment shows "Pro unlocks when the payment completes" and is granted when Play reports it purchased, even on a later start.
- Acknowledge purchases within 3 days, as Play requires; any unacknowledged purchase is acknowledged on the next start.
- Store unavailable or no price: the price button is disabled with "Store not available right now, try again later"; "Restore purchase" stays available.

**Acceptance criteria:**

- [ ] After purchase, no ad of any kind is requested again, including after restart.
- [ ] Reinstalling and tapping "Restore purchase" restores Pro.

### PRM-02 Rewarded unlock prompt (shared bottom sheet)

**Layout:** Icon of the feature, title ("Unlock advanced reports for 24 hours"), one-line explanation, primary button "Watch a short ad," secondary "Get Pro instead" (→ PRM-01), and "Not now."

**Behavior:**

- Preload one rewarded ad when the sheet opens; show a spinner on the button until loaded (timeout 8 s → "Ad not available, try again later").
- Grant the unlock **only** in the `onUserEarnedReward` callback, then write to `unlocks` (or run the caller's grant, e.g. +1 freeze for a habit).
- Rewards: advanced reports (24 h), one CSV or PDF export, one premium theme (permanent), one streak freeze (max 2 per habit). There is no ad-free day reward.
- Closing the ad early keeps the sheet open with "Watch the whole ad to unlock" and loads a new ad for a retry.
- At most 10 earned rewards per feature key per local day (each premium theme counts separately); after that the sheet says the daily limit is reached, loads no ad, and offers only "Get Pro instead" and "Not now" (feature `specs/009-ads-rewarded-pro`, clarification 2026-10-22).
- Reusable API: `showRewardedUnlock(context, FeatureKey key, {Duration? duration, Future<void> Function()? grant})` returns `Future<bool>` when the sheet closes.

**Acceptance criteria:**

- [ ] Closing the ad early grants nothing.
- [ ] Unlock expiry is respected after app restart. If the device clock is moved backwards, expired unlocks stay expired (store the latest time ever seen and use the later of that and the current time).

## 11. Ads integration spec

Ads must never interrupt logging. Every placement below sits on a reading screen or after a finished action, and one global frequency cap controls all interstitials.

| Format | Screens | Rule |
| --- | --- | --- |
| Banner (standard 320×50, anchored bottom) | EXP-01, EXP-03, EXP-04, EXP-06, EXP-11, HAB-01, HAB-03, HAB-04, SET-01, SET-02 | Never on add/edit forms, lock, onboarding, login (AUTH-01), account dialogs (ACC-04), or PRM screens |
| Native (medium template) | DSH-01 (after 2nd card), EXP-01 (after row 8, then every 15, max 3), EXP-08 (after list), HAB-01 (after 4th card, if 5+ habits) | Clearly labeled "Ad"; styled like app cards |
| Interstitial | After EXP-02 save (every 4th new entry), after new habit save in HAB-02, after manual backup success in SET-02 | Shown only after the screen has closed and the app is idle; may appear over Home when EXP-02 or HAB-02 closes back to it |
| Rewarded | PRM-02 only: advanced reports (24 h), one export, one premium theme (permanent), streak freeze | Reward granted only in `onUserEarnedReward` |
| App open | Not used in MVP | Revisit after measuring retention |

AUTH-01 Login and the ACC-04 Log out of guest dialog never show or request an ad of any format, and no interstitial may appear over them.

**Interstitial frequency cap (global):**

- No interstitial in the first 2 days after install, and never in a user's first session of the day. A session starts on a cold start or when the app returns after at least 30 minutes in the background.
- Minimum 3 minutes between interstitials, maximum 4 per day.
- Counter of qualifying actions (saves) resets after each shown interstitial.
- All values live in one `AdConfig` class (and can later come from Firebase Remote Config) so they can be tuned without code changes.

**AdService design (`core/ads/`):**

- `abstract class AdService` with: `Future<void> init()`, `bool get adsEnabled`, a `Stream<bool> adsEnabledStream`, `loadBanner` and `loadNative` (used only by `AppBannerAd` and `AppNativeAd`), `Future<void> preloadInterstitial()`, `Future<void> maybeShowInterstitial(AdTrigger trigger)`, `Future<bool> prepareRewarded()`, and `Future<RewardedOutcome> showRewarded(FeatureKey key, {required Future<void> Function() onEarned})` (feature `specs/009-ads-rewarded-pro` contracts).
- `AdMobAdService` implements it with `google_mobile_ads`. `NoAdsService` is used when Pro is purchased (from the next screen build; from cold start the ads SDK is not started) and in widget tests.
- `AdUnitIds` reads IDs from `--dart-define` per build flavor. **Dev-flavor and debug builds always use Google's official test ad unit IDs and test App ID.** Release IDs are never committed to the repo. The AdMob App ID reaches `AndroidManifest.xml` through a Gradle manifest placeholder read from `local.properties` or an environment variable; only builds meant for Play upload fail without it, other prod release builds use the test App ID and request no ads.
- `AppBannerAd` and `AppNativeAd` widgets handle load, retry with backoff, dispose, and collapse to zero height on failure (no empty boxes).
- Preload the next interstitial after one is shown; preload rewarded only when PRM-02 opens.

**Consent and privacy:**

- Use the UMP SDK (bundled with `google_mobile_ads`) at startup. Request ads only after `canRequestAds()` is true.
- Show "Ad privacy choices" in SET-01 when required.
- Set `tagForChildDirectedTreatment` to unspecified and keep the app's Play target audience 18+ to avoid Families policy requirements.
- Do not send any financial or habit data to ad or analytics SDKs, including as custom targeting keywords.

**Mediation (after launch):** Enable AdMob mediation for Meta Audience Network, AppLovin, and Unity Ads through their Flutter adapters once daily active users pass about 1,000. The `AdService` interface does not change.

**Acceptance criteria:**

- [ ] Unit tests cover the frequency cap: install-age rule, 3-minute gap, 4-per-day maximum, and counter reset.
- [ ] With `NoAdsService`, no ad widget occupies any space.
- [ ] No ad request is made before consent is resolved.

## 12. Notifications, home widget, localization, and accessibility

**Notifications (`core/notifications/`)**

| Channel | Trigger | Default | Tap opens |
| --- | --- | --- | --- |
| Habit reminders | Each habit's reminder times; skipped if done when "only if not done" is on | On | HAB-01 for today |
| Daily summary | User time (default 9:00 PM): "Spent ₹X today · 3/5 habits done" | On | DSH-01 |
| Budget alerts | Category or overall budget reaches 80% / 100% | On | EXP-08 |
| Backup | Auto backup failed 3 times in a row; auto backup paused because another phone made a newer backup (section 16, shown once per pause) | On | SET-02 (failure), ACC-01 (pause) |

- Habit reminders include action buttons "Mark done" (yes/no habits) and "Snooze 1 h," handled without opening the app. "Mark done" marks the day of the latest reminder occurrence at or before the tap (so a tap after midnight marks the reminder's day). "Snooze 1 h" shows the reminder once more an hour later, unless the habit is done by then and "only if not done" is on.
- The daily summary text is kept current: it is rescheduled after every change to the data it shows and at midnight.
- Use exact alarms only if the user grants `SCHEDULE_EXACT_ALARM`; otherwise fall back to inexact scheduling and note possible delays.
- Reschedule all notifications on app start, after restore (including a restore from AUTH-01 or ACC-02 and the first start after an Android Auto Backup restore), after timezone change, and after reboot.
- The home widget is refreshed after a restore, after "Remove data from this phone" (ACC-03), and after "Log out and delete" (ACC-04). ACC-04 cancels every scheduled notification.
- Account and backup strings (section 16) are translated like all others; device names and email addresses are shown as given, never translated.

**Home screen widget (`home_widget`)**

- Size 4×2: today's spend, month budget bar (overall budget), and up to 4 of today's scheduled habits. Tapping a check marks a yes/no habit done or adds 1 to a count habit via a background callback; tapping a done habit does nothing (the widget never undoes a check-in). Tapping elsewhere opens the app (through SYS-03 if locked).
- When app lock is on, the widget shows only "Open DailyTrack" unless the user enables "Show data on widget" in SET-05.
- Updated after every relevant DB write and at midnight.

**Localization**

- ARB files for `en`, `hi`, `gu`. Keys are grouped by feature prefix (`expense_addTitle`, `habit_streakLabel`).
- Numbers and currency use `intl` with the selected locale; INR uses Indian grouping (12,34,567.00).
- Default category names and habit templates are l10n keys, so they translate; user-created names are stored as typed.
- Use Noto Sans plus Noto Sans Devanagari and Noto Sans Gujarati as bundled fonts for consistent rendering.

**Accessibility**

- Minimum touch target 48×48 dp; all icon buttons have semantic labels.
- Colors meet WCAG AA contrast in both themes; budget status is never shown by color alone (also text or icon).
- Supports system font scale up to 200% without clipped text (test with the Large setting).
- TalkBack reads amounts as currency ("rupees one thousand two hundred").

## 13. Non-functional requirements, testing, and Play Store compliance

| Requirement | Target |
| --- | --- |
| Min Android version | Android 7.0 (API 24); target the latest API level Play requires |
| Cold start to Home | < 1.5 s on a mid-range device (e.g. 4 GB RAM) |
| Save transaction / check-in | < 100 ms DB write; UI never blocks |
| List scrolling | 60 fps with 10,000 transactions |
| APK size | < 25 MB per ABI (use `--split-per-abi` / App Bundle) |
| Crash-free users | ≥ 99.5% |
| Offline | 100% of features work offline except Google sign-in, Drive backup and restore, ads, and purchase; signing in with Google is never required ("Continue as guest" on AUTH-01 works offline) |
| Data safety | User data leaves the device only as backups the user chose: manual and auto Drive backups to their own Google account's hidden app folder (only while signed in with Google, `authMode = google`; auto backups also need auto backup on), backup or export files they save or share, and Android Auto Backup of the database (section 16). Guest data never leaves the device through the app: in guest mode the app makes no Google sign-in or Drive request and sends no user data anywhere; it leaves the phone only in backup or export files the guest saves or shares, or through Android's own device backup and device transfer, which the user controls in system settings. The PIN, lockout state, and backup password never leave the device |

**Testing strategy**

- **Unit tests** (domain + data): money math, streak calculation, recurring rule generation, budget thresholds, frequency cap, backup serialization round-trip, migrations (Drift `SchemaVerifier`). Target ≥ 80% coverage on `domain/` and `data/`.
- **Widget tests:** every screen's acceptance criteria, using fake repositories and `NoAdsService`.
- **Golden tests:** DSH-01, EXP-01, EXP-02, HAB-01 in light and dark themes and in English and Gujarati.
- **Integration tests:** add expense → see on Home → appears in Reports; create habit → check in → streak; backup → erase → restore.
- **CI** (GitHub Actions): `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`, build release App Bundle on every pull request.

**Build flavors:** `dev` (test ad IDs, debug banner, "DailyTrack Dev" label) and `prod` (real ad IDs from CI secrets via `--dart-define`). Both use the application ID `com.midexcode.dailytrack`, so installing one replaces the other.

**Play Store compliance checklist**

- [ ] Data safety form: declares on-device financial and health-adjacent data, ads SDK device identifiers, crash logs; no data sold. Also declares the Google account name, email, and photo (used only to show the signed-in account, stored on the device) and that backups go to the user's own Google Drive and Android backup, encrypted in transit, and can be deleted from the app (ACC-01 "Delete my backups").
- [ ] Google OAuth consent screen set up and verified for the scopes used (`email`, `profile`, Drive `appDataFolder` only).
- [ ] Android Auto Backup rules (`dataExtractionRules` and `fullBackupContent`) include the database and exclude secure storage and the no-backup folder (section 16).
- [ ] Privacy policy URL hosted publicly and linked in SET-01.
- [ ] Target audience 18+; not in Designed for Families.
- [ ] Ads policy: no ads on lock screen, forms, or exit; no accidental-click layouts (8 dp minimum gap between ads and tappable controls); interstitials never appear unexpectedly mid-task.
- [ ] `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` usage justified or avoided.
- [ ] In-app purchase acknowledged within 3 days; "Restore purchase" available.
- [ ] `app-ads.txt` published on the developer website domain listed in Play Console.

## 14. Implementation phases for Claude Code

Build in this order so each phase ends with a runnable, tested app. With Spec Kit, each group below is one feature run through `/speckit.specify` → `/speckit.clarify` → `/speckit.plan` → `/speckit.tasks` → `/speckit.analyze` → `/speckit.implement`.

**Phase 0: Foundation**

- [ ] T0.1 Create Flutter project, flavors (`dev`, `prod`), lints, folder structure from section 3, CI workflow.
- [ ] T0.2 `core/`: theme tokens, l10n setup (en, hi, gu), money and date utils with unit tests, shared widgets.
- [x] T0.3 Drift `AppDatabase` with settings table, migration test harness.
- [x] T0.4 `TrackerModule` interface, module registry, go_router with `StatefulShellRoute` and placeholder tabs.
- [ ] T0.5 SYS-01 Splash, SYS-02 Onboarding, SET-06 Modules (basic).

**Phase 1: Expense module**

- [ ] T1.1 Tables, DAOs, repositories, seed data (accounts, categories, transactions).
- [ ] T1.2 EXP-02 Add/edit transaction (custom keypad, validation).
- [ ] T1.3 EXP-01 Transactions list + EXP-03 detail.
- [ ] T1.4 EXP-04/05 Categories, EXP-06/07 Accounts.
- [x] T1.5 EXP-08/09 Budgets + budget alerts.
- [x] T1.6 EXP-10 Recurring rules + `workmanager` job.
- [x] T1.7 EXP-11 Reports (free tabs only; advanced tabs gated by `FeatureGate`, feature 003).

**Phase 2: Habit module and Home**

- [ ] T2.1 Tables, streak engine with exhaustive unit tests.
- [ ] T2.2 HAB-02 Add/edit + reminder scheduling.
- [ ] T2.3 HAB-01 Today list + milestone sheet.
- [ ] T2.4 HAB-03 Detail (calendar, heatmap, stats), HAB-04 Archived.
- [ ] T2.5 DSH-01 Home with module cards, FAB menu, insights.

**Phase 3: Settings, security, data**

- [ ] T3.1 SET-01 Settings, SET-04 Themes, SET-05 + SYS-03/04 App lock.
- [ ] T3.2 SET-02 Backup and restore (local, then Drive, then encryption).
- [ ] T3.3 SET-03 Export CSV and PDF.
- [ ] T3.4 Notifications: daily summary, action buttons, reboot handling. Home screen widget.
- [ ] T3.5 Google account and cloud backup (section 16): ACC-01–ACC-03, SYS-02 "Restore with Google" (replaced by AUTH-01 in T3.6), background backups, conflict rule, metadata, safety copy, Android Auto Backup (feature `specs/010-google-account-backup`).
- [ ] T3.6 Login and guest mode (feature `specs/011-login-guest-mode`): `authMode` setting, its migration, and the router redirect (section 5); SYS-02 Intro without restore or app lock; AUTH-01 Login with the "Finish setting up" sheet after login; SET-01 account card; guest sign-in (section 16); ACC-04 Log out of guest; ACC-03 sign-out to AUTH-01.

**Phase 4: Monetization**

- [ ] T4.1 `core/ads`: `AdService`, `AdConfig`, consent flow, banner and native widgets (test IDs).
- [ ] T4.2 Place banners and natives per section 11.
- [ ] T4.3 Interstitial triggers + frequency cap with unit tests.
- [ ] T4.4 PRM-02 rewarded unlocks; lock advanced reports, exports, premium themes, streak freezes.
- [ ] T4.5 PRM-01 Pro purchase, restore, `NoAdsService` switch.

**Phase 5: Release** (feature 012)

- [ ] T5.1 Golden and integration tests, performance pass with 10,000 seeded transactions.
- [ ] T5.2 Play Store assets, data safety form, privacy policy, `app-ads.txt`, internal testing track.

**Later phases:** Water tracker module (`features/water/`), then Period tracker module (`features/period/`, with local-only encrypted storage and non-personalized ads only on its screens), then AdMob mediation and Remote Config tuning.

**Project rules file:** see `CLAUDE.md` at the repo root.

**Example task prompt**

```
Implement task T1.2 (screen EXP-02) from docs/spec.md.
First write a short plan listing files you will create or change.
Then implement, add widget tests for every acceptance criterion of EXP-02,
run flutter analyze and flutter test, and summarize what changed.
```

## 15. UI/UX guidelines

Every screen must let the user finish its main task fast, look calm and consistent, and never let ads get in the way. These rules apply to all modules, including Water and Period later. Build them as shared tokens and widgets in `core/theme/` and `core/widgets/` (task T0.2), so screens never define their own colors, sizes, or spacing.

### 15.1 Design principles

1. **Speed first.** The most common action on any screen is reachable in one tap and completed in three or fewer. Logging an expense or checking a habit must never need scrolling.
2. **One primary action per screen.** Only one filled (primary) button or FAB is visible at a time. Everything else is a secondary, text, or icon button.
3. **Calm and trustworthy.** This is a money app. Use plenty of white space, restrained color, and exact numbers. Red is reserved for expenses, errors, and over-budget states.
4. **Forgiving.** Prefer undo over confirmation dialogs. Nothing the user does should be impossible to reverse within a few seconds.
5. **Consistent.** The same thing looks and behaves the same everywhere: a category icon, an amount, a progress bar, a swipe action.
6. **Respectful ads.** Ads look like ads, sit in predictable places, and never appear in the middle of a task (section 11).

### 15.2 Design system (Material 3)

Use Material 3 with `ColorScheme.fromSeed` and expose app-specific values through a `ThemeExtension` called `AppTokens`. Widgets read tokens from the theme only; hex values appear in one file, `core/theme/app_colors.dart`.

**Color roles**

| Token | Use | Light | Dark |
| --- | --- | --- | --- |
| `seed` | Generates the Material scheme | Teal #0F766E | same seed |
| `income` | Income amounts, positive net | #15803D | #4ADE80 |
| `expense` | Expense amounts, negative net | #B91C1C | #F87171 |
| `warning` | Budget 80–100%, pending states | #B45309 | #FBBF24 |
| `success` | Habit done, budget under 80% | #15803D | #4ADE80 |
| `habitDone` | Fill for completed habit checks | habit's own color | habit's own color at 85% |
| `adBadge` | "Ad" label background | `surfaceContainerHighest` | `surfaceContainerHighest` |

Rules: never show meaning by color alone (pair with an icon, sign, or text); amounts use a `+` or `−` sign as well as color; category and habit colors come from a fixed set of 16 that all pass 3:1 contrast against both themes' surfaces.

**Typography** (Material 3 type scale, Noto Sans family)

| Role | Size / weight | Used for |
| --- | --- | --- |
| `displaySmall` | 36 / 600 | Amount entry on EXP-02, big totals |
| `headlineSmall` | 24 / 600 | Screen titles in large app bars, stat tile values |
| `titleMedium` | 16 / 600 | Card titles, list row primary text |
| `bodyMedium` | 14 / 400 | Body text, notes |
| `bodySmall` | 12 / 400 | Secondary row text (account, time), helper text |
| `labelLarge` | 14 / 600 | Buttons, chips |
| `labelSmall` | 11 / 600 | Badges, the "Ad" label |

Amounts always use tabular figures (`FontFeature.tabularFigures()`) so columns of numbers line up.

**Spacing, shape, and size**

| Token | Value |
| --- | --- |
| Spacing scale | 4, 8, 12, 16, 24, 32, 48 dp (4-point grid only) |
| Screen side padding | 16 dp (24 dp on screens wider than 600 dp) |
| Gap between cards | 12 dp |
| Corner radius | 8 dp chips and inputs · 16 dp cards · 28 dp bottom sheets (top corners) |
| Elevation | Flat; use tonal surface colors (`surfaceContainer*`) instead of shadows |
| Icons | Material Symbols Rounded, 24 dp; 20 dp inside chips; category icons 24 dp in a 40 dp circle |
| Touch targets | Minimum 48 × 48 dp |
| Max content width | 600 dp, centered on tablets and landscape |

### 15.3 Layout rules

- **Screen anatomy:** app bar → optional selector (period, week strip) → summary → content list → anchored banner ad → bottom navigation. Keep this order on every list screen.
- **Bottom navigation:** 4 destinations, icons with labels always visible, 80 dp tall (Material 3 `NavigationBar`). The active tab uses a filled icon.
- **FAB:** bottom right, 16 dp from the edges, above the banner ad. It hides while scrolling down and returns on scroll up.
- **Forms:** single column, labels above fields, primary button sticky at the bottom and lifted above the keyboard. Required fields are not marked with asterisks; optional ones say "(optional)."
- **Full screen vs bottom sheet:** use a full-screen modal for forms with more than 3 fields or with their own keyboard (EXP-02, HAB-02); use a bottom sheet for short pickers and forms of 3 fields or fewer (EXP-05, EXP-07, EXP-09, PRM-02).
- **Lists:** group by date with sticky headers. Row height 64–72 dp. The primary value (amount, streak) is right-aligned.
- **Safe areas:** respect system insets; draw edge to edge behind the status and navigation bars (Android 15 default).

### 15.4 Shared components

Build these once in `core/widgets/` with widget tests and golden tests. Screens compose them instead of styling raw Material widgets.

| Component | What it standardizes |
| --- | --- |
| `AppScaffold` | App bar style, padding, banner slot, FAB position, safe areas |
| `AmountText` | Currency formatting, Indian grouping, sign, income/expense color, tabular figures |
| `CategoryAvatar` | Icon in a colored 40 dp circle, used for categories, accounts, habits |
| `SummaryCard` | Card with title, main value, optional progress, optional action chip |
| `ProgressBarStatus` / `ProgressRing` | Threshold colors (under 80%, 80–100%, over 100%) plus a text label |
| `PeriodSelector` | `< Month Year >` control with the period picker |
| `ChipSelector` | Single and multi-select chips (payment mode, weekdays) |
| `NumericKeypad` | Custom keypad with calculator keys for amount entry |
| `AppBottomSheet` | Drag handle, title, 28 dp corners, keyboard-aware padding |
| `EmptyState` | Illustration, one-line title, one-line helper text, one action button |
| `ErrorState` | Icon, plain-language message, "Try again" button |
| `SkeletonList` / `SkeletonCard` | Loading placeholders that match the final layout |
| `UndoSnackBar` | Message + "Undo" action, 5 seconds |
| `ConfirmDialog` | Title, consequence text, destructive action in `error` color |
| `LockedFeatureOverlay` | Blurred preview + lock badge + "Watch an ad" and "Get Pro" actions |

### 15.5 Interaction patterns

- **Undo vs confirm:** reversible actions (delete transaction, uncheck habit, archive) use an undo snackbar with no dialog. Irreversible or bulk actions (erase all data, log out of guest, delete habit with history, restore backup) use a `ConfirmDialog` that states exactly what will be lost.
- **Swipe actions:** left = delete (red, trash icon), right = duplicate or secondary action. Every swipe action is also available from the long-press menu for users who don't know about swiping.
- **Back behavior:** back on a form with unsaved changes asks "Discard changes?" Back on a tab root goes to Home; back on Home exits the app.
- **Keyboard:** amount fields open the custom keypad, not the system keyboard. Text fields use the right input action ("Next" moves focus, "Done" saves).
- **Pull to refresh** only on screens with computed content (Home insights, Reports). Data lists update live from Drift streams and don't need it.
- **Defaults remember the user:** last used account, payment mode, and category order by frequency. Never make the user re-pick the same thing every time.
- **Date entry:** default to now; show "Today" and "Yesterday" shortcut chips before opening the full picker.

### 15.6 Feedback, states, and motion

Every screen designs all four states: loading, empty, error, and content. A screen spec without them is incomplete. The one exception: a screen whose content is a fixed set of controls (settings lists, PIN keypads) may omit the empty state, and its feature plan must say so.

- **Loading:** show skeletons only if loading takes over 300 ms; never a full-screen spinner for local data.
- **Empty:** explain what goes here and give one action ("Add your first expense"). First-time empty states may use an illustration; filtered empty states ("No matches") use text and a "Clear filters" button only.
- **Error:** plain language, no codes or stack traces ("Couldn't save the backup. Check your connection and try again."). Always offer a next step.
- **Success:** a snackbar for saves and deletes; a celebration sheet only for real milestones (streaks, first month on budget). Don't celebrate routine actions.
- **Haptics:** light impact on habit check and successful save; none on scrolling or navigation.
- **Motion:** 150–250 ms with Material 3 standard easing; page transitions use the default Android predictive back animation. Respect the system "Remove animations" setting (`MediaQuery.disableAnimations`).
- **No layout shift:** content must not jump under the user's finger. Ads and late-loading cards animate in their height over 200 ms, and only above or below the area the user is touching.

### 15.7 Content and microcopy

- **Tone:** friendly, short, and plain. Talk to the user as "you." No guilt or nagging ("You missed 3 days!"); use encouragement ("Pick it up again today").
- **Buttons** start with a verb and say what happens: "Save expense," "Set budget," "Watch ad to unlock." Avoid "OK" and "Submit."
- **Sentence case** everywhere, including titles and buttons.
- **Numbers:** always formatted by `AmountText` and locale; dates are relative when close ("Today," "Yesterday") and `EEE, d MMM` otherwise.
- **Translation-safe:** no string concatenation; use ARB placeholders and plurals (`{count, plural, one{1 habit} other{{count} habits}}`). Layouts must tolerate 30% longer text for Hindi and Gujarati.
- **Limits are explained, not hidden:** when a field has a max length or a feature is locked, say so before the user hits the wall.

### 15.8 Ad UX rules

- Every native ad carries a visible "Ad" badge (`labelSmall` on `adBadge`) in the top-left corner and uses the same card shape as surrounding content, but never imitates a transaction row or habit card closely enough to be mistaken for one.
- Keep at least 8 dp between any ad and any tappable control, and never place an ad directly next to the FAB, Save button, or a check button.
- Banner slots take no space until an ad has loaded, then animate in (15.6) so nothing shifts under a tap.
- Rewarded ads are always the user's choice, explained before playing: what they get and for how long.
- After Pro purchase, all ad slots disappear completely, with no empty boxes or "Upgrade" placeholders in their place.

### 15.9 Dark mode and theming

- Every screen and golden test is checked in light and dark mode.
- Dark mode uses the Material 3 tonal surfaces, not pure black, except for an optional "True black" setting later.
- Premium themes change only the seed color; they never change layout, typography, or semantic colors (income, expense, warning).

### 15.10 Design review checklist (per screen)

Claude Code should check these before marking any screen task done, and include the result in its task summary.

- [ ] Uses only `AppTokens` and shared components; no hard-coded colors, sizes, or text styles.
- [ ] Main task takes three taps or fewer; one primary action visible.
- [ ] Loading, empty, error, and content states implemented and tested (empty may be omitted only on fixed-control screens listed in the feature plan).
- [ ] Works at 200% font scale and on a 360 dp-wide screen without clipping or overflow.
- [ ] Light and dark golden tests pass, in English and Gujarati.
- [ ] All touch targets ≥ 48 dp; all icons have semantic labels; TalkBack order is logical.
- [ ] Destructive actions follow the undo-vs-confirm rule.
- [ ] Ad placements match section 11 and the ad UX rules above; no layout shift.
- [ ] All strings come from ARB files and use placeholders, not concatenation.

## 16. Google account and cloud backup

Every user chooses on AUTH-01 how to keep their data: signed in with Google (`authMode = google`) or as a guest (`authMode = guest`). Signing in with Google is optional. Its only purpose is to back up this phone's data to the user's own Google Drive and bring it back on a new or reset phone. Every feature works the same as a guest, and the app never asks the user to sign in except from the places listed here (AUTH-01, SET-01 account card, SET-02 Drive card, ACC-04 "Sign in with Google instead," SYS-03 "Forgot PIN?").

**Rules for the whole section**

- **Guest mode:** a guest's data stays only on this phone. The app makes no Google sign-in or Drive request for a guest and sends their data nowhere (Android's own device backup still applies as the user sets it in system settings, section 13). A guest can sign in with Google at any time (guest sign-in, below) or log out, which deletes their data (ACC-04).
- **Labels:** backup status always says "Backed up to Google" (e.g. "Backed up to Google · 5 min ago"), never "Synced" or "Sync." Live multi-device sync is out of scope: each phone backs up its own data, and another phone sees it only by restoring.

- **Sign-in:** `google_sign_in` with the `email` and `profile` scopes plus Drive `appDataFolder` only. Backups live in the hidden app folder, which the user cannot see or edit in Drive and no other app can read. One account is signed in at a time.
- **What is backed up:** the same backup file as SET-02 (module data and user preferences, with receipts and encryption if those settings are on). The PIN hash, lockout state, app lock and biometric settings, backup password, Google account, purchase state, unlocks, and ad consent are never backed up, to Drive or anywhere else.
- **Restore replaces, never merges.** A restore replaces all module rows on this phone with the backup's rows in one transaction (constitution III). Combining data from two phones is out of scope.
- **Account state is local.** `backupAccountEmail`, `accountDisplayName`, and `accountPhotoUrl` (section 4) are set on sign-in and cleared on sign-out. `authMode` is `google` only while they are set. On start, while `authMode = google`, the app tries a silent sign-in; if it fails because the token was revoked or the account was removed from the phone, the app clears the account keys, sets `authMode = guest`, and keeps all data (SET-01 shows the guest card). An offline start keeps `authMode = google`. A start that finds account keys while `authMode` is `none` or `guest` (the app closed during sign-in) clears them and signs out of Google, so the user can sign in again.

### Backup metadata

Every Drive backup carries metadata, so the app can list and compare backups without downloading or decrypting them:

| Field | Value |
| --- | --- |
| `deviceId` | This phone's `deviceId` (section 4) |
| `deviceName` | Manufacturer + model at backup time, e.g. "Xiaomi Redmi Note 12" |
| `appVersion` | App version name and build number |
| `createdAt` | UTC ms |
| `kind` | `manual` or `auto` |
| `counts` | Row counts per module section, non-deleted rows only, e.g. `{"expense.transactions": 1240, "habit.habits": 8}` |
| `schemaVersion`, `encrypted` | As in the backup file |

- The metadata is stored twice: as Drive file `appProperties` (read when listing) and inside the backup file as a `meta` object next to `format` and `schemaVersion` (the source of truth; for an encrypted file it is read after decryption). If the two disagree, the file wins.
- `counts` are shown in plain words using ARB plurals ("1,240 transactions · 8 habits"). Each module provides the labels for its own counts through `TrackerModule.backupSection()`.
- Local backup files (SET-02 "Save backup file") also include `meta`.
- Backups made before this feature have no `meta`. They stay listable and restorable, show the device name feature 008 already stored ("Unknown device" when there is none) without counts, and never trigger the conflict warning.

### Auto backup while signed in

- While signed in (`authMode = google`) and Auto backup is not Off (SET-02), a backup to Drive runs:
  1. **On background:** when the app goes to the background, if data has changed since the last backup (change counter, §4), onboarding is done, and the last background backup was requested at least 15 minutes ago (`lastBackgroundBackupAt`). It runs as a one-off `workmanager` task, so it finishes even if the app is closed.
  2. **Scheduled:** the existing daily (or weekly) `workmanager` job from SET-02. It skips the upload if nothing changed since the last successful backup.
- Both respect "Wi-Fi only": the task waits for an unmetered network instead of using mobile data. A waiting background backup is replaced by the next one, never queued twice.
- Background backups count as auto backups for SET-02's day-based rotation (today's newest plus the newest of each of the 5 most recent earlier days) and the 3-failures notification. They never trigger ads.
- Changes made as a guest or while signed out are backed up by the first backup after signing in.
- Every successful backup sets `backedUpChangeCounter` to the counter value read inside the backup's own snapshot, so a write made while it ran still counts as changed; updates the last backup time, and sets `lastKnownDriveBackupAt` and `lastKnownDriveBackupDeviceId` to the new backup.

### Conflict rule: last backup wins

- The newest backup on the account, by `createdAt`, is the one restored by default (ACC-02, AUTH-01). Older backups stay in the SET-02 list until rotation or deletion.
- Before any backup to Drive, the app reads the newest backup's metadata. If it was made on a **different** `deviceId` and is newer than `lastKnownDriveBackupAt`, another phone has backed up data this phone has never seen:
  - **Manual backup** ("Back up now" in ACC-01 or SET-02, or the sign-out backup in ACC-03): a `ConfirmDialog` says "A newer backup from Redmi Note 12 (Today, 8:15 PM) exists. Backing up now makes this phone's data the latest." with "Back up anyway" and "Cancel". "Back up anyway" uploads and updates `lastKnownDriveBackup*`.
  - **Auto backup:** does not upload. It sets `autoBackupPausedByConflict`, shows the Backup notification once, and shows "Backup paused" in ACC-01 and SET-01. The pause ends when the user restores, chooses "Keep this phone's data" (ACC-02), or makes a manual backup.
- Backups made on the same `deviceId` never trigger the warning, and neither does a backup older than `lastKnownDriveBackupAt`.
- **Empty phone over a backup with data:** if this phone has no user data (the ACC-02 rule) and the newest backup's counts show data, an auto backup does not upload (not a failure and not a pause), and a manual backup shows a `ConfirmDialog`: "This phone has no data. Backing up now makes an empty backup the latest." with "Back up anyway" and "Cancel". This protects the account after Erase all data, which keeps the sign-in, and after AUTH-01 "Continue without restoring."

### Android Auto Backup

- `android:allowBackup="true"` with `android:dataExtractionRules` (Android 12+) and `android:fullBackupContent` (Android 11 and lower). Both use an include list with only the Drift database file and its `-wal` and `-shm` files (`app_flutter/dailytrack.sqlite*` in the `root` domain; the database holds the settings table), so nothing else is backed up: not secure storage (also explicitly excluded: `sharedpref` `FlutterSecureStorage.xml`), the no-backup folder (`deviceId`), receipt images (to stay under Android's 25 MB limit), the safety copy, WorkManager's own database, or caches. Device-to-device transfer follows the same rules (constitution III).
- This is a fallback the user does not manage; it works whether or not they sign in. It is described in the privacy policy.
- **First start after an Android Auto Backup restore** (the settings table has a `deviceId` copy but the no-backup folder has no `deviceId` file, or the two differ): the app makes a new `deviceId`; turns app lock and biometric off if no PIN hash exists in secure storage; clears the account keys, then tries a silent sign-in (on success `authMode` stays `google`; on failure a restored `google` becomes `guest`, and a restored `guest` or `none` is kept); sets `lastKnownDriveBackupAt` to 0 so the conflict rule applies; reschedules notifications; runs Restore purchase; and shows the "Finish setting up" sheet (AUTH-01) on Home. Intro is not shown again; AUTH-01 is shown only if the restored `authMode` is `none`. If "Encrypt backup" was on, the password didn't come along (secure storage is excluded): backups fail with "Set your backup password in Backup and restore" and are never made unencrypted.

### Guest sign-in (from More)

A guest moves to a Google account without leaving the app. Started from the SET-01 account card "Sign in with Google," the SET-02 Drive card "Sign in with Google," or ACC-04 "Sign in with Google instead."

- Opens Google Sign-In (account chooser and scope consent). On success, saves the account keys, sets `authMode = google`, and sets Auto backup to Daily if it was Off. Then:
  - **Account has no backup:** backs up this phone's data right away and shows "Signed in. Your data is backed up." If that first backup fails, the user stays signed in and auto backup retries as usual (SET-02).
  - **Account has a backup:** opens ACC-02, which can't be dismissed. "Restore from account" replaces this phone's data with the backup (after the safety copy); "Keep this phone's data" backs up this phone's data, which becomes the account's latest backup in place of the one found. If this phone has no user data, the newest backup is restored without the sheet (ACC-02 rule).
- There is no merging in the MVP: the result is always either the account's data or this phone's data.
- Cancelled or failed sign-in: the user stays a guest with nothing changed; a failure shows "Couldn't sign in. Check your connection and try again." Offline, the sign-in button shows "Connect to the internet to sign in with Google" and makes no request.

**Acceptance criteria:**

- [ ] Signing in to an account without a backup backs up this phone's data, sets `authMode = google`, turns Auto backup to Daily if it was Off, and the SET-01 card switches to the Google state.
- [ ] Signing in to an account with a backup opens ACC-02; "Restore from account" replaces this phone's data and "Keep this phone's data" makes this phone's data the account's latest backup, and no rows from the two are combined.
- [ ] Cancelling or failing sign-in leaves `authMode = guest` and every local row unchanged.

### ACC-01 Account

**Purpose:** Manage the signed-in Google account and its backups. Opened from the SET-01 account card (or the SET-02 Drive card email) only while `authMode = google`.

**Layout:**

1. **Account card:** profile photo (initial in a `CategoryAvatar` if there is no photo), name, email.
2. **Backup status:** "Last backup: Today, 9:41 PM · Redmi Note 12" and a state line: "Backed up to Google," "Backing up…," "Waiting for Wi-Fi," "Backup paused: a newer backup from another phone exists" (with "Review" → ACC-02 for that backup), or "Backup failed" (with the error message).
3. **Back up now** (primary button).
4. **Restore** (secondary button): opens ACC-02 for the newest backup, with a "See all backups" link to the SET-02 Drive list.
5. **Auto backup:** current setting ("Daily · Wi-Fi only") → SET-02.
6. **Switch account** and **Sign out** (text buttons).
7. **Delete my backups** (text button in `error` color).
8. Footnote: "Your app lock PIN is never backed up."

**Behavior:**

- Signing in happens on AUTH-01 or through guest sign-in (above), never on this screen.
- **Back up now:** runs a manual backup with the conflict rule, ignoring "Wi-Fi only." Shows progress on the button and a success snackbar. No interstitial follows (the SET-02 interstitial applies only to SET-02).
- **Switch account:** backs up to the current account first (as in ACC-03 step 1; a failure offers "Switch anyway"), signs out without touching this phone's data, and opens the account chooser. After signing in to the new account, the flow is the same as guest sign-in (above). Cancelling the chooser sets `authMode = guest`, keeps all data, and returns to SET-01 with the guest card.
- **Delete my backups:** a `ConfirmDialog`: "Delete all 7 DailyTrack backups from user@gmail.com? Data on this phone stays. This can't be undone." On confirm, deletes every DailyTrack file in the account's app folder (manual and auto). The user stays signed in, `lastKnownDriveBackup*` is reset, and the next auto backup creates a fresh one.
- The photo is loaded from `accountPhotoUrl` and cached; the screen never waits for it.

**States:**

- Loading: skeleton of the backup status while reading Drive metadata; local account details show at once.
- Offline: account details from settings, status "You're offline. Backups resume when you're back online." Back up now, Restore, Switch account, and Delete my backups are disabled with that reason; Sign out still works (ACC-03).
- Error reading Drive: `ErrorState` text in the status area with "Try again"; the rest of the screen stays usable.
- No empty state: the screen is opened only while signed in, and closes back to SET-01 if the account stops being signed in while it is open (for example a revoked token).

**Ads:** None.

**Acceptance criteria:**

- [ ] Shows name, email, photo (or initial), "Backed up to Google" with the last backup time and device, and all actions.
- [ ] ACC-01 can't be opened as a guest; the SET-01 guest card starts guest sign-in instead.
- [ ] "Back up now" with a newer backup from another device shows the warning, and "Cancel" uploads nothing.
- [ ] "Delete my backups" removes every backup file in the app folder and leaves local data and the sign-in in place.
- [ ] Switch account backs up to the old account before signing out and never removes local data.
- [ ] Offline, the network actions are disabled with an explanation and Sign out still works.

### ACC-02 Restore choice (bottom sheet)

**Purpose:** Let the user choose between the account's backup and the data already on this phone, right after sign-in (AUTH-01 or guest sign-in) or from ACC-01 "Restore."

**Layout:**

1. Title "Backup found on user@gmail.com."
2. **Backup summary card:** date and time ("Yesterday, 10:02 PM"), device name ("From Redmi Note 12," or "From this phone" when the `deviceId` matches), counts ("1,240 transactions · 8 habits"), Manual or Auto, and a lock icon with "Encrypted" when it is.
3. **This phone** line: counts of this phone's data in the same format.
4. Password field, shown only for an encrypted backup when the saved backup password doesn't open it.
5. Primary "Restore from account," secondary "Keep this phone's data," and a "See all backups" link (→ SET-02 Drive list).

**Behavior:**

- **No data on this phone:** if every module's backup section reports zero user rows (seeded defaults don't count), the sheet is not shown; the newest backup is restored at once behind a progress view, then the "Finish setting up" sheet (AUTH-01) is shown if app lock is off. This also covers AUTH-01 "Continue with Google" on a fresh install.
- **Safety copy:** before "Restore from account" (or a restore from the SET-02 Drive list) replaces a phone that has user data, the app saves a copy of the current data (backup format with receipts, never encrypted, never uploaded) in its private storage, replacing any earlier copy. If it can't be saved (e.g. storage full), the restore doesn't start and the error says why. The copy is kept for 7 days and restored from SET-02 "Restore previous phone data" (clarification Q3).
- **Restore from account:** the sheet already says "This replaces the data on this phone," so there is no second dialog. Runs the SET-02 restore (validate, migrate, single transaction), then sets `lastKnownDriveBackup*` to that backup (from the file's `meta`), sets `backedUpChangeCounter` to the current counter, clears `autoBackupPausedByConflict`, turns "Encrypt backup" on with the password used if the backup was encrypted, reschedules notifications, and refreshes the widget. Success snackbar: "Restored 1,240 transactions and 8 habits."
- **Keep this phone's data:** closes the sheet without restoring. Sets `lastKnownDriveBackup*` to the newest backup (so the conflict rule does not fire for it), clears `autoBackupPausedByConflict`, and starts a backup, which becomes the newest, so this phone's data replaces the account backup as the one restored by default. The declined backup stays in the SET-02 list until rotation or deletion.
- Opened after sign-in, the sheet cannot be dismissed by dragging or tapping outside, so the user always chooses. Opened from ACC-01 "Restore," it also has a close button that changes nothing.
- Wrong password: inline error "That password didn't work"; nothing is written.

**States:** Loading while reading metadata (skeleton card). Download or restore failure: "Couldn't restore. Your data on this phone wasn't changed." with "Try again." Offline: "Connect to the internet to restore," with restore disabled; "Keep this phone's data" still works.

**Ads:** None.

**Acceptance criteria:**

- [ ] The summary shows the backup's date, device name, counts, and encryption from metadata without downloading the file.
- [ ] With no user data on the phone, the newest backup is restored without showing the choice.
- [ ] Seeded categories and the Cash account alone count as no data.
- [ ] "Restore from account" replaces all module rows in one transaction; a failure leaves this phone's data unchanged.
- [ ] "Keep this phone's data" writes nothing locally, starts a backup, and no conflict warning appears for the declined backup.
- [ ] An encrypted backup asks for the password only when the saved one fails; a wrong password writes nothing.

### ACC-03 Sign out (bottom sheet)

**Purpose:** Sign out safely, without losing changes that aren't backed up.

**Layout:**

1. Title "Sign out of user@gmail.com?"
2. **Step 1, backup:** "Backing up your latest changes…" with progress, or "Backed up" when nothing changed since the last backup (change counter, §4).
3. **Step 2, choice:** two radio options:
    - "Keep data on this phone" (default): "Continue as a guest to keep using it without an account."
    - "Remove data from this phone": "Your backup stays in your Google account."
4. Buttons: "Sign out" (primary; in `error` color when Remove is chosen) and "Cancel."

**Behavior:**

- The step 1 backup is a manual backup and follows the conflict rule; cancelling the conflict warning counts as a failed backup.
- **Backup fails** (offline, error, or declined): step 1 shows "Couldn't back up your latest changes" with "Try again" and "Sign out anyway." "Sign out anyway" moves to step 2, and choosing "Remove data from this phone" then needs a typed "DELETE" confirmation, as in Erase all data, because those changes would be lost.
- **Sign out:** calls `GoogleSignIn.signOut()`, clears the account keys and `lastKnownDriveBackup*`, sets `authMode = none`, cancels pending Drive backup tasks, and stops background backups. The Auto backup setting is kept for the next sign-in. The app then opens AUTH-01 (not Intro) with the back stack cleared.
- **Remove data from this phone:** after signing out, runs the same erase as SET-01 "Erase all data" (all module rows, receipts, the safety copy, backup password, and app lock), keeps `deviceId`, and opens AUTH-01, where "Continue with Google" brings the data back.
- **Keep data on this phone:** opens AUTH-01 with the snackbar "Signed out. Your data is still on this phone." "Continue as guest" keeps using that data without an account; "Continue with Google" opens ACC-02 if the account has a backup. App lock stays on if it was on, so leaving AUTH-01 goes through SYS-03.

**States:** Backup in progress (step 1 progress, "Sign out" disabled), backup failed (as above), and ready. Offline goes straight to the failed state.

**Ads:** None.

**Acceptance criteria:**

- [ ] With changes not yet backed up, sign-out backs up first and enables "Sign out" only after the backup succeeds or the user picks "Sign out anyway."
- [ ] "Keep data on this phone" leaves every local row in place, opens AUTH-01, and "Continue as guest" there shows the same data.
- [ ] "Remove data from this phone" erases local data, keeps the Drive backups, and opens AUTH-01.
- [ ] After sign-out with either choice, `authMode` is `none` and the app opens AUTH-01, never Intro; a restart also opens AUTH-01.
- [ ] After a failed backup, "Remove data from this phone" needs the typed "DELETE" confirmation.
- [ ] After sign-out, no Drive request is made until the user signs in again.

### ACC-04 Log out of guest (dialog)

**Purpose:** Let a guest leave guest mode, making clear that their data exists only on this phone and will be deleted for good.

**Layout:** A `ConfirmDialog` (section 15.4, 15.5).

1. Title "Log out and delete your data?"
2. Body: "As a guest, your data is stored only on this phone. Logging out permanently deletes all your expenses, habits, budgets, receipts, and unlocks. This can't be undone."
3. Actions: "Sign in with Google instead" (text button), "Cancel," and "Log out and delete" (destructive, in `error` color).

**Behavior:**

- Opened from the SET-01 Data group "Log out of guest," shown only while `authMode = guest`.
- **Sign in with Google instead:** closes the dialog and starts guest sign-in (above). Nothing is deleted.
- **Cancel,** back, or tapping outside: closes the dialog and changes nothing.
- **Log out and delete:** shows progress on the button with all actions disabled, then:
  1. In one database transaction, removes every user data row permanently (as SET-01 "Erase all data" does), including rewarded unlocks (`unlocks` rows; streak freezes go with their habits), and resets settings: it keeps the device preferences (language, currency, theme mode and selected theme, enabled modules and their order) and onboarding done, plus `deviceId`, `adsInstallAt`, ad consent, and Pro state (`removeAdsPurchased` and the Pro check keys); everything else goes back to its default, and `authMode` becomes `none`. A selected premium theme that came from a rewarded unlock falls back to Default Teal unless Pro is owned.
  2. Cancels every scheduled notification and pending `workmanager` job (recurring rules, reminders, daily summary).
  3. Deletes receipt images, the safety copy, and, from secure storage, the PIN hash, lockout state, and backup password (app lock and biometric are off afterwards).
  4. Refreshes the home widget and opens AUTH-01 with the back stack cleared. Intro is not shown again.
- Pro is unaffected: `removeAdsPurchased` is kept and is verified with Google Play on the next start as usual (PRM-01), and "Restore purchase" restores it after a reinstall.
- Backup or export files the user saved or shared outside the app are not touched.
- If the transaction fails, nothing is deleted, the user stays a guest, and the dialog shows "Couldn't delete your data. Try again."

**States:** Ready, deleting (progress, actions disabled), and error (as above). No empty or loading state: it is a fixed dialog.

**Ads:** None. No interstitial may appear over the dialog or over AUTH-01 after it (section 11).

**Acceptance criteria:**

- [ ] "Cancel," back, and tapping outside delete nothing: every row, receipt, unlock, the PIN, scheduled notifications, settings, and `authMode = guest` are unchanged.
- [ ] "Sign in with Google instead" deletes nothing and starts guest sign-in.
- [ ] "Log out and delete" removes all module rows, receipts, the safety copy, rewarded unlocks, the PIN hash and lockout state, and the backup password, and cancels every scheduled notification.
- [ ] After "Log out and delete," language, currency, theme, enabled modules, onboarding done, and Pro are kept, `authMode` is `none`, and the app opens AUTH-01 with no way back; a restart opens AUTH-01, not Intro or SYS-03.
- [ ] "Log out and delete" is shown in `error` color, and "Log out of guest" never appears in the Google state.
- [ ] A failed erase leaves all data and settings in place.

### Section acceptance criteria

- [ ] Every screen outside this section works the same as a guest, and only the places listed at the top of this section offer sign-in.
- [ ] As a guest, the app makes no Google sign-in or Drive request (a fake client records zero calls across a full session).
- [ ] No account or backup text in the app says "Synced" or "Sync"; status uses "Backed up to Google."
- [ ] Neither a Drive backup file nor Android Auto Backup data contains the PIN hash, lockout state, or backup password (a test inspects the backup JSON and the backup rules XML).
- [ ] Going to the background with changed data starts a backup; going to the background again within 15 minutes does not; nothing starts when no data changed.
- [ ] With "Wi-Fi only" on, background and scheduled auto backups don't upload on mobile data and run once Wi-Fi is back.
- [ ] Auto backup does not upload over a newer backup from another device; it pauses, notifies once, and resumes after a restore, "Keep this phone's data," or a manual backup.
- [ ] Each Drive backup has `deviceId`, `deviceName`, `appVersion`, `createdAt`, `kind`, and `counts` in both `appProperties` and the file's `meta`.
- [ ] Two installs never share a `deviceId`, including after a Drive restore or an Android Auto Backup restore.
- [ ] On the first start after an Android Auto Backup restore with app lock on and no PIN hash, the lock is turned off and the "Finish setting up" sheet is shown instead of locking the user out.

**Out of scope:** live multi-device sync (backups are labeled "Backed up to Google," never "Synced"), merging data from two phones, sign-in methods other than Google, and backing up to any cloud other than the user's own Google Drive.
