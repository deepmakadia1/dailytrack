---

description: "Task list for Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)"
---

# Tasks: Budgets, Recurring Rules, and Reports (Phase 1, T1.5–T1.7)

**Input**: Design documents from `specs/003-budgets-recurring-reports/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and spec FR-051 require:
- At least one automated test per acceptance criterion.
- ≥ 80% coverage on `domain/` and `data/`.
- Widget tests with fakes and `NoAdsService`.
- Unit tests for budget thresholds, per day left, rollover, copy, and recurring rule generation.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US5). Test names start with the
Screen ID and scenario, e.g. `EXP-08 US1-2 per day left counts today` (Constitution I).

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US5 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`.
- **Strings**: add keys to `tool/l10n/phase0_strings.py` (en, hi, and gu together; prefixes
  `expense_`, `notif_`, `premium_`, `more_`; sentence case; buttons start with a verb; placeholders,
  plurals, and `selectordinal`, never concatenation). Then run `python tool/l10n/phase0_strings.py`
  and `flutter gen-l10n`. Never edit ARB files by hand.
- **Codegen**: after changing any `@riverpod`, `@freezed`, or Drift file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: always read time from `clockProvider` (`package:clock`) or a `DateTime now` parameter.
  Never call `DateTime.now()` (scan-enforced from T004).
- **Screens**:
  - Use only `AppTokens` and `lib/core/widgets/`, on `AppScaffold` with `bannerSlot: null`.
  - Every screen has 4 states: `DelayedSkeleton`, `EmptyState`, `ErrorState` (with "Try again" →
    `ref.invalidate`), and content.
  - One `@riverpod` notifier per screen, with a `freezed` state (contracts/screens.md).
- **Charts**: `package:fl_chart` is imported **only** under
  `lib/features/expense/presentation/widgets/charts/`. Controllers build plain view models
  (research R12).
- **Widget tests**: `pumpTestApp` (`test/helpers/test_app.dart`) with fakes from
  `test/helpers/fakes.dart` and `test/features/expense/fakes.dart`. They never open a database, and
  each one asserts that no `AppBannerAd`/`AppNativeAd` is in the tree (FR-049).
- **Unit tests with real Drift**: `makeRealContainer` (`test/helpers/real_container.dart`) or
  `test/features/expense/data/expense_db_fixture.dart`.
- **Goldens**: tag `golden`, Linux only (`flutter test --tags golden --update-goldens`). On
  Windows, run `flutter test --exclude-tags golden`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependencies, the move to `package:clock`, layering guards, and shared strings

- [X] T001 Add dependencies with `flutter pub add clock:^1.1.3 workmanager:^0.10.10 fl_chart:^1.2.0` (research R1). This updates `pubspec.yaml` and `pubspec.lock`. Then:
  - Run `flutter pub get`.
  - Run `flutter build apk --flavor dev --debug` and inspect `build/app/intermediates/merged_manifests/devDebug/AndroidManifest.xml`.
  - Record any permissions `workmanager` adds (expected: `WAKE_LOCK`, `RECEIVE_BOOT_COMPLETED`, `FOREGROUND_SERVICE`) in plan.md Open item 9 (Play data-safety form). Remove anything else with `tools:node="remove"` in `android/app/src/main/AndroidManifest.xml`.
- [X] T002 Move to `package:clock` (research R2):
  - Rewrite `lib/core/utils/clock_provider.dart` so `clockProvider` (keep-alive) returns `package:clock`'s `Clock`. Production value: `const Clock()`.
  - Delete `lib/core/utils/clock.dart` and switch all 15 importers in `lib/` to `package:clock/clock.dart`. Find them with `grep -rl "core/utils/clock.dart" lib`.
  - Replace `DateTime.now()` in `lib/core/utils/date_keys.dart` (`nowUtcMs`) and `lib/core/widgets/period_selector.dart` with `clock.now()`.
  - Regenerate code.
- [X] T003 [P] Create `test/helpers/mutable_clock.dart`: a `MutableClock` that wraps `Clock(() => value)` and has `value` and `advance(Duration)`. Then:
  - Replace `FixedClock` in the 3 tests that use it (`grep -rl FixedClock test integration_test`).
  - Make every `clockProvider` override in `test/` use `Clock.fixed` or `MutableClock`.
  - Run `flutter test --exclude-tags golden` and confirm it is green.
- [X] T004 Extend the scan tests in `test/core/theme/no_hardcoded_style_test.dart` (contracts/routes_and_module.md "Layering scan"). New tests:
  - (a) no `DateTime.now(` anywhere in `lib/`;
  - (b) `package:workmanager` only in `lib/core/background/workmanager_background_scheduler.dart` and `lib/app/background_dispatcher.dart`;
  - (c) `package:fl_chart` only under `lib/features/expense/presentation/widgets/charts/`;
  - (d) `package:flutter_local_notifications` only in `lib/core/notifications/local_*.dart`;
  - (e) no file in `presentation/controllers/` imports `fl_chart`;
  - (f) `lib/features/` never imports `app/flavor.dart`;
  - (g) `app_database.dart` may additionally import `features/expense/data/tables/{budgets,recurring_rules}_table.dart`.

  (b)–(e) pass trivially until the files exist. (a) must pass after T002.
- [X] T005 [P] Add the shared strings (en/hi/gu) to `tool/l10n/phase0_strings.py` and regenerate:
  - Overflow entries: `expense_menuBudgets` "Budgets", `expense_menuRecurring` "Recurring", `expense_menuReports` "Reports".
  - Premium: `premium_getPro` "Get Pro", `premium_advancedReportsMessage` "Advanced reports are part of Pro.", `premium_lockedPeriod` "Locked".
  - Developer: `more_developerSection` "Developer", `more_debugUnlockAll` "Unlock all features (debug)".
  - Notification channel: `notif_channelBudgetAlerts` "Budget alerts", `notif_channelBudgetAlertsDescription` "When a budget reaches 80% or 100%".

**Checkpoint**: All existing tests are green on `package:clock`, and the new scan rules are in
place.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schema v3, settings, core notifications, background and gate services, module hooks,
app wiring, and the shared breakdown query

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Schema v3

- [X] T006 Add `enum Frequency { daily, weekly, monthly, yearly }` (index order, **append-only**) to `lib/features/expense/domain/enums.dart`. Extend `test/features/expense/domain/enums_test.dart` so it pins the indexes `daily=0 … yearly=3`.
- [X] T007 [P] Create `lib/features/expense/data/tables/recurring_rules_table.dart` (`@DataClassName('RecurringRuleRow')`, data-model §3.1), with these columns:
  - `id` TEXT PK;
  - `templateType` `intEnum<TxnType>`;
  - `amountMinor` "`BETWEEN 1 AND 99999999900`";
  - `accountId` FK `accounts(id)`;
  - `toAccountId` nullable FK `accounts(id)`;
  - `categoryId` nullable FK `categories(id)`;
  - `paymentMode` `intEnum<PaymentMode>`;
  - `note` nullable "`length ≤ 200`";
  - `frequency` `intEnum<Frequency>`;
  - `interval` "default 1, `CHECK (interval >= 1)`";
  - `anchorAt` int;
  - `nextRunAt` int;
  - `endAt` nullable "`CHECK (end_at IS NULL OR end_at >= anchor_at)`";
  - `isActive` bool;
  - `createdAt`, `updatedAt`, nullable `deletedAt`.

  Add the same type-shape table CHECK as `transactions_table.dart` (reuse the constant by moving it to `lib/features/expense/data/tables/type_shape_check.dart`) and `@TableIndex(name: 'recurring_rules_due', columns: {#isActive, #nextRunAt})`.
- [X] T008 [P] Create `lib/features/expense/data/tables/budgets_table.dart` (`@DataClassName('BudgetRow')`, data-model §3.2), with these columns:
  - `id` TEXT PK;
  - `categoryId` nullable FK `categories(id)` ("NULL = Overall");
  - `monthKey` TEXT "`GLOB '[0-9][0-9][0-9][0-9]-[01][0-9]'`";
  - `limitMinor` "`BETWEEN 1 AND 99999999900`";
  - `rollover` bool;
  - `alert80SentAt` nullable;
  - `alert100SentAt` nullable, with "`CHECK (alert100_sent_at IS NULL OR alert80_sent_at IS NOT NULL)`";
  - `createdAt`, `updatedAt`, `deletedAt`.

  Indexes: `@TableIndex(name: 'budgets_month', columns: {#monthKey})`, plus `@TableIndex.sql('CREATE UNIQUE INDEX budgets_month_category_unique ON budgets (month_key, IFNULL(category_id, \'\')) WHERE deleted_at IS NULL')` (research R4).
- [X] T009 [P] Create `lib/core/database/tables/unlocks_table.dart` (`@DataClassName('UnlockRow')`, data-model §3.3), with these columns:
  - `id` TEXT PK;
  - `featureKey` TEXT;
  - `expiresAt` nullable ("NULL = permanent");
  - `source` `intEnum<UnlockSource>`;
  - `createdAt`, `updatedAt`, `deletedAt`.

  Index `unlocks_feature (featureKey)`. `UnlockSource { rewardedAd, purchase }` (append-only) lives in `lib/core/feature_gate/domain/unlock.dart`; create that file now with just the enum. T026 adds the entity.
- [X] T010 Edit `lib/features/expense/data/tables/transactions_table.dart`:
  - `recurringRuleId` becomes `text().nullable().references(RecurringRules, #id)()`.
  - Add `@TableIndex(name: 'transactions_rule', columns: {#recurringRuleId})`.
  - Update its doc comment: the link is set by T1.6, and research R3 of feature 003 settles it.
  - Leave everything else unchanged.
