# Quickstart: Validate Foundation (Phase 0)

How to prove this feature works from start to finish. Details are in [plan.md](plan.md),
[data-model.md](data-model.md), and [contracts/](contracts/).

## Prerequisites

- Flutter 3.47.x stable (Dart 3.13.x), Android SDK, and an emulator or device on API 24+. To
  check the notification prompt you also need API 33+.
- The project root is a git repository, for CI (see the open items in the plan).

## 1. Quality gates (must all pass)

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze                              # expect: No issues found!
dart format --set-exit-if-changed .          # expect: exit 0
flutter test --exclude-tags golden           # Windows/macOS dev machines
flutter test                                 # Linux / CI: includes goldens
```

Expected: all green. The test names include SYS-01, SYS-02, and SET-06 acceptance criteria (see
step 4).

## 2. Migration harness

```bash
dart run drift_dev make-migrations           # no changes expected; schema v1 dump is up to date
flutter test test/drift/
```

Expected: the v1 schema verifier test passes. `drift_schemas/app_database/drift_schema_v1.json`
is unchanged.

## 3. Flavors install side by side

```bash
flutter run --flavor dev                     # app label "DailyTrack Dev", id ...dailytrack.dev, debug banner
flutter build apk --flavor prod --release && flutter install --flavor prod
```

Expected: both apps appear on the launcher at the same time.

## 4. Acceptance criteria → automated tests (map)

| Criterion | Test file (planned) |
| --- | --- |
| SYS-01 seeds 12 expense + 5 income categories + 1 Cash account exactly once | `test/core/database/seed_runner_test.dart`, `test/app/bootstrap_test.dart` |
| SYS-01 lock on → SYS-03 (`/lock`), lock off → DSH-01 | `test/app/bootstrap_test.dart`, `test/app/router/app_router_test.dart` |
| SYS-01 ads SDK not initialized when Remove Ads purchased | `test/app/bootstrap_test.dart` (mock `AdService`) |
| SYS-02 language persists and applies after restart | `test/features/onboarding/onboarding_screen_test.dart` (`restartTestApp` with a shared `FakeSettingsRepository`), `test/core/settings/settings_repository_test.dart` (real DB reopen), `integration_test/app_smoke_test.dart` (end to end) |
| SYS-02 denying notification permission doesn't block | same file (fake `NotificationPermission` returns false or throws) |
| SYS-02 cannot turn off both modules | same file, plus `test/core/settings/settings_repository_test.dart` (`LastModuleError`) |
| SET-06 disable hides tab and calls `onDisable` | `test/features/settings/modules_screen_test.dart` (fakes) |
| SET-06 disabling keeps data (no rows deleted or soft-deleted) | `test/features/settings/modules_controller_test.dart` (real in-memory DB, unit test) |
| SET-06 at least one module stays enabled; reorder changes tab order | same file |
| Shell: per-tab back stack, back to Home, disabled-module redirect | `test/app/router/app_shell_test.dart` |
| Shared widgets (§15.4) | `test/core/widgets/*_test.dart` + `*_golden_test.dart` |
| §15.10 screen goldens (SYS-01, SYS-02, SET-06; light/dark × en/gu) | `test/goldens/screens_golden_test.dart` (T110) |
| SC-008 a third module needs only a registry entry | `test/app/module_extensibility_test.dart` (T111) |
| SYS-02 save failure keeps choices and offers retry | `test/features/onboarding/onboarding_screen_test.dart` |
| Money / date utils | `test/core/utils/money_formatter_test.dart`, `date_keys_test.dart` |

## 5. Manual smoke test (dev flavor, fresh install)

1. Launch the app. You see the native splash and then the Flutter splash, with no white flash,
   followed by onboarding step 1.
2. Tap **ગુજરાતી**. The text switches to Gujarati right away. Go to step 2. INR is selected, and
   searching "dol" shows US Dollar.
3. On step 3, turn Habit off, then try to turn Expense off. The toggle stays on and a message
   explains why.
4. On step 4, tap "Allow notifications" and deny it. You can still tap "Get started". You land on
   Home, which has 3 tabs (Home, Expenses, More) in Gujarati.
5. Force-stop the app and relaunch. It goes straight to Home, still in Gujarati, with no
   onboarding.
6. Open More → Modules. Enable Habit and drag it above Expense. The tabs now read Home, Habits,
   Expenses, More.
7. Open Expenses, switch to More, and switch back. Expenses is in the same state. Press back on
   Expenses and you return to Home. Press back on Home and the app exits.
8. Set the font size to the largest system setting and repeat steps 1 to 6. Nothing clips or
   overflows.

## 6. CI

Open a pull request. The `ci.yml` jobs (codegen, analyze, format, test, prod App Bundle build) all
pass.
