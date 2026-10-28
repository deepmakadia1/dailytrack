# Research: Release Readiness (feature 012)

Each decision lists what was chosen, why, and what else was considered. "Repo today" notes come from
reading the code on 2026-10-28.

## R1. Release signing from `android/key.properties`

**Repo today**: `android/app/build.gradle.kts` signs `release` with the debug key under a `TODO`.
`isStoreBuild` is already true when `-PstoreBuild=true`, `DAILYTRACK_STORE_BUILD=true`, or
`android/key.properties` exists. `.gitignore` has `/android/key.properties` and `*.keystore`.

**Decision**:
- Keep the signing config in `android/app/build.gradle.kts` (planning input). Read
  `rootProject.file("key.properties")` (that is `android/key.properties`) with the four standard keys
  `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. `storeFile` is resolved relative to
  `android/`, so `upload-keystore.jks` next to it works, as does an absolute path.
- If the file exists, `signingConfigs.create("release")` is used by `buildTypes.release`.
- If it doesn't, a store build fails in the existing `preProdReleaseBuild` check, with
  "Release signing missing: create android/key.properties (see config/README.md)". A non-store local
  release still falls back to the debug key with a Gradle warning, so `flutter run --release` keeps
  working (spec FR-020).
- A missing or unreadable `storeFile` fails the build with the path it looked for, never the
  passwords.
- `.gitignore` adds `key.properties` (anywhere), `*.jks`, and `config/prod.env.json`, and keeps
  `*.keystore` (planning input).

**Alternatives**: signing with `--key-store` command-line flags (rejected: passwords would show up
in the shell history and CI logs); Play App Signing only, with no upload key (rejected: Play still
needs a signed upload).

## R2. Code shrinking (R8) and keep rules

**Repo today**: no `proguard-rules.pro`. The Flutter Gradle plugin turns R8 on for release by
default, but nothing in the repo says so, and no plugin feature has been smoke-tested on a shrunk
build.

**Decision**:
- Make it explicit in `buildTypes.release`: `isMinifyEnabled = true`, `isShrinkResources = true`,
  `proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")`.