- [X] T011 Update `lib/core/database/app_database.dart` (research R3, R9):
  - Add `RecurringRules`, `Budgets`, and `Unlocks` to `@DriftDatabase`, and set `schemaVersion => 3`.
  - Run `dart run drift_dev make-migrations` (it creates `drift_schemas/app_database/drift_schema_v3.json` and regenerates `app_database.steps.dart` and the test helpers).
  - Implement `from2To3` in the data-model §1 order:
    1. create `recurring_rules` + `recurring_rules_due`;
    2. create `budgets` + `budgets_month` + `budgets_month_category_unique`;
    3. create `unlocks` + `unlocks_feature`;
    4. `PRAGMA foreign_keys = OFF` → `m.alterTable(TableMigration(schema.transactions))` → make sure the 3 existing transaction indexes exist → create `transactions_rule` → `PRAGMA foreign_key_check` (throw if any row is returned) → `PRAGMA foreign_keys = ON`.
  - Change `open()` to `driftDatabase(name: 'dailytrack', native: const DriftNativeOptions(shareAcrossIsolates: true))`.
  - Add `PRAGMA busy_timeout = 5000` in `beforeOpen`.
  - Update the core → feature import comment to list the two new tables.
- [X] T012 Extend `test/drift/app_database/migration_test.dart` (quickstart §3):
  - v1→v3 and v2→v3 with data. Seed settings (including the seed markers), categories, accounts, and about 50 transactions of all 3 types, with notes and receipt paths. Assert every row is identical after the upgrade.
  - `PRAGMA foreign_key_list(transactions)` contains `recurring_rule_id → recurring_rules(id)`.
  - All 4 transaction indexes, `recurring_rules_due`, `budgets_month`, `budgets_month_category_unique`, and `unlocks_feature` exist.
  - `PRAGMA foreign_key_check` is empty.
  - `SeedRunner` inserts 0 rows afterwards.
  - `SchemaVerifier` validates v3.
- [X] T013 [P] Create `test/features/expense/data/budgets_recurring_tables_test.dart` (real in-memory Drift). It asserts that the database rejects each of these:
  - `limit_minor` 0 or 99999999901, a bad `month_key` ("2026-1", "26-10"), and `alert100` set without `alert80`;
  - a second live Overall budget in the same month, and a second live category budget in the same month, while the same slot after a soft delete is allowed;
  - a rule with `interval` 0, `end_at < anchor_at`, a transfer without `to_account_id`, or an expense without a category;
  - a transaction whose `recurring_rule_id` points at no rule.

### Settings (research R7, R13, R15)

- [X] T014 Extend settings in `lib/core/settings/domain/app_settings.dart`, `lib/core/settings/data/settings_codec.dart`, `lib/core/settings/domain/settings_repository.dart`, and `lib/core/settings/data/settings_repository_impl.dart` (contracts/core_services.md "Settings"):
  - New `AppSettings` fields: `@Default(true) bool notificationsEnabled`, `@Default(true) bool budgetAlertsEnabled`, `@Default(false) bool debugUnlockAll`, `int? latestSeenAt`, with codec keys of the same names.
  - New repository methods:
    - `setNotificationsEnabled`, `setBudgetAlertsEnabled`, `setDebugUnlockAll`;
    - `raiseLatestSeenAt(int utcMs)`, which writes only if larger, inside a transaction;
    - `readModuleState(String key)` and `writeModuleState(String key, String value)`, stored under `module.<key>`.

  Extend `test/core/settings/settings_repository_test.dart`: defaults, round trip, `raiseLatestSeenAt` never lowers, module-state namespacing, and bad JSON falling back to the default.

### Core notifications (research R15)

- [X] T015 [P] Create `lib/core/notifications/notification_service.dart` (pure Dart) with:
  - `enum NotificationChannelId { budgetAlerts }`;
  - `final class AppNotification` (`id`, `channel`, `title`, `body`, `payload`, `tag?`);
  - the `NotificationService` interface (`initialize`, `canNotify`, `show`, `cancelByTag`, `launchPayload`, `taps`) as in contracts/core_services.md.

  Add `notificationServiceProvider` (keep-alive; throws unless overridden) to `lib/core/notifications/notification_providers.dart`.
- [X] T016 Create `lib/core/notifications/local_notification_service.dart`, implementing `NotificationService` with `flutter_local_notifications`:
  - `initialize()` creates the Android channel `budget_alerts` (name and description from `lookupAppLocalizations` for the saved or device locale, default importance). It is idempotent and wires `onDidReceiveNotificationResponse` into a broadcast `taps` stream.
  - `canNotify()` uses `AndroidFlutterLocalNotificationsPlugin.areNotificationsEnabled()`, and returns `true` when that is null.
  - `show` sets the `tag`.
  - `cancelByTag` uses `getActiveNotifications` and cancels the matching ones.
  - `launchPayload()` uses `getNotificationAppLaunchDetails`.

  Mark plugin-only lines `// coverage:ignore`. In `test/core/notifications/local_notification_service_test.dart`, test the pure mapping helpers (channel id → Android details, payload passthrough).

### Core background jobs (research R10)

- [X] T017 [P] Create the background job service:
  - `lib/core/background/background_scheduler.dart`: pure `BackgroundScheduler` (`ensureDaily(String uniqueName)`, `cancel(String uniqueName)`) and `typedef BackgroundTask = Future<bool> Function(ProviderReader read);`.
  - `lib/core/background/workmanager_background_scheduler.dart`: `registerPeriodicTask(uniqueName, uniqueName, frequency: const Duration(hours: 24), existingWorkPolicy: ExistingPeriodicWorkPolicy.keep)` and `cancelByUniqueName`. Also a top-level `Future<void> initializeBackground(Function dispatcher)` that calls `Workmanager().initialize(dispatcher)`.
  - `lib/core/background/background_providers.dart`: `backgroundSchedulerProvider` (keep-alive; throws unless overridden).

### Module hooks and app wiring (research R10)

- [X] T018 Change `lib/core/module/tracker_module.dart` (contracts/core_services.md "TrackerModule"):
  - Add `typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);`.
  - `onEnable(ProviderReader read)`, `onDisable(ProviderReader read)`, new `Future<void> onAppOpen(ProviderReader read)`, and new `Map<String, BackgroundTask> get backgroundTasks`.

  Then:
  - Implement no-ops in `lib/features/habit/habit_module.dart` and, for now, in `lib/features/expense/expense_module.dart`.
  - Pass `ref.read` from `lib/features/settings/presentation/controllers/modules_controller.dart`.
  - Update `test/app/module_extensibility_test.dart` and the SET-06 tests that fake modules.
- [X] T019 Move `productionOverrides()` from `lib/main.dart` to a new `lib/app/production_overrides.dart`, and add these overrides:
  - `notificationServiceProvider` → `LocalNotificationService(...)`;
  - `backgroundSchedulerProvider` → `WorkmanagerBackgroundScheduler()`;
  - `debugToolsAvailableProvider` → `!FlavorConfig.current.isProd`;
  - `featureGateProvider` and `unlockRepositoryProvider` (both from T024).

  In `lib/main.dart`, call `initializeBackground(backgroundDispatcher)` before `runApp`. Update `integration_test/*` to import `production_overrides.dart`.
- [X] T020 Create `lib/app/background_dispatcher.dart` with `@pragma('vm:entry-point') void backgroundDispatcher()`. It calls `Workmanager().executeTask`, and for each task:
  1. calls `WidgetsFlutterBinding.ensureInitialized()`;
  2. builds `ProviderContainer(overrides: productionOverrides())`;
  3. calls `notificationService.initialize()`;
  4. loads settings;
  5. finds the task by name among `ModuleRegistry.enabled(settings)` modules' `backgroundTasks`;
  6. runs it;
  7. disposes the container.

  It returns `true` for unknown or disabled tasks and `false` if the task throws. Extract the pure lookup and run logic into `Future<bool> runBackgroundTask(String name, ProviderContainer c)`, and test it in `test/app/background_dispatcher_test.dart` with a fake module: found → runs; disabled module → `true` without running; throws → `false`.
- [X] T021 Update `lib/app/bootstrap.dart` and `lib/app/app.dart` (research R10, R15):
  - **Bootstrap**, after settings load:
    - `unawaited(notificationService.initialize())`, with errors caught.
    - Read `launchPayload()`. If onboarding is done, lock is off, and the payload starts with `/`, it becomes the initial location.
    - `unawaited` run `onAppOpen(ref.read)` for every enabled module, each in `try/catch`. A keep-alive `appOpenRunnerProvider` (`lib/app/app_open_runner.dart`) has an in-flight guard that skips a run while one is in progress.
    - Raise `latestSeenAt` to `clock.now()`.
  - **app.dart**: an `AppLifecycleListener(onResume: …)` calls the same runner, and a subscription to `notificationService.taps` calls `router.go(payload)`.

  Tests in `test/app/bootstrap_test.dart`:
  - The first route is not delayed by a never-completing `onAppOpen`.
  - A throwing `onAppOpen` is ignored.
  - The launch payload is used only when allowed.
  - Disabled modules are skipped.
  - Resume triggers the runner, and the guard prevents overlap.

### Feature gate (research R13)

- [X] T022 [P] Create the gate's domain files in `lib/core/feature_gate/domain/` (pure Dart; contracts/core_services.md "FeatureGate"):
  - `feature_key.dart`: `FeatureKey` value class with constants `exportCsv`, `exportPdf`, `advancedReports`, `adFreeDay`, `streakFreeze`, `factory premiumTheme(String name)` → `premiumTheme_<name>`, `storageKey`, `==`, and `fromStorage`.
  - `unlock.dart`: add the `freezed` `Unlock` entity (`id`, `featureKey`, `expiresAt?`, `source`, `createdAt`).
  - `unlock_repository.dart`: `watchLive`, `grant`, `revoke`.
  - `feature_gate.dart`: `watch` and `isUnlocked`.
