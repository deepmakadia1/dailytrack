# Implementation Plan: Release Readiness (§14 T5.1, code side of T5.2, §13 targets)

**Branch**: `012-release-readiness` | **Date**: 2026-10-28 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `specs/012-release-readiness/spec.md`

## Summary

Make DailyTrack shippable:
- **Tests**: finish the §13 test strategy, with 28 Linux-only goldens and seven integration
  journeys (guest, Google with fakes, app lock, plus the §13 flows).
- **Performance**: add a dev-only "Seed 10,000 transactions" action, and measure the §13
  performance targets on a reference device.
- **Release build**:
  - Sign from `android/key.properties`.
  - Turn on R8 with keep rules.
  - Take the version from `pubspec.yaml`.
  - **Wire the production AdMob IDs.** Today the prod release requests no ads.
  - Read them from a git-ignored `config/prod.env.json` that both Gradle and Dart use.
  - Keep Google's test IDs out of the prod binary through compile-time constants.
- **Branding**: icons and splash stay generated from `assets/branding/`, and CI fails if they drift.
- **CI**: a tag-triggered workflow tests, runs the integration suite on an emulator, builds a
  signed App Bundle from secrets, checks it, and attaches it to a GitHub release. Pull requests
  compare goldens and build the bundle.
- **Audit**: a final audit, made of ordinary tests plus one bundle script, proves every acceptance
  criterion has a test and the code-controlled Play items pass.

## Technical Context

**Language/Version**: Dart 3.13.5 / Flutter 3.47.7 stable (unchanged); Kotlin DSL Gradle with AGP
9.1 and Kotlin 2.4 (unchanged).

**Primary Dependencies**:
- The `docs/spec.md` §2 stack is unchanged: `flutter_riverpod` 3.4 + `riverpod_generator`,
  `go_router` 18, `drift` 2.35, `freezed` 4.
- The existing `flutter_launcher_icons` 0.14.4 and `flutter_native_splash` 2.4.8 drive branding;
  `integration_test` and `flutter_driver` come from the SDK.
- **New Dart or pub dependencies: none.**
- New CI-only tools:
  - `reactivecircus/android-emulator-runner@v2`;
  - `bundletool`, a pinned release with a SHA-256 check;
  - `gh`, preinstalled on the runner.

**Storage**: no schema change (Drift schema 5) and no new settings row. Seeded rows are ordinary
`transactions` rows. Build config lives in git-ignored files. See [data-model.md](data-model.md).

**Testing**:
- **Unit tests**:
  - `AdUnitIds.resolveFor`;
  - the seeder, over a real in-memory database;
  - the criteria coverage, markers, Google scopes, and splash colors audit tests;
  - extensions to the manifest and backup rules tests.
- **Widget tests** (`pumpTestApp`, fakes): the Developer section with dev actions, and DSH-01
  calling `StartupReporter` once.
- **Goldens** (tag `golden`, Linux only, bundled Noto fonts from `test/flutter_test_config.dart`):
  the matrix in data-model §8.
- **Integration** (`integration_test/`, dev flavor, emulator): seven journeys on a shared harness
  (research R8).
- **Device performance** (`integration_test/perf/`, `flutter drive --profile`): scrolling and
  writes. Cold start and APK size use scripts.

**Target Platform**: Android, min API 24, target API 36 or higher. Play requires 36 for new apps
and updates from 31 Aug 2026 (research R13, confirmed 2026-10-28). iOS stays untested.

**Project Type**: Mobile app (Flutter, single project) plus CI workflows and shell tooling.

**Performance Goals**: §13, with the blocking rule from clarification Q4:
- **Blocking**: writes p95 < 100 ms, and each ABI APK < 25 MB.
- **Within 20%, recorded as open items**: cold start < 1.5 s (up to 1.8 s) and EXP-01 at most 1%
  missed frames (up to 1.2%).

**Constraints**:
- Secrets and real ad IDs are never committed and never printed. Constitution III and spec FR-019,
  FR-023, FR-025, FR-032 require this.
- Test ad IDs aren't in the prod binary (FR-036).
- Prod has no seed code path (FR-013).
- Features don't import each other: the seed action reaches SET-01 through `TrackerModule.devActions(read)`.
- Goldens are generated on Linux only, through `goldens.yml` (clarification Q5).
- Integration tests run on tags only (clarification Q3).
- There's no Play upload (clarification Q1).

