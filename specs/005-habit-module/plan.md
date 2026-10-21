# Implementation Plan: Habit Module (Phase 2, T2.1–T2.4)

**Branch**: `005-habit-module` | **Date**: 2026-10-18 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/005-habit-module/spec.md`

## Summary

This feature builds the Habit module (`docs/spec.md` §14, T2.1–T2.4) in place of the Phase 0
placeholder:

- **T2.1 Data and streaks**: `habits`, `habit_schedules`, and `habit_entries` tables (schema v4), a
  pure-Dart `StreakEngine` with an injected clock (current and best streak, completion rate over
  scheduled days, weekly streaks, freezes, back-filling, schedule history), and repositories.
- **T2.2 HAB-02 + reminders**: the add/edit form with templates, validation, archive and delete, and
  habit reminders scheduled through the core `NotificationService` with stable IDs, "only if not
  done" by moving the first fire past done days, and reboot rescheduling.
- **T2.3 HAB-01 + milestones**: the today list with week strip (one week of paging for back-fill),
  check-in, count entry, Skip today with a freeze (Q1), archive with Undo, reorder, templates, and
  the milestone sheet with a shareable image card.
- **T2.4 HAB-03 + HAB-04**: stat tiles, calendar, year heatmap (controller-built), locked weekly
  chart (`advancedReports`), notes, freeze card with the dev-only grant button (Q2), and the archived
  list.
- **HabitModule**: routes, Home card (ring + checks), quick-add, reminder hooks, backup stub.

**Approach**:
- Schema v3 → v4 adds 3 tables only (R2); one physical entry row per habit and day (R4).
- Schedule and target changes are versioned from the change date (R3).
- Every day change goes through one transactional write that also handles freezes and milestone
  compare-and-set (R8).
- Reminders are repeating zoned notifications whose first fire skips done days (R10); the device
  zone comes from a 10-line platform channel (R1).
- Heatmap, calendar, and chart data are pure view-model builders run by controllers (R13).

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged)

**Primary Dependencies**:
- Existing: `flutter_riverpod` 3.4 + `riverpod_generator` 4.0, `go_router` 18.0, `drift` 2.35 +
  `drift_flutter` 0.3, `freezed` 4.0, `intl` 0.20, `uuid` 4.6, `clock` 1.1,
  `flutter_local_notifications` 22.3, `share_plus` 13.3, `path_provider` 2.1, `fl_chart` 1.2.
- **New direct** (research R1): `timezone` ^0.11.2 (already transitive).

**Storage**: SQLite through Drift `AppDatabase`, **schema v4**: + `habits`, `habit_schedules`,
`habit_entries`. One new settings key. See [data-model.md](data-model.md).

**Testing**:
- `flutter_test`: unit (pure domain with `Clock.fixed`/`MutableClock`; real in-memory Drift for
  data), widget (fake repositories, `FakeNotificationService`, `FakeImageSharer`, `FakeFeatureGate`,
  `NoAdsService`), Linux goldens.
- `SchemaVerifier` for v1/v2/v3 → v4 with data; a streak oracle over ≥ 100 random histories.
- `integration_test` (§13 habit flow).

**Target Platform**: Android API 24+ (iOS-ready code, not tested)

**Project Type**: Mobile app (single Flutter project)

**Performance Goals** (spec SC-003, SC-004, HAB-03 criterion):
- Check-in write + engine < 100 ms; UI updated within the same frame sequence (< 200 ms).
- HAB-01 and HAB-03 first content < 500 ms with 50 habits × 5 years of entries (host stand-in, same
  thresholds; one manual check on a Snapdragon 6-series / 4 GB device).
- Heatmap model for 365 days < 100 ms.

**Constraints**:
- Offline; no data leaves the device except user-started sharing of the streak or heatmap image.
- No ads anywhere in this feature; banner/native slots not built.
- Local `yyyy-MM-dd` day keys; UTC ms timestamps; soft delete.
- ARB text in en, hi, gu, including reminder text produced without a `BuildContext`.
- 200% font scale and 360 dp width; status never by color only.

**Scale/Scope**:
- 4 screens (HAB-01–04), 1 bottom sheet (milestone), 1 Home card, ~8 dialogs/sheets (value entry,
  day edit, note, freeze picker, confirm).
- 3 new tables; 2 core interfaces extended (notifications, share).
- About 130 new ARB keys × 3 languages.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs in files, tests, commits; spec updated before code | ✅ `docs/spec.md` updated 2026-10-18: Changes line; §4 `habits` columns (`remindOnlyIfNotDone`, `archivedAt`, `freezesAvailable`, `celebratedMilestones`) and the new `habit_schedules` table; streak rules for freezes, unscheduled days, start dates, schedule history; HAB-01 Skip today (Q1); HAB-03 freeze card scope and debug grant (Q1, Q2). Feature spec User Story 7 scenario 5 aligned with the static quick-add location |
| II. Layered, feature-first | presentation → domain only; pure domain; no cross-feature imports; one notifier per screen; registry | ✅ All habit code under `lib/features/habit/{data,domain,presentation}` (user request). `StreakEngine`, `FreezePolicy`, `planReminders` are pure Dart with an injected `Clock`. Reminders reach the plugin only through core `NotificationService`; images through core `ImageSharer`; the chart through `presentation/widgets/charts/`. `stableNotificationId` moves to core so habit does not import expense. One notifier each for HAB-01–04, the Home card, and HAB-02 |
| III. Data integrity & privacy | int values; UTC ms; local date keys; soft delete; migration + test; no egress | ✅ All 3 tables have `deletedAt` and CHECKs; entries soft-delete with one physical row per day (R4); v3→v4 migration tested from v1, v2, v3 with data. Reminder text has only the habit name. Share images are user-initiated and contain only icon, name, streak |
| IV. Test-backed acceptance | ≥ 1 test per criterion; ≥ 80% domain/data; fakes + NoAdsService; HAB-01 goldens | ✅ Map in [quickstart §5](quickstart.md#5-acceptance-criteria--automated-tests); streak unit tests exhaustive with an oracle (constitution names streaks explicitly). HAB-01 goldens light/dark × en/gu. ⚠️ "Reminders fire … after a device reboot" is verified by unit tests of scheduling + manifest declaration + a manual device check; the OS reboot itself cannot run in CI (Complexity Tracking) |
| V. Offline, fast, accessible | tokens/shared widgets; 4 states; 3 languages; 48 dp; 200%; never color only | ✅ Shared `ProgressRing`, `CategoryAvatar`, `ChipSelector`, pickers, `EmptyState`, `ErrorState`, `UndoSnackBar`, `ConfirmDialog`, `AppBottomSheet`, `LockedFeatureOverlay`. Heatmap is one `CustomPaint` with a text summary; calendar marks have icons. Perf tests per SC-003/004. §15.10 per screen |
| VI. Isolated monetization | ads only via AdService; none on forms; rewarded only from PRM-02 | ✅ by exclusion: no ad code; freeze "Watch an ad" not built; debug grant only in dev builds. HAB-01/03/04 banners, HAB-01 native, and the HAB-02 interstitial deferred (Complexity Tracking) |
| VII. Locked stack, YAGNI | §2 packages only; additions justified | ✅ Only `timezone` becomes direct (in §2, user-named). `flutter_timezone` rejected for a 10-line channel (R1). No background job for reminders (R10). Notification actions, ads, Home layout, backup out of scope |

**Result**: PASS. **After Phase 1 design**: PASS. Design choices made to keep principles intact:
`stableNotificationId` moved to core (II), one write path for days (III atomicity), scan rules
extended for `timezone`, `share_plus`, and habit domain purity (II).

## Project Structure

### Documentation (this feature)

```text
specs/005-habit-module/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R18
├── data-model.md        # Phase 1: schema v4, entities, validation, state transitions
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── repositories.md        # Habit domain interfaces, ports, use cases, errors
│   ├── core_services.md       # NotificationService, ImageSharer, settings, database, Android manifest
│   ├── screens.md             # HAB-01/02/03/04, milestone sheet, Home card
│   └── routes_and_module.md   # routes, HabitModule hooks, bindings, scan rules
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
android/app/src/main/
  AndroidManifest.xml                         # + RECEIVE_BOOT_COMPLETED, SCHEDULE_EXACT_ALARM, 2 plugin receivers
  kotlin/com/midexcode/daily/track/dailytrack/MainActivity.kt  # + dailytrack/timezone channel