- [X] T023 [P] Write `test/core/feature_gate/drift_feature_gate_test.dart` first (real in-memory Drift, `MutableClock`, fake settings). Cases:
  - no unlock → locked;
  - permanent → unlocked across a new container;
  - expiring → unlocked before `expiresAt`, then `watch` emits `false` at expiry (timer) without another write;
  - clock moved back after expiry → stays locked (`latestSeenAt`);
  - revoke → locked;
  - `debugUnlockAll` on with `debugToolsAvailable` true → unlocked, and with it false (prod) → locked;
  - `premiumTheme('saffron')` stored as `premiumTheme_saffron`.
- [X] T024 Create the gate's implementation and providers:
  - `lib/core/feature_gate/data/drift_unlock_repository.dart`.
  - `lib/core/feature_gate/data/drift_feature_gate.dart`. Unlocked if (`debugToolsAvailable && settings.debugUnlockAll`), or a live row has `expiresAt == null || expiresAt > effectiveNow`, where `effectiveNow = max(clock.now(), settings.latestSeenAt)`. Each evaluation calls `raiseLatestSeenAt`. `watch` combines the unlock and settings streams and re-arms a `Timer` for the nearest future expiry, cancelled on listen cancel.
  - `lib/core/feature_gate/feature_gate_providers.dart`: `featureGateProvider` and `unlockRepositoryProvider` (keep-alive, throw unless overridden), and `debugToolsAvailableProvider` (keep-alive, default `false`).

  Wire the `featureGateProvider` (→ `DriftFeatureGate`) and `unlockRepositoryProvider` overrides into `lib/app/production_overrides.dart` (T019). Make T023 pass.
- [X] T025 [P] Change `lib/core/widgets/locked_feature_overlay.dart` (research R14): `onWatchAd` becomes optional (null → the button is not built), `onGetPro` becomes nullable (null → a disabled button), and add an optional `String? message` line. Update `test/core/widgets/locked_feature_overlay_test.dart`:
  - With `onWatchAd: null`, no "Watch an ad" text is found.
  - "Get Pro" is disabled, but still has a semantics label.
  - The child is excluded from semantics.
  - The message is shown.

  Regenerate the overlay golden in `test/core/widgets/goldens/` (Linux).

### Shared query and fakes

- [X] T026 [P] Write `test/features/expense/data/breakdown_test.dart` first (real Drift, `MutableClock`). Cases:
  - `watchBreakdown(TxnQuery(period: month))` groups expense by category, account, and payment mode.
  - Income and transfers are excluded.
  - Soft-deleted rows are excluded.
  - Each grouping's sum equals `watchLedger(sameQuery).expenseMinor` for day, week, month, year, and custom periods.
  - It re-emits after an insert.
  - At 10,000 seeded rows, a year breakdown's first emit takes < 500 ms (tag `perf`; reuse the seeding helper from `transaction_perf_test.dart`).
- [X] T027 Implement the breakdown and the gate providers:
  - Add `ExpenseBreakdown` (`freezed`: `byCategory: Map<String,int>`, `byAccount: Map<String,int>`, `byPaymentMode: Map<PaymentMode,int>`, `totalExpenseMinor`) in `lib/features/expense/domain/entities/expense_breakdown.dart`.
  - Add `Stream<ExpenseBreakdown> watchBreakdown(TxnQuery)` to `lib/features/expense/domain/repositories/transaction_repository.dart`.
  - Implement it in `lib/features/expense/data/daos/transactions_dao.dart` and `lib/features/expense/data/repositories/drift_transaction_repository.dart` (research R11). It runs 3 `GROUP BY` queries in one read transaction, all built from the **same** private where-builder as the ledger (refactor that builder if it is inlined).

  Make T026 pass.
- [X] T028 Add the shared fakes:
  - In `test/helpers/fakes.dart`:
    - `FakeFeatureGate` (a settable map of keys to bool, with a stream);
    - `FakeNotificationService` (records `show` and `cancelByTag`; settable `canNotify`; a controllable `taps` and `launchPayload`);
    - `FakeBackgroundScheduler` (records `ensureDaily` and `cancel`).
  - In `test/helpers/test_app.dart`, give `pumpTestApp` defaults for `featureGateProvider` (everything locked), `notificationServiceProvider`, `backgroundSchedulerProvider`, and `debugToolsAvailableProvider` (`false`), each overridable.
  - In `test/features/expense/fakes.dart`, add `watchBreakdown` to the fake transaction repository.

**Checkpoint**: The gates (quickstart §1) are green. Schema v3 is migrated and tested. The app starts
with app-open hooks that do nothing yet. The gate, notification, and background services are
injectable.

---

## Phase 3: User Story 1 - Set monthly budgets and see how much is left (EXP-08, EXP-09) (Priority: P1) 🎯 MVP

**Goal**: Overall and per-category monthly budgets with live spent, remaining, progress, and per
day left. "Copy last month's budgets", rollover on the first app open of a month, and the EXP-09
sheet.

**Independent Test**: With fixed October transactions, set an overall budget and two category
budgets. Check the spent, remaining, progress, and per-day-left values on a fixed "today". Check the
empty state. "Copy last month" fills only missing slots. Moving the clock into November and opening
the app creates the repeating budgets once.

### Tests for User Story 1 ⚠️ (write first, confirm they fail)

- [X] T029 [P] [US1] Write `test/features/expense/domain/budget_math_test.dart` (pure; research R5):
  - **EXP-08 criterion "Per day left" uses remaining days including today**: first, middle, and last day of 28-, 29-, 30-, and 31-day months, e.g. 31 Oct with ₹310 remaining → ₹310 for 1 day; 1 Oct → 31 days.
  - Floor division to whole paise.
  - Remaining ≤ 0 → null per-day.
  - Past month → `daysLeft` null. Future month → all days.
  - Levels at 79.99%, exactly 80% (warning), exactly 100% (warning, "reached"), and 100.01% (over).
  - Percent 135.
  - `monthKeyOf` and `monthRangeUtc` across a non-IST test zone's DST boundary.
- [X] T030 [P] [US1] Write `test/features/expense/domain/validate_budget_test.dart`: amount missing or 0 → `amountMissing`; 99999999901 → `amountTooLarge`; 99999999900 is valid.
- [X] T031 [P] [US1] Write `test/features/expense/data/budget_repository_test.dart` (real Drift, `MutableClock`):
  - `create` and `BudgetSlotTaken` for the same slot.
  - `update` keeps the category.
  - `softDelete` and `undelete`, and `undelete` → `BudgetSlotTaken` when the slot was refilled.
  - **EXP-08 criterion "Copy last month does not overwrite budgets already set for this month"**: September has Food ₹1,000, Overall ₹20,000, and Travel ₹500; October already has Food ₹2,000. Copy → returns 2, Food stays ₹2,000, and the copies have their markers cleared.
  - Copy skips hidden or deleted categories.
  - `rolloverIfNeeded`:
    - copies only `rollover = true` budgets into empty slots and writes the marker;
    - a second call in the same month copies nothing, even after the user deletes a rolled-over budget;
    - a skipped month (source August, now October) uses the latest earlier month with budgets;
    - skips a repeating budget whose category is hidden or deleted (edge case), while still rolling over the others;
    - a first install with no budgets sets the marker only.
  - Limit-change clearing (clarification Q4): spent ₹900 against ₹1,000 with both markers set → update to ₹2,000 clears both; update to ₹950 clears 100 only; lowering keeps reached markers.
  - `watchOverview` spent equals the sum of expenses (income and transfers excluded), re-emits on a transaction insert, and lists the non-hidden expense categories without a budget.
  - `spentFor` equals the `watchOverview` spent for Overall and for a category in the same month (income, transfers, and soft-deleted rows excluded).
- [X] T032 [P] [US1] Write `test/features/expense/presentation/budgets_controller_test.dart` (fake repositories, `MutableClock`):
  - Defaults to the current month, or the `month` argument.
  - `previousMonth` and `nextMonth`.
  - `copyLastMonth` returns the count.
  - `deleteBudget` returns an Undo that calls `undelete`.
  - The error → retry path.
- [X] T033 [P] [US1] Write `test/features/expense/presentation/budgets_screen_test.dart` (US1 scenarios 1–3, 7–8, 10–12):
  - Order: month selector → overall card → category list → "Categories without budget".
  - The overall card text "₹X per day left for N days", and the past-month "Under budget by" and "Over budget by" texts.
  - Category rows show spent / limit, progress, and a level text or icon (not color alone).
  - The empty state with "Set monthly budget" opens EXP-09 with Overall preselected.
  - Overflow "Copy last month's budgets" → snackbar with the count, and "Nothing to copy".
  - The delete Undo snackbar.
  - No ad widgets.
  - The loading skeleton after 300 ms, and the error state with "Try again".
- [X] T034 [P] [US1] Write `test/features/expense/presentation/budget_sheet_test.dart` (US1 scenarios 4–6):
  - New with category options = Overall plus categories without a budget.
  - Amount via keypad; 0 → inline error; above the max → inline error.
  - "Repeat every month" toggle.
  - Save calls `create` with the selected month.
  - Edit mode: the category is read-only, "Delete budget" is shown, and update keeps the slot.
  - `BudgetSlotTaken` → inline error.
  - The form keeps its input when saving fails.

### Implementation for User Story 1

- [X] T035 [P] [US1] Create the budget entities:
  - `lib/features/expense/domain/entities/budget.dart`: `Budget` and `BudgetDraft` (`freezed`, fields per data-model §4).
  - `lib/features/expense/domain/entities/budget_status.dart`: `BudgetStatus`, `BudgetsOverview`, `BudgetLevel { under, warning, over }`, and `MonthPhase { past, current, future }`.
  - Errors `BudgetSlotTaken` and `BudgetNotFound` in `lib/features/expense/domain/errors.dart`.
