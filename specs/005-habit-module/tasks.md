---

description: "Task list for Habit Module (Phase 2, T2.1–T2.4)"
---

# Tasks: Habit Module (Phase 2, T2.1–T2.4)

**Input**: Design documents from `specs/005-habit-module/`

**Prerequisites**: [plan.md](plan.md), [spec.md](spec.md), [research.md](research.md), [data-model.md](data-model.md), [contracts/](contracts/), [quickstart.md](quickstart.md)

**Tests**: REQUIRED. Constitution IV and the request ("exhaustive unit tests with an injected
clock") require:
- At least one automated test per acceptance criterion (map in quickstart §5).
- Exhaustive streak tests, including an oracle over ≥ 100 random histories (SC-002).
- ≥ 80% coverage on `lib/features/habit/domain/` and `lib/features/habit/data/`.
- Widget tests with fakes and `NoAdsService`; HAB-01 goldens light/dark × en/gu.

Write each test task first and confirm it fails before its implementation task.

**Organization**: Tasks are grouped by user story (spec.md US1–US7). Test names start with the
Screen ID or `STREAK`/`REMINDER` and the scenario, e.g. `HAB-01 US1-4 toggle deletes entry row`
(Constitution I). US2 (streak engine, P1) comes before US1 (P1) because every screen shows streaks.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an incomplete task)
- **[Story]**: US1–US7 from spec.md. Setup, Foundational, and Polish tasks have no story label.

## Conventions used by every task