lib/
  app/
    production_overrides.dart                 # + habitReminders channel labels, ...habitOverrides()
    router/routes.dart                        # + habitAdd, habitArchived, habitDetail, habitEdit
  core/
    database/
      app_database.dart                       # v4, + 3 habit tables, from3To4
      app_database.steps.dart                 # regenerated
    notifications/
      notification_service.dart               # + habitReminders, ScheduledNotification, schedule, cancel, canScheduleExact, refreshTimeZone
      local_notification_service.dart         # + zonedSchedule, tz init
      notification_ids.dart                   # NEW (stableNotificationId moved from expense)
      time_zone_source.dart                   # NEW MethodChannel wrapper
    settings/                                 # + habitRemindersEnabled
    share/image_sharer.dart                   # NEW (+ .g.dart)
    widgets/share_capture.dart                # NEW captureBoundaryPng
  features/expense/data/notifications/local_budget_alert_notifier.dart  # import stableNotificationId from core
  features/habit/
    habit_module.dart                         # real module (routes, card, quick-add, hooks)
    habit_bindings.dart                       # NEW habitOverrides()
    domain/
      enums.dart                              # HabitKind, ScheduleType
      dates.dart                              # LocalDate
      errors.dart
      entities/                               # habit, habit_schedule, schedule_version, habit_entry, entry_snapshot,
                                              #   habit_history, streak_summary, day_status, milestone, habit_draft,
                                              #   habit_template, planned_reminder, reminder_time, day_op, day_write_result
      repositories/{habit_repository,habit_entry_repository}.dart
      ports/habit_reminder_scheduler.dart
      streaks/{streak_engine,milestones,freeze_policy}.dart
      reminders/{plan_reminders,reminder_ids}.dart
      usecases/{validate_habit,habit_day_writer,schedule_text}.dart
      templates.dart
    data/
      tables/{habits,habit_schedules,habit_entries}_table.dart
      daos/{habits_dao,habit_entries_dao}.dart
      mappers/habit_mapper.dart
      repositories/drift_{habit,habit_entry}_repository.dart
      reminders/local_habit_reminder_scheduler.dart
      reminders/noop_habit_reminder_scheduler.dart  # bound until the real scheduler lands (T031 → T069)
    presentation/
      habit_providers.dart                    # (+ .g.dart)
      controllers/                            # habits_today_, habit_form_, habit_detail_, archived_habits_,
                                              #   habit_dashboard_ controllers + states; habit_view_models.dart
      screens/                                # habits_today_screen (HAB-01), habit_form_screen (HAB-02),
                                              #   habit_detail_screen (HAB-03), archived_habits_screen (HAB-04)
      widgets/                                # week_strip, progress_header, habit_card, habit_card_menu,
                                              #   value_entry_dialog, all_done_banner, template_chips,
                                              #   stat_tiles, habit_calendar, day_edit_sheet, year_heatmap,
                                              #   notes_list, freeze_card, milestone_sheet, streak_share_card,
                                              #   habit_dashboard_card, count_popup, schedule_section, reminders_section
      widgets/charts/weekly_bars_chart.dart   # only fl_chart importer in habit
    presentation/screens/habits_placeholder_screen.dart  # DELETED