- [X] T036 [P] [US1] Implement `lib/features/expense/domain/usecases/budget_math.dart` (research R5): `monthKeyOf`, `monthRangeUtc`, `levelFor`, `percentOf`, `daysLeftInclusive`, `perDayLeft`, `monthPhase`, and `buildBudgetStatus`. All `int` math. Make T029 pass.
- [X] T037 [P] [US1] Implement `lib/features/expense/domain/usecases/validate_budget.dart` (`BudgetError { amountMissing, amountTooLarge, slotTaken }`). Make T030 pass.
- [X] T038 [US1] Create `lib/features/expense/domain/repositories/budget_repository.dart`, exactly as in contracts/repositories.md "BudgetRepository", including `BudgetThreshold { p80, p100 }` and `markAlertSent` (which US2 uses).
- [X] T039 [US1] Implement the budgets data layer:
  - `lib/features/expense/data/daos/budgets_dao.dart`.
  - `lib/features/expense/data/mappers/budget_mapper.dart`.
  - `lib/features/expense/data/repositories/drift_budget_repository.dart`, with:
    - `watchOverview`: combines live budgets for the month, `watchBreakdown` for the month, and the category stream, plus a local-midnight tick from `clockProvider` so days left update. It builds statuses with `budget_math`.
    - `create`, `update` (clearing markers in the same transaction per data-model §6), `softDelete`, `undelete` (unique violation → `BudgetSlotTaken`), `copyPreviousMonth` and `rolloverIfNeeded`, both skipping budgets whose category is hidden or deleted (rollover marker `expense.budgetRolloverMonth` via `readModuleState`/`writeModuleState`).
    - `markAlertSent`: compare-and-set `UPDATE … WHERE alert100_sent_at IS NULL`, setting `alert80_sent_at = IFNULL(alert80_sent_at, :now)` for p100. Returns true only if 1 row changed.
    - `forAlert` and `spentFor` (one `SUM` query on the shared where-builder from T027).

  Make T031 pass, and add a `markAlertSent` concurrency case: two parallel calls → exactly one `true`.
- [X] T040 [US1] Wire the budget repository:
  - Add `budgetRepositoryProvider` (throws unless overridden) to `lib/features/expense/presentation/expense_providers.dart`.
  - Bind `DriftBudgetRepository` in `lib/features/expense/expense_bindings.dart`.
  - Add `FakeBudgetRepository` to `test/features/expense/fakes.dart`.
- [X] T041 [US1] In `lib/features/expense/expense_module.dart`, implement the budget part of `onAppOpen(read)`: `read(budgetRepositoryProvider).rolloverIfNeeded(monthKeyOf(read(clockProvider).now()))` inside `try/catch`. Test it in `test/features/expense/expense_module_test.dart`: `onAppOpen` with a real-Drift container on 1 November creates October's repeating budgets once.
- [X] T042 [P] [US1] Add the budget strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Titles and sections: `expense_budgetsTitle` "Budgets", `expense_budgetOverall` "Overall", `expense_budgetCategoryBudgets` "Category budgets", `expense_budgetWithoutBudget` "Categories without budget".
  - Actions: `expense_budgetSet` "Set budget", `expense_budgetSetMonthly` "Set monthly budget", `expense_budgetCopyLastMonth` "Copy last month's budgets".
  - Copy results: `expense_budgetCopied` "{count, plural, =0{Nothing to copy} one{Copied 1 budget} other{Copied {count} budgets}}".
  - Overall card: `expense_budgetPerDayLeft` "{amount} per day left for {days, plural, one{1 day} other{{days} days}}", `expense_budgetNoneLeft` "No budget left this month", `expense_budgetUnderBy` "Under budget by {amount}", `expense_budgetOverBy` "Over budget by {amount}", `expense_budgetFuturePerDay` "{amount} per day for {days} days".
  - Rows: `expense_budgetSpentOfLimit` "{spent} of {limit}", `expense_budgetLevelUnder` "On track", `expense_budgetLevelWarning` "Almost used", `expense_budgetLevelOver` "Over budget", `expense_budgetPercentUsed` "{percent}% used".
  - Empty state: `expense_budgetEmptyTitle` "Plan your month", `expense_budgetEmptyBody` "Set a monthly budget to see how much you can still spend each day.".
  - Sheet: `expense_budgetRepeatMonthly` "Repeat every month", `expense_budgetDelete` "Delete budget", `expense_budgetDeleted` "Budget deleted", `expense_budgetRestoreFailed` "Couldn't restore the budget because one is already set.", `expense_budgetSlotTaken` "This category already has a budget this month.", `expense_budgetHidden` "Hidden".
  - Errors: `expense_budgetAmountMissing` "Enter an amount", `expense_budgetAmountTooLarge` "Amount is too large".
  - `expense_budgetSetOverallPrompt` "Set an overall budget".
- [X] T043 [US1] Implement `lib/features/expense/presentation/controllers/budgets_controller.dart` and `budgets_state.dart` (contracts/screens.md EXP-08). Make T032 pass.
- [X] T044 [P] [US1] Create `lib/features/expense/presentation/widgets/overall_budget_card.dart` (on `SummaryCard` + `ProgressBarStatus`, using the 4 per-day text variants) and `lib/features/expense/presentation/widgets/budget_row.dart` (`CategoryAvatar`, name + "Hidden", spent of limit, `ProgressBarStatus`, and level text). Row height 64–72 dp, with touch targets ≥ 48 dp.
- [X] T045 [US1] Implement `lib/features/expense/presentation/screens/budgets_screen.dart` (EXP-08):
  - `AppScaffold` titled "Budgets", with an overflow "Copy last month's budgets".
  - `PeriodSelector` in month-only mode. Add a `monthOnly` flag to `lib/core/widgets/period_selector.dart` that disables the picker, plus a test in `test/core/widgets/period_selector_test.dart`.
  - Sections, all 4 states, snackbars, and Undo via `UndoSnackBar`.

  Make T033 pass.
- [X] T046 [US1] Implement EXP-09 in `lib/features/expense/presentation/controllers/budget_form_controller.dart`, `budget_form_state.dart`, and `lib/features/expense/presentation/widgets/budget_sheet.dart` (`AppBottomSheet`, `NumericKeypad` + `AmountEntry`, category picker, rollover switch, primary "Set budget", and "Delete budget" in the error color in edit mode). Make T034 pass.
- [X] T047 [US1] Add the EXP-08 route and entry point:
  - In `lib/app/router/routes.dart`: `expenseBudgets = '/expenses/budgets'`, the segment `budgets`, name `expenseBudgets`, and `expenseBudgetsPath({String? month})`, declared before `:id`.
  - In `lib/features/expense/expense_module.dart`: the route, parsing `month`.
  - In `lib/features/expense/presentation/screens/transactions_screen.dart`: add "Budgets" to the overflow.

  Extend `test/features/expense/expense_module_test.dart` (route resolves, `?month=2026-09` opens September) and `transactions_screen_test.dart` (the overflow entry).

**Checkpoint**: US1 is fully usable and tested. Budgets work without alerts.

---

## Phase 4: User Story 2 - Get warned before going over budget (EXP-02 budget alerts) (Priority: P1)

**Goal**: After an expense is saved for the current month, send one local notification per
threshold (80%, 100%) per budget per month. It respects the settings and the OS permission, never
blocks the save, and tapping it opens EXP-08.

**Independent Test**: With a fake notifier and fixed budgets, save expenses that cross 80% and then
100% of a category budget and of the overall budget. Expect exactly one notification per
threshold, none when alerts are off or the expense is dated in a past month, and markers that
survive a restart.

### Tests for User Story 2 ⚠️

- [X] T048 [P] [US2] Write `test/features/expense/domain/check_budget_alerts_test.dart` (fakes: `FakeBudgetRepository` with real compare-and-set semantics, `FakeBudgetAlertNotifier`, `FakeNotificationGate`, `MutableClock`):
  - **EXP-02 criterion "Budget alert fires once at 80% and once at 100% per category per month"**: a table of ≥ 50 generated save sequences (SC-003) asserting exactly one 80% and one 100% notification per budget per month.
  - A single save crossing both → only 100%, with both marked.
  - Overall and category alert independently.
  - A drop then a rise → no repeat.
  - Income or transfer → no check.
  - Past-month and future-month expenses → no notification and no marker (Q2).
  - Gate off (master off, alerts off, or OS denied) → markers recorded, no notification.
  - A notifier that throws → `check` returns normally.
  - A new month → alerts again.
  - A raised limit (marker cleared) → alerts once more (Q4).
- [X] T049 [P] [US2] Write `test/features/expense/data/local_budget_alert_notifier_test.dart` (`FakeNotificationService`):
  - en/hi/gu text from ARB.
  - The body contains the category name (a default category translated) and the percentage, and **no amount digits or note** (FR-020).
  - A stable id for the same budget and threshold.
  - Tag `budget`.
  - Payload `/expenses/budgets?month=2026-10`.
  - Channel `budgetAlerts`.
  - `cancelAll` → `cancelByTag('budget')`.
- [X] T050 [P] [US2] Write `test/features/expense/data/settings_notification_gate_test.dart`: allowed only when `notificationsEnabled && budgetAlertsEnabled && canNotify()`, covering all 8 combinations.
- [X] T051 [P] [US2] Write `test/features/expense/presentation/transaction_form_budget_alert_test.dart` (US2 scenarios 1, 7, 8):
  - Saving a current-month expense calls `BudgetAlertChecker.check` once with the saved category and time.
  - An edit also checks.
  - Income doesn't check.
  - A checker that never completes or throws still lets the screen close with "Saved · Undo".
- [X] T052 [P] [US2] Write `test/app/notification_tap_test.dart` (US2 scenario 6): a tap on the `FakeNotificationService` with payload `/expenses/budgets?month=2026-09` while running → EXP-08 shows September. As a launch payload with onboarding done and lock off → the initial route is EXP-08. With lock on → `/lock` and EXP-08 is **not** shown (forwarding is T3.1, plan Open item 3 and Complexity Tracking). Name the test `EXP-02 US2-6 tap with lock on opens lock screen (forwarding deferred to T3.1)`.

