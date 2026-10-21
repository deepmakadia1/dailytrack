# Implementation Plan: Foundation (Phase 0)

**Branch**: `001-foundation` | **Date**: 2026-10-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/001-foundation/spec.md`

## Summary

Phase 0 sets up the runnable, tested base for DailyTrack (`docs/spec.md` §14, T0.1–T0.5):

- `dev` and `prod` Android flavors, strict lints, the §3 folder layout, and CI.
- `AppTokens` and the Material 3 theme, plus the 15 shared widgets from §15.4.
- Money and date utilities, and en/hi/gu localization with bundled Noto fonts.
- A Drift `AppDatabase` (v1) with `settings`, `categories`, and `accounts`, and a migration test
  harness. The categories and accounts tables move forward from T1.1, per the clarification.
- The `TrackerModule` contract and registry, with placeholder Expense and Habit modules.
- A `go_router` `StatefulShellRoute` with 4 tabs driven by the module registry.
- Screens SYS-01 Splash (bootstrap, exactly-once seeding, lock routing to a placeholder `/lock`,
  ads gated on `removeAdsPurchased`), SYS-02 Onboarding, and SET-06 Modules.

The approach is Riverpod codegen notifiers per screen, repository interfaces in pure-Dart
`domain/`, Drift in `data/`, and every acceptance criterion tested
([quickstart.md](quickstart.md#4-acceptance-criteria--automated-tests-map)).

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable

**Primary Dependencies**: `flutter_riverpod` 3.4, `riverpod_generator` 4.0, `go_router` 18.0,
`drift` 2.35 + `drift_flutter` 0.3, `freezed` 4.0, `json_serializable` 6.14, `intl` 0.20,
`flutter_local_notifications` 22.3 (permission request only), `uuid` 4.6,
`flutter_native_splash` 2.4, `very_good_analysis` 11.0, `mocktail` 1.0. The full table and
the deferred packages are in [research.md R1](research.md#r1-package-set-for-phase-0).

**Storage**: SQLite through Drift (`AppDatabase` schema v1): `settings` (key-value JSON),
`categories`, `accounts`. See [data-model.md](data-model.md).

**Testing**: `flutter_test` (unit, widget, golden tagged `golden`), `mocktail`, and the Drift
`SchemaVerifier` (`make-migrations`). `integration_test` is set up but has no flows yet; the §13
flows arrive with their features.

**Target Platform**: Android API 24+ (target is the latest Play-required API). The code stays
iOS-ready but is not tested on iOS.

**Project Type**: Mobile app (single Flutter project)

**Performance Goals**: Cold start to Home < 1.5 s on a mid-range device. Settings writes < 100 ms. APK < 25 MB per ABI (Constitution V; checked in T108. Phase 0 adds about 6 Noto TTFs plus a logo, so this sets the size baseline).
Instant locale switch, with no restart.

**Constraints**: Fully offline. No network calls or SDKs that send data in Phase 0. Zero analyzer
warnings. All strings come from ARB. No hard-coded colors outside `app_colors.dart`. 200% font
scale and 360 dp width without overflow.

**Scale/Scope**: 3 real screens (SYS-01, SYS-02, SET-06), 1 lock placeholder, 4 tab
placeholders, 15 shared widgets, 3 tables, 3 locales.

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-checked after Phase 1 design.*

| Principle | Gate | Status |
| --- | --- | --- |
| I. Spec is source of truth | Screen IDs in names and tests; spec updated before code | ✅ with two **pre-implementation spec updates** required (see Open items 1–2) |
| II. Layered, feature-first | `presentation` → `domain` only; pure-Dart domain; no cross-feature imports; modules registered in `app/module_registry.dart`; one Notifier per screen | ✅ One justified deviation: `core/database/app_database.dart` lists feature-owned table classes (Complexity Tracking). There is no app ↔ features import cycle: `moduleRegistryProvider` lives in `core/module/` and is overridden in `main.dart`, and features import nothing from `app/` except the import-free `app/router/routes.dart` (enforced by the T020 scan). |
| III. Data integrity & privacy | int minor units; UTC ms; `deletedAt` on user tables; migration and test for schema v1; no data egress | ✅ No ads, crash, or analytics SDK in Phase 0. PIN is not in scope. |
| IV. Test-backed acceptance | ≥ 1 test per acceptance criterion; ≥ 80% coverage on `domain/` and `data/`; widget tests with fakes and `NoAdsService` | ✅ Map in quickstart §4. Widget tests run through `pumpTestApp` (T059), which overrides the settings repository with `FakeSettingsRepository`, bootstrap with `FakeBootstrap`, ads with `NoAdsService`, and makes `appDatabaseProvider` throw if touched. Real Drift persistence is tested only in unit tests (T039, T073, T074, T087) and the integration test (T103). The constitution's named screen goldens (DSH-01, EXP-01/02, HAB-01) come with those screens. Shared-widget goldens are added now (T093). Because §15.10 applies to every screen (Principle V), SYS-01, SYS-02 and SET-06 also get light/dark × en/gu goldens (T110). |
| V. Offline, fast, accessible | Tokens and shared widgets only; 4 states per screen; ARB in 3 languages; 48 dp targets; 200% font | ✅ The §15.10 checklist runs per screen at task end |
| VI. Isolated monetization | `AdService` interface only; no ads on onboarding or lock | ✅ `NoAdsService` stand-in; no ads SDK added |
| VII. Locked stack, YAGNI | Only §2 packages; additions justified | ✅ Additions: `uuid` (§4 UUID keys), `flutter_native_splash` (named by SYS-01). `permission_handler` and `sqlite3_flutter_libs` rejected (R1). |

**Result**: PASS. After Phase 1 design: PASS, with no new violations. The contracts keep
`domain/` Flutter-free, and `TrackerModule` is placed in `core/module/` as a UI-composition
contract, which §3 allows.

## Project Structure

### Documentation (this feature)

```text
specs/001-foundation/
├── plan.md              # This file
├── research.md          # Phase 0: decisions R1–R13
├── data-model.md        # Phase 1: settings, categories, accounts, seed data, state machines
├── quickstart.md        # Phase 1: validation guide and AC→test map
├── contracts/
│   ├── tracker_module.md   # TrackerModule, Seeder, ModuleRegistry
│   ├── services.md         # SettingsRepository, AdService, NotificationPermission, bootstrap, SeedRunner
│   ├── routes.md           # route table, redirect rules, AppShell
│   ├── app_tokens.md       # AppTokens, shared widgets, utils
│   └── screens.md          # SYS-01, SYS-02, SET-06, /lock placeholder behavior
├── checklists/requirements.md
└── tasks.md             # Phase 2 (/speckit-tasks)
```

### Source Code (repository root)

```text
lib/
  main.dart                          # bootstrap ProviderScope + DailyTrackApp
  app/
    app.dart                         # MaterialApp.router: theme, locale from settings, l10n delegates
    flavor.dart                      # FlavorConfig from appFlavor (dev/prod)
    bootstrap.dart                   # BootstrapResult + bootstrap() (DB, settings, seeding, ads gate, initial route)
    splash/                          # SYS-01: splash_screen.dart, splash_controller.dart
    module_registry.dart             # ONLY registeredModules (the one file importing concrete modules); main.dart overrides moduleRegistryProvider
    router/
      routes.dart                    # all paths + names
      app_router.dart                # GoRouter, redirects, StatefulShellRoute
      app_shell.dart                 # NavigationBar from registry + settings, back handling
  core/
    ads/ad_service.dart              # AdService, NoAdsService
    database/
      app_database.dart              # @DriftDatabase(tables: [Settings, Categories, Accounts]), migrations
      tables/settings_table.dart
      seeding.dart                   # Seeder contract
      seed_runner.dart
      database_provider.dart
    notifications/                   # notification_permission.dart (interface), local_notification_permission.dart (plugin impl), notification_providers.dart
    settings/
      domain/                        # AppSettings (freezed), SettingsRepository, LastModuleError, OnboardingChoices
      data/                          # SettingsRepositoryImpl, SettingsCodec (bound only in main.dart)
      settings_providers.dart        # settingsRepositoryProvider (throws unless overridden), appSettingsProvider; no data/ or Drift imports
    theme/                           # app_colors.dart (only hex), app_tokens.dart, app_theme.dart
    l10n/                            # app_en.arb, app_hi.arb, app_gu.arb; gen/ (generated)
    utils/                           # money_formatter.dart, date_keys.dart, currencies.dart, keypad_expression.dart
    widgets/                         # 15 shared components (§15.4)
    module/
      tracker_module.dart            # TrackerModule, QuickAddAction, BackupSection, ComingSoonModule
      module_registry.dart           # ModuleRegistry, comingSoonModules, moduleRegistryProvider (overridden in main)
    billing/ security/ backup/       # empty folders with README placeholders (later phases)
  features/
    onboarding/{domain,presentation/{screens,widgets,controllers}}   # SYS-02
    lock/presentation/screens/lock_placeholder_screen.dart          # /lock placeholder
    dashboard/presentation/screens/home_placeholder_screen.dart     # DSH-01 placeholder
    expense/
      data/tables/{categories_table,accounts_table}.dart
      data/seed/expense_defaults_seeder.dart
      domain/enums.dart              # CategoryType, AccountType (append-only)
      presentation/screens/expenses_placeholder_screen.dart
      expense_module.dart
    habit/
      presentation/screens/habits_placeholder_screen.dart
      habit_module.dart
    settings/presentation/{screens,controllers}/                    # more_placeholder_screen, modules_screen (SET-06)
    premium/                          # empty (Phase 4)