- Paths are relative to the repository root `C:\Workspace\DailyTrack`.
- **Strings**: add keys to `tool/l10n/phase0_strings.py` (en, hi, gu together; prefixes `habit_`,
  `notif_`; sentence case; buttons start with a verb; ICU placeholders and plurals, never
  concatenation). Then run `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit
  ARB files by hand.
- **Codegen**: after changing any `@riverpod`, `@freezed`, or Drift file, run
  `dart run build_runner build --delete-conflicting-outputs`.
- **Time**: read time only from `clockProvider` (`package:clock`) or an injected `Clock`/`now`
  parameter. Never call `DateTime.now()` (scan-enforced). Domain day logic uses `LocalDate`
  (research R5).
- **Domain purity**: nothing under `lib/features/habit/domain/` imports `package:flutter`,
  `package:drift`, or `data/` (scan-enforced from T004).
- **Screens**:
  - Use only `AppTokens` and `lib/core/widgets/`, on `AppScaffold` with `bannerSlot: null` (all ads
    out of scope).
  - Every screen has 4 states: `DelayedSkeleton`, `EmptyState`, `ErrorState` (with "Try again" →
    `ref.invalidate`), and content.
  - One `@riverpod` notifier per screen with a `freezed` state (contracts/screens.md).
  - Respect `MediaQuery.disableAnimations`; light haptic on check and successful save only.
  - Status never by color only (check icon, snowflake icon, outline + label).
- **Charts**: `package:fl_chart` only in `lib/features/habit/presentation/widgets/charts/`.
  Controllers build plain view models (research R13).
- **Widget tests**: `pumpTestApp` (`test/helpers/test_app.dart`) with fakes from
  `test/helpers/fakes.dart` and `test/features/habit/fakes.dart`, `MutableClock`, and
  `NoAdsService`. They never open a database and assert no `AppBannerAd`/`AppNativeAd` is in the
  tree (FR-049).
- **Unit tests with real Drift**: `makeRealContainer` (`test/helpers/real_container.dart`) or the
  new `test/features/habit/data/habit_db_fixture.dart`.
- **Goldens**: tag `golden`, Linux only (`flutter test --tags golden --update-goldens`). On Windows
  run `flutter test --exclude-tags golden`.

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Dependency, shared notification id helper, layering guards, shared strings

- [X] T001 Run `flutter pub add timezone:^0.11.2` (research R1) and `flutter pub get`. Confirm `pubspec.lock` changes only `timezone` from transitive to direct.
- [X] T002 Move `stableNotificationId` (FNV-1a, 31-bit) from `lib/features/expense/data/notifications/local_budget_alert_notifier.dart` to the new `lib/core/notifications/notification_ids.dart` with the same doc comment; import it from core in the expense notifier and in `test/features/expense/data/local_budget_alert_notifier_test.dart`. Add `test/core/notifications/notification_ids_test.dart` pinning `stableNotificationId('b1:p80')` to its current value so ids never change.
- [X] T003 [P] Create `test/features/habit/fakes.dart` (empty library with a header comment) and `test/features/habit/data/habit_db_fixture.dart` (opens an in-memory `AppDatabase`, seeds nothing, exposes `db`, `clock` as `MutableClock`, and `close()`), following `test/features/expense/data/expense_db_fixture.dart`.
- [X] T004 Extend `test/core/theme/no_hardcoded_style_test.dart` (contracts/routes_and_module.md "Layering scan") with tests:
  - (a) `lib/features/habit/domain/**` imports no `package:flutter`, `package:drift`, or `/data/`;
  - (b) `lib/features/habit/presentation/**` imports no `/data/`, `package:drift`, `package:share_plus`, `package:flutter_local_notifications`, or `package:timezone`;
  - (c) `package:fl_chart` only under `lib/features/*/presentation/widgets/charts/` (generalize the expense rule);
  - (d) `package:timezone` and `package:flutter_local_notifications` only in `lib/core/notifications/`;
  - (e) `package:share_plus` only in `lib/core/share/`;
  - (f) `app_database.dart` may additionally import `features/habit/data/tables/*_table.dart` and `features/habit/domain/enums.dart`.

  Rules pass trivially until the files exist.
- [X] T005 [P] Add shared strings (en/hi/gu) to `tool/l10n/phase0_strings.py` and regenerate:
  - Channel: `notif_channelHabitReminders` "Habit reminders", `notif_channelHabitRemindersDescription` "Reminders for your habits".
  - Common: `habit_title` "Habits", `habit_quickAddCheckIn` "Check in habit", `habit_streakDays` `{count, plural, one{1 day} other{{count} days}}`, `habit_streakWeeks` `{count, plural, one{1 week} other{{count} weeks}}`, `habit_doneOfTotal` "{done} of {total} done", `habit_undo` "Undo", `habit_loadError` "Couldn't load your habits. Try again.".

**Checkpoint**: existing tests green; new scan rules in place.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Schema v4, domain types and interfaces, settings, core notifications and share,
routes and providers

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

### Domain types (research R5, data-model §2, §5)

- [X] T006 [P] Create `lib/features/habit/domain/enums.dart`: `enum HabitKind { yesNo, count }` and `enum ScheduleType { daily, specificWeekdays, timesPerWeek }` (index order, **append-only**). Add `test/features/habit/domain/enums_test.dart` pinning indexes (`yesNo=0, count=1`; `daily=0, specificWeekdays=1, timesPerWeek=2`).
- [X] T007 [P] Write `test/features/habit/domain/local_date_test.dart`: `fromKey`/`key` round trip; invalid keys throw `FormatException`; `addDays` across month/year ends and 29 Feb; `difference`; `weekday` (1=Mon … 7=Sun); `startOfWeek(firstDayOfWeek)` for 1, 6, 7; `fromDateTime` uses the local calendar date; arithmetic correct across a DST change (use a `DateTime.utc` based assertion).
- [X] T008 [P] Create `lib/features/habit/domain/dates.dart`: immutable `LocalDate` (year, month, day; `==`/`hashCode`/`compareTo`; `fromKey` via `DateKeys.parse`, `key` via `DateKeys.fromLocal`; `fromDateTime(DateTime local)`; `addDays`, `difference`, `weekday`, `startOfWeek(int firstDayOfWeek)`, `isBefore/isAfter`), all arithmetic on `DateTime.utc(y, m, d)` (R5). Make T007 pass.
- [X] T009 [P] Create the freezed entities in `lib/features/habit/domain/entities/` (data-model §5): `habit.dart` (`Habit`), `habit_schedule.dart` (`HabitSchedule` with `type`, `weekdays` `Set<int>` 1–7, `timesPerWeek?`, `target`; plus `weekdaysMask` getter/factory "Mon=1 … Sun=64"), `schedule_version.dart`, `habit_entry.dart`, `entry_snapshot.dart` (incl. `wasLive`, `freezesAvailableBefore`), `habit_history.dart`, `streak_summary.dart` (`current`, `best`, `completionRate` `int?`, `totalCompletions`, `unit` `StreakUnit { days, weeks }`), `day_status.dart` (`enum DayStatus { done, partial, missed, freeze, unscheduled, beforeStart, future, pending }`), `milestone.dart` (`enum Milestone { d7, d21, d30, d50, d100, d365 }` with `value` and `bit`, plus `Set<Milestone> fromMask(int)` / `int toMask(Set)`), `habit_draft.dart`, `habit_template.dart`, `planned_reminder.dart` (`id`, `firstAt` local `DateTime`, `repeat`), `reminder_time.dart` (`hour`, `minute`, `parse('HH:mm')`, `format()`), `day_op.dart` (sealed `DayOp`: `Toggle`, `Increment`, `SetValue(int)`, `SetNote(String?)`, `UseFreeze({required bool allowToday})`, `Restore(EntrySnapshot)`), `day_write_result.dart`.
- [X] T010 [P] Create `lib/features/habit/domain/errors.dart`: `HabitNotFound`, `KindLocked`, `DayNotEditable`, `FreezeNotAllowed`, `NoFreezesLeft`, `HabitValidationFailed(List<HabitFieldError>)`, and `enum HabitFieldError { nameRequired, nameTooLong, targetOutOfRange, unitTooLong, weekdayRequired, timesOutOfRange, tooManyReminders, duplicateReminder, kindLocked }`.
- [X] T011 Create the repository interfaces and port exactly as in contracts/repositories.md: `lib/features/habit/domain/repositories/habit_repository.dart`, `lib/features/habit/domain/repositories/habit_entry_repository.dart`, `lib/features/habit/domain/ports/habit_reminder_scheduler.dart`.

### Schema v4 (research R2, data-model §1, §3)

- [X] T012 [P] Create `lib/features/habit/data/tables/habits_table.dart` (`@DataClassName('HabitRow')`, data-model §3.1): `id` TEXT PK; `name` "1–40 chars after trim" (CHECK `length(trim(name)) BETWEEN 1 AND 40`); `iconKey`; `colorHex`; `kind` `intEnum<HabitKind>`; `targetValue` with CHECK "`(kind = 0 AND target_value = 1) OR (kind = 1 AND target_value BETWEEN 1 AND 9999)`"; `unit` nullable "≤ 20 chars"; `scheduleType` `intEnum<ScheduleType>`; `weekdaysMask` "CHECK `BETWEEN 0 AND 127`"; `timesPerWeek` nullable "CHECK `BETWEEN 1 AND 6`"; `reminderTimes` TEXT default `'[]'`; `remindOnlyIfNotDone` bool default true; `startDateKey` TEXT; `isArchived` bool default false; `archivedAt` nullable int; `sortOrder` int; `freezesAvailable` int default 0 "CHECK `BETWEEN 0 AND 2`"; `celebratedMilestones` int default 0 "CHECK `BETWEEN 0 AND 63`"; `createdAt`, `updatedAt`, nullable `deletedAt`. Index `habits_active_order` on `(deleted_at, is_archived, sort_order)`.
- [X] T013 [P] Create `lib/features/habit/data/tables/habit_schedules_table.dart` (`@DataClassName('HabitScheduleRow')`, data-model §3.2): `id`; `habitId` FK `habits(id)`; `effectiveFromKey`; `scheduleType`, `weekdaysMask`, `timesPerWeek`, `targetValue` with the same CHECKs as `habits` (target CHECK `BETWEEN 1 AND 9999`); `createdAt`, `updatedAt`, `deletedAt`. Index `habit_schedules_habit_from_unique` UNIQUE on `(habit_id, effective_from_key)` WHERE `deleted_at IS NULL`.
- [X] T014 [P] Create `lib/features/habit/data/tables/habit_entries_table.dart` (`@DataClassName('HabitEntryRow')`, data-model §3.3): `id`; `habitId` FK `habits(id)`; `dateKey`; `value` "CHECK `BETWEEN 0 AND 9999`"; `isFreeze` bool default false; `note` nullable "≤ 200 chars"; `createdAt`, `updatedAt`, `deletedAt`. Indexes `habit_entries_habit_date_unique` UNIQUE on `(habit_id, date_key)` (**full**, not partial, research R4) and `habit_entries_date` on `(date_key)`.
- [X] T015 Register `Habits`, `HabitSchedules`, `HabitEntries` in `lib/core/database/app_database.dart`, set `schemaVersion => 4`, update the core→feature import comment (features 001–005), run `dart run drift_dev make-migrations` (creates `drift_schemas/app_database/drift_schema_v4.json` and regenerates `app_database.steps.dart` and `test/drift/app_database/generated/`), then add `from3To4` creating, in order: `habits` + `habits_active_order`; `habit_schedules` + `habit_schedules_habit_from_unique`; `habit_entries` + `habit_entries_habit_date_unique` + `habit_entries_date` (data-model §1).
- [X] T016 Extend `test/drift/app_database/migration_test.dart`: v1→v4, v2→v4, v3→v4 **with data** (settings incl. seed markers, categories, accounts, transactions, budgets, recurring rules, unlocks): every row identical after upgrade; re-seeding inserts 0 rows; the 3 habit tables and 4 indexes exist; `PRAGMA foreign_key_check` empty; schema equals v4 snapshot via `SchemaVerifier`.
- [X] T017 [P] Write `test/features/habit/data/habit_tables_test.dart` (real in-memory DB): each CHECK rejects out-of-range values listed in T012–T014; inserting a second physical entry row for the same `(habit_id, date_key)` fails even when the first is soft-deleted; two live schedule rows with the same `(habit_id, effective_from_key)` fail, but a live + deleted pair succeeds.

### Settings (research R17)

- [X] T018 Add `@Default(true) bool habitRemindersEnabled` to `lib/core/settings/domain/app_settings.dart`, the `habitRemindersEnabled` key to `lib/core/settings/data/settings_codec.dart`, and `setHabitRemindersEnabled({required bool enabled})` to `SettingsRepository`, `SettingsRepositoryImpl`, and `FakeSettingsRepository` in `test/helpers/fakes.dart`. Extend the settings codec/repository tests for default true and round trip.

### Core notifications (research R1, R10, R11; contracts/core_services.md)

- [X] T019 Extend `lib/core/notifications/notification_service.dart`: append `habitReminders` to `NotificationChannelId`; add `enum RepeatInterval { daily, weekly }`, `final class ScheduledNotification { AppNotification notification; DateTime firstAt; RepeatInterval repeat; bool exact; }`, and interface methods `schedule`, `cancel(int id)`, `canScheduleExact()`, `refreshTimeZone()` with doc comments from contracts/core_services.md.
- [X] T020 [P] Create `lib/core/notifications/time_zone_source.dart`: `abstract interface class TimeZoneSource { Future<String?> deviceZoneId(); }` and `MethodChannelTimeZoneSource` over `MethodChannel('dailytrack/timezone')` method `getTimeZone` (returns null on any error); provider `timeZoneSourceProvider` (keep-alive) in `notification_providers.dart`.
- [X] T021 Update `android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/MainActivity.kt`: override `configureFlutterEngine`, register `MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dailytrack/timezone")` answering `getTimeZone` with `java.util.TimeZone.getDefault().id`.
- [X] T022 Update `lib/core/notifications/local_notification_service.dart`: channel id `habit_reminders` in `androidChannelId`; constructor takes a `TimeZoneSource`; `initialize()` also calls `tz_data.initializeTimeZones()` and `refreshTimeZone()`; `refreshTimeZone()` sets `tz.setLocalLocation(tz.getLocation(id))` and returns false if the id is null or unknown; `schedule` maps to `zonedSchedule(id, scheduledDate: tzWallTime(firstAt, tz.local), matchDateTimeComponents: daily → DateTimeComponents.time, weekly → DateTimeComponents.dayOfWeekAndTime, androidScheduleMode: exact ? exactAllowWhileIdle : inexactAllowWhileIdle)`; `cancel` → `_plugin.cancel(id:)`; `canScheduleExact` → Android `canScheduleExactNotifications() ?? false`. Pure mapping helpers (`matchFor(RepeatInterval)`, `scheduleModeFor(bool)`, `tzWallTime(DateTime, tz.Location)` building `tz.TZDateTime(location, y, m, d, h, min)` from the wall-clock fields, never `TZDateTime.from`) are top-level and unit-tested in `test/core/notifications/local_notification_mapping_test.dart`, including a non-UTC location such as `America/New_York` across a DST change; plugin calls stay under `coverage:ignore`.
- [X] T023 Update `android/app/src/main/AndroidManifest.xml` (contracts/core_services.md "Android"): add `RECEIVE_BOOT_COMPLETED` and `SCHEDULE_EXACT_ALARM` permissions; add receivers `com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver` (`exported="false"`) and `com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver` (`exported="false"`) with intent-filter actions `android.intent.action.BOOT_COMPLETED`, `android.intent.action.MY_PACKAGE_REPLACED`, `android.intent.action.QUICKBOOT_POWERON`, `com.htc.intent.action.QUICKBOOT_POWERON`.
- [X] T024 [P] Create `test/android/manifest_test.dart`: parses `android/app/src/main/AndroidManifest.xml` as text/XML and asserts both permissions and both receivers (with the 4 boot actions) are declared (HAB-02 reboot criterion, partial; plan Complexity Tracking).
- [X] T025 Extend `FakeNotificationService` in `test/helpers/fakes.dart`: `Map<int, ScheduledNotification> scheduled` (schedule replaces by id), `List<int> cancelled` (cancel removes from `scheduled`), settable `bool exactAllowed` (default true) and `bool zoneResolvable` (default true) returned by `canScheduleExact`/`refreshTimeZone`.
- [X] T026 Bind the habit channel labels in `lib/app/production_overrides.dart` (`NotificationChannelId.habitReminders` → `notif_channelHabitReminders*`) and pass `MethodChannelTimeZoneSource()` to `LocalNotificationService`.

### Core share (research R12)

- [X] T027 [P] Create `lib/core/share/image_sharer.dart`: `ImageSharer.sharePng(Uint8List png, {required String fileName, String? text})`; `SharePlusImageSharer` writes to `getTemporaryDirectory()/share/<fileName>` and calls `SharePlus.instance.share(ShareParams(files: [XFile(path, mimeType: 'image/png')], text: text))` (coverage-ignored); keep-alive `imageSharerProvider`. Add `FakeImageSharer` (records `fileName`, byte length, `text`) to `test/helpers/fakes.dart`.
- [X] T028 [P] Create `lib/core/widgets/share_capture.dart`: `Future<Uint8List?> captureBoundaryPng(GlobalKey key, {double pixelRatio = 3})` using `RenderRepaintBoundary.toImage` + `toByteData(format: png)`; returns null when the boundary is missing. Test in `test/core/widgets/share_capture_test.dart` (non-null PNG header bytes for a pumped boundary).

### Routes, providers, bindings (research R15; contracts/routes_and_module.md)

- [X] T029 Add to `lib/app/router/routes.dart`: `habitAdd` `/habits/add`, `habitArchived` `/habits/archived`, `habitDetail` `/habits/:id`, `habitEdit` `/habits/:id/edit`, their segments (`add`, `archived` before `:id`), names in `RouteNames`, and helpers `habitAddPath({String? template})`, `habitDetailPath(id)`, `habitEditPath(id)`. Extend `test/app/router/routes_test.dart` for encoding and segment order.
- [X] T030 Create `lib/features/habit/presentation/habit_providers.dart` (keep-alive, throw until overridden): `habitRepositoryProvider`, `habitEntryRepositoryProvider`, `habitReminderSchedulerProvider`; plus the declarations of `streakEngineProvider` (body added in T046) and `habitDayWriterProvider` (body added in T048).
- [X] T031 Create `lib/features/habit/habit_bindings.dart` with `habitOverrides()` (repositories added in T045, real scheduler in T069) and spread it in `productionOverrides()` after `expenseOverrides()` in `lib/app/production_overrides.dart`. Until T069, bind `habitReminderSchedulerProvider` to a `NoopHabitReminderScheduler` (in `lib/features/habit/data/reminders/noop_habit_reminder_scheduler.dart`; every method completes without doing anything, `exactAlarmsAllowed` returns true) so the app never throws on save, archive, or delete at the MVP checkpoint.
- [X] T032 Add fakes to `test/features/habit/fakes.dart`: `FakeHabitRepository` and `FakeHabitEntryRepository` (in-memory, broadcast streams, implement every contract method using the real `StreakEngine` once it exists — until T040 they may return an empty summary), `FakeHabitReminderScheduler` (records `reconcile`, `reconcileAll`, `cancel`, `cancelAll` calls; `exact` flag), and a `habitTestOverrides(...)` helper for `pumpTestApp`.

**Checkpoint**: migration test green, app starts on schema v4, Habits tab still shows the
placeholder, all existing tests green.

---

## Phase 3: User Story 2 - Trustworthy streaks and back-filling (streak engine) (Priority: P1)

**Goal**: A pure-Dart `StreakEngine` and the transactional day write path that every screen uses
(T2.1).

**Independent Test**: Pure domain tests with an injected "today" for every schedule type, goal
type, schedule/target change, freeze, back-fill, start date, and week/month/year boundary match
hand-computed values; the oracle matches on ≥ 100 random histories; repository tests prove the
one-row and compare-and-set invariants.

### Tests for User Story 2 ⚠️ (write first, confirm they fail)

- [X] T033 [P] [US2] Write `test/features/habit/domain/streak_engine_test.dart` (each case with `Clock.fixed`): spec US2 scenarios 1–9 verbatim as test names (`STREAK US2-1 …`); groups:
  - **daily**: done run incl. today; today pending not breaking; gap breaks; partial count day breaks (US2-5); freeze day continues without adding (US2-6); unscheduled-day completions count in total but not streak.
  - **specificWeekdays**: Mon/Wed/Fri run across weekends (US2-4); weekday-only habit Mon–Fri run + weekend = streak kept.
  - **timesPerWeek**: 4 met weeks = 4 (US2-7); current unmet week skipped; unmet past week with freeze keeps streak without adding; unmet past week breaks; week start Monday/Sunday/Saturday.
  - **best**: longest run, ≥ current (US2-9); runs separated by a schedule change.
  - **completion rate (HAB-03 criterion "Completion rate counts only scheduled days")**: last 30 days incl. today; only scheduled days ≥ start; freeze excluded; today counted only if done; whole percent rounded half up; `null` with no countable day; weekly habits by weeks overlapping the window, current week only once met or over.
  - **total completions**: done days ≥ start, scheduled or not.
  - **start date**: days before start are `beforeStart` and never missed; future start → no scheduled days yet.
  - **schedule/target history (R3)**: change from daily to Mon/Wed/Fri mid-run; target raised from 10 to 20 → earlier day with 15 still done; same-day versions (last wins); start date moved earlier than the first version.
  - **boundaries**: month end, year end, 29 Feb, clock at 23:59:59 and 00:00:00 local.
  - **clock moved back**: an entry dated 2 days after today has status `future` and counts toward no statistic (spec Edge Cases).
  - **times per week scheduling (research R6)**: `isScheduledOn` is true for every day ≥ start, also after the week's target is met.
  - **dayStatus** for each `DayStatus` value.
- [X] T034 [P] [US2] Write `test/features/habit/domain/streak_engine_oracle_test.dart`: a deliberately literal reference implementation (walks every calendar day and week from start to today with no shortcuts) and a seeded `Random(42)` generator of ≥ 100 histories (all schedule types, both kinds, random entries/freezes/notes, 0–2 schedule versions, start 0–800 days ago, week start 1/6/7); assert `current`, `best`, `completionRate`, `totalCompletions` equal for every history (SC-002).
- [X] T035 [P] [US2] Write `test/features/habit/domain/freeze_policy_test.dart`: card freezes allowed only on missed days 1–3 before today (HAB-03 criterion "A freeze cannot be applied to today or to a day older than 3 days"); rejected for today (allowToday false), day 4+ back, future, before start, done days, unscheduled "Specific days" days; `available == 0` → `NoFreezesLeft`; Skip today (`allowToday: true`) allowed only when today is scheduled and not done. Times-per-week habits: any not-done day 1–3 back is freezable and Skip today is allowed on any not-done day (research R6).
- [X] T036 [P] [US2] Write `test/features/habit/domain/milestones_test.dart` for `selectNewMilestones`: reaching 7 → show d7; already celebrated d7 → nothing; jump from 5 to 35 → set {d7, d21, d30}, show d30; broken and rebuilt streak with d7 celebrated → nothing; 365 → d365.
- [X] T037 [P] [US2] Write `test/features/habit/data/habit_entry_repository_test.dart` and `test/features/habit/data/habit_repository_test.dart` (real DB, `habit_db_fixture.dart`). The habit repository test covers data-model §7 invariants 1–4, `KindLocked`, schedule versions on same-day edits, archive/`undoArchive` keeping `sortOrder`, restore placing the habit at the end, reorder touching only active habits, and the `addFreeze` cap. The entry repository test covers:
  - HAB-01 criterion "Toggling a yes/no habit creates or deletes the `habit_entries` row for that date key": toggle on → 1 live row with value 1; toggle off → same physical row soft-deleted; toggle 10× → still 1 physical row.
  - Toggle off with a note → row stays live with value 0 and the note.
  - `SetNote` on a day with no entry → live row with value 0, `is_freeze` false, and the note (Add note for today); `SetNote(null)` on that row → soft-deleted.
  - `Increment`/`SetValue` (0 with no note → soft-deleted; > target kept).
  - `UseFreeze` decrements `freezes_available`, sets `is_freeze`; turning a freeze day done refunds one freeze, capped at 2.
  - `Restore(snapshot)` returns entry and freeze count to the exact previous state.
  - `DayNotEditable` for future/before-start dates; `FreezeNotAllowed`/`NoFreezesLeft` propagate.
  - `watchActiveHistories(from:)` returns only live entries ≥ `from` of active habits; `watchHistory` full; `watchNotes` newest first.
  - Back-filling yesterday after a gap restores `current` in the returned `DayWriteResult.summary` (HAB-01 criterion "Back-filling yesterday restores a broken streak", data level).
- [X] T038 [P] [US2] Write `test/features/habit/data/milestone_cas_test.dart`: two concurrent `apply` calls (via `Future.wait`) that both reach 7 → exactly one result carries `Milestone.d7`; the mask has the d7 bit once (HAB-01 criterion "Milestone sheet appears once per milestone per habit", data level).
- [X] T039 [P] [US2] Write `test/features/habit/domain/habit_day_writer_test.dart` with fake repositories: a write on a day in the current week calls `HabitReminderScheduler.reconcile(habitId)` once; a back-fill in an earlier week does not; errors propagate without reconciling.

### Implementation for User Story 2

- [X] T040 [US2] Implement `lib/features/habit/domain/streaks/streak_engine.dart` (research R6): `StreakEngine(Clock clock, {int firstDayOfWeek = 1})`; `scheduleOn(history, date)` (newest version with `effectiveFrom ≤ date`, else oldest); `isScheduledOn`; `dayStatus`; `weekProgress`; `summarize` (current, best in one forward pass, completion rate, total completions, unit). O(days since start). Make T033 and T034 pass.
- [X] T041 [P] [US2] Implement `lib/features/habit/domain/streaks/freeze_policy.dart` (`FreezePolicy.check(...) → FreezeDecision` sealed: `allowed`, `notAllowed(reason)`, `noneLeft`) and `lib/features/habit/domain/streaks/milestones.dart` (`selectNewMilestones`). Make T035 and T036 pass.
- [X] T042 [P] [US2] Create `lib/features/habit/data/mappers/habit_mapper.dart`: `HabitRow` ↔ `Habit` (`reminderTimes` JSON list of `HH:mm`, sorted, distinct; `weekdaysMask` ↔ `Set<int>`; `celebratedMilestones` ↔ `Set<Milestone>`; `startDateKey` ↔ `LocalDate`); `HabitScheduleRow` → `ScheduleVersion`; `HabitEntryRow` → `HabitEntry`. Unit test in `test/features/habit/data/habit_mapper_test.dart`.
- [X] T043 [US2] Create `lib/features/habit/data/daos/habits_dao.dart` and `lib/features/habit/data/daos/habit_entries_dao.dart` (`@DriftAccessor`): queries for active/archived habits in order, versions by habit, live entries since a key (selecting only `habit_id, date_key, value, is_freeze`, research R7), full entries for one habit, notes newest first, physical row by `(habit_id, date_key)` including deleted, and CAS updates `UPDATE habits SET celebrated_milestones = :new WHERE id = :id AND celebrated_milestones = :old` and freeze count updates with `WHERE freezes_available > 0` / `< 2`.
- [X] T044 [US2] Implement `lib/features/habit/data/repositories/drift_habit_entry_repository.dart` (contracts/repositories.md, research R4, R8): `apply` runs one Drift transaction — read snapshot + habit counters → `FreezePolicy` → upsert/soft-delete per data-model §6 table → load history (window from `today − 400 days`, or full when the run reaches the window start) → `StreakEngine.summarize` → `selectNewMilestones` + CAS (retry once on CAS miss with re-read) → `DayWriteResult`. Streams per contract. Make T037 and T038 pass.
- [X] T045 [US2] Implement `lib/features/habit/data/repositories/drift_habit_repository.dart` (create with version 1 effective from start date; update writes/replaces today's version only when schedule or target changed and mirrors it on `habits`, throws `KindLocked` when kind differs; archive sets `archivedAt` from the clock; `undoArchive` clears it keeping `sortOrder`; restore clears it and sets `sortOrder` to max active + 1 (data-model §6); delete soft-deletes habit + schedules + entries in one transaction; reorder rewrites `sortOrder` 0..n-1 of active habits only; `addFreeze` with `< 2` guard returning the new count). Make the T037 habit repository test pass. Bind both repositories in `habitOverrides()` (`lib/features/habit/habit_bindings.dart`).
- [X] T046 [US2] Bind `streakEngineProvider` in `lib/features/habit/presentation/habit_providers.dart` (rebuilt when `firstDayOfWeek` changes) and make the fakes in `test/features/habit/fakes.dart` use the real engine for summaries.
- [X] T047 [US2] Implement `lib/features/habit/domain/usecases/habit_day_writer.dart` (`HabitDayWriter(entries, scheduler, clock, {firstDayOfWeek})`: `write(habitId, date, op)` → `apply`, then `scheduler.reconcile(habitId)` when `date` is in the current week). Make T039 pass.
- [X] T048 [US2] Add `habitDayWriterProvider` to `lib/features/habit/presentation/habit_providers.dart`.

**Checkpoint**: `flutter test test/features/habit/domain test/features/habit/data` green; coverage
of `streaks/` ≥ 95%.

---

## Phase 4: User Story 1 - Create a habit and check it in every day (HAB-01, HAB-02) (Priority: P1) 🎯 MVP

**Goal**: HAB-02 form (without reminders UI, added in US4) and HAB-01 today list with week strip,
check-in, count entry, long-press menu, archive with Undo, reorder, and template empty state.

**Independent Test**: With `MutableClock` and fake repositories: create a yes/no and a count habit
from HAB-02, check them in on several days, confirm entries for the right date keys, progress
header and rings update, back-fill from the previous-week page, and the empty state shows the
6 templates.

### Tests for User Story 1 ⚠️

- [X] T049 [P] [US1] Write `test/features/habit/domain/validate_habit_test.dart` (data-model §5.1): name trimmed 1–40 (`nameRequired`, `nameTooLong`); yes/no target forced 1; count target 1–9,999 (`targetOutOfRange`); unit ≤ 20 (`unitTooLong`); HAB-02 criterion "'Specific days' requires at least one weekday" (`weekdayRequired`); timesPerWeek 1–6 (`timesOutOfRange`); ≤ 3 distinct reminders (`tooManyReminders`, `duplicateReminder`); `kindLocked` when editing with a different kind.
- [X] T050 [P] [US1] Write `test/features/habit/domain/schedule_text_test.dart`: daily → `daily`; Mon/Wed/Fri → ordered weekdays respecting `firstDayOfWeek`; timesPerWeek 3 with 2 done → `timesPerWeek(3, left: 1)`; all 7 weekdays → `daily`.
- [X] T051 [P] [US1] Write `test/features/habit/presentation/habit_form_screen_test.dart` (HAB-02): field order per spec US1-2; template prefill via `/habits/add?template=read` (name "Read", count, 20, "pages", daily); name suggestions appear while typing; "Specific days" with no weekday → Save blocked with inline error (criterion); count target out of range error; goal type read-only in edit mode; Save creates via repository and pops with "Habit saved"; edit changing schedule calls `update` (history kept); overflow Archive (Undo snackbar) and Delete (`ConfirmDialog` naming the history) in edit mode; back with unsaved changes asks "Discard changes?" (US1-13).
- [X] T052 [P] [US1] Write `test/features/habit/presentation/habits_today_controller_test.dart`: week cells for `firstDayOfWeek` 1 and 7; selectable days = today … 7 days back, incl. previous-week page; future disabled; ratios done/scheduled per day; scheduled vs "Not scheduled today" split incl. timesPerWeek listing rule and future start date; `allDoneToday` only for today with ≥ 1 scheduled; streaks from the engine; day rollover on resume resets selection to the new today.
- [X] T053 [P] [US1] Write `test/features/habit/presentation/habits_today_screen_test.dart` (HAB-01):
  - US1-1 empty state with the 6 template chips; chip opens HAB-02 prefilled; FAB opens empty HAB-02.
  - US1-4 / criterion "Toggling a yes/no habit creates or deletes the `habit_entries` row for that date key": tap check → fake repo has a live entry for today's key; tap again → removed + Undo snackbar restores it.
  - US1-5 count: `+` adds 1; long-press opens number entry 0–9,999; reaching target shows done; values above target kept.
  - Criterion "Streak updates immediately after check-in and matches the rules in section 4": flame count updates in the same pump sequence with no reload.
  - Criterion "Back-filling yesterday restores a broken streak": clock on the first day of the week; streak 0; page back; select yesterday; check → streak restored.
  - US1-6 card content (icon, name, schedule text, streak, check control); US1-7/8 strip disabled days with hint; US1-9 "All done for today" banner appears and disappears.
  - SC-001: from the empty state, tapping the "Read" chip then "Save habit" (2 taps) creates the habit.
  - FR-019 with `MediaQuery(disableAnimations: true)`: check-in shows done with no animation running (`tester.hasRunningAnimations` false after one pump).
  - US1-10 long-press menu items; "Add note for today" saves the note on a not-done habit (fake repo has a live value-0 entry with the note); Archive → Undo; Skip today disabled with "No freezes left" when 0 freezes (full Skip behavior in US5).
  - US1-11 reorder mode persists order.
  - Loading skeleton after 300 ms, error state with Try again; no ad widgets.

### Implementation for User Story 1

- [X] T054 [P] [US1] Implement `lib/features/habit/domain/usecases/validate_habit.dart` and `lib/features/habit/domain/usecases/schedule_text.dart` (returns data, not strings). Make T049, T050 pass.
- [X] T055 [P] [US1] Create `lib/features/habit/domain/templates.dart` (research R16): const `habitTemplates` — `drinkWater` (count 8, unit key `habit_unit_glasses`), `read` (count 20, `habit_unit_pages`), `walk` (count 30, `habit_unit_minutes`), `meditate` (count 10, `habit_unit_minutes`), `wakeUpEarly` (yes/no), `study` (count 60, `habit_unit_minutes`); all daily; icon and color keys from the shared sets in `lib/core/theme/app_icons.dart` / `app_colors.dart`.
- [X] T056 [US1] Add US1 strings to `tool/l10n/phase0_strings.py` and regenerate: HAB-01 (`habit_menuArchived` "Archived habits", `habit_menuReorder` "Reorder", `habit_emptyTitle` "Build your first habit", `habit_emptyBody`, `habit_notScheduledToday` "Not scheduled today", `habit_allDone` "All done for today", `habit_menuEdit`, `habit_menuAddNote` "Add note for today", `habit_menuSkipToday` "Skip today", `habit_noFreezesLeft` "No freezes left", `habit_menuArchive` "Archive", `habit_archived` "Habit archived", `habit_unchecked` "Check-in removed", `habit_olderEditsHint` "Edit older days from the habit's page", `habit_valueEntryTitle`, `habit_markDoneLabel` "Mark {name} done", `habit_countLabel` "{name}, {value} of {target} {unit}"), schedule text (`habit_scheduleDaily` "Daily", `habit_scheduleTimesPerWeek` "{times}× per week · {left} left" with plural), templates (`habit_template_*`, `habit_unit_*`), HAB-02 (`habit_addTitle` "New habit", `habit_editTitle` "Edit habit", field labels, `habit_goalYesNo` "Yes / No", `habit_goalCount` "Count", `habit_scheduleEveryDay` "Every day", `habit_scheduleSpecificDays` "Specific days", `habit_scheduleXTimes` "X times per week", `habit_startDate` "Start date", `habit_save` "Save habit", `habit_saved` "Habit saved", errors per `HabitFieldError`, `habit_deleteTitle` "Delete habit?", `habit_deleteBody` "This removes {name} and all its history.", `habit_deleteConfirm` "Delete habit", `habit_discardTitle` "Discard changes?").
- [X] T057 [US1] Implement `lib/features/habit/presentation/controllers/habit_form_controller.dart` + `habit_form_state.dart` (contracts/screens.md HAB-02; reminders fields present but UI in US4): `load(id/templateId)`, setters, `save()` (validate → create/update → `HabitReminderScheduler.reconcile`), `archive()` (its Undo snackbar calls `undoArchive()` → `HabitRepository.undoArchive`, keeping the sort position, never `restore`), `delete()` (also `scheduler.cancel`), `dirty` tracking.
- [X] T058 [US1] Implement `lib/features/habit/presentation/screens/habit_form_screen.dart` and widgets `lib/features/habit/presentation/widgets/schedule_section.dart` (segmented schedule; weekday `ChipSelector` ordered by `firstDayOfWeek`; 1–6 stepper), name field with template suggestions, icon/color pickers (`IconPickerGrid`, `ColorPickerRow`), goal type segmented (read-only in edit), count target + unit, start date with Today/Yesterday chips (§15.5), sticky "Save habit" above the keyboard, edit overflow Archive/Delete, discard guard. Make T051 pass.
- [X] T059 [US1] Implement `lib/features/habit/presentation/controllers/habits_today_controller.dart` + `habits_today_state.dart` (contracts/screens.md HAB-01; research R7 window, R14 paging): watch `watchActive` + `watchActiveHistories(from: today − 400)`; full-history fallback per habit when a run reaches the window start; methods `selectDay`, `pageWeek`, `toggle`, `increment`, `setValue`, `setNote`, `skipToday` (calls writer with `UseFreeze(allowToday: true)`), `archive`, `undo`, `undoArchive` (repository `undoArchive`), `setReorderMode`, `reorder`; each write returns the `DayWriteResult` to the screen. Make T052 pass.
- [X] T060 [US1] Implement widgets in `lib/features/habit/presentation/widgets/`: `week_strip.dart` (7 `ProgressRing`-style mini rings, previous-week page button, disabled days with semantics hint), `progress_header.dart` ("X of Y done" + `ProgressBarStatus`), `habit_card.dart` (`CategoryAvatar`, name, schedule text, flame + streak, yes/no check button 48 dp or count `+` with long-press), `value_entry_dialog.dart` (0–9,999), `habit_card_menu.dart`, `all_done_banner.dart`, `template_chips.dart`, `note_dialog.dart` (≤ 200 chars with counter).
- [X] T061 [US1] Implement `lib/features/habit/presentation/screens/habits_today_screen.dart` (HAB-01 per spec layout, check animation 150–250 ms + `HapticFeedback.lightImpact` on new done, Undo snackbars, collapsed "Not scheduled today", reorder mode with `ReorderableListView`, FAB → `Routes.habitAdd`, overflow → Archived/Reorder). Make T053 pass.
- [X] T062 [US1] Wire routes in `lib/features/habit/habit_module.dart`: HAB-01 root (replacing the placeholder), `add` and `:id/edit` on the root navigator (full-screen modal like `expenseAdd`), placeholders for `archived` and `:id` filled in US6/US5. Update `test/app/router/app_shell_test.dart` and `test/app/router/disabled_module_redirect_test.dart` to expect `HabitsTodayScreen`, then delete `lib/features/habit/presentation/screens/habits_placeholder_screen.dart`.

**Checkpoint**: MVP — habits can be created, checked in, back-filled, archived, and reordered.

---

## Phase 5: User Story 4 - Get reminded only when it matters (reminders) (Priority: P2)

**Goal**: HAB-02 reminders section and the reminder scheduler with stable ids, "only if not done",
reconcile on every relevant change, and reboot survival (T2.2).

**Independent Test**: With `FakeNotificationService` and `MutableClock`, saving, editing,
checking in, archiving, deleting, and toggling the module produce exactly the expected scheduled
and cancelled ids and first-fire times.

### Tests for User Story 4 ⚠️

- [X] T063 [P] [US4] Write `test/features/habit/domain/plan_reminders_test.dart` (research R10):
  - Daily habit, reminder 07:00, now 06:00 not done → first 07:00 today, repeat daily; now 08:00 → tomorrow 07:00.
  - HAB-02 criterion "'Remind only if not done' suppresses the notification when today's entry already meets the target": done today, now 06:00, flag on → first fire tomorrow 07:00; flag off → today 07:00.
  - Specific days Mon/Thu → 2 notifications per index, weekly repeat, each on the next matching weekday; done today on a Monday skips to next Monday.
  - timesPerWeek with week target met → first fire on the first day of next week (week start 1 and 7).
  - Start date in the future → first fire on/after start date.
  - Ids: `stableNotificationId('habit:<id>:<index>:<weekday 0–7>')`; same input → same ids; `reminderIdsFor` returns 24 distinct ids.
  - 0 reminders → empty list.
- [X] T064 [P] [US4] Write `test/features/habit/data/local_habit_reminder_scheduler_test.dart` (fake service, fake repos, `MutableClock`): `reconcile` cancels all 24 ids then schedules the plan (no duplicates after 3 saves — SC-005); removed reminder index is cancelled; HAB-02 criterion "Reminders fire at the set local time…": `firstAt` hour/minute equal the set time in local wall time and `repeat` correct; `exact` follows `canScheduleExact`; nothing scheduled when `notificationsEnabled`/`habitRemindersEnabled` is off, the OS blocks notifications, or `refreshTimeZone()` returns false (existing schedules left alone); `reconcileAll` covers every active habit only; `cancel`/`cancelAll` cancel every id; text contains only the habit name and ARB encouragement (FR-043); payload is `/habits`.
- [X] T065 [P] [US4] Extend `test/features/habit/presentation/habit_form_screen_test.dart`: "+ Add reminder" up to 3 (button hidden at 3), duplicate time rejected, remove reminder, "Remind me only if not done yet" default on, notifications-denied hint (US4-7), inexact hint when `exactAlarmsAllowed` is false, Save calls `reconcile`.
- [X] T066 [P] [US4] Write `test/features/habit/habit_module_reminders_test.dart`: archive/delete → `cancel(id)`; restore → `reconcile`; `onDisable` → `cancelAll`; `onEnable` and `onAppOpen` → `refreshTimeZone` then `reconcileAll`; check-in today → `reconcile` (US4-3); unchecking today → `reconcile` again restores today's later reminder in the plan.

### Implementation for User Story 4

- [X] T067 [US4] Implement `lib/features/habit/domain/reminders/reminder_ids.dart` (`reminderIdsFor`, `reminderIdFor(habitId, index, weekday)` using core `stableNotificationId`) and `lib/features/habit/domain/reminders/plan_reminders.dart` (`planReminders(Habit, {required DateTime now, required bool doneToday, required bool weekTargetMet, required int firstDayOfWeek})`). Make T063 pass.
- [X] T068 [US4] Add US4 strings and regenerate: `habit_reminders` "Reminders", `habit_addReminder` "Add reminder", `habit_remindOnlyIfNotDone` "Remind me only if not done yet", `habit_reminderLimit` "You can add up to 3 reminders", `habit_reminderDuplicate`, `habit_notificationsOffHint` "Reminders need notification permission", `habit_inexactHint` "Reminders may be a few minutes late", `notif_habitReminderTitle` "{name}", `notif_habitReminderBody` (short encouragement, e.g. "Time for {name}. You've got this.").
- [X] T069 [US4] Implement `lib/features/habit/data/reminders/local_habit_reminder_scheduler.dart` (`HabitReminderScheduler` over `NotificationService`, repositories, `StreakEngine`, settings, `l10nFor(settings.locale)`): per research R10/R11. Bind in `habitOverrides()`. Make T064 pass.
- [X] T070 [US4] Implement `lib/features/habit/presentation/widgets/reminders_section.dart` and add it to `habit_form_screen.dart` (time picker, chips with remove, toggle, hints from `notificationPermissionProvider` and `exactAlarmsAllowed`). Make T065 pass.
- [X] T071 [US4] Implement `onEnable`, `onDisable`, `onAppOpen` in `lib/features/habit/habit_module.dart` (contracts/routes_and_module.md) and the `cancel`/`reconcile` calls in the archive, restore, and delete paths of the controllers (`habit_form_controller.dart`, `habits_today_controller.dart`). Make T066 pass.

**Checkpoint**: reminders scheduled, replaced, suppressed, and cancelled correctly in tests;
manifest test green.

---

## Phase 6: User Story 3 - Celebrate milestones and share the streak (Priority: P2)

**Goal**: Milestone sheet shown once per milestone per habit from any check-in path, with a
"Share streak" image card (T2.3).

**Independent Test**: With `MutableClock`, build a streak to each milestone and confirm one sheet
per milestone per habit (also after a broken and rebuilt streak), and that "Share streak" passes a
PNG to `FakeImageSharer`.

### Tests for User Story 3 ⚠️

- [X] T072 [P] [US3] Write `test/features/habit/presentation/milestone_sheet_test.dart`: HAB-01 criterion "Milestone sheet appears once per milestone per habit" — sheet appears on the check-in reaching 7, 21, 30, 50, 100, 365 (seeded histories) and not on the next day; broken + rebuilt streak shows nothing (US3-2); one back-fill passing several milestones shows the highest only (US3-3); weekly habit sheet says weeks (US3-5); "Share streak" → `FakeImageSharer` received `streak.png` with PNG bytes and no note text (US3-4); "Close" dismisses; animations off respected.

### Implementation for User Story 3

- [X] T073 [US3] Add US3 strings and regenerate: `habit_milestoneTitle` `{count, plural, …}` "{count}-day streak!" and weekly variant, `habit_milestoneBody` encouragement (no guilt, §15.7), `habit_shareStreak` "Share streak", `habit_close` "Close", `habit_shareCardFooter` "Tracked with DailyTrack".
- [X] T074 [P] [US3] Implement `lib/features/habit/presentation/widgets/streak_share_card.dart` (fixed-size card from tokens: `CategoryAvatar` with habit icon/color, name, streak number + unit, app name; no other data).
- [X] T075 [US3] Implement `lib/features/habit/presentation/widgets/milestone_sheet.dart` (`AppBottomSheet`; off-screen `RepaintBoundary` with `StreakShareCard` → `captureBoundaryPng` → `imageSharerProvider.sharePng(fileName: 'streak.png')`) and `showMilestoneSheet(context, habit, milestone)`; call it from `habits_today_screen.dart` when a `DayWriteResult` carries a milestone. Make T072 pass.

**Checkpoint**: HAB-01 criteria all green.

---

## Phase 7: User Story 5 - Review a habit's history and repair a missed day (HAB-03) (Priority: P2)

**Goal**: HAB-03 with stat tiles, calendar, year heatmap, locked weekly chart, notes, and the
freeze card (incl. Skip today and the debug grant) (T2.4).

**Independent Test**: With seeded histories and `MutableClock`: tile values, calendar markings,
heatmap intensities, notes order, freeze rules, the locked/unlocked chart, and the debug button
visibility match expectations; the heatmap builder runs in under 100 ms.

### Tests for User Story 5 ⚠️

- [X] T076 [P] [US5] Write `test/features/habit/presentation/habit_view_models_test.dart` (pure builders, research R13): day map statuses; intensity quarters from `min(value/target, 1)`; heatmap 53×7 aligned to week start for 1 and 7, cells outside the 12-month range empty; calendar month grid incl. leading/trailing blanks; weekly bars for 12 weeks; semantics summary counts.
- [X] T077 [P] [US5] Write `test/features/habit/presentation/habit_view_models_perf_test.dart` (tag `perf`): HAB-03 criterion "Heatmap renders 365 days in under 100 ms (precompute in the controller)" — building the view model for 365 days and for 5 years completes < 100 ms; pumping `YearHeatmap` with a prebuilt model < 100 ms.
- [X] T078 [P] [US5] Write `test/features/habit/presentation/habit_detail_controller_test.dart`: view model built once per history change (counter on the builder); `freezeableDays` = missed days 1–3 back only; `useFreeze` → writer with `UseFreeze(allowToday: false)`; `addDebugFreeze` only when `debugToolsAvailable && debugUnlockAll`; gate stream toggles `advancedReportsUnlocked`.
- [X] T079 [P] [US5] Write `test/features/habit/presentation/habit_detail_screen_test.dart` (HAB-03): section order (US5-1); calendar markings with icons and semantics (US5-2); tap day → edit value/note sheet; future days disabled (US5-3); "Completion rate counts only scheduled days" tile value for a Mon/Wed/Fri habit (criterion); heatmap share → `FakeImageSharer` (US5-4); chart locked shows `LockedFeatureOverlay` with no "Watch an ad" and disabled "Get Pro", unlocked shows the chart (US5-5); notes newest first and empty message (US5-6); freeze card count, use freeze on yesterday → snowflake + streak restored + Undo returns the freeze (US5-7); "A freeze cannot be applied to today or to a day older than 3 days" — today and day 4 not offered (criterion); cap 2 (US5-8); debug button visible only with dev tools + switch on, disabled at 2, absent when `debugToolsAvailable` false (US5-9).
- [X] T080 [P] [US5] Extend `test/features/habit/presentation/habits_today_screen_test.dart` for Skip today (Q1): with 1 freeze and today scheduled not done → today becomes a freeze day, count 0, Undo restores; with 0 → disabled "No freezes left"; checking in after Skip today refunds the freeze.

### Implementation for User Story 5

- [X] T081 [US5] Add US5 strings and regenerate: stat tiles (`habit_statCurrent` "Current streak", `habit_statBest` "Best streak", `habit_statRate` "Completion rate (last 30 days)", `habit_statTotal` "Total completions", `habit_rateNone` "—"), calendar/heatmap semantics (`habit_dayDone`, `habit_dayMissed`, `habit_dayFreeze`, `habit_heatmapSummary` "{done} of {total} days done in the last 12 months"), `habit_shareHeatmap` "Share", `habit_weeklyChartTitle` "Completions per week", `habit_notesTitle` "Notes", `habit_notesEmpty` "No notes yet", freeze card (`habit_freezesAvailable` "Freezes available: {count}", `habit_useFreeze` "Use a freeze", `habit_freezeUsed` "Freeze used", `habit_addFreezeDebug` "Add a freeze (debug)", `habit_freezeCapReached` "You can keep up to 2 freezes"), day edit (`habit_editDayTitle`, `habit_noteHint`).
- [X] T082 [US5] Implement `lib/features/habit/presentation/controllers/habit_view_models.dart` (pure builders) and `lib/features/habit/presentation/controllers/habit_detail_controller.dart` + `habit_detail_state.dart` (contracts/screens.md HAB-03). Make T076–T078 pass.
- [X] T083 [P] [US5] Implement `lib/features/habit/presentation/widgets/charts/weekly_bars_chart.dart` (`fl_chart` `BarChart`, 12 bars, text axis labels, `Semantics` summary) — the only `fl_chart` importer in habit.
- [X] T084 [US5] Implement HAB-03 widgets in `lib/features/habit/presentation/widgets/`: `stat_tiles.dart` (2×2, `headlineSmall` values), `habit_calendar.dart` (month `PageView` back to start date; done fill in habit color + check icon, snowflake for freeze, faint outline + label for missed), `day_edit_sheet.dart` (toggle or value + note ≤ 200), `year_heatmap.dart` (single `CustomPaint` + share via `captureBoundaryPng` + per-month text list for screen readers), `notes_list.dart`, `freeze_card.dart` (count, "Use a freeze" day picker limited to `freezeableDays`, debug button per R9).
- [X] T085 [US5] Implement `lib/features/habit/presentation/screens/habit_detail_screen.dart` (sections in order; weekly chart wrapped in `LockedFeatureOverlay(onWatchAd: null, onGetPro: null, message: premium_advancedReportsMessage)` while `featureGate.watch(FeatureKey.advancedReports)` is false; Edit → `habitEditPath`; milestone sheet on milestone results) and route `/habits/:id` (pushed in branch) in `lib/features/habit/habit_module.dart`; HAB-01 card tap → `habitDetailPath`. Wire Skip today in `habits_today_screen.dart` per T080. Make T079 and T080 pass.

**Checkpoint**: HAB-03 criteria green.

---

## Phase 8: User Story 6 - Archive, restore, and delete habits (HAB-04) (Priority: P3)

**Goal**: HAB-04 archived list with restore and permanent delete (T2.4).

**Independent Test**: Archive and restore habits and confirm list content, reminder reconcile and
cancel calls, and that delete removes the habit everywhere after confirmation.

### Tests for User Story 6 ⚠️

- [X] T086 [P] [US6] Write `test/features/habit/presentation/archived_habits_screen_test.dart`: rows with name, archive date (relative/`EEE, d MMM`), best streak (US6-1); Restore → habit back in HAB-01 at the end of the list, `reconcile` called, snackbar with Undo (US6-2); Delete permanently → `ConfirmDialog` stating all history is removed → gone from HAB-01/HAB-04, `cancel` called (US6-3); empty state (US6-4); entry from HAB-01 overflow.

### Implementation for User Story 6

- [X] T087 [US6] Add US6 strings and regenerate: `habit_archivedTitle` "Archived habits", `habit_archivedOn` "Archived {date}", `habit_bestStreakLabel`, `habit_restore` "Restore", `habit_restored` "Habit restored", `habit_deletePermanently` "Delete permanently", `habit_archivedEmpty` "Archived habits appear here".
- [X] T088 [US6] Implement `lib/features/habit/presentation/controllers/archived_habits_controller.dart` + state (best streak from one-shot full history per habit, research R7) and `lib/features/habit/presentation/screens/archived_habits_screen.dart`; route `/habits/archived` (pushed, declared before `:id`) in `lib/features/habit/habit_module.dart`; HAB-01 overflow "Archived habits" navigates there. Make T086 pass.

---

## Phase 9: User Story 7 - Habits on Home and quick add (HabitModule) (Priority: P3)

**Goal**: The module's Home card and quick-add action; module hooks complete.

**Independent Test**: Render `HabitDashboardCard` and `quickAddAction` with fakes and confirm the
ring, check buttons, count popup, long-press navigation, milestone sheet, and empty state.

### Tests for User Story 7 ⚠️

- [X] T089 [P] [US7] Write `test/features/habit/presentation/habit_dashboard_card_test.dart`: ring "X of Y done today" (US7-1); yes/no tap marks done and ring updates without reload (US7-2); count tap opens popup with "+1" and custom value; long-press opens HAB-03 (US7-3); empty state "Create your first habit" → `/habits/add` (US7-4); milestone sheet on a milestone write.
- [X] T090 [P] [US7] Write `test/features/habit/habit_module_test.dart` (separate from the US4 `habit_module_reminders_test.dart`): `routes` contain the 5 paths with static segments before `:id`; `quickAddAction` = label `habit_quickAddCheckIn`, location `/habits` (US7-5); `backupSection()` is null; `seeders` and `backgroundTasks` empty.

### Implementation for User Story 7

- [X] T091 [US7] Add strings and regenerate: `habit_cardTitle`, `habit_doneTodayRing` "{done} of {total} done today", `habit_cardEmpty` "Create your first habit", `habit_addOne` "+1", `habit_customValue` "Enter value".
- [X] T092 [US7] Implement `lib/features/habit/presentation/controllers/habit_dashboard_controller.dart` + state, `lib/features/habit/presentation/widgets/count_popup.dart`, and `lib/features/habit/presentation/widgets/habit_dashboard_card.dart` (`SummaryCard` + `ProgressRing` + horizontal check buttons 48 dp); set `dashboardCard`, `quickAddAction`, `backupSection` (null) in `lib/features/habit/habit_module.dart`. Make T089 and T090 pass.

---

## Phase 10: Polish & Cross-Cutting Concerns

**Purpose**: Goldens, accessibility, performance, integration flow, design review, device checks,
and spec checkboxes

- [ ] T093 [P] Create `test/goldens/habit_screens_golden_test.dart` (tag `golden`, Linux): HAB-01 with 5 habits (yes/no done, count partial, timesPerWeek, not scheduled, streak) in light/dark × en/gu; HAB-01 empty state light/dark en; HAB-03 light/dark en (locked chart); milestone sheet light/dark en. Run `flutter test --tags golden --update-goldens` on Linux and commit the images.
- [X] T094 [P] Extend `test/a11y/font_scale_test.dart` for HAB-01, HAB-02, HAB-03, HAB-04, the milestone sheet, and the Home card at 200% font scale on a 360 dp screen in en, hi, gu: no overflow, touch targets ≥ 48 dp, semantic labels on check buttons and calendar days, status exposed as text.
- [ ] T095 [P] Create `test/features/habit/data/habit_perf_test.dart` (tag `perf`, real DB with 50 habits × 5 years): day write + engine + result < 100 ms (SC-003); `watchActiveHistories` first emit + HAB-01 controller first data < 500 ms; HAB-03 full history + view model < 500 ms (SC-004).
- [ ] T096 Create `integration_test/habit_flow_test.dart` using `productionOverrides()` with `FakeNotificationService` and a `MutableClock` override: create habit "Read" from the template → check in → streak 1 → advance the clock 2 days → streak broken → back-fill yesterday → streak restored; a reminder was scheduled with the expected id (§13). Run `flutter test integration_test/habit_flow_test.dart --flavor dev`.
- [X] T097 Create `specs/005-habit-module/checklists/design-review.md`: go through the §15.10 checklist for HAB-01, HAB-02, HAB-03, HAB-04, the milestone sheet, and the Home card; record each result. Note deferred items: HAB-01 native and banner ads, HAB-03/HAB-04 banners, HAB-02 interstitial (T4.2/T4.3), "Watch an ad to get a freeze" (T4.4).
- [ ] T098 Run the quality gates and checks from quickstart.md:
  - `flutter analyze` (0 issues), `dart format --set-exit-if-changed .`, `flutter test --exclude-tags golden` (green).
  - Coverage: `flutter test --coverage`, confirm ≥ 80% for `lib/features/habit/domain/` and `lib/features/habit/data/`.
  - APK size (`flutter build apk --flavor prod --release --split-per-abi`; arm64 < 25 MB; record it).
  - Device checks (quickstart §4): reminder at set time; "only if not done" suppression; reboot with a pending reminder on a **prod release** build (plan Open items 2–3); exact vs inexact; share sheet shows the image; HAB-03 heatmap and HAB-01 timings on the reference device (SC-004).
  - Re-check the Play exact-alarm policy (plan Open item 4) and record the outcome in plan.md.
- [ ] T099 Update `docs/spec.md` §14: check T2.1, T2.2, T2.3, T2.4 (HAB-02 reboot criterion only after the T098 device check). Write the task summary: files changed, tests added, checklist results, and open items from plan.md (background check-ins reconcile in T3.4, deep link with lock in T3.1, SET-01 habit reminders toggle in T3.1, habit tables in backups in T3.2, native-speaker review).

---

## Dependencies & Execution Order

### Phase dependencies

- **Setup (Phase 1)**: none. T002 before T019 (shared id helper).
- **Foundational (Phase 2)**: depends on Setup; blocks all stories.
  - Domain: T006 → T007 → T008; T009 needs T006, T008; T010 independent; T011 after T009, T010.
  - Schema: T012/T013/T014 (need T006) → T015 → T016, T017.
  - T018 independent. Notifications: T019 → T020 → T022; T021, T023 → T024 independent of Dart; T025 after T019; T026 after T020, T022.
  - Share: T027, T028 independent.
  - T029 independent; T030 after T011; T031 after T030; T032 after T011, T025.
- **US2 (Phase 3)**: after Foundational. Blocks US1, US3, US5, US6, US7 (all show streaks or write days).
- **US1 (Phase 4, MVP)**: after US2.
- **US4 (Phase 5)**: after US1 (adds to the HAB-02 form and module hooks); `plan_reminders` (T063, T067) can start right after US2.
- **US3 (Phase 6)**: after US1 (sheet shown from HAB-01). Independent of US4.
- **US5 (Phase 7)**: after US1. Independent of US3/US4 except the milestone call in T085 (skip if US3 not done).
- **US6 (Phase 8)**: after US1; uses `reconcile` from US4 (fake-only without it).
- **US7 (Phase 9)**: after US1 (needs the HAB-02 and HAB-03 routes for the empty state and long-press); reuses `showMilestoneSheet` from US3 if present.
- **Polish (Phase 10)**: after all stories to ship.

### Shared files (never [P] with each other)

`tool/l10n/phase0_strings.py` (T005, T056, T068, T073, T081, T087, T091),
`lib/features/habit/habit_module.dart` (T062, T071, T085, T088, T092),
`lib/features/habit/presentation/habit_providers.dart` (T030, T046, T048),
`lib/features/habit/habit_bindings.dart` (T031, T045, T069),
`test/helpers/fakes.dart` (T018, T025, T027), `test/features/habit/fakes.dart` (T032, T046),
`lib/app/production_overrides.dart` (T026, T031),
`habits_today_screen.dart` (T061, T075, T085), `habits_today_controller.dart` (T059, T071),
`habit_form_screen.dart` (T058, T070), `habit_form_screen_test.dart` (T051, T065),
`habits_today_screen_test.dart` (T053, T080), `lib/core/database/app_database.dart` (T015).

### Within each story

Tests first (they must fail) → entities/use cases → repository/data → providers and bindings →
controllers → widgets and screens → routes and module hooks.

---

## Parallel Examples

### Phase 2

```text
Task: "T006 enums"        Task: "T010 errors"            Task: "T012 habits_table"
Task: "T013 schedules"    Task: "T014 entries"           Task: "T018 settings"
Task: "T020 time zone"    Task: "T021 MainActivity.kt"   Task: "T023 manifest" → "T024 manifest test"
Task: "T027 image sharer" Task: "T028 share capture"     Task: "T029 routes"
```

### User Story 2

```text
Task: "T033 engine tests"   Task: "T034 oracle"   Task: "T035 freeze policy tests"
Task: "T036 milestones"     Task: "T037 entry repo tests"   Task: "T038 CAS"   Task: "T039 writer"
Then: "T040 engine"  with  "T041 freeze/milestones"  and  "T042 mapper"
```

### User Story 1

```text
Task: "T049 validate"  Task: "T050 schedule text"  Task: "T051 form screen test"
Task: "T052 today controller test"                 Task: "T053 today screen test"
Then: "T054 use cases"  "T055 templates"  (T056 strings alone)
```

### User Stories 3, 4, 5 after US1

```text
US4: "T063 plan_reminders test" "T064 scheduler test" "T066 module test"
US3: "T072 milestone sheet test" → "T074 share card"
US5: "T076 view models" "T077 perf" "T078 controller" "T079 screen" → "T083 chart"
```

---

## Implementation Strategy

### MVP first (US2 + US1)

1. Phase 1 → Phase 2. **Stop and validate**: migration test green, app starts on v4.
2. Phase 3 (US2). **Stop and validate**: engine + oracle + repository invariants green (T2.1).
3. Phase 4 (US1). **Stop and validate**: create, check in, back-fill, archive end to end.

### Incremental delivery

1. US4 reminders (P2): completes T2.2. Device check of reminders.
2. US3 milestones (P2): completes T2.3.
3. US5 detail (P2) and US6 archived (P3): complete T2.4.
4. US7 Home card and quick add (P3).
5. Polish: goldens, a11y, perf, integration, design review, device checks, spec checkboxes.

Following Constitution I ("one task at a time: plan → implement → test → summarize → stop for
review"), the natural review stops are after Phase 2, after US2 (T2.1), after US1 + US4 (T2.2),
after US3 (T2.3), after US5 + US6 (T2.4), and after Polish.

---

## Notes

- [P] means a different file with no dependency on an incomplete task. See "Shared files" for files
  that serialize tasks.
- Every task names a Screen ID, data-model section, or research decision for traceability.
- Commit after each task or logical group, with the Screen ID in the commit message.