### Implementation for User Story 2

- [X] T053 [P] [US2] Create the alert domain types:
  - `lib/features/expense/domain/entities/budget_alert.dart`: `BudgetAlert` (`freezed`: `budgetId`, `monthKey`, `categoryId?`, `threshold`, `percent`).
  - The ports `lib/features/expense/domain/ports/budget_alert_notifier.dart` (`notify`, `cancelAll`) and `lib/features/expense/domain/ports/notification_gate.dart` (`budgetAlertsAllowed`).
- [X] T054 [US2] Implement `lib/features/expense/domain/usecases/check_budget_alerts.dart`, `BudgetAlertChecker` (research R6):
  1. expense + current local month only;
  2. `forAlert`;
  3. spent from `BudgetRepository`;
  4. pick the target threshold;
  5. `markAlertSent` compare-and-set;
  6. only on `true` and `gate.budgetAlertsAllowed()` → `notifier.notify`.

  Step 3 uses `BudgetRepository.spentFor`. Errors are swallowed, and the sent alerts are returned. Make T048 pass.
- [X] T055 [US2] Implement `lib/features/expense/data/notifications/local_budget_alert_notifier.dart`:
  - Text via `lookupAppLocalizations` for the saved locale or the device locale.
  - The category name through `DefaultNameCatalog` for defaults.
  - Id = a 31-bit stable hash of `"$budgetId:$threshold"`, tag `budget`, payload `Routes.expenseBudgetsPath(month: monthKey)`.

  Also implement `lib/features/expense/data/notifications/settings_notification_gate.dart`. Make T049 and T050 pass.
- [X] T056 [P] [US2] Add the notification strings (en/hi/gu) to `tool/l10n/phase0_strings.py`: `notif_budget80Title` "{category} budget at {percent}%", `notif_budget80Body` "You've used {percent}% of your {category} budget this month.", `notif_budget100Title` "{category} budget used up", `notif_budget100Body` "You've used {percent}% of your {category} budget this month.", and `notif_overallBudget` "Overall". The text has no amounts.
- [X] T057 [US2] Wire the alert checker:
  - Add `budgetAlertNotifierProvider`, `notificationGateProvider` (both throw unless overridden), and `budgetAlertCheckerProvider` (composes the repository, ports, and clock) to `lib/features/expense/presentation/expense_providers.dart`.
  - Bind the notifier and gate in `lib/features/expense/expense_bindings.dart`.
  - Add `FakeBudgetAlertNotifier` and `FakeNotificationGate` to `test/features/expense/fakes.dart`.
- [X] T058 [US2] In `lib/features/expense/presentation/controllers/transaction_form_controller.dart` `save()`: after a successful create or update of an **expense**, call `unawaited(_checkBudgets(saved))`, which reads `budgetAlertCheckerProvider` inside `try/catch` (FR-015, FR-018). The save result and snackbar are unaffected. Make T051 pass.
- [X] T059 [US2] Wire notification taps:
  - In `lib/app/app.dart` and `lib/app/bootstrap.dart`, use the payload routing from T021 for budget payloads.
  - In `lib/features/expense/expense_module.dart`, `onDisable(read)` calls `read(budgetAlertNotifierProvider).cancelAll()`.

  Make T052 pass, and extend `expense_module_test.dart` for `onDisable`.

**Checkpoint**: US1 and US2 both work. Alerts fire once per threshold per month, and only for the
current month.

---

## Phase 5: User Story 3 - Automate repeating transactions (EXP-02 Repeat, EXP-10) (Priority: P2)

**Goal**: The Repeat section in EXP-02 (new entries, edits of unlinked entries, and rule-edit
mode), the exactly-once generator on app open and the daily background job, EXP-10 with pause,
resume, and delete, the repeat icon in EXP-01, and the rule link in EXP-03.

**Independent Test**: With a `MutableClock`, create daily, weekly, monthly (including the 31st),
and yearly rules. Advance the clock (including 3 months without opening the app), then run the
generator from app open and from the background task. Check the exact set of generated entries and
their dates, that there are no duplicates, that each is linked to its rule, and that the next run
date has advanced.

### Tests for User Story 3 ⚠️

- [X] T060 [P] [US3] Write `test/features/expense/domain/recurrence_test.dart` (pure; research R8):
  - **EXP-10 criterion "A monthly rule on the 31st runs on the last day of shorter months"**: from 31 Jan 2027 for 48 months, each occurrence is `min(31, daysInMonth)` and back to the 31st whenever possible (31 Mar, 31 May).
  - Day 30 → Feb 28/29.
  - Yearly on 29 Feb 2028 → 28 Feb 2029, 2030, 2031, then 29 Feb 2032.
  - Weekly keeps the weekday. Daily keeps the wall-clock time across a DST change (run in a non-IST zone such as `America/New_York` via the TZ environment variable, or by injecting a local-offset function).
  - `indexAtOrAfter` correctness at 0, 1, 10, and 3,650 steps (O(1) estimate ±2).
  - `firstAfter(now)`.
  - `describe()` for every frequency.
- [X] T061 [P] [US3] Extend `test/features/expense/domain/validate_transaction_test.dart` with `RepeatSettings`: end date before the entry date → `repeatEndBeforeStart`; equal → valid; no end → valid.
- [X] T062 [P] [US3] Write `test/features/expense/data/recurring_rule_repository_test.dart` (real Drift, `MutableClock`):
  - `createWithFirstOccurrence` → 1 transaction + 1 rule, linked; `nextRunAt` = the next occurrence; `anchorAt` = the entry's moment.
  - `attachNewRule` on an unlinked entry (Q3) → linked; on a linked entry → `TransactionAlreadyLinked`.
  - **EXP-02 US3-14**: an unlinked monthly entry dated 3 months ago + `attachNewRule` + `generateDue` → exactly 3 new linked rows with the correct dates; `undoRuleCreation(restoreSnapshot)` then removes those 3 and restores the entry's previous values.
  - `undoRuleCreation`: for a new entry it removes the rule and every linked row; with `restoreSnapshot` it restores the entry and clears its link while removing the generated rows.
  - `updateRule` changes only future occurrences (existing rows unchanged); the new `anchorAt` = the chosen date; `nextRunAt` = first occurrence ≥ max(chosen, now).
  - `pause`, then `resume`, skips occurrences missed during the pause (US3 scenario 10).
  - `softDelete` keeps the generated rows and their links; `undelete`.
  - `watchAll` puts active rules first by `nextRunAt`, then paused or ended; `staleReference` is set for an archived account or hidden category.
- [X] T063 [P] [US3] Write `test/features/expense/data/recurring_generator_test.dart` (real Drift + real `RecurringGenerator`, fake alert checker):
  - **EXP-10 criterion "If the app was not opened for 3 months, all missed entries are created once, with correct dates, and no duplicates"**, for daily, weekly, monthly, and yearly rules, across a 3-month clock jump. Assert the exact `occurredAt` list.
  - Running again → 0 created.
  - Two `runDue()` calls started concurrently on the same database → no duplicates (the compare-and-set loser rolls back).
  - `ExpenseModule.backgroundTasks['expense.recurring']` and `onAppOpen` run back to back → no duplicates.
  - `endAt` respected → the rule becomes ended (`isActive` false); clock moved back → nothing created; clock jumping 1 year for a daily rule → 365 rows in < 200 ms (tag `perf`).
  - A rule with an archived account still generates.
  - A monthly **transfer** rule → generated rows are transfers with the same `accountId` and `toAccountId`, no category, linked to the rule; no alert check runs for them.
  - Generated current-month **expenses** call the alert checker; past-month ones don't (Q2).
  - The monthly 31st rule through `generateDue` matches T060.
- [X] T064 [P] [US3] Extend `test/features/expense/presentation/transaction_form_controller_test.dart` with repeat and modes (contracts/screens.md EXP-02 changed):
  - The Repeat toggle defaults to off and Monthly.
  - New + repeat save → `createWithFirstOccurrence`, then `generateDue`; Undo → `undoRuleCreation`.
  - Edit of an unlinked entry + repeat → `attachNewRule`, then `generateDue` for the new rule; Undo → `undoRuleCreation` with the snapshot.
  - Edit of a linked entry → `linkedToRule` true and Repeat hidden.
  - Rule-edit load from `RecurringRule`; save → `updateRule`; Repeat off + save → `softDelete` with Undo → `undelete` (Q5).
  - A missing rule → not-found state.
  - The validation error for the end date.
- [X] T065 [P] [US3] Write `test/features/expense/presentation/transaction_form_repeat_test.dart` (widget; US3 scenarios 1–3, 11, 13, 14):
  - The Repeat switch and frequency chips; the end-date chip; the schedule in words ("Every month on 5th").
  - The inline error under the Repeat section.
  - The rule-edit title "Edit recurring transaction", the date chip label "Next date", no receipt field, and no delete icon.
  - Repeat hidden for a linked entry.
  - A 200% font scale at 360 dp without overflow.
- [X] T066 [P] [US3] Write `test/features/expense/presentation/recurring_screen_test.dart` (EXP-10; US3 scenarios 8–9, 12):
  - Active and Paused sections; row content (icon, note or category, signed amount, frequency text, "Next: …").
  - "Ended {date}" for an ended rule, with Resume disabled.
  - A warning line for a stale reference.
  - Swipe left → delete with a 5 s Undo; swipe right → pause or resume; the long-press menu has both.
  - Tap → `/expenses/recurring/:ruleId/edit`.
  - The empty state with "Add recurring transaction" → `/expenses/recurring/add` (FAB hidden then); FAB visible with rules.
  - Loading and error states. No ads.
