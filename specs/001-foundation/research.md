# Research: Foundation (Phase 0)

**Feature**: `001-foundation` · **Date**: 2026-10-13 · **Plan**: [plan.md](plan.md)

Toolchain found in the repo: Flutter 3.47.7 (stable), Dart 3.13.5. Android `applicationId` is
`com.midexcode.daily.track.dailytrack`. The project uses Kotlin DSL Gradle and Java 17.

Package versions are the latest stable releases on pub.dev as of 2026-10-13. They are added with
`flutter pub add` and locked in `pubspec.lock`. If the solver picks an older compatible version,
that version wins. These numbers are a starting point, not a hard pin.

## R1. Package set for Phase 0

**Decision**: Add only the §2 packages that Phase 0 actually uses, plus three small packages,
each justified below.

| Package | Version | Use in Phase 0 | Source |
| --- | --- | --- | --- |
| `flutter_riverpod` | ^3.4.3 | State + DI | §2 |
| `riverpod_annotation` / `riverpod_generator` (dev) | ^4.0.7 / ^4.0.9 | Codegen notifiers | §2 |
| `go_router` | ^18.0.2 | Routing, `StatefulShellRoute` | §2 |
| `drift` / `drift_flutter` / `drift_dev` (dev) | ^2.35.2 / ^0.3.1 / ^2.35.1 | DB, connection, schema tools | §2 |
| `freezed` (dev) / `freezed_annotation` | ^4.0.2 / ^3.1.0 | Immutable state + entities | §2 |
| `json_serializable` (dev) / `json_annotation` | ^6.14.1 / ^4.12.0 | Settings JSON values | §2 |
| `build_runner` (dev) | ^2.16.2 | Codegen | §2 (implied) |
| `flutter_localizations` (sdk) + `intl` | sdk / ^0.20.3 | gen-l10n, number/date formatting | §2 |
| `flutter_local_notifications` | ^22.3.2 | **Only** the Android 13+ `POST_NOTIFICATIONS` request in SYS-02 | §2 |
| `very_good_analysis` (dev) | ^11.0.0 | Lints, zero-warnings policy | §2 |
| `mocktail` (dev) | ^1.0.5 | Fakes/mocks | §2 |
| `flutter_native_splash` | ^2.4.8 | Android 12+ native splash, no white flash. A runtime dependency, because `lib/` calls `preserve`/`remove` | Named in SYS-01 |
| `uuid` | ^4.6.0 | TEXT UUID primary keys (§4) | Added, justified |
| `sqlite3` (dev, transitive pin only if needed) | ^3.7.0 | Native SQLite for host-side DB tests | Transitive via drift |

**Deferred to their phases (not added now)**: `google_mobile_ads`, `in_app_purchase`,
`workmanager`, `timezone`, `local_auth`, `flutter_secure_storage`, `fl_chart`, `google_sign_in`,
`googleapis`, `file_picker`, `share_plus`, `csv`, `pdf`, `printing`, `home_widget`, Firebase.

**Rationale**: Constitution VII (YAGNI). Each deferred package brings native setup such as
manifest entries, Firebase config, or AdMob app IDs. That setup belongs to the task that uses it.

**Alternatives considered**:
- `permission_handler` for the notification prompt. Rejected because it adds a package outside
  §2, and `flutter_local_notifications` (in §2) already exposes
  `AndroidFlutterLocalNotificationsPlugin.requestNotificationsPermission()`.
- `sqlite3_flutter_libs`. It is marked end-of-life (`0.6.0+eol`) because `sqlite3` 3.x bundles
  native libraries through build hooks. Rejected; `drift_flutter` handles this.
- `riverpod_lint`. Deferred. `very_good_analysis` is enough for the zero-warnings gate. Riverpod
  lints can be added once their analyzer-plugin setup is stable with this Dart SDK.

## R2. Build flavors (dev / prod)

**Decision**: Android `productFlavors` with dimension `env`:
- `dev`: `applicationIdSuffix = ".dev"`, `resValue("string", "app_name", "DailyTrack Dev")`.
- `prod`: no suffix, app name "DailyTrack".

Dart reads the active flavor through `appFlavor` (`package:flutter/services.dart`) into a
`FlavorConfig` in `lib/app/flavor.dart`. There is a single `lib/main.dart`, as §3 requires. Build
commands are `flutter run --flavor dev` and `flutter build appbundle --flavor prod --dart-define=...`.
Ad unit IDs are not used in Phase 0, because the ad service is a no-op (R8). `AdUnitIds` is
created in T4.1 with test IDs for `dev` and `String.fromEnvironment` values for `prod`.

**Rationale**: Built-in Flutter flavor support, one entry point, nothing secret in the repo.

**Alternatives considered**: `main_dev.dart`/`main_prod.dart` entry points. Rejected because they
duplicate bootstrap code and §3 names only `main.dart`. `flutter_flavorizr`. Rejected as an extra
tool.

## R3. Lints

**Decision**: `include: package:very_good_analysis/analysis_options.yaml`. Exclude `**/*.g.dart`,
`**/*.freezed.dart`, `lib/core/l10n/gen/**`, and the drift schema test outputs. Set
`public_member_api_docs: false`, because this is an app, not a published library. Remove
`flutter_lints`.