assets/
  fonts/                             # NotoSans, NotoSansDevanagari, NotoSansGujarati (400, 600)
  branding/logo.png                  # placeholder logo (native + Flutter splash)
drift_schemas/app_database/drift_schema_v1.json
test/                                # mirrors lib/; flutter_test_config.dart loads fonts
  drift/app_database/                # generated SchemaVerifier + migration_test.dart
integration_test/app_smoke_test.dart # launches dev flavor to Home (smoke)
android/app/build.gradle.kts         # productFlavors dev/prod
.github/workflows/ci.yml
l10n.yaml  build.yaml  dart_test.yaml  analysis_options.yaml  pubspec.yaml
```

**Structure Decision**: A single Flutter project following `docs/spec.md` §3 exactly. Two
placements are not named in §3:
- `app/splash/`: SYS-01 is app bootstrap, not a feature.
- `features/expense/data/tables/`: the tables moved forward from T1.1. T1.1 adds DAOs and
  repositories next to them.

The stray `dailytrack/` subfolder (a nested git repo with only `.gitattributes`) is not part of
the app (Open item 3).

## Implementation order (input for /speckit-tasks)

1. **T0.1**:
   - pubspec (packages per R1, fonts, assets, native splash config), `analysis_options.yaml`
     (very_good_analysis), `l10n.yaml`, `build.yaml`, `dart_test.yaml`.
   - Gradle flavors, `FlavorConfig`.
   - Folder skeleton.
   - `ci.yml`.
   - Remove the counter app and `test/widget_test.dart`.
2. **T0.2**:
   - `app_colors` → `AppTokens` → `AppTheme`.
   - Utilities: money, date keys, currencies, keypad expression (unit tests first).
   - ARB files (en/hi/gu) for all Phase 0 strings, including category, currency, and nav keys.
   - The 15 shared widgets with widget tests and goldens.
3. **T0.3**:
   - `settings` table plus the expense `categories`/`accounts` tables, then `AppDatabase` v1.
   - `make-migrations` schema dump and verifier test.
   - `SettingsRepository` domain and implementation, with tests (defaults, corrupt JSON,
     `LastModuleError`, atomic `completeOnboarding`).
   - `Seeder`, `SeedRunner`, `ExpenseDefaultsSeeder`, with exactly-once tests.
4. **T0.4**:
   - `TrackerModule`, Expense and Habit placeholder modules, `ModuleRegistry`.
   - `routes.dart`, `app_router.dart` (redirects), `AppShell`.
   - Placeholder screens (Home, Expenses, Habits, More) and the `/lock` placeholder.
   - Router and shell tests.
5. **T0.5**:
   - `AdService`/`NoAdsService` and `NotificationPermission`.
   - `bootstrap()` and SYS-01 screen tests (all 3 acceptance criteria and the error state).
   - SYS-02 onboarding tests (all 3 criteria and scenarios).
   - SET-06 tests.
   - §15.10 review for each screen.
6. Quality gates (quickstart §1), then the task summary.

## Open items (resolve before or during implementation)

1. **Update `docs/spec.md` §4** with the default category list (research R7). Constitution I
   requires the spec to be updated before code.
2. **Update `docs/spec.md` §SYS-02** to say the currency list is a curated 30-currency ISO 4217
   subset (research R5). The feature spec's Assumption should match.
3. **Git repository**: RESOLVED 2026-10-13 (T002). The user chose `git init` at the project root
   (branch `main`). `dailytrack/.gitattributes` was copied to the root. `dailytrack/` (a nested
   repo with one commit and no remote) is left untouched and listed in `.gitignore`, for the user
   to delete. No remote is configured yet, so CI runs once the repo is pushed to GitHub.
4. **Logo artwork**: a placeholder is used for the native and Flutter splash (R13).
5. **Release signing**: the CI prod bundle uses debug signing until T5.2.

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| `core/database/app_database.dart` imports table classes from `features/expense/data/tables/` (core → feature) | Drift needs one `@DriftDatabase` class that lists every table for a single SQLite file, migrations, and `SchemaVerifier`. §3 puts tables in feature `data/` folders and `AppDatabase` in `core/database/`. | Moving feature tables into `core/` breaks feature ownership, and Water and Period would have to edit `core/` anyway. Separate databases per feature break cross-table transactions and backup consistency. The import is limited to `data/tables/*` files. No feature imports another feature, and `app_database.dart` is the only core file allowed to do this, enforced by an import-scan test. |
| Placeholder screens (Home/DSH-01, Expenses/EXP-01, Habits/HAB-01, More/SET-01, `/lock`/SYS-03) have no Riverpod Notifier (Principle II), implement only content + empty states (Principle V), and have no §15.10 light/dark × en/gu golden tests (Principle V via §15.10) | Phase 0 needs routable tab roots and a lock target so the shell, redirects, and SET-06 can be built and tested. Each placeholder is a temporary stand-in for a screen owned by a later task: EXP-01 → T1.3, HAB-01 → T2.3, DSH-01 → T2.5, SET-01 and SYS-03 → T3.1. The real screen gets its notifier and all four states there. Placeholders load no data, so they have no loading or error condition to show. The §15.10 golden item moves with each screen to its replacing task, where the constitution already requires DSH-01, EXP-01 and HAB-01 goldens (Principle IV). SET-01 and SYS-03 get theirs in T3.1. All other §15.10 items still apply to the placeholders now: tokens only, 200% font scale and 360 dp (T104), touch targets and labels (T104), and ARB strings. Two exceptions keep minimal reactive logic: Home lists `dashboardCard()` from `appSettingsProvider` + `moduleRegistryProvider`, and More links to SET-06. Both are covered by T082/T086. | A per-placeholder notifier with fake loading/error states would be dead code that is deleted when the real screen lands, and its tests would assert behavior the spec never asks for. Placeholder golden baselines would also be thrown away when the real screen replaces them. The deviation ends when each replacing task is done. Each of those tasks MUST remove its placeholder file, which T106 records. |