- [X] T067 [P] [US3] Extend `test/features/expense/presentation/transactions_screen_test.dart` and `transaction_detail_screen_test.dart` (US3 scenario 7):
  - A linked expense row and a linked transfer row both show the repeat icon with the semantic label "Recurring", and the row height is unchanged.
  - The overflow has "Recurring".
  - EXP-03 for a linked entry shows "Created from recurring rule" → rule-edit; when the rule is deleted it shows "Recurring rule deleted" as plain text.
- [X] T068 [P] [US3] Extend `test/features/expense/expense_module_test.dart`:
  - `onAppOpen` runs rollover → generator → `ensureDaily('expense.recurring')` in order, each failure isolated.
  - `backgroundTasks` contains `expense.recurring`, which runs rollover and the generator and returns `true`.
  - `onEnable` → `ensureDaily` + `onAppOpen`.
  - `onDisable` → `cancel('expense.recurring')` + `cancelAll()`.

### Implementation for User Story 3

- [X] T069 [P] [US3] Create the recurring entities:
  - `lib/features/expense/domain/entities/recurring_rule.dart`: `RecurringRule` and `RecurringRuleView` (`freezed`; fields per data-model §4; `isEnded = !isActive && endAt != null && nextRunAt > endAt`).
  - `lib/features/expense/domain/entities/repeat_settings.dart`: `RepeatSettings(frequency, endAt?)`.
  - Errors `RuleNotFound` and `TransactionAlreadyLinked` in `domain/errors.dart`.
  - Add `bool get isRecurring => recurringRuleId != null` to `TransactionView` in `lib/features/expense/domain/entities/transaction_view.dart`.
- [X] T070 [P] [US3] Implement `lib/features/expense/domain/usecases/recurrence.dart`, `RecurrenceSchedule` (research R8), with `occurrence(n)`, `indexAtOrAfter`, `firstAfter`, and `describe()` returning a `ScheduleDescription` (frequency, weekday, day of month, month). Make T060 pass.
- [X] T071 [P] [US3] Extend `lib/features/expense/domain/usecases/validate_transaction.dart` with an optional `RepeatSettings` and `TransactionError.repeatEndBeforeStart`. Make T061 pass.
- [X] T072 [US3] Create `lib/features/expense/domain/repositories/recurring_rule_repository.dart`, exactly as in contracts/repositories.md "RecurringRuleRepository".
- [X] T073 [US3] Implement the recurring rules data layer:
  - `lib/features/expense/data/daos/recurring_rules_dao.dart`.
  - `lib/features/expense/data/mappers/recurring_rule_mapper.dart`.
  - `lib/features/expense/data/repositories/drift_recurring_rule_repository.dart`, with every method in the contract.

  `generateDue` follows research R9 step by step, all in **one transaction per rule**:
  1. Re-read the rule; skip it if deleted, inactive, or `next_run_at > now`.
  2. Batch-insert every occurrence `≤ now` and `≤ endAt`, copying the template, with a new UUID, `occurred_at = occ(n)`, and `recurring_rule_id`.
  3. Compare-and-set: `UPDATE … SET next_run_at, is_active, updated_at WHERE id = ? AND next_run_at = ?`. If 0 rows changed, throw the internal `RuleChangedConcurrently` → rollback → return an empty list.

  Make T062 pass.
- [X] T074 [US3] Implement `lib/features/expense/domain/usecases/generate_recurring.dart`, `RecurringGenerator.runDue()`:
  - `dueRuleIds(now)` → `generateDue` for each.
  - For created **expenses** dated in the current month → `BudgetAlertChecker.check` (optional dependency; skipped when null so US3 works without US2).
  - A failing rule is caught and the generator continues.
  - Returns the number created.

  Make T063 pass (after T075).
- [X] T075 [US3] Wire the recurring rules into the module:
  - Add `recurringRuleRepositoryProvider` (throws unless overridden) and `recurringGeneratorProvider` to `lib/features/expense/presentation/expense_providers.dart`, and bind the Drift repository in `lib/features/expense/expense_bindings.dart`.
  - In `lib/features/expense/expense_module.dart`:
    - `static const recurringTaskName = 'expense.recurring'`;
    - `onAppOpen`: rollover (T041) → `runDue()` → `read(backgroundSchedulerProvider).ensureDaily(recurringTaskName)`, each in `try/catch`;
    - `backgroundTasks`: `{recurringTaskName: (read) async { rollover; runDue; return true; }}`;
    - `onEnable`: `ensureDaily` + `onAppOpen`;
    - `onDisable`: also `cancel(recurringTaskName)`.
  - Add `FakeRecurringRuleRepository` to `test/features/expense/fakes.dart`.

  Make T068 pass.
- [X] T076 [P] [US3] Add the recurring strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - EXP-02 Repeat section: `expense_repeat` "Repeat", `expense_freqDaily` "Daily", `expense_freqWeekly` "Weekly", `expense_freqMonthly` "Monthly", `expense_freqYearly` "Yearly", `expense_repeatEndDate` "End date (optional)", `expense_repeatEndBeforeStart` "End date can't be before the first date".
  - Schedule descriptions: `expense_everyDay` "Every day", `expense_everyWeekOn` "Every week on {weekday}", `expense_everyMonthOn` "Every month on {day, selectordinal, one{{day}st} two{{day}nd} few{{day}rd} other{{day}th}}" (hi/gu use their own ordinal or "day {day}" forms; plan Open item 6), `expense_everyYearOn` "Every year on {date}".
  - EXP-10 screen: `expense_recurringTitle` "Recurring transactions", `expense_recurringPaused` "Paused", `expense_recurringNext` "Next: {date}", `expense_recurringEnded` "Ended {date}", `expense_recurringPause` "Pause", `expense_recurringResume` "Resume", `expense_recurringDeleted` "Recurring transaction deleted", `expense_recurringAdd` "Add recurring transaction", `expense_recurringEmptyTitle` "Nothing repeats yet", `expense_recurringEmptyBody` "Add rent, salary, or bills once and they'll be logged for you.", `expense_recurringStaleAccount` "Account archived", `expense_recurringStaleCategory` "Category hidden".
  - Rule-edit mode: `expense_ruleEditTitle` "Edit recurring transaction", `expense_nextDate` "Next date".
  - EXP-03 and EXP-01: `expense_createdFromRule` "Created from recurring rule", `expense_ruleDeleted` "Recurring rule deleted", `expense_recurringLabel` "Recurring".
- [X] T077 [US3] Extend `lib/features/expense/presentation/controllers/transaction_form_controller.dart` and `transaction_form_state.dart` (contracts/screens.md, research R16):
  - `FormMode { create, edit, ruleEdit }`, `ruleId`, `RepeatState`, and `linkedToRule`.
  - The intents `toggleRepeat`, `setFrequency`, `setEndDate`, and `clearEndDate`.
  - Rule-edit loading.
  - The save branches (new + repeat, edit + repeat, rule-edit, rule-edit with repeat off), each returning the correct Undo.
  - The budget check (T058) still runs for created or updated expenses.

  Make T064 pass.
- [X] T078 [US3] Create `lib/features/expense/presentation/widgets/repeat_section.dart` (a switch, a `ChipSelector` for frequency, an end-date chip using the existing date picker flow, the schedule in words via `RecurrenceSchedule.describe()` + ARB, and a `FieldError`). Embed it in `lib/features/expense/presentation/screens/transaction_form_screen.dart` above Save, hidden when `linkedToRule`. In rule-edit mode, also apply the title and label changes and hide the receipt field and the delete icon. Make T065 pass.
- [X] T079 [US3] Add the recurring routes in `lib/app/router/routes.dart`, before `:id`: `expenseRecurring` `/expenses/recurring`, `expenseRecurringAdd` `/expenses/recurring/add` (EXP-02 new with Repeat on, root navigator), and `expenseRuleEdit` `/expenses/recurring/:ruleId/edit` (EXP-02 rule-edit, root navigator), plus the helper `expenseRuleEditPath`. Register them in `lib/features/expense/expense_module.dart`, and extend the route tests in `test/features/expense/expense_module_test.dart`.
- [X] T080 [US3] Implement EXP-10:
  - `lib/features/expense/presentation/controllers/recurring_controller.dart` and its state.
  - `lib/features/expense/presentation/widgets/recurring_row.dart` (`Dismissible` swipe actions + long-press menu, the "Ended" and stale lines).
  - `lib/features/expense/presentation/screens/recurring_screen.dart` (Active and Paused sections, FAB "Add recurring transaction" hidden in the empty state, all 4 states).

  Make T066 pass.
- [X] T081 [US3] Update EXP-01 and EXP-03:
  - `lib/features/expense/presentation/widgets/transaction_row.dart`: a 16 dp `Icons.repeat` with the semantic label `expense_recurringLabel` when `isRecurring`, without changing the row height.
  - `lib/features/expense/presentation/screens/transactions_screen.dart`: add "Recurring" to the overflow.
  - `lib/features/expense/presentation/screens/transaction_detail_screen.dart` and its controller: the "Created from recurring rule" link (or the deleted text, using `recurringRuleRepositoryProvider.findById`).

  Make T067 pass.

**Checkpoint**: US1–US3 work. Recurring entries are generated exactly once, both from app open and
from the background job.

---

## Phase 6: User Story 4 - Understand spending with free reports (EXP-11 Overview and Categories) (Priority: P2)

**Goal**: EXP-11 with a period selector and the Overview and Categories tabs, free for the current
and previous month and for overlapping weeks (Q1). Totals match EXP-01, and charts are drawn from
controller-built view models.

**Independent Test**: With fixed transactions across several months, categories, accounts, and
payment modes, open Reports for the current and previous month. Every figure and chart total equals
the EXP-01 summary strip for the same period, and selecting a slice lists exactly that category's
transactions.

### Tests for User Story 4 ⚠️