- Add `android/app/proguard-rules.pro` with only the rules the plugins don't ship themselves:
  - `flutter_local_notifications`: its scheduled notifications are serialized with Gson, and R8
    strips the generic type info. Keep `com.google.gson.reflect.TypeToken` and its subclasses, and
    keep signatures and annotations (the plugin README's rules).
  - Flutter embedding references Play Core deferred components the app doesn't use, so add
    `-dontwarn com.google.android.play.core.**`.
  - Anything listed in `build/app/outputs/mapping/prodRelease/missing_rules.txt` after the first
    shrunk build is added with a comment naming the plugin.
- The other plugins ship consumer rules: `google_mobile_ads`, `in_app_purchase_android`,
  `workmanager`, `home_widget`, `local_auth`, `flutter_secure_storage`, `share_plus`, Firebase,
  `google_sign_in`, `webview_flutter`. They get no rules unless the smoke check (R14) fails.
- Dart code is **not** obfuscated (`--obfuscate` is off). Crashlytics gets readable Dart stack
  traces without a symbol upload step, and the size gain is small. The Java/Kotlin `mapping.txt`
  is kept with each release (spec FR-031).

**Alternatives**: turning shrinking off (rejected: it costs APK size, and §13 caps it at 25 MB);
Dart obfuscation with `--split-debug-info` (deferred: it needs the Firebase CLI symbol upload in
CI, and adds no compliance value).

## R3. Version name and code

**Decision**: keep `versionCode = flutter.versionCode` and `versionName = flutter.versionName` in
`defaultConfig`. They come from `pubspec.yaml` `version: x.y.z+n`, and no `--build-name` or
`--build-number` is passed anywhere (spec FR-022). The release workflow checks that
`v${x.y.z}` equals the pushed tag before building (spec FR-029), and the bundle check (R13) reads
the version back out of the built bundle's manifest. Split-per-ABI APKs get Flutter's
`abi*1000 + n` offset. That offset applies only to the APK size check (R10), which is never
uploaded, so the store version code stays `n`.

**Alternatives**: deriving the version code from the CI run number (rejected: then the pubspec
wouldn't be the one place to edit it, which breaks FR-022).

## R4. Production ad IDs from `config/prod.env.json`

**Repo today**: `AdUnitIds.fromEnvironment()` reads `ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`,
`ADMOB_INTERSTITIAL_ID`, and `ADMOB_REWARDED_ID`. Gradle reads the App ID from `local.properties`
`admob.appId` or `ADMOB_APP_ID`. However, `production_overrides.dart` passes
`manifestUsesTestAppId: true, fromEnv: AdUnitIds.none`. **The prod release requests no ads
today** (009's "until T117 wires the release IDs").

**Decision**:
- `config/prod.env.json` (git-ignored) holds `ADMOB_APP_ID` and the four unit IDs as a flat JSON
  object. `config/prod.env.example.json`, with placeholders, is committed.
- **One source for both sides**:
  - Flutter reads the file with `--dart-define-from-file=config/prod.env.json`, passed after the
    committed `config/dart_defines.json`. Flutter accepts the flag more than once.
  - Gradle reads `ADMOB_APP_ID` from the same file with `groovy.json.JsonSlurper`. The order is
    `config/prod.env.json`, then `local.properties admob.appId`, then the `ADMOB_APP_ID` environment
    variable. That keeps 009's sources working.
- `production_overrides.dart` passes `fromEnv: AdUnitIds.fromEnvironment()` and
  `manifestUsesTestAppId: const String.fromEnvironment('ADMOB_APP_ID').isEmpty`. If Gradle found an
  App ID but Dart didn't, the app shows no ads (safe). The bundle check (R13) catches that mismatch
  in CI.
- In CI the secret `PROD_ENV_JSON` is the whole file. The workflow writes it to
  `config/prod.env.json` before building and deletes it afterwards (planning input).

**Alternatives**: one GitHub secret per ID (rejected: the planning input asks for the prod env file
as a secret, and one file keeps local and CI builds the same); reading the App ID back from the
manifest at runtime over a platform channel (rejected: it adds native code just to learn a
build-time value).

## R5. Keeping test ad IDs out of the prod binary

**Problem**: spec FR-036 wants no Google test ID inside a prod release. `AdUnitIds.test` is a
`const` that `resolve` references, so today AOT compiles its strings into every build's
`libapp.so`.

**Decision**:
- A new `resolveAdUnitIds` in `lib/core/ads/ad_providers.dart` branches on compile-time constants:
  `kReleaseMode` and `appFlavor == 'prod'`. `appFlavor` is a `const` from
  `package:flutter/services.dart`, set by `--flavor`. It lives outside `domain/` because those
  constants come from Flutter, and constitution II keeps the domain pure Dart.
- So the prod-release branch is folded at compile time. `AdUnitIds.test` isn't reachable in prod
  release, and the AOT tree shaker drops its strings.
- The runtime-parameter version stays in `domain/ad_unit_ids.dart` for unit tests, as
  `AdUnitIds.resolveFor(...)`. `resolveAdUnitIds` doesn't call it, so `AdUnitIds.test` stays
  unreachable in prod.
- The test **App ID** in Gradle reaches the manifest only for non-store prod releases. A store
  build fails without the real one (009 clarification Q2).
- The bundle check (R13) proves both:
  - no string `ca-app-pub-3940256099942544` in `base/lib/*/libapp.so` or the base manifest of the
    store bundle;
  - no `ca-app-pub-` ID other than Google's test publisher in a dev or debug build.

**Alternatives**: a separate Dart entry point for prod (rejected: two `main` files to keep in sync);
only checking at runtime (rejected: it doesn't satisfy "contains none").

## R6. App icon and splash

**Repo today**: `pubspec.yaml` already configures `flutter_launcher_icons` 0.14.4 (adaptive
foreground and background, monochrome) and `flutter_native_splash` 2.4.8 (light and dark, an
Android 12 icon with a background). The generated `mipmap-*`, `mipmap-anydpi-v26`, `drawable*`,
`values-v31`, and `values-night*` resources are committed and include the monochrome layer.

**Decision**:
- Keep both generators and their config as the single source.
- Change `min_sdk_android` from 21 to 24 to match the app.
- Re-run both generators from `assets/branding/` and commit the output (spec FR-026, FR-027).
- Add a CI step that regenerates both and fails on `git diff --exit-code android/app/src/main/res`,
  so the committed icons can't drift from `assets/branding/`.
- No separate Dev icon: the dev flavor is already labelled "DailyTrack Dev".
- The splash colors stay `#FFFFFF` / `#191C1B` with the `#014D42` icon background. These match the
  `AppTokens` light and dark surfaces of the default theme. A unit test reads `pubspec.yaml` and
  `app_colors.dart` and fails if they diverge.
- SYS-01 paints the same surface color, so there's no flash at handover.

**Alternatives**: hand-made `res/` files (rejected: they drift from the branding source); a dev
icon badge (rejected: YAGNI).

## R7. Golden tests with bundled Noto fonts

**Repo today**:
- `test/flutter_test_config.dart` already loads `NotoSans`, `NotoSansDevanagari`, and
  `NotoSansGujarati` from `assets/fonts/`, plus Material Icons, before every test.
- Five golden files exist (tag `golden`): DSH-01, EXP-01 to EXP-07, HAB-01 to HAB-04, SYS-01,
  ACC-01 to ACC-03, and a stale `SYS-02 restore with Google`.
- **No baseline PNG is committed**, and CI runs `--exclude-tags golden`.

**Decision**:
- Keep the bundled-font loader (planning input). Also call `loader.load()` for the Roboto fallback
  name the theme uses, if it differs from `NotoSans`. Every text style then resolves to a
  bundled file, so no glyph comes from the machine's fonts.
- New `test/goldens/auth_settings_golden_test.dart`: AUTH-01 default, SET-01 guest card, and SET-01
  Google card, each light/dark × English/Gujarati.
- The required matrix (spec FR-001) is DSH-01 seeded, EXP-01 content, EXP-02 new with amount,
  HAB-01 five habits, AUTH-01 default, and SET-01 guest: 6 screens × 2 themes × 2 languages = 24.
  SET-01 Google adds 4 more, so 28 required images. The existing extra states stay.
- Delete the `SYS-02 restore with Google` scenario (spec FR-005).
- Baselines are made **only** by the new manual workflow `goldens.yml` on `ubuntu-latest`. It runs
  `flutter test --tags golden --update-goldens` and uploads `test/goldens/` (next to the test files) as an artifact.
  The developer reviews and commits it (clarification Q5).
- Once the baselines are committed, `ci.yml` stops excluding the `golden` tag, so pull requests
  compare goldens. On failure it already uploads `failures/`.
- Golden pixel tolerance stays at 0. The same runner image and bundled fonts keep it
  deterministic.

**Alternatives**: `alchemist` or `golden_toolkit` (rejected: a new dependency for something the SDK
already does); a tolerance comparator (rejected: it hides real one-pixel regressions in Gujarati
text).

## R8. Integration journeys

**Repo today**:
- `expense_flow_test.dart` covers expense → EXP-01 → Home → Reports, plus a habit check-in through
  DSH-01.
- `backup_restore_test.dart` covers backup → erase → restore.
- `account_backup_flow_test.dart` still ends on SYS-02 "Restore with Google", **removed in 011**.
- `app_smoke_test.dart` "SYS-02 Skip … lands on Home" is also stale: a fresh install now lands on
  AUTH-01.

**Decision**: one shared harness, `integration_test/helpers/app_harness.dart`:
- `freshInstall()` wipes every table including settings, secure storage, and app files.
- `launch()` uses `productionOverrides()` with recording notifications, a recording background
  scheduler, and `NoAdsService`.
- It also provides in-memory fake `AccountAuth` and Drive store whose `calls` survive a sign-out.
  They're lifted from `account_backup_flow_test.dart`.

| Journey | File | Change |
|---|---|---|
| Add expense → Home → Reports | `expense_flow_test.dart` | Keep. Starts from AUTH-01 "Continue as guest" through the harness. |
| Habit → check in → streak | new `habit_flow_test.dart` | HAB-02 create → HAB-01 check-in → streak 1 on HAB-01 and HAB-03. The DSH-01 path stays in `expense_flow_test`. |
| Backup → erase → restore | `backup_restore_test.dart` | Keep. Moves to the harness. |
| Guest | new `guest_flow_test.dart` | Intro → AUTH-01 guest → EXP-02 → SET-01 "Log out of guest" → ACC-04 confirm → AUTH-01. Restart opens AUTH-01. Fake `calls` is empty. |
| Google | new `google_flow_test.dart`, replaces `account_backup_flow_test.dart` | AUTH-01 Google → SET-02 Back up now → ACC-03 "Keep data" → AUTH-01 → Google → ACC-02 Restore → rows match. |
| App lock | new `app_lock_flow_test.dart` | SET-05 set PIN → restart → SYS-03 → wrong PIN refused → right PIN → Home. Background past the timeout (injected clock) → SYS-03. |
| Smoke | `app_smoke_test.dart` | Fix: fresh install → Intro → AUTH-01. |

Everything runs on the **dev** flavor (test ads) with `flutter test integration_test --flavor dev`,
offline (spec FR-010).

**Alternatives**: `patrol` (rejected: a new dependency; nothing here needs system dialogs);
real Google test accounts (rejected: needs the network, and secrets in CI).

## R9. Integration tests in the tag workflow

**Decision**:
- In `release.yml`, an `integration` job on `ubuntu-latest` turns KVM on (udev rule) and runs
  `reactivecircus/android-emulator-runner@v2`: API 34, `google_apis`, x86_64, with `disable-animations`
  and an AVD cache.
- The job runs `flutter test integration_test --flavor dev -d emulator-5554`.
- `build` needs `integration`, so a failed journey builds nothing (clarification Q3). A flaky run is
  re-run for the same tag ("Re-run failed jobs").
- Pull requests don't run it.

**Alternatives**: Firebase Test Lab (rejected: a paid quota and a service-account secret); a macOS
runner with HVF (rejected: slower and 10× the cost).

## R10. Performance pass

| Target | How it's measured | Where |
|---|---|---|
| Cold start to Home < 1.5 s | Android's **fully drawn** time. On DSH-01's first content frame, the app calls `Activity.reportFullyDrawn()` once per process. `tool/perf/cold_start.sh` runs `adb shell am force-stop` then `am start -W -S` 10 times and reports the median `TotalTime` and the "Fully drawn" logcat line. | `MainActivity.kt` method channel `dailytrack/startup`, behind a core port `StartupReporter` |
| EXP-01 60 fps | `integration_test/perf/exp01_scroll_perf_test.dart` with `IntegrationTestWidgetsFlutterBinding.watchPerformance`: fling EXP-01 top to bottom over 10,000 seeded rows. Run with `flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart`. The driver writes `build/exp01_scroll.timeline_summary.json`. The test fails if the missed-frame share is over the limit. | device |
| Writes < 100 ms | `integration_test/perf/write_perf_test.dart`: with 10,000 rows on the device database, 50 transaction saves and 50 habit check-ins through the real repositories, timed with a `Stopwatch`. p95 must be < 100 ms. | device |
| APK < 25 MB per ABI | `tool/release/apk_sizes.sh`: `flutter build apk --release --flavor prod --split-per-abi` (with the prod env file), then it fails if any `app-*-prod-release.apk` is ≥ 25 MB (26,214,400 bytes). | release workflow and local |

- Measurements run on the reference device: a mid-range phone with about 4 GB RAM on Android 13 or
  later, in a profile or release build.
- The existing in-memory perf tests (`transaction_perf_test`, `home_perf_test`) stay as fast
  regressions, tag `perf`.
- The DSH-01 300 ms widget timing is flaky on Windows, so it gets the `perf` tag and stops counting
  as the §13 measurement.
- Results go in `specs/012-release-readiness/performance-report.md`, using the blocking rule from
  clarification Q4.

**`reportFullyDrawn` is reached through a port.**
- `lib/core/startup/startup_reporter.dart` is a pure Dart interface.
- The `MethodChannel` implementation lives in `lib/app/`, and DSH-01 calls it through a provider.
- A widget test binds a recording fake.
- This is also what Android vitals uses for time to full display.

**Alternatives**: `--trace-startup` (rejected: it measures Flutter's first frame, which is SYS-01,
not Home); Macrobenchmark (rejected: a separate Gradle module and a new toolchain).

## R11. "Seed 10,000 transactions" without crossing features

**Problem**: the action sits in SET-01 (`features/settings`), but the data belongs to
`features/expense`, and features never import each other.

**Decision**:
- Add an optional member to `TrackerModule`: `List<DevAction> devActions(ProviderReader read) => const [];`.
  It takes a `ProviderReader` like `contributeGlance` and `handleAction`, so a module can check
  `debugToolsAvailableProvider` itself.
- `DevAction` is a new core type, `lib/core/module/dev_action.dart`:
  `labelKey`, `icon`, `confirmKey`, and
  `Future<int> run(ProviderReader read, void Function(double) onProgress)`.
- SET-01's dev-only Developer section lists the `devActions(read)` of the enabled modules, reached
  through the module registry provider, the same way Export reaches `exportDatasets()`.
- `ExpenseModule.devActions(read)` returns the seed action only when
  `read(debugToolsAvailableProvider)` is true. That provider is already `!FlavorConfig.current.isProd`. The Developer section isn't built
  in prod at all.

**The seeder**, `lib/features/expense/data/dev/large_data_seeder.dart`:
- It uses `Random(42)`, so the same data comes out each run.
- 80% expenses, 15% income, 5% transfers, spread over the non-hidden accounts and categories, with
  times uniform over the past 365 days.
- Amounts are log-normal between ₹10 and ₹50,000 in paise (`int`).
- A note on every 4th row; no receipts.
- It inserts in 20 `db.batch` chunks of 500, each in its own transaction. That keeps the UI isolate
  responsive and reports progress after each chunk, and an interrupted run leaves only whole chunks
  (spec edge case).
- It writes through the DAOs' companions, with the same `id`, `createdAt`/`updatedAt` UTC
  milliseconds, and `deletedAt = null` as the repository. It never calls the save use case, so no
  budget alert or interstitial counter fires (spec FR-015).
- `GlanceRefresher` sees one table update per chunk; that's acceptable for a dev tool.
- It never writes `dataChangeCounter` itself: the database triggers raise it for every inserted
  row, as for any write, so ACC-01 and auto backup see the data as changed.
- **Busy guard**: it runs inside `BackupCoordinator.run`. That lease (an in-isolate flag plus the
  `backupLeaseUntil` row) already serializes every backup and restore, including background ones.
  `BackupBusy` becomes `DevActionBusy` and a message.
- **Strings**: `more_seedTransactions`, `more_seedConfirm`, `more_seedProgress`, `more_seedDone`
  (with a count placeholder) and `more_seedBusy` go through `tool/l10n/phase0_strings.py` in en,
  hi, and gu.

**Alternatives**: a `--dart-define` that seeds at startup (rejected: the spec asks for a Developer
section action); importing the expense repository in settings (rejected: it breaks the layer rule);
`compute()` isolates (rejected: Drift already runs queries on its own isolate with
`drift_flutter`, so chunking is enough).

## R12. Tag-triggered release workflow

**Decision**: new `.github/workflows/release.yml`, separate from `ci.yml` and `distribute.yml`.
- **Trigger**: `push: tags: ['v[0-9]+.[0-9]+.[0-9]+']`.
- **Permissions**: `contents: write` (for the GitHub release). Concurrency is per tag.
- **Job `verify`**:
  - Every required secret is non-empty: `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
    `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `PROD_ENV_JSON`. Each missing one is named in an
    `::error::` line.
  - `PROD_ENV_JSON` parses with `jq`, has all five keys, and isn't the test publisher.
  - The tag equals `v` plus the pubspec version name.
- **Job `checks`** (needs `verify`): build_runner, analyze, format, and `flutter test`, including
  goldens once the baselines are committed.
- **Job `integration`** (needs `verify`): R9.
- **Job `build`** (needs `checks` and `integration`):
  1. Decode the keystore to `$RUNNER_TEMP/upload.jks`.
  2. Write `android/key.properties` with `storeFile=$RUNNER_TEMP/upload.jks`.
  3. Write `config/prod.env.json` from the secret, masking every value with `::add-mask::` first.
  4. `flutter build appbundle --release --flavor prod --dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json`
     with `DAILYTRACK_STORE_BUILD=true`.
  5. `tool/release/check_bundle.sh` (R13), then `tool/release/apk_sizes.sh` (R10).
  6. Upload `app-prod-release.aab` and `mapping.txt` as run artifacts.
  7. `gh release create "$TAG" --verify-tag --title "$TAG" --generate-notes <aab> <mapping>`.
  8. An `if: always()` step deletes the keystore, `key.properties`, and `prod.env.json`.
- No Play upload (clarification Q1).
- **`ci.yml` changes**:
  - It builds an unsigned-for-store (debug-key) prod App Bundle on **every pull request**, as
    constitution "Development Workflow" asks. Today it builds only on `main`.
  - It runs the generator drift check (R6).
  - Once the baselines are committed, it drops `--exclude-tags golden`.

**Alternatives**: `softprops/action-gh-release` (rejected: `gh` is preinstalled and needs no
third-party action with write access); signing with `r0adkll/sign-android-release` (rejected: Gradle
already signs from `key.properties`, so local and CI builds stay the same).

## R13. Release audit

**Decision**: the audit is mostly ordinary tests, so it runs in every `flutter test`, plus one
shell check on the built bundle.

| Check | Where | Fails when |
|---|---|---|
| Every acceptance criterion has a test (spec FR-033) | `test/audit/criteria_coverage_test.dart` over `specs/012-release-readiness/criteria-coverage.md` | A `- [ ]` or `- [x]` item under an "Acceptance criteria" heading in `docs/spec.md` has no row, a row names a missing file, or the named test string isn't in that file |
| No markers (spec FR-034) | `test/audit/markers_test.dart` | `TODO`, `FIXME`, `Replaced in`, or `Interim` (case-insensitive, word-bounded) appears in `lib/`, `test/`, `integration_test/`, `tool/`, `android/app/**/*.kts`, `android/app/src/main/**/*.{kt,xml}`, or `.github/workflows/`. Generated `*.g.dart`, `*.freezed.dart`, and `lib/core/l10n/gen/` are skipped. |
| No "sync" in UI strings (spec FR-035) | existing `test/core/l10n/no_sync_wording_test.dart`, which already covers every en/hi/gu ARB value and the Android `strings.xml` files | unchanged |
| No test IDs in prod and no prod IDs in dev (spec FR-036) | `tool/release/check_bundle.sh <aab> prod\|dev`, using `unzip` + `strings` + `bundletool dump manifest`, plus a `resolve` unit test | prod: `3940256099942544` in `libapp.so` or the manifest, a manifest App ID that's empty or a test ID, `versionName`/`versionCode` ≠ pubspec, or `targetSdkVersion` < the Play minimum. dev: any `ca-app-pub-` ID outside the test publisher |
| Backup rules (§13) | existing `test/android/backup_rules_test.dart` | it stops including only the database |
| Permissions (§13) | existing `test/android/manifest_test.dart`, extended | `USE_EXACT_ALARM` is declared, or a permission not on the allow-list is added. `SCHEDULE_EXACT_ALARM` stays, justified in `compliance.md`: user-set habit reminders and the daily summary, with an inexact fallback when it's denied. |
| Google scopes (§13) | new `test/audit/google_scopes_test.dart` (none exists today) | anything beyond `email`, `profile`, and `drive.appdata` |
| Ad placement, cap, consent, no data to ads (§11, §13) | existing 009 tests, referenced in `compliance.md` | unchanged |
| Target and min SDK (§13) | `check_bundle.sh` | `minSdkVersion` ≠ 24 or `targetSdkVersion` < 36. Confirmed on 2026-10-28: Play requires new apps and app updates to target Android 16 (API 36) from 31 Aug 2026 (an extension to 1 Nov 2026 can be requested), per developer.android.com/google/play/requirements/target-sdk. |

- `specs/012-release-readiness/compliance.md` lists each §13 Play item:
  - code-controlled items: the test or check that covers each, and the result;
  - console-only items, with what the code provides for each. These are the data safety form,
    OAuth verification, the 18+ audience, `app-ads.txt`, and the internal track upload.
- When everything passes, `docs/spec.md` §14 T5.1 is checked and the code-controlled §13 boxes are
  ticked. T5.2 stays unchecked (spec FR-038).

**Criteria IDs**: a criterion is identified by its section's Screen ID and its 1-based position
(for example `EXP-02#3`), plus its first 60 characters. A spec edit that reorders criteria then
fails the audit loudly instead of matching silently.

**Alternatives**: automatic text matching of test names to criteria (rejected: it's unreliable
across about 150 criteria, and test names paraphrase); a YAML map (rejected: it would need the `yaml`
package as a direct dependency, and a Markdown table is reviewable in the spec folder).

## R14. Release smoke check of plugin features

**Decision**: a manual checklist in `quickstart.md` §6, run on two devices: an Android 7.0 (API 24)
emulator and the reference device on the latest Android. It uses the store-signed bundle, installed
through `bundletool build-apks --connected-device`. It covers:
- Google sign-in, Drive backup and restore;
- a scheduled notification firing, and its action button;
- a WorkManager auto backup;
- the home widget refreshing;
- the banner, native, interstitial, and rewarded ads, and UMP consent;
- Pro purchase and Restore with a license tester;
- secure storage (the PIN survives a restart);
- share sheet export, PDF export, and biometric unlock.

Results go in `compliance.md`. Automating it would need real Google and Play accounts on a device,
which is out of scope.

## R15. Things deliberately not changed

- `config/dart_defines.json` stays committed. Firebase Android client values and the OAuth web
  client ID are public by design and already in the APK.
- `distribute.yml` stays. It gains the prod env file only if `PROD_ENV_JSON` is set, so its prod
  release builds request real ads like the tag build does.
- No Dart or pub dependency is added. The only new third-party pieces are CI actions:
  `reactivecircus/android-emulator-runner@v2`, plus `bundletool`, downloaded by a pinned URL with a
  checksum in `check_bundle.sh`.