**Rationale**: §2 names `very_good_analysis` as the first choice. It is stricter, which supports
the zero-warnings gate.

## R4. Localization (en / hi / gu)

**Decision**: gen-l10n with `l10n.yaml`:
`arb-dir: lib/core/l10n`, `template-arb-file: app_en.arb`, `output-dir: lib/core/l10n/gen`,
`output-class: AppLocalizations`, `nullable-getter: false`. Keys use feature prefixes (`common_`,
`onboarding_`, `splash_`, `modules_`, `nav_`, `expense_cat_`, `currency_`).

Locale resolution works like this. The stored `locale` setting wins. Otherwise the device locale
is used if it is en, hi, or gu. Otherwise English. `MaterialApp.router` gets `locale:` from the
settings provider, so changing it on SYS-02 step 1 rebuilds the UI instantly.

**Fonts**: Noto Sans, Noto Sans Devanagari, and Noto Sans Gujarati are bundled as static TTF
assets in `assets/fonts/` (Regular 400 and SemiBold 600 only). The theme `fontFamily` is Noto Sans,
with `fontFamilyFallback: ['NotoSansDevanagari', 'NotoSansGujarati']`.

**Rationale**: §12 requires bundled Noto fonts. Fallback rendering keeps one type scale for all
three scripts. Two weights cover the §15.2 scale (400 and 600).

**Alternatives considered**: `google_fonts` (runtime download). Rejected because the app is
offline-first and golden tests need deterministic fonts.

## R5. Currency list (SYS-02 step 2)

**Decision**: Ship a curated static list of 30 common currencies in
`lib/core/utils/currencies.dart`. Each entry has an ISO code, a symbol, and minor-unit digits.
Localized display names come from ARB keys (`currency_INR`, …). INR is first and preselected when
the device region is IN, and it is also the fallback default. Search matches the code or the
localized name, case-insensitively.

**Rationale**: `intl` has no localized currency display names. The constitution requires every
user-facing string to come from ARB files. A full ISO 4217 list (about 160 entries times 3
languages) costs a lot of translation for little value to the target users.

**Spec impact**: This narrows the spec Assumption "ISO 4217 currencies" to a curated ISO 4217
subset. Record it in `docs/spec.md` §SYS-02 per Constitution I. Listed under open items in the plan.

## R6. Drift database, migrations, and tests

**Decision**:
- `AppDatabase` is in `lib/core/database/app_database.dart`, with `schemaVersion = 1` and tables
  `settings`, `categories`, `accounts`. The connection uses `driftDatabase(name: 'dailytrack')`
  from `drift_flutter`.
- The table classes live with their owners. `settings` is in `core/database/tables/`. `categories`
  and `accounts` are in `features/expense/data/tables/`, and `AppDatabase` lists them. See plan,
  Complexity Tracking.
