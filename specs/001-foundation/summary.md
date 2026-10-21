# Task summary: Foundation (Phase 0)

**Feature**: `specs/001-foundation` · **Updated**: 2026-10-14 · **Status**: implemented. Linux golden baselines,
the first CI run and on-device timing are still open (see "Open items").

## What was built

- **Project base (T0.1)**: `dev`/`prod` Android flavors (they install side by side as "DailyTrack Dev" and
  "DailyTrack"), `very_good_analysis` lints, the §3 folder layout, `.github/workflows/ci.yml`, and bundled Noto
  fonts with the placeholder logo and native splash.
- **Core (T0.2)**: `AppColors`, `AppTokens`, `AppTheme` (Material 3, light and dark), and en/hi/gu ARB files generated
  from `tool/l10n/phase0_strings.py`. Money (`int` minor units, `BigInt` math), date keys, currency table, the keypad
  expression evaluator, and all 16 §15.4 shared widgets.
- **Database (T0.3)**: Drift `AppDatabase` v1 (`settings`, `categories`, `accounts`), the schema dump and
  `SchemaVerifier` test, `SettingsRepository` (atomic `completeOnboarding`, `LastModuleError`), and `SeedRunner` with
  `ExpenseDefaultsSeeder` (12 expense + 5 income categories + Cash, exactly once).
- **Modules and navigation (T0.4)**: `TrackerModule` (with `tabLabel` added in T084), `ModuleRegistry`,
  placeholder Expense and Habit modules, and the go_router `StatefulShellRoute`. Redirect rules 1–6, and a
  registry-driven, settings-ordered `AppShell` with per-tab back stacks and back-to-Home.
- **Screens (T0.5)**: SYS-01 Splash (bootstrap, seeding, lock routing, ads gate, error and Retry), SYS-02 Onboarding
  (4 steps, Skip, save-error Retry), SET-06 Modules (toggle with at least one kept on, drag reorder, onEnable/onDisable,
  Coming soon), the `/lock` placeholder, and four tab placeholders.

## Tests

237 tests pass with `flutter test --exclude-tags golden` on Windows. There are 94 golden cases (58 shared-widget +
36 screen) waiting for Linux baselines, and 2 integration scenarios that passed on the Pixel 8a emulator.

| Area | Files |
| --- | --- |
| Acceptance criteria SYS-01 / SYS-02 / SET-06 | `test/app/bootstrap_test.dart`, `test/app/splash/`, `test/app/router/`, `test/features/onboarding/`, `test/features/settings/` |
| Shell and redirects | `test/app/router/app_shell_test.dart`, `disabled_module_redirect_test.dart`, `redirect_test.dart`, `lock_redirect_test.dart` |
| SC-006 restart persistence | `test/core/settings/settings_repository_test.dart`, `integration_test/app_smoke_test.dart` |
| SC-008 extensibility | `test/app/module_extensibility_test.dart` |
| Accessibility (200%, 360 dp, en/hi/gu, tap targets, labels) | `test/a11y/font_scale_test.dart` |
| Performance | `test/app/bootstrap_perf_test.dart` (first-launch bootstrap < 300 ms in memory) |
| Shared widgets | `test/core/widgets/*_test.dart`, goldens in `test/core/widgets/goldens/` |
| Screen goldens | `test/goldens/screens_golden_test.dart` |

## Quality gates (2026-10-14)

| Gate | Result |
| --- | --- |
| `build_runner build` | ✅ |
| `flutter analyze` | ✅ No issues found |
| `dart format --set-exit-if-changed .` | ✅ 0 changed |
| `flutter test --exclude-tags golden` | ✅ 237 passed |
| `flutter test --tags golden` | ⏳ baselines not generated (Linux only, T102/T110) |
| `make-migrations` | ✅ schema dump and generated helpers unchanged |
| `flutter test integration_test --flavor dev` | ✅ 2 passed (Pixel 8a emulator) |
| Flavors side by side | ✅ `…dailytrack.dev` "DailyTrack Dev" and `…dailytrack` "DailyTrack" both installed |
| Coverage ≥ 80% | ✅ settings 96.3%, database 95.7%, utils 99.1%, expense data 100% |
| APK size < 25 MB per ABI (prod release) | ✅ arm64-v8a 21.0 MB · armeabi-v7a 18.6 MB · x86_64 22.4 MB |

**APK size, top contributors (arm64)**: native libraries 19 MB (Flutter engine, `libapp.so` with 6 MB of Dart AOT
code, of which `package:flutter` is 3 MB and the app itself 165 KB, plus SQLite), `flutter_assets` 1 MB (the six Noto
TTFs compress well, and the MaterialIcons font is tree-shaken to 4 KB), dex 0.4 MB. The fonts were expected to be the
largest assets and they are, but they are small next to the engine. The build warns that the framework references
`CupertinoIcons`; `lib/` doesn't use them, so this is harmless.

**Coverage note**: Drift table declarations (schema DSL that only the code generator reads) and the production-only
`AppDatabase.open()` / `appDatabaseProvider` are marked `coverage:ignore` with a reason. They are exercised by the
migration test and the integration test.

## Checklists

- `checklists/requirements.md`: 16/16.
- `checklists/design-review.md` (§15.10): every item passes for SYS-01, SYS-02 and SET-06 except "light and dark
  goldens", which is waiting for the Linux baselines. The placeholders follow the plan.md Complexity Tracking
  deviation (states and goldens come with their replacing screens).

## Decisions made during implementation

- `TrackerModule.tabLabel(context)` was added: tab labels are "Expenses"/"Habits" while module names are
  "Expense"/"Habit". `contracts/tracker_module.md` is updated.
- New strings (en/hi/gu): `modules_errorMessage`, `common_cancel`, `keypad_backspace`, `keypad_done`,
  `premium_lockedLabel`. **The Hindi and Gujarati wording should be checked by a native speaker.**
- `integration_test` (Flutter SDK) was added as a dev dependency. `lib/main.dart` exposes `productionOverrides()` for it.
- `test/flutter_test_config.dart` also loads the SDK's MaterialIcons font, so goldens show real icons.

## Open items

1. **Golden baselines (T102, T110)**: generate on Linux with `flutter test --tags golden --update-goldens` and
   commit `test/core/widgets/goldens/*.png` and `test/goldens/*.png`. There is no WSL distro on the dev machine
   (`wsl --install -d Ubuntu`), and no GitHub remote for CI yet. Until then, CI's `flutter test --coverage` fails on
   missing goldens.
2. **Cold start on a mid-range device (T105, SC-002 < 1.5 s)**: `flutter run --flavor prod --profile --trace-startup`
   needs a physical device, because profile mode doesn't run on emulators.
3. **Manual smoke test (quickstart §5)**: to be walked through on a device. Most of it is covered by automated
   tests (onboarding, restart, SET-06, back behavior, 200% font).
4. **First CI run (quickstart §6)**: needs a GitHub remote. The repo has no commits yet.
5. **`docs/spec.md` §14**: T0.3 and T0.4 are checked. T0.1 (CI green), T0.2 (shared-widget goldens) and T0.5
   (screen goldens) are checked once items 1 and 4 are done.
6. Carried over from plan.md: placeholder logo artwork (R13), and release signing for the prod bundle (T5.2).
7. Minor: `test/core/widgets/chip_selector_test.dart` logs an off-screen tap warning. The test passes.