- [X] T082 [P] [US4] Write `test/features/expense/domain/report_access_test.dart`, covering the full Q1 matrix from contracts/repositories.md "ReportAccess":
  - Current and previous month are free on Overview and Categories, and advanced on Trends and Accounts.
  - Two months back → advanced.
  - A future month → advanced; a week entirely in next month → advanced; a week spanning the end of the current month → free.
  - A week spanning the previous month's first day → free; a week entirely before it → advanced.
  - A week containing today → free.
  - Year and Custom → advanced on every tab.
  - Use a fixed `now` of 15 Oct 2026 and of 1 Jan 2027 (previous month = December 2026 across the year boundary).
- [X] T083 [P] [US4] Write `test/features/expense/presentation/report_view_models_test.dart` (pure builders; research R12):
  - `OverviewVm`: net, savings rate ("—" when income is 0, rounded half-up), average daily spend over the elapsed days of the current period and all days of a past period, null for a future period, and the top 3 with share percents.
  - `DonutVm`: sorted descending; percents sum to 100 ± rounding; merged into "Other" only when there are > 8 slices and a slice < 2%; "Other" carries its member category ids; `selectedId` handling, including selecting "Other".
- [X] T084 [P] [US4] Write `test/features/expense/presentation/reports_controller_test.dart` (fake repositories, fake gate, `MutableClock`):
  - **EXP-11 criterion "Chart totals match the EXP-01 summary strip for the same period"**: for month, week, year, and custom periods, `OverviewVm` income, expense, and net and the `DonutVm` total equal `FakeTransactionRepository.watchLedger` for the same `TxnQuery` (the same fixture the EXP-01 summary-strip test uses).
  - The default period is the current month and the tab Overview.
  - `selectSlice` loads that category's transactions, newest first; selecting "Other" loads the transactions of all its member categories.
  - `refresh` re-subscribes.
  - `locked` is derived from `ReportAccess` and the gate.
- [X] T085 [P] [US4] Write `test/features/expense/presentation/reports_screen_test.dart` (free tabs; US4 scenarios 1–7):
  - The period selector offers Week, Month, Year, and Custom (no Day).
  - The tabs and their order.
  - Overview cards and the income-vs-expense chart, with a semantics summary.
  - The Categories donut with a legend (name, amount, %); tapping a legend row highlights it and lists its transactions; tapping one → EXP-03.
  - The empty period state "No transactions in October" with "Add expense".
  - Pull to refresh.
  - No "Export this report" and no ad widgets.
  - Loading and error states.
  - 200% font scale at 360 dp.

### Implementation for User Story 4

- [X] T086 [P] [US4] Implement `lib/features/expense/domain/usecases/report_access.dart` (`enum ReportTab { overview, categories, trends, accounts }` and `bool requiresAdvanced(ReportTab, Period, DateTime now)`). Make T082 pass.
- [X] T087 [P] [US4] Implement `lib/features/expense/presentation/controllers/report_view_models.dart` (pure Dart, **no `fl_chart` import**):
  - `OverviewVm`, `DonutVm`/`DonutSlice`, `TrendVm`/`TrendPoint`, and `BarsVm`/`BarItem` (`freezed`).
  - The builders `buildOverview(PeriodLedger, ExpenseBreakdown, Period, DateTime now)` and `buildDonut(ExpenseBreakdown, categories, selectedId)`.

  Make T083 pass. `TrendVm` and `BarsVm` builders are added in T096.
- [X] T088 [P] [US4] Add the report strings (en/hi/gu) to `tool/l10n/phase0_strings.py`:
  - Screen and tabs: `expense_reportsTitle` "Reports", `expense_reportTabOverview` "Overview", `expense_reportTabCategories` "Categories", `expense_reportTabTrends` "Trends", `expense_reportTabAccounts` "Accounts".
  - Overview: `expense_reportNetSavings` "Net savings", `expense_reportSavingsRate` "Savings rate", `expense_reportSavingsRateValue` "{percent}%", `expense_reportNoValue` "—", `expense_reportAvgDaily` "Average daily spend", `expense_reportTopCategories` "Top categories", `expense_reportIncomeVsExpense` "Income vs expense", `expense_reportShare` "{percent}% of spending", `expense_reportOther` "Other".
  - Chart summaries: `expense_reportChartSummaryDonut` "Expense by category: {items}", `expense_reportChartSummaryBar` "Income {income}, expense {expense}".
  - Empty state: `expense_reportEmpty` "No transactions in {period}".
- [X] T089 [US4] Implement `lib/features/expense/presentation/controllers/reports_controller.dart` and `reports_state.dart` (contracts/screens.md EXP-11):
  - It watches `watchLedger` and `watchBreakdown` for `TxnQuery(period)` and `featureGate.watch(FeatureKey.advancedReports)`.
  - It derives `locked` and builds the view models for the active tab.
  - It does not subscribe to the data streams while the tab is locked.

  Make T084 pass.
- [X] T090 [P] [US4] Create the free-tab chart widgets in `lib/features/expense/presentation/widgets/charts/`:
  - `income_expense_bar.dart` (`BarChart`, 2 bars with value labels, `income`/`expense` token colors, plus sign and text labels).
  - `category_donut.dart` (`PieChart` with `centerSpaceRadius`, selected-slice offset, colors from the category color keys via `AppColors`, a `Semantics` summary).

  Each maps its view model 1:1 and does no arithmetic, sorting, or grouping.