- Migrations use `MigrationStrategy` with `onCreate: m.createAll()` and `onUpgrade` through
  `stepByStep` (drift's generated `schema_versions.dart`). It starts empty at v1.
  `beforeOpen` enables `PRAGMA foreign_keys = ON`.
- Migration test harness:
  - `dart run drift_dev make-migrations`, configured in `build.yaml`, dumps
    `drift_schemas/app_database/drift_schema_v1.json` and generates
    `test/drift/app_database/generated/` with a `SchemaVerifier` test.
  - Phase 0 verifies that v1 is created and matches the dump. Each future version adds a
    `vN→vN+1` test to the same file. This is the harness FR-012 asks for.
- Host tests use `NativeDatabase.memory()` (`package:drift/native.dart`), with native SQLite
  supplied by `sqlite3` 3.x build hooks. This works on Windows dev machines and Linux CI.

**Rationale**: `make-migrations` is drift's current recommended workflow. It generates both the
step-by-step helpers and the verifier tests.

**Alternatives considered**: hand-written `if (from < 2)` migrations. Rejected as error-prone.

## R7. First-launch seeding, exactly once (FR-025)

**Decision**:
- `core/database/seeding.dart` defines a `Seeder` contract with `id` (for example
  `expense.defaults.v1`) and `Future<void> seed(AppDatabase db)`.
- Each `TrackerModule` may contribute seeders. The Expense placeholder module contributes
  `ExpenseDefaultsSeeder`: 12 expense categories, 5 income categories, and the Cash account.
- `SeedRunner` runs during SYS-01 bootstrap. For each seeder, inside one `db.transaction`, it
  checks the settings key `seed.<id>`. If the key is missing, it runs the seeder and writes the
  key. If anything throws, the whole transaction rolls back. Seeding is atomic and idempotent
  across restarts, retries, and process death.
- Seeding runs for all registered modules whether or not they are enabled. Disabling Expense
  during onboarding must not change the seeded data, and the data is kept anyway (SET-06).

**Default set** (proposal, to be recorded in `docs/spec.md` §4; names are l10n keys):
- **Expense (12)**: food, groceries, transport, fuel, shopping, bills, rent, health, education,
  entertainment, travel, other.
- **Income (5)**: salary, business, gift, interest, other.
- **Account**: Cash (type cash, opening balance 0, l10n key `expense_account_cash`).

Icons and colors come from the fixed 16-color palette in `core/theme/app_colors.dart`.

**Rationale**: The settings-flag-in-transaction approach makes "exactly once" provable in a test
(run twice, count rows) without a schema change.

**Alternatives considered**: seeding in `MigrationStrategy.onCreate`. Rejected because it can't
use l10n keys from modules, it ties seed data to schema, and it is harder to test separately.

## R8. Ad service stand-in (FR-027)

**Decision**: `lib/core/ads/ad_service.dart` defines the `AdService` interface. Phase 0 only adds
`Future<void> initialize()`; later methods are added in T4.x. `NoAdsService implements AdService`
does nothing. Splash bootstrap calls `adService.initialize()` only when
`settings.removeAdsPurchased == false`. Tests inject a `mocktail` mock and verify the call or its
absence.

**Rationale**: This matches Constitution VI and the `NoAdsService` name in the constitution. No
SDK and no manifest app ID are needed yet.

## R9. Navigation (StatefulShellRoute with module-driven, reorderable tabs)

**Decision**:
- `StatefulShellRoute.indexedStack` with one branch per registered destination, built once at
  startup: Home, then every registered module's tab branch in registry order, then More. Branches
  are not rebuilt when the user toggles modules. That would recreate `GoRouter` and lose each
  tab's back stack.
- The shell widget (`AppShell`) builds the `NavigationBar` from the enabled-modules setting:
  Home, then enabled modules in the user's order, then More. It maps visible index to branch index
  for `goBranch`.
- The router redirect does three things:
  1. `/splash` until bootstrap is done.
  2. `/onboarding` until `onboardingDone`.
  3. `/lock` when `lockEnabled`.

  It also sends any path under a disabled module's route prefix to `/home`. `refreshListenable`
  is a `ChangeNotifier` bridged from the settings and bootstrap providers.
- Back behavior: `AppShell` uses `PopScope`. On a non-Home tab root, back runs `goBranch(home)`.
  On Home, back lets the system pop, which exits the app.
- `routes.dart` holds all paths and names: `/splash`, `/onboarding`, `/lock`, `/home`,
  `/expenses`, `/habits`, `/more`, `/more/modules`. Module paths are declared by modules through
  `TrackerModule.routes` and gathered by the registry.

**Rationale**: Each tab keeps its own back stack, toggling modules is instant, and adding a
module only changes the registry.

**Alternatives considered**: rebuilding the router on module change. Rejected because state is
lost and redirects flicker. A plain `ShellRoute`. Rejected because it doesn't keep a back stack
per tab.

## R10. State management conventions

**Decision**: One `@riverpod` Notifier or AsyncNotifier per screen, with `freezed` state
(`OnboardingState`, `ModulesState`, `SplashState`). Repositories are exposed as providers
(`settingsRepositoryProvider`, `moduleRegistryProvider`, `adServiceProvider`,
`appDatabaseProvider`). Tests override them with fakes. Settings are watched as a stream
(`watchSettings()`) so the locale, router, and nav bar react live.

**Rationale**: Constitution II and §2 rule 9.

## R11. Golden tests and platform consistency

**Decision**: Golden tests use the bundled Noto fonts, loaded in `test/flutter_test_config.dart`,
and are tagged `golden` (`dart_test.yaml`). Light and dark goldens are created for each §15.4
component. CI (ubuntu-latest) is the reference platform: it runs
`flutter test --tags golden` and owns the baseline images. On Windows dev machines,
`flutter test --exclude-tags golden` runs the rest of the suite. Goldens are updated with
`flutter test --tags golden --update-goldens` on Linux, either through CI artifacts or WSL.

**Rationale**: Text rasterization differs between Windows and Linux, so a single reference
platform keeps the gate stable.

## R12. CI workflow

**Decision**: `.github/workflows/ci.yml` runs on `pull_request` and pushes to `main`, using
`subosito/flutter-action` with the stable channel pinned to 3.47.x. Steps:
1. `flutter pub get`
2. `dart run build_runner build --delete-conflicting-outputs`
3. `flutter analyze`
4. `dart format --set-exit-if-changed .`
5. `flutter test` (all tags, coverage)
6. `flutter build appbundle --flavor prod --release`

The release bundle uses debug signing until the release keystore is set up in T5.2. Secrets are
not needed in Phase 0.

**Note**: The workspace root (`C:\Workspace\DailyTrack`) is not a git repository. There is a
nested repo at `dailytrack/` that holds only `.gitattributes`. CI needs the Flutter project at a
git repo root. This is an open item for the user (see plan).

## R13. Native splash and app logo

**Decision**: Configure `flutter_native_splash` in `pubspec.yaml` with `color` (light) and
`color_dark`, and an `android_12:` section with an icon on the theme background. A placeholder
logo `assets/branding/logo.png` (teal mark) is used until final branding. The Flutter SYS-01
screen draws the same logo and app name, so the switch from native to Flutter splash is seamless.

**Open item**: final logo artwork.