**Scale/Scope**:
- New: 1 core type (`DevAction`), 1 core port (`StartupReporter`), 1 golden file, 4 integration
  journeys plus 2 device perf tests, 3 workflows touched (1 new release, 1 new goldens, `ci.yml`
  changed), 3 scripts, and 4 audit tests.
- Changed: `build.gradle.kts`, `production_overrides.dart`, `ad_unit_ids.dart`, `tracker_module.dart`,
  `ExpenseModule`, SET-01's Developer section, DSH-01 (one call), `MainActivity.kt`, `.gitignore`,
  `pubspec.yaml` (icon `min_sdk_android`).
- No new prod screen.

**Fixed-control screens without an empty state** (constitution V): none new. The Developer section
is part of SET-01, which is a fixed-control screen already (feature 007).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Status |
|---|---|---|
| I. Spec is the source of truth | Spec 012 is clarified (5 answers). §14 T5.1 is checked only after the audit; T5.2 stays open until its manual steps are done. Test names keep Screen IDs. | Pass |
| II. Layered, feature-first | SET-01 reaches the seeder only through `TrackerModule.devActions(read)` (core). DSH-01 reaches `reportFullyDrawn` through the core `StartupReporter` port; the channel lives in `lib/app/`. The seeder is in `features/expense/data/`. Presentation imports no `data/`. | Pass |
| III. Data integrity and privacy | Seeded money is `int` paise in UTC ms, and inserts are chunked transactions. No schema change. The keystore, passwords, and real ad IDs stay in git-ignored files or CI secrets and are masked in logs. No data goes to ad or analytics SDKs (existing 009 tests, referenced in the audit). | Pass |
| IV. Test-backed acceptance | Every spec 012 scenario maps to a test, a script, or a quickstart device step. `criteria_coverage_test` enforces coverage for the whole `docs/spec.md`. The §13 golden matrix is extended with AUTH-01 and SET-01. | Pass |
| V. Offline-first, fast, accessible | Integration journeys run offline. Performance targets are measured on a device. The new Developer rows use tokens and shared widgets, and their strings go through ARB in en/hi/gu. | Pass |
| VI. Monetization | Prod release gets real IDs only from the env file or secrets; dev and debug always use test IDs, now compile-time. No placement changes. | Pass |
| VII. Simplicity and locked stack | No new pub dependency. CI actions are justified in research R9 and R12. No Dart obfuscation or Play upload automation (YAGNI). | Pass |
| Workflow: CI builds a release bundle on every PR | `ci.yml` today builds only on `main`. This feature moves the bundle build to every pull request. | Pass, after the change |

**Post-design re-check (after Phase 1)**: Pass. The design adds one optional `TrackerModule`
member, following the existing `exportDatasets()` pattern, and one core port. Neither adds a
cross-feature import or a dependency.

## Project Structure

### Documentation (this feature)

```text
specs/012-release-readiness/
├── plan.md                 # This file
├── research.md             # Phase 0: R1–R15
├── data-model.md           # Phase 1: config files, secrets, DevAction, seeded rows, reports, golden matrix
├── quickstart.md           # Phase 1: validation guide
├── contracts/
│   ├── build.md            # Gradle variants, failure messages, check_bundle.sh
│   ├── workflows.md        # release.yml, goldens.yml, ci.yml, distribute.yml
│   ├── dev-seed.md         # DevAction API, Developer section, seeder tests
│   └── audit.md            # audit tests, outputs, spec updates
├── checklists/requirements.md
├── criteria-coverage.md    # written during implement (audit output)
├── compliance.md           # written during implement (audit output)
├── performance-report.md   # written during implement (device results)
└── tasks.md                # /speckit-tasks
```

### Source Code (repository root)

