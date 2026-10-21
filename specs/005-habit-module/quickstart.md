# Quickstart & Validation: Habit Module (Phase 2, T2.1–T2.4)

**Feature**: [spec.md](spec.md) · **Plan**: [plan.md](plan.md) · **Data model**: [data-model.md](data-model.md) · **Contracts**: [contracts/](contracts/)

This is a validation guide, not an implementation guide. It lists what to run and what "done" looks
like.

## 1. Quality gates (every task)

```powershell
flutter pub get
dart run build_runner build --delete-conflicting-outputs
python tool/l10n/phase0_strings.py; flutter gen-l10n
flutter analyze                                   # zero issues
dart format --set-exit-if-changed .               # 0 changed
flutter test --exclude-tags golden                # Windows/macOS
flutter test --tags golden                        # Linux/CI only
```

## 2. Dependencies

```powershell
flutter pub add timezone:^0.11.2
```

Expected: `timezone` moves from transitive to direct; no other package changes (research R1).

## 3. Schema change workflow (v3 → v4)

```powershell
dart run drift_dev make-migrations
flutter test test/drift/app_database/migration_test.dart
```

Expected (data-model §1, research R2):
- `drift_schema_v4.json` exists; v1–v3 are unchanged.
- v1→v4, v2→v4, and v3→v4 **with data**: every settings, category, account, transaction, budget,
  recurring rule, and unlock row is identical; seed markers kept (re-seeding inserts 0 rows).
- The 3 habit tables and their 4 indexes exist; `PRAGMA foreign_key_check` is empty.

## 4. Run the app

```powershell
flutter run --flavor dev
```

Manual walkthrough (dev flavor):
1. Habits tab → empty state with 6 template chips → tap "Read" → HAB-02 prefilled → "Save habit".
2. Tap `+` on the card until 20/20 → check animation, haptic, "All done for today".
3. Long-press → Skip today is disabled ("No freezes left"). More tab → turn on "Unlock all features
   (debug)" → open the habit → "Add a freeze (debug)" twice → button disabled at 2.
4. Add a reminder 2 minutes ahead with "Remind me only if not done yet" on; uncheck today → the
   notification arrives; check in → a second reminder for later today does not arrive.
5. Restart the device with a reminder pending → it still fires (device check).
6. Archive from the long-press menu → Undo → archive again → Archived habits → Restore.
7. HAB-03: calendar edits, heatmap share opens the share sheet with an image, weekly chart locked
   (turn the debug switch off) and visible (switch on).

## 5. Acceptance criteria → automated tests

| Criterion (verbatim from `docs/spec.md`) | Test |
| --- | --- |
| HAB-01: Toggling a yes/no habit creates or deletes the `habit_entries` row for that date key. | `test/features/habit/data/habit_entry_repository_test.dart` (one physical row, live/deleted) + `presentation/habits_today_screen_test.dart` |
| HAB-01: Streak updates immediately after check-in and matches the rules in section 4. | `domain/streak_engine_test.dart`, `domain/streak_engine_oracle_test.dart` (≥ 100 histories) + `presentation/habits_today_screen_test.dart` (same frame sequence) |
| HAB-01: Back-filling yesterday restores a broken streak. | `presentation/habits_today_screen_test.dart` (first day of week, previous-week page) + engine table case |
| HAB-01: Milestone sheet appears once per milestone per habit. | `data/milestone_cas_test.dart` (2 concurrent writers) + `presentation/milestone_sheet_test.dart` (7…365, rebuilt streak, multi-pass back-fill) |
| HAB-02: "Specific days" requires at least one weekday. | `domain/validate_habit_test.dart` + `presentation/habit_form_screen_test.dart` |
| HAB-02: Reminders fire at the set local time, including after a device reboot (`RECEIVE_BOOT_COMPLETED` reschedule). | `domain/plan_reminders_test.dart` (times, ids, first fire) + `data/local_habit_reminder_scheduler_test.dart` (fake service) + `test/android/manifest_test.dart` (permission and boot receiver declared) + device check §4 step 5 |
| HAB-02: "Remind only if not done" suppresses the notification when today's entry already meets the target. | `domain/plan_reminders_test.dart` (first fire moves past a done day / met week) + `domain/habit_day_writer_test.dart` (reconcile after write) |
| HAB-03: Completion rate counts only scheduled days. | `domain/streak_engine_test.dart` (rate group) + `presentation/habit_detail_screen_test.dart` (tile) |
| HAB-03: A freeze cannot be applied to today or to a day older than 3 days. | `domain/freeze_policy_test.dart` + `presentation/habit_detail_screen_test.dart` (freeze card offers only days 1–3 back) |
| HAB-03: Heatmap renders 365 days in under 100 ms (precompute in the controller). | `presentation/habit_view_models_perf_test.dart` (builder < 100 ms) + `presentation/habit_detail_controller_test.dart` (view model built once per history change) |

Derived scenarios of User Stories 1–7 each get a widget or unit test named with the screen ID
(e.g. `HAB-04 restore reschedules reminders`). §15.10 results go in `checklists/design-review.md`.

## 6. Performance checks (SC-003, SC-004)

```powershell
flutter test test/features/habit --tags perf
```

Expected on the host stand-in (same thresholds as the mid-range device; checked once on a device):
- Day write + engine + result < 100 ms with 5 years of entries.
- HAB-01 first content < 500 ms with 50 habits × 5 years (window load per research R7).
- Heatmap builder 365 days < 100 ms.

## 7. Goldens

HAB-01 light/dark × English/Gujarati; HAB-03 and the milestone sheet light/dark English. Generated
and compared on Linux only.

## 8. Integration test

```powershell
flutter test integration_test/habit_flow_test.dart --flavor dev
```

Create habit → check in → streak 1 → move the clock a day (test clock override) → back-fill
yesterday → streak restored (§13).

## 9. Done checklist (per task)

- Quality gates in §1 pass.
- Every criterion row in §5 is green.
- §15.10 checklist recorded; 200% font scale and 360 dp checked.
- `docs/spec.md` §14 checkboxes T2.1–T2.4 ticked at the end of the feature.
- Task summary lists files changed, tests added, and open items.