- [X] T091 [US4] Implement `lib/features/expense/presentation/screens/reports_screen.dart` (EXP-11):
  - A `PeriodSelector` with Day hidden. Add an `allowedKinds` parameter to `lib/core/widgets/period_selector.dart` and `lib/core/widgets/period_picker_sheet.dart`, with tests in `test/core/widgets/period_picker_sheet_test.dart`.
  - A `TabBar`.
  - The Overview tab (`SummaryCard`s, `IncomeExpenseBar`, top 3 rows).
  - The Categories tab (`CategoryDonut`, a legend list, the selected category's `TransactionRow`s → EXP-03).
  - `RefreshIndicator`, all 4 states, `bannerSlot: null`.
  - Trends and Accounts show a temporary placeholder body until US5.

  Make T085 pass.
- [X] T092 [US4] Add the route `expenseReports` `/expenses/reports` in `lib/app/router/routes.dart` (before `:id`), register it in `lib/features/expense/expense_module.dart`, and add "Reports" to the EXP-01 overflow in `lib/features/expense/presentation/screens/transactions_screen.dart`. Extend the route and overflow tests.

**Checkpoint**: US1–US4 work. The free reports match EXP-01.

---

## Phase 7: User Story 5 - Advanced reports behind a feature gate (EXP-11 Trends, Accounts, Year, Custom; FeatureGate) (Priority: P3)

**Goal**: The Trends and Accounts tabs. Locked content shows a blurred overlay with only a
disabled "Get Pro" button, and locked periods show a lock icon. A dev-only "Unlock all features"
switch.

**Independent Test**: With a fake gate (locked, unlocked, expired), check which tabs and periods
are locked, that the overlay shows only a disabled "Get Pro", that unlocking shows the real charts
with totals matching EXP-01, and that the dev switch exists in dev and never in prod.

### Tests for User Story 5 ⚠️

- [X] T093 [P] [US5] Extend `test/features/expense/presentation/report_view_models_test.dart`:
  - `TrendVm`: daily points for week, month, and custom; monthly points for year (12, from the day totals); the previous period has the same length (custom → the immediately preceding range of the same day count); `maxY` rounded up to a nice step; months of different lengths aligned by day index.
  - `BarsVm`: by account and by payment mode, sorted descending, with sums equal to the breakdown total.
- [X] T094 [P] [US5] Extend `test/features/expense/presentation/reports_screen_test.dart` with the locked and advanced cases:
  - **EXP-11 criterion "Locked tabs show a blurred preview and a 'Watch an ad to unlock for 24 hours' button"** (partial; plan Complexity Tracking): with the gate locked, Trends and Accounts show `LockedFeatureOverlay` with blurred **sample** content (no user amounts in the tree), the lock badge, the message "Advanced reports are part of Pro.", a **disabled** "Get Pro", and **no** "Watch an ad". Name the test `EXP-11 locked tabs show blurred preview (watch-ad button deferred to feature 008)`.
  - Locked tabs show a lock icon in the `TabBar`.
  - Year, Custom, a month 2 back, and an old week show a lock icon in the picker; selecting one shows the overlay on every tab (Q1).
  - With the gate unlocked, the Trends line chart shows a solid current line and a dashed previous line, with a legend naming both; the Accounts tab shows two bar charts with value labels.
  - The gate flipping while open → the overlay appears or disappears without navigation (US5 scenario 8).
  - The chart totals match (the EXP-11 criterion again for Trends and Accounts).
- [X] T095 [P] [US5] Write `test/features/settings/presentation/more_placeholder_screen_test.dart` (US5 scenario 7):
  - With `debugToolsAvailableProvider` true, the "Developer" section and the "Unlock all features (debug)" switch exist, and toggling calls `setDebugUnlockAll`.
  - With it false, the section is absent.
  - Add a `test/app/production_overrides_test.dart` asserting that `FlavorConfig.fromName('prod')` → `debugToolsAvailable` is false, and `dev` → true.

### Implementation for User Story 5

- [X] T096 [US5] Add `buildTrend(PeriodLedger current, PeriodLedger previous, Period)` and `buildBars(ExpenseBreakdown, accounts)` to `lib/features/expense/presentation/controllers/report_view_models.dart`. Extend `reports_controller.dart` to also watch the previous period's ledger on the Trends tab, and the accounts for the Accounts tab. Make T093 pass.
- [X] T097 [P] [US5] Create the advanced chart widgets in `lib/features/expense/presentation/widgets/charts/`:
  - `trend_line.dart`: `LineChart` with two `LineChartBarData`; the previous one uses `dashArray: [6, 4]`; a legend row with both labels; a `Semantics` summary.
  - `breakdown_bars.dart`: a horizontal `BarChart` with value labels and labels from the account names and the `expense_pay*` keys.

  Plain view-model mapping only.
- [X] T098 [P] [US5] Add the advanced report strings (en/hi/gu) to `tool/l10n/phase0_strings.py`: `expense_reportThisPeriod` "This period", `expense_reportPreviousPeriod` "Previous period", `expense_reportByAccount` "By account", `expense_reportByPaymentMode` "By payment mode", `expense_reportChartSummaryTrend` "Spending this period {current}, previous period {previous}", and `expense_reportLockedTab` "{tab}, locked".
- [X] T099 [US5] Finish `lib/features/expense/presentation/screens/reports_screen.dart`:
  - Replace the US4 placeholders with the Trends tab (`TrendLine`) and the Accounts tab (`BreakdownBars` × 2).
  - When `state.locked`, wrap the tab body in `LockedFeatureOverlay(onWatchAd: null, onGetPro: null, message: l10n.premium_advancedReportsMessage, child: <sample chart from fixed placeholder view models>)`.
  - Show lock icons on locked tabs (with the `expense_reportLockedTab` semantics).
  - Pass a `lockedKinds`/`isLocked(Period)` callback to `PeriodSelector`/`PeriodPickerSheet` (extend those shared widgets and their tests) so locked options show a lock icon.

  Make T094 pass.
- [X] T100 [US5] Update `lib/features/settings/presentation/screens/more_placeholder_screen.dart`:
  - Make it a `ConsumerWidget`.
  - When `ref.watch(debugToolsAvailableProvider)` is true, add a "Developer" section with a `SwitchListTile` bound to `settings.debugUnlockAll` → `settingsRepository.setDebugUnlockAll`.
  - Do not import `app/flavor.dart`.

  Make T095 pass.

**Checkpoint**: All 5 user stories work independently.

---

## Phase 8: Polish & Cross-Cutting Concerns

**Purpose**: Goldens, accessibility, performance, the integration flow, design review, and the
spec checkboxes

- [ ] T101 [P] Update and add goldens in `test/goldens/expense_screens_golden_test.dart` (tag `golden`, Linux; light/dark × en/gu):
  - Regenerate EXP-01 (with a recurring row) and EXP-02 (with Repeat on).
  - Add EXP-08 (with budgets at all 3 levels), EXP-11 Overview, and EXP-11 Trends locked.
  - Run `flutter test --tags golden --update-goldens` on Linux and commit the images.
- [X] T102 [P] Extend `test/a11y/font_scale_test.dart` for EXP-08, the EXP-09 sheet, EXP-10, EXP-11 (each tab), and the EXP-02 Repeat section at 200% font scale on a 360 dp screen in en, hi, and gu: no overflow and touch targets ≥ 48 dp. Also check that charts have a `Semantics` label and that budget levels expose text.
- [X] T103 [P] Extend `test/features/expense/data/transaction_perf_test.dart` (tag `perf`, 10,000 rows): save + `BudgetAlertChecker.check` < 100 ms; `watchOverview` first emit < 500 ms; `watchBreakdown` for a year < 500 ms; the Trends inputs (`watchLedger` for the current and previous year, combined) first emit < 500 ms (quickstart §6).
- [ ] T104 Extend `integration_test/expense_flow_test.dart`, using `productionOverrides()` with a fake notification service and a fake background scheduler:
  - Add an expense → it appears on Home → open Reports → the Overview totals equal the EXP-01 summary strip (spec §13 flow).
  - Set a ₹1,000 Food budget → save ₹850 Food → the fake notifier received exactly one 80% alert → save ₹200 → one 100% alert.
  - Create a monthly rule dated 3 months ago → 4 linked rows exist with the repeat icon.

  Run `flutter test integration_test/expense_flow_test.dart --flavor dev`.
- [X] T105 Create `specs/003-budgets-recurring-reports/checklists/design-review.md`. Go through the §15.10 checklist for EXP-08, EXP-09, EXP-10, EXP-11, and the changed EXP-01, EXP-02, EXP-03, and More placeholder, and record each result. Note the deferred items: the EXP-08 native ad and EXP-11 banner (T4.2), and the EXP-11 "Watch an ad" button (feature 008).
- [ ] T106 Run the quality gates and the checks from quickstart.md:
  - `flutter analyze` (0 issues), `dart format --set-exit-if-changed .`, and `flutter test --exclude-tags golden` (green).
  - Coverage: `flutter test --coverage`, then confirm ≥ 80% for `lib/features/expense/domain/`, `lib/features/expense/data/`, and `lib/core/feature_gate/`.
  - The APK size (`flutter build apk --flavor prod --release --split-per-abi`; arm64 < 25 MB; record the size).
  - The quickstart §4 manual smoke test on a device or emulator, including running the background task.
  - On the reference device (plan Performance Goals), open EXP-08 and each EXP-11 tab with 10,000 seeded rows and record the time to first content (SC-004).
- [X] T107 Update `docs/spec.md` §14: check T1.5, T1.6, and T1.7. Leave the EXP-11 "Watch an ad" criterion unchecked and add a note pointing to feature 008. Write the task summary (files changed, tests added, checklist results, open items from plan.md: deep link with lock (T3.1), SET-01 toggles (T3.1), native-speaker review, device background check, and backup of the new tables (T3.2)).

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: none. T002 → T003 → T004(a).
- **Foundational (Phase 2)**: depends on Setup. It blocks all stories.
  - Schema: T006 → T007/T008/T009 → T010 → T011 → T012, T013.
  - T014 is independent. T015 → T016. T017 is independent. T018 → T019 → T020, T021.
  - Gate: T022 → T023 → T024. T019 needs T024 for its gate overrides (they can be added when T024 lands).
  - T025 is independent. T026 → T027. T028 comes after T015/T017/T022/T027.
- **US1 (Phase 3)**: after Foundational.
- **US2 (Phase 4)**: after Foundational. It uses `BudgetRepository` and `markAlertSent` from US1 (T038–T040), so start it after T040. US2 can be tested with `FakeBudgetRepository` only.
- **US3 (Phase 5)**: after Foundational. It is independent of US1 and US2, except:
  - T041 (rollover in `onAppOpen`) is ordered before T075 inside `expense_module.dart`. Without US1, skip the rollover call.
  - The `BudgetAlertChecker` dependency in T074 is optional.
- **US4 (Phase 6)**: after Foundational (needs T027 `watchBreakdown` and the T024 gate).
- **US5 (Phase 7)**: after US4 (it extends the same controller and screen).
- **Polish (Phase 8)**: after all the stories you want to ship.

### Shared files (never [P] with each other)

`tool/l10n/phase0_strings.py` (T005, T042, T056, T076, T088, T098), `lib/features/expense/expense_module.dart`
(T018, T041, T047, T059, T075, T079, T092), `lib/app/router/routes.dart` (T047, T079, T092),
`transactions_screen.dart` (T047, T081, T092), `transaction_form_controller.dart` (T058, T077),
`expense_providers.dart` and `expense_bindings.dart` (T040, T057, T075), `test/features/expense/fakes.dart`
(T028, T040, T057, T075), `period_selector.dart` and `period_picker_sheet.dart` (T045, T091, T099),
`reports_screen.dart` (T091, T099), `report_view_models.dart` (T087, T096).

### Within each story

Tests first (they must fail) → entities → use cases → repository → providers and bindings →
controllers → widgets and screens → routes and entry points.

---

## Parallel Examples

### Phase 2

```text
Task: "T007 recurring_rules_table.dart"   Task: "T008 budgets_table.dart"   Task: "T009 unlocks_table.dart"
Task: "T015 notification_service.dart"    Task: "T017 background scheduler"  Task: "T022 feature gate domain"
Task: "T025 LockedFeatureOverlay change"  Task: "T026 breakdown_test.dart"
```

### User Story 1

```text
Task: "T029 budget_math_test.dart"   Task: "T030 validate_budget_test.dart"   Task: "T031 budget_repository_test.dart"
Task: "T032 budgets_controller_test" Task: "T033 budgets_screen_test"          Task: "T034 budget_sheet_test"
Then: "T035 entities"  "T036 budget_math.dart"  "T037 validate_budget.dart"  "T042 strings"  "T044 card/row widgets"
```

### User Story 3

```text
Task: "T060 recurrence_test"  Task: "T061 validate_transaction repeat"  Task: "T062 repository test"
Task: "T063 generator test"   Task: "T065 form repeat widget test"     Task: "T066 recurring_screen_test"
Then: "T069 entities"  "T070 recurrence.dart"  "T071 validate_transaction"  "T076 strings"
```

### User Story 4 + 5

```text
Task: "T082 report_access_test"  Task: "T083 view model test"  Task: "T084 controller test"  Task: "T085 screen test"
Then: "T086 report_access.dart"  "T087 report_view_models.dart"  "T090 free charts"
US5: "T093" "T094" "T095" in parallel, then "T097 advanced charts" alongside "T096"
```

---

## Implementation Strategy

### MVP first (US1)

1. Phase 1 → Phase 2. **Stop and validate**: the migration test is green, the app starts, and the
   hooks do nothing.
2. Phase 3 (US1). **Stop and validate**: budgets usable end to end (EXP-08/09, copy, rollover).

### Incremental delivery

1. US2 alerts (P1): together with US1, this completes T1.5.
2. US3 recurring (P2): completes T1.6. Run a device check of the background job.
3. US4 free reports (P2), then US5 advanced and gate (P3): completes T1.7.
4. Polish: goldens, a11y, perf, the integration test, design review, and the spec checkboxes.

Following Constitution I ("one task at a time: plan → implement → test → summarize → stop for
review"), the natural review stops are after Phase 2, after US2 (T1.5 done), after US3 (T1.6
done), after US5 (T1.7 done), and after Polish.

---

## Notes

- [P] means a different file with no dependency on an incomplete task. See "Shared files" for files
  that serialize tasks.
- Every task description names a Screen ID, data-model section, or research decision for
  traceability.
- Commit after each task or logical group, with the Screen ID in the commit message.