```text
.gitignore                                   # + key.properties, *.jks, config/prod.env.json
config/
├── prod.env.example.json                    # new, placeholders
└── README.md                                # new: keystore, key.properties, prod.env.json, secrets
android/app/
├── build.gradle.kts                         # release signing, R8, App ID from prod.env.json
├── proguard-rules.pro                       # new: notifications Gson, Play Core dontwarn
└── src/main/kotlin/…/MainActivity.kt        # dailytrack/startup channel → reportFullyDrawn()
lib/
├── app/
│   ├── production_overrides.dart            # real AdUnitIds; StartupReporter binding
│   └── startup/channel_startup_reporter.dart# new
├── core/
│   ├── ads/ad_providers.dart                # resolveAdUnitIds: compile-time branch (Flutter consts)
│   ├── ads/domain/ad_unit_ids.dart          # resolveFor for tests (stays pure Dart)
│   ├── module/dev_action.dart               # new
│   ├── module/tracker_module.dart           # + devActions(ProviderReader read)
│   └── startup/startup_reporter.dart        # new port
└── features/
    ├── dashboard/…/home_screen.dart         # reports fully drawn once
    ├── expense/expense_module.dart          # devActions(read) → seed (dev only)
    ├── expense/data/dev/large_data_seeder.dart  # new
    └── settings/…/settings_screen.dart      # Developer section lists devActions(read)
tool/
├── l10n/phase0_strings.py                   # + more_seed* strings
├── perf/cold_start.sh                       # new
└── release/{check_bundle.sh,apk_sizes.sh}   # new
test/
├── goldens/auth_settings_golden_test.dart   # new; account_golden_test drops SYS-02
├── goldens/*.png                            # committed from goldens.yml output
├── audit/{criteria_coverage,markers,google_scopes}_test.dart   # new
├── android/manifest_test.dart               # extended
├── core/ads/domain/ad_unit_ids_test.dart    # extended
├── core/theme/splash_colors_test.dart       # new
├── features/expense/data/large_data_seeder_test.dart  # new
└── features/settings/developer_section_test.dart       # new
integration_test/
├── helpers/app_harness.dart                 # new: freshInstall, launch, Google fakes
├── {guest,google,app_lock,habit}_flow_test.dart         # new
├── account_backup_flow_test.dart            # deleted (replaced by google_flow_test)
├── app_smoke_test.dart, expense_flow_test.dart, backup_restore_test.dart  # moved to the harness, AUTH-01 start
└── perf/{exp01_scroll,write}_perf_test.dart # new
test_driver/perf_driver.dart                 # new
.github/workflows/
├── release.yml                              # new
├── goldens.yml                              # new
├── ci.yml                                   # bundle on every PR, generator drift check, goldens on
└── distribute.yml                           # optional PROD_ENV_JSON
docs/spec.md, docs/CLAUDE.md                 # §14 T5.1 and §13 ticks; release rules
```

**Structure Decision**: a single Flutter project, as in features 001–011. Release tooling goes in
`tool/release/` and `tool/perf/`, and CI in `.github/workflows/`. Cross-feature reach goes through
`lib/core/module/` and `lib/core/startup/` only.

## Implementation order (for `/speckit-tasks`)

1. **Secrets hygiene first**: `.gitignore`, `config/prod.env.example.json`, `config/README.md`.
2. **Build**: signing, R8 with `proguard-rules.pro`, App ID from `prod.env.json`, `AdUnitIds`
   compile-time resolve, and the `production_overrides` wiring, plus their unit tests.
3. **Branding**: icon `min_sdk_android: 24`, regenerate, splash colors test, CI drift check.
4. **Dev seed**: `DevAction`, the `TrackerModule` member, the seeder, the Developer section, strings,
   and tests.
5. **Startup reporter**: the port, the channel, MainActivity, and the DSH-01 call, plus a test.
6. **Goldens**: the new file, drop SYS-02, `goldens.yml`, baselines from Linux, then `ci.yml`
   compares them.
7. **Integration**: the harness, rework the stale journeys, and add the four new ones.
8. **Performance**: the device perf tests, driver, and scripts, a run on the reference device, and
   `performance-report.md`.
9. **Release workflow**: `release.yml`, `check_bundle.sh`, `apk_sizes.sh`, and `distribute.yml`.
10. **Audit**: the markers, scopes, and criteria coverage tests; `criteria-coverage.md` (fill gaps
    with tests); `compliance.md`; the device smoke check (quickstart §6); then the spec and
    `CLAUDE.md` updates.

## Open items carried in

- Feature 011's open tasks overlap this feature and are taken over here:
  - T044 and T060 (AUTH-01 and SET-01 goldens);
  - T062 (login integration flow, now `guest_flow_test` and `google_flow_test`);
  - T066 (the full gate run).
- 011's T042, T043, T050, T052, T058, T065, and T067 still belong to 011. The criteria coverage
  audit fails until they have tests.
- The full `flutter test` run was stopped by the system for low memory on the developer machine.
  For memory, the gate can run in folders (`flutter test test/core`, `test/features`, …); CI runs
  it in one go.

## Complexity Tracking

No constitution violations to justify.