drift_schemas/app_database/drift_schema_v4.json # NEW
tool/l10n/phase0_strings.py                   # + habit_*, notif_habit*, notif_channelHabitReminders*
test/
  helpers/fakes.dart                          # FakeNotificationService schedule/cancel; FakeImageSharer
  core/notifications/, core/share/            # scheduling mapping, ids, image sharer
  core/theme/no_hardcoded_style_test.dart     # + scan rules (routes_and_module.md)
  android/manifest_test.dart                  # NEW boot receiver + permissions declared
  drift/app_database/migration_test.dart      # + v1/v2/v3 → v4 with data
  features/habit/{domain,data,presentation}/  # see quickstart §5
  goldens/habit_screens_golden_test.dart      # HAB-01 light/dark × en/gu; HAB-03; milestone sheet
integration_test/habit_flow_test.dart         # NEW
```

**Structure Decision**: a single Flutter project following `docs/spec.md` §3, with all habit code
under `lib/features/habit/{data,domain,presentation}` as requested. Additions not named in §3:
`domain/streaks/` and `domain/reminders/` (pure logic grouped by concern), `domain/ports/` (as in
expense), `core/share/image_sharer.dart` and `core/widgets/share_capture.dart` (shared share
plumbing), and `core/notifications/time_zone_source.dart`.

## Implementation order (input for /speckit-tasks)

1. **Pre-work**: `flutter pub add timezone`; move `stableNotificationId` to core; ARB keys then
   `gen-l10n`; scan-rule additions (failing first).
2. **Foundation (blocks all stories)**:
   - Schema v4: tables, `make-migrations`, `from3To4`, migration test with data.
   - Domain: enums, `LocalDate`, entities, errors, repository interfaces, port.
   - Settings `habitRemindersEnabled`.
   - Core notifications: channel, `schedule`/`cancel`/`canScheduleExact`/`refreshTimeZone`,
     `TimeZoneSource`, `MainActivity.kt`, manifest; fakes.
   - Core `ImageSharer` + `captureBoundaryPng`; fake.
   - Routes, `habit_providers.dart`, `habit_bindings.dart`, production overrides.
3. **US2 Streak engine (P1, T2.1)**: `StreakEngine` (table tests → oracle) → `FreezePolicy` →
   `selectNewMilestones` → Drift repositories (`apply` transaction, one-row invariant, CAS) →
   `HabitDayWriter`. **Checkpoint**: engine and data tests green.
4. **US1 Create and check in (P1, T2.2 + T2.3)**: `validateHabit`, templates → HAB-02 form
   (no reminders yet) → HAB-01 list, week strip with paging, progress, check/count, long-press menu,
   archive Undo, reorder, empty state → HAB-01 and HAB-02 criteria. **Checkpoint**.
5. **US4 Reminders (P2, T2.2)**: `planReminders` (exhaustive) → `LocalHabitReminderScheduler` →
   HAB-02 reminders section and hints → reconcile wiring (writer, save, archive, delete, module
   hooks) → manifest test → HAB-02 reminder criteria. **Checkpoint**.
6. **US3 Milestones (P2, T2.3)**: `MilestoneSheet`, `StreakShareCard`, share → milestone criterion.
7. **US5 Detail (P2, T2.4)**: view-model builders + perf test → HAB-03 sections → freeze card,
   Skip today (Q1), debug grant (Q2) → locked chart → HAB-03 criteria. **Checkpoint**.
8. **US6 Archived (P3, T2.4)**: HAB-04 list, restore (reschedule), delete permanently.
9. **US7 Home card + module (P3)**: `HabitDashboardCard`, quick-add, `HabitModule` hooks; delete the
   placeholder screen.
10. **Finish**: goldens (Linux); a11y sweep at 200% and 360 dp; §15.10 in
    `checklists/design-review.md`; perf tests; integration test; device checks (reminders, reboot,
    share); `docs/spec.md` §14 T2.1–T2.4 ticked; task summary.

## Open items (resolve before or during implementation)

1. ✅ **Done 2026-10-18: `docs/spec.md` updated** (Constitution I): §4 habit columns and
   `habit_schedules`, streak rule details, HAB-01 Skip today (Q1), HAB-03 freeze card scope and debug
   grant (Q2), Changes line.
2. **Reboot criterion**: tested by scheduling unit tests + manifest test now; confirmed on a physical
   device (quickstart §4 step 5) before ticking HAB-02's criterion in `docs/spec.md`.
3. **Release shrinking**: confirm the release build keeps the plugin's Gson-based scheduled
   notification storage working (plugin ships consumer ProGuard rules; verify a scheduled reminder
   survives a reboot on a `prod` release build).
4. **Exact alarms on Play**: `SCHEDULE_EXACT_ALARM` is user-granted and not the restricted
   `USE_EXACT_ALARM`; re-check the Play exact-alarm policy and the §13 compliance item before
   release. If it needs a declaration, drop the permission and keep inexact scheduling (the code path
   already exists).
5. **Background check-ins later**: T3.4 (notification "Mark done", home widget) must call
   `HabitReminderScheduler.reconcile` after writing, like `HabitDayWriter` does.
6. **Notification deep link with app lock on** (carried over from feature 003): the `/habits`
   payload is dropped behind `/lock` until T3.1 forwards it.
7. **SET-01 toggle**: `habitRemindersEnabled` has no UI until T3.1.
8. **Backups (T3.2)**: include `habits`, `habit_schedules`, `habit_entries` (with soft-deleted rows
   for the 30-day restore window) and `habitRemindersEnabled`; purge rows deleted > 30 days.
9. **Native-speaker review** of new hi/gu strings, especially plural forms of days/weeks and the
   weekday abbreviations in schedule text.
10. **Play data safety**: `RECEIVE_BOOT_COMPLETED` was already merged from `workmanager` (feature 003
    Open item 9); `SCHEDULE_EXACT_ALARM` collects no data. Answers unchanged.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `core/database/app_database.dart` imports `features/habit/data/tables/*` and `features/habit/domain/enums.dart` (core → feature) | Carried over from features 001–003: Drift needs every table in one `@DriftDatabase` for atomic writes and `SchemaVerifier` | Moving habit tables to core breaks feature ownership; a second database breaks the single migration chain. The scan rule allows only this file |
| HAB-02 criterion "Reminders fire … including after a device reboot" is not fully automated (Constitution IV) | A real OS reboot cannot run in CI | Unit tests prove the schedule and ids; a manifest test proves the boot receiver and permission are declared; the plugin owns re-registration. A manual device check is required before ticking (Open item 2) |
| HAB-01 banner and native ads, HAB-03 and HAB-04 banners, and the HAB-02 post-save interstitial are not built, though §11 lists them | All ads are out of scope (request) | Ads need T4.1 consent and `AdService`; empty slots take no space, so adding them later causes no layout shift |
| "Watch an ad to get a freeze" replaced by a dev-only "Add a freeze (debug)" button | Rewarded ads are out of scope; Q2 chose a debug grant | A dead "Watch an ad" button would break §15.1 "Forgiving"; prod users simply have 0 freezes until T4.4 |
| `habits` gains 4 columns and a new `habit_schedules` table not in the original §4 | HAB-02 "from the change date onward", HAB-04 archive date, per-habit freeze cap, and "once per milestone per habit" need stored state | Recomputing past days with the new schedule contradicts HAB-02; storing milestones or freezes in settings is not per habit. Spec §4 updated first (Open item 1) |
| FR-042 with app lock on: a reminder tap lands on `/lock` and HAB-01 is not opened after unlock | The real SYS-03 lock flow, which owns post-unlock navigation, is built in T3.1 (same gap as feature 003) | A pending-location hand-off built against the placeholder lock screen would be rewritten in T3.1; never bypassing the lock is the safe behavior now. T3.1 is obligated to add forwarding (Open item 6). FR-042 states this explicitly |
| `MainActivity.kt` platform channel for the device time zone | `timezone` cannot read the device zone | `flutter_timezone` is a non-§2 plugin; a 10-line channel avoids a new dependency (R1) |
