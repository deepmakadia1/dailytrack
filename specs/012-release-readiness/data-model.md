# Data Model: Release Readiness (feature 012)

**No schema change.** Drift stays at schema 5, the backup `schemaVersion` is unchanged, and no
settings row is added. The new things here are build-time files, one module hook, and the records
the audit and the performance pass produce.

## 1. Build-time configuration files

| File | Committed? | Read by | Contents |
|---|---|---|---|
| `android/key.properties` | **No** (git-ignored) | `android/app/build.gradle.kts` | `storeFile`, `storePassword`, `keyAlias`, `keyPassword` |
| `android/upload-keystore.jks` (or any `*.jks`) | **No** (git-ignored) | Gradle through `storeFile` | the upload key |
| `config/prod.env.json` | **No** (git-ignored) | Flutter `--dart-define-from-file`; Gradle (`ADMOB_APP_ID`) | `ADMOB_APP_ID`, `ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID` |
| `config/prod.env.example.json` | Yes | people | the same keys with `ca-app-pub-XXXXXXXXXXXXXXXX~…` placeholders |
| `config/dart_defines.json` | Yes (unchanged) | Flutter `--dart-define-from-file` | Firebase client values, `GOOGLE_SERVER_CLIENT_ID` |
| `config/README.md` | Yes (new) | people | how to make the keystore, `key.properties`, and `prod.env.json`, and the CI secret names |

**Validation**
- `key.properties`: all four keys present and non-blank. `storeFile` must exist. Otherwise a store
  build fails and names the key or path, never a password.
- `prod.env.json`: a flat JSON object of strings.
  - The App ID must match `^ca-app-pub-\d{16}~\d{10}$`.
  - Each unit ID must match `^ca-app-pub-\d{16}/\d{10}$`.
  - None may use the test publisher `3940256099942544`.
  - The release workflow checks this before building, and `check_bundle.sh` checks the result.
- Precedence for the Gradle App ID: `config/prod.env.json`, then `local.properties admob.appId`,
  then the `ADMOB_APP_ID` environment variable.

## 2. GitHub secrets (release workflow)

| Secret | Required | Becomes |
|---|---|---|
| `ANDROID_KEYSTORE_BASE64` | yes | `$RUNNER_TEMP/upload.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | yes | `storePassword` |
| `ANDROID_KEY_ALIAS` | yes | `keyAlias` |
| `ANDROID_KEY_PASSWORD` | yes | `keyPassword` |
| `PROD_ENV_JSON` | yes | `config/prod.env.json` (every value masked) |

All of them are deleted from the runner in an `always()` step. None is printed.

## 3. Version

`pubspec.yaml` `version: <name>+<code>` is the only source.
- `name` is `MAJOR.MINOR.PATCH`, and must equal the pushed tag without its `v`.
- `code` is a positive integer that grows with every Play upload; the maintainer bumps it.

## 4. `DevAction` (new core type, `lib/core/module/dev_action.dart`)

| Field | Type | Notes |
|---|---|---|
| `id` | `String` | stable, e.g. `expense.seed10k`; used as the widget key `dev_<id>` |
| `labelKey` | `String` | ARB key of the row title |
| `confirmKey` | `String` | ARB key of the confirm dialog body |
| `icon` | `IconData` | |
| `run` | `Future<DevActionResult> Function(ProviderReader read, void Function(double fraction) onProgress)` | must not throw. Returns `DevActionDone(count)` or `DevActionBusy()` |

`TrackerModule` gains `List<DevAction> devActions(ProviderReader read) => const [];`. Only enabled
modules' actions are shown, and only when `debugToolsAvailableProvider` is true, which means never
in prod. Each module also checks that provider through `read` and returns `const []` when it's
false.

## 5. Seeded transaction (expense module, existing `transactions` table)

These are ordinary rows; no column is added.

| Rule | Value |
|---|---|
| Count per run | 10,000, added on top of what's there (never deletes) |
| Type mix | 80% expense, 15% income, 5% transfer (a transfer has two distinct non-archived accounts) |
| Amount | `int` paise, log-normal, clamped to 1,000–5,000,000 (₹10–₹50,000) |
| `occurredAt` | UTC ms, uniform over the 365 days before now |
| Account and category | random over non-archived accounts and non-hidden categories of the matching type |
| Note | every 4th row, from a fixed list; no receipt |
| `createdAt`, `updatedAt` | now, UTC ms; `deletedAt` null |
| Random source | `Random(42)`, so each run makes the same data |
| Chunks | 20 × 500 rows, one transaction each, with progress after each |
| Side effects | the database triggers raise `dataChangeCounter` for each inserted row, as for any write (the seeder never sets it); no budget alert, notification, or interstitial counter |
| Busy | runs inside `BackupCoordinator.run`; if another backup or restore holds the lease (`BackupBusy`), returns `DevActionBusy` and writes nothing |

## 6. Performance report (`specs/012-release-readiness/performance-report.md`)

One row per target:

| Field | Example |
|---|---|
| Target | Cold start to Home |
| Limit | < 1.5 s (open item allowed up to 1.8 s) |
| Device | Pixel 6a, Android 15, 6 GB (or the actual reference device) |
| Build | prod profile, commit `abc1234` |
| Data | 10,000 seeded transactions |
| Runs | 10 |
| Measured | median 1.21 s, p90 1.34 s |
| Result | Pass / Open (within 20%) / Fail |
| Blocking | yes for writes and APK size; within-20% misses of cold start and fps are not (clarification Q4) |

## 7. Criteria coverage table (`specs/012-release-readiness/criteria-coverage.md`)

A Markdown table, one row per acceptance criterion in `docs/spec.md`:

| Column | Meaning |
|---|---|
| `ID` | `<Screen ID or section>#<n>`, e.g. `EXP-02#3`, `§11#2`, `§16-guest#1` |
| `Criterion` | the first 60 characters of the criterion text, which must match the spec |
| `Test` | `path/to/file_test.dart` :: a quoted substring of the test name, or `device: quickstart §N`, or `manual: compliance.md` |

`test/audit/criteria_coverage_test.dart` parses both files. It fails on a missing row, an extra
row, a text mismatch, a missing file, or a test name not found in that file. Rows marked `device:`
or `manual:` are allowed only for criteria that can't run in `flutter test` (for example, a home
screen icon on a launcher).

## 8. Golden matrix

| Screen | State | Themes | Languages | File |
|---|---|---|---|---|
| DSH-01 | seeded | light, dark | en, gu | `home_golden_test.dart` |
| EXP-01 | content | light, dark | en, gu | `expense_screens_golden_test.dart` |
| EXP-02 | new with amount | light, dark | en, gu | `expense_screens_golden_test.dart` |
| HAB-01 | five habits | light, dark | en, gu | `habit_screens_golden_test.dart` |
| AUTH-01 | default | light, dark | en, gu | `auth_settings_golden_test.dart` (new) |
| SET-01 | guest card | light, dark | en, gu | `auth_settings_golden_test.dart` (new) |
| SET-01 | Google card | light, dark | en, gu | `auth_settings_golden_test.dart` (new) |

That's 28 required images at 360 × 800 dp, DPR 1, with fixed "now" 2026-10-14 10:00. Existing
extra states stay. `SYS-02 restore with Google` is deleted.
