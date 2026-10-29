---

description: "Task list for feature 012 Release Readiness"
---

# Tasks: Release Readiness

**Input**: Design documents from `/specs/012-release-readiness/`

**Prerequisites**: plan.md, spec.md, research.md (R1–R15), data-model.md, contracts/ (build.md, workflows.md, dev-seed.md, audit.md), quickstart.md

**Tests**: Required. Constitution IV says every acceptance criterion needs at least one automated test, and spec FR-033 makes the whole of `docs/spec.md` auditable. Widget tests use `pumpTestApp` with fakes and `NoAdsService` and never open a database (docs/CLAUDE.md). Unit tests that need real Drift use `makeRealContainer`. Write each story's tests first and confirm they fail. Criteria that need a device, CI, or a console are covered by a script or a numbered quickstart step instead; each task says which.

**Organization**: Tasks are grouped by the user stories in spec.md (US1–US6), so each story can be built and checked on its own.

**Rules for every task**:
- **Goldens**: generated on Linux only, never committed from Windows or macOS (docs/CLAUDE.md).
- **Strings**: go through `tool/l10n/phase0_strings.py` (en/hi/gu), then `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. Never edit ARB files by hand.
- **Secrets**: never commit `android/key.properties`, any `*.jks`/`*.keystore`, or `config/prod.env.json`, and never print a password or a real ad ID.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependency on an unfinished task)
- **[Story]**: The user story (US1–US6) the task belongs to
- Paths are from the repository root (single Flutter project, plan.md "Project Structure")

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Make the secret files impossible to commit, and document them, before any build change.

- [X] T001 Update `.gitignore` (research R1, planning input). Add these lines:
  - `key.properties` (any folder)
  - `*.jks`
  - `config/prod.env.json`

  Keep the existing `/android/key.properties`, `*.keystore` and `/android/local.properties`. Then verify that `git check-ignore -v android/key.properties android/upload-keystore.jks config/prod.env.json` prints a rule for all three. Confirm that `git ls-files` lists none of them.
  - *Done: `key.properties` (any folder) and `/config/prod.env.json` added; `*.jks` and `*.keystore` were already there. Note: `/config/dart_defines.json` is listed but the file is tracked (real Firebase client values), so the rule has no effect on it; left for the user to decide.*

- [X] T002 [P] Create `config/prod.env.example.json` with exactly the keys `ADMOB_APP_ID`, `ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`, `ADMOB_INTERSTITIAL_ID` and `ADMOB_REWARDED_ID`.
  - The values are placeholders: `ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX` for the App ID, and `ca-app-pub-XXXXXXXXXXXXXXXX/XXXXXXXXXX` for the four units (data-model §1).
  - It must not contain the test publisher `3940256099942544`.

- [X] T003 [P] Create `config/README.md` (data-model §1–§3). It covers:
  - How to create the upload key with `keytool`, and the `android/key.properties` format (`storeFile`, `storePassword`, `keyAlias`, `keyPassword`; `storeFile` relative to `android/`).
  - How to copy `prod.env.example.json` to `prod.env.json`.
  - The App ID precedence: `config/prod.env.json`, then `local.properties admob.appId`, then the `ADMOB_APP_ID` environment variable.
  - The five GitHub secrets (`ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, `PROD_ENV_JSON`) and how to make the base64 value (`base64 -w0 upload-keystore.jks`).
  - That `config/dart_defines.json` stays committed, because its Firebase client values and OAuth web client ID are public (research R15).

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: The production ad ID wiring. US3 (signed builds), US6 (no test IDs in prod), and the integration journeys in US2 all depend on it. They need `AdUnitIds` to behave the same in every build.

**⚠️ CRITICAL**: Finish this phase before US2, US3 or US6.

- [X] T004 Extend `test/core/ads/domain/ad_unit_ids_test.dart` first (research R5, contracts/audit.md). Rename the existing runtime cases to `AdUnitIds.resolveFor(...)` and keep them. Add:
  - **Debug or dev → test**: a dev flavor or any non-release build always returns `AdUnitIds.test`, even when `fromEnv` has real-looking IDs.
  - **Prod release, test App ID → none**: a prod release whose manifest uses the test App ID returns `AdUnitIds.none`.
  - **Prod release, real App ID → env IDs**: a prod release with a real App ID returns `fromEnv` format by format; a missing format is `null`.

  Confirm the new cases fail.

- [X] T005 Split ad ID resolution so the domain stays pure Dart (research R5, constitution II):
  - In `lib/core/ads/domain/ad_unit_ids.dart` (pure Dart, no Flutter import), rename today's `resolve({isProd, isRelease, manifestUsesTestAppId, fromEnv})` to `resolveFor(...)`, with the same body.
  - In `lib/core/ads/ad_providers.dart` (which may import Flutter), add a top-level `AdUnitIds resolveAdUnitIds({required bool manifestUsesTestAppId, required AdUnitIds fromEnv})`. It branches only on the compile-time constant `kReleaseMode && appFlavor == 'prod'` (`kReleaseMode` from `package:flutter/foundation.dart`, `appFlavor` from `package:flutter/services.dart`).
    - **Prod-release branch**: returns `manifestUsesTestAppId ? AdUnitIds.none : fromEnv`, and never references `AdUnitIds.test`.
    - **Otherwise**: returns `AdUnitIds.test`.
  - Add a doc comment explaining that the constant condition lets the AOT tree shaker drop the test IDs from prod release, and that tests use `resolveFor`.
  - Don't call `resolveFor` from `resolveAdUnitIds`: passing `AdUnitIds.test` through it would keep the test strings reachable in prod.
  - *Done as written. Verified on the built prod bundle: no `ca-app-pub` string in any `libapp.so`.*

- [X] T006 Wire the real IDs in `lib/app/production_overrides.dart` (research R4). Replace the `adUnitIdsProvider` override with:

  ```dart
  resolveAdUnitIds(
    manifestUsesTestAppId: const String.fromEnvironment('ADMOB_APP_ID').isEmpty,
    fromEnv: AdUnitIds.fromEnvironment(),
  )
  ```

  - Delete the "until T117 wires the release IDs" comment.
  - Keep `UmpConsentService.fromEnvironment(isProd: …)` as is.
  - Run `flutter test test/core/ads test/app` and confirm green.

**Checkpoint**: Ad IDs resolve from `prod.env.json` in prod release only. Every other build uses test IDs, and the prod branch is folded at compile time.

---

## Phase 3: User Story 1 - Visual regressions are caught before release (Priority: P1) 🎯 MVP

**Goal**: 28 required golden images: DSH-01, EXP-01, EXP-02, HAB-01, AUTH-01 and SET-01 (guest and Google), in light/dark × en/gu. They are generated on Linux by a manual workflow, committed by hand, and compared on every pull request.

**Independent Test**: In Linux CI, `flutter test --tags golden` passes against the committed baselines. Changing a token in `lib/core/theme/app_colors.dart` makes the affected images fail. On Windows, `flutter test --exclude-tags golden` skips them (spec US1, quickstart §2).

### Tests for User Story 1

- [X] T007 [P] [US1] Create `test/goldens/auth_settings_golden_test.dart`, `@Tags(['golden'])` (data-model §8, spec FR-001, FR-002). Follow the pattern in `test/goldens/home_golden_test.dart`:
  - a 360×800 view at `devicePixelRatio = 1`, with `addTearDown(tester.view.reset)`;
  - `pumpTestApp` with fakes; "now" fixed at 2026-10-14 10:00 through the existing fake clock;
  - `matchesGoldenFile('goldens/<name>_<theme>_<lang>.png')`.

  Scenarios, each for `theme ∈ {light, dark}` × `lang ∈ {en, gu}`:
  - **`AUTH-01 default`**: `authMode = none`, onboarding done, online. Both "Continue with Google" and "Continue as guest" are visible.
  - **`SET-01 guest card`**: `/more`, the `guest` fixture.
  - **`SET-01 Google card`**: `/more`, the `signedIn` fixture with `lastBackupAt` 5 minutes before now. A fixed initial, no photo URL.

  Reuse the account fixtures from `test/features/account/account_test_app.dart` (`guest`, `signedIn`). Copy them into the golden file if importing pulls in non-golden setup.

- [X] T008 [P] [US1] In `test/goldens/account_golden_test.dart`, delete the `'SYS-02 restore with Google'` scenario and any helper only it used (spec FR-005). That screen was removed in feature 011.

- [X] T009 [US1] Make sure the four §13 screens have the full matrix (spec FR-001):
  - `DSH-01 seeded` in `test/goldens/home_golden_test.dart`;
  - `EXP-01 content` and `EXP-02 new with amount` in `test/goldens/expense_screens_golden_test.dart`;
  - `HAB-01 five habits` in `test/goldens/habit_screens_golden_test.dart`.

  Each must list `themes: ['light', 'dark']` and `langs: ['en', 'gu']`; widen any scenario that's narrower. Other existing states stay as they are.
  - *Done (no change): all four scenarios already list light/dark × en/gu.*

- [X] T010 [US1] Check `test/flutter_test_config.dart` against the theme (research R7). Every `fontFamily` and `fontFamilyFallback` in `lib/core/theme/app_theme.dart` and the text theme must resolve to a family that `_loadFamily` loads:
  - If the theme names a family (for example `Roboto`) that isn't loaded, add a `_loadFamily` call that maps it to the bundled Noto files.
  - Add a comment there saying that goldens must never fall back to system fonts.
  - *Done: the theme names only `NotoSans` with `NotoSansDevanagari` and `NotoSansGujarati` fallbacks, all loaded; the rule is now a comment in `test/flutter_test_config.dart`.*

### Implementation for User Story 1

- [X] T011 [P] [US1] Create `.github/workflows/goldens.yml` (contracts/workflows.md "goldens.yml"):
  - **Trigger**: `workflow_dispatch` with an optional string input `filter`.
  - **Job**: `ubuntu-latest`. Use `actions/checkout@v4`, `actions/setup-java@v4` (temurin 17), and `subosito/flutter-action@v2` with `flutter-version: 3.47.x` and `cache: true`. Then `flutter pub get` and `dart run build_runner build --delete-conflicting-outputs`.
  - **Generate**: `flutter test --tags golden --update-goldens` (plus `--plain-name "$FILTER"` when `filter` is set).
  - **Upload**: `actions/upload-artifact@v4`, named `golden-baselines`, with path `test/goldens/*.png`.
  - It never commits, pushes, or opens a pull request (clarification Q5). Add a header comment with the review-and-commit steps.
  - *Implementation note: `matchesGoldenFile` writes next to the test files, so baselines are `test/goldens/*.png`, not `test/goldens/goldens/`. The workflow and docs use that path.*

- [ ] T012 [US1] Generate the baselines (quickstart §2, spec FR-004):
  1. Run the "Regenerate goldens" workflow on this branch.
  2. Download `golden-baselines` and unzip it into `test/goldens/` (next to the test files).
  3. Open each of the 28 required PNGs and check it: Gujarati glyphs aren't boxes, the dark theme is really dark, and nothing overflows.
  4. Commit them.

  If the workflow can't run yet (no push access to Actions), use WSL Ubuntu with Flutter 3.47.x instead. Never commit images rendered on Windows.

- [ ] T013 [US1] In `.github/workflows/ci.yml`, compare goldens on every pull request (research R7). In the same change that commits T012's baselines:
  - Change the Tests step to `flutter test --coverage`, with no `--exclude-tags golden`.
  - Delete the "No baselines are committed yet" comment.
  - Keep the `golden-failures` upload.

**Checkpoint**: Pull request CI compares 28+ golden images and fails on any pixel change. Windows test runs skip them.

---

## Phase 4: User Story 2 - The main journeys work end to end (Priority: P1)

**Goal**: Seven journeys on a real device database with fake Google clients and test ads, run offline from a fresh install: expense → Home → Reports, habit → streak, backup → erase → restore, guest, Google, app lock, and smoke.

**Independent Test**: With Wi-Fi off, `flutter test integration_test --flavor dev -d <emulator>` passes (spec US2, quickstart §3).

### Implementation for User Story 2

- [X] T014 [US2] Create `integration_test/helpers/app_harness.dart` (research R8):
  - **`Future<void> freshInstall()`**:
    - Opens `AppDatabase.open()` and deletes every table in reverse order, *including* `settings`, in one transaction.
    - Deletes every key from `FlutterSecureStorage`.
    - Deletes the app's receipts folder, the safety copy, and the device ID file under the app documents and support directories, using the same paths the reset service uses.
  - **`Future<HarnessWorld> launch(WidgetTester tester, {List<Override> extra})`**:
    - Pumps `ProviderScope(overrides: [...productionOverrides(), …], child: const DailyTrackApp())`.
    - The overrides are a recording `NotificationService`, a recording `BackgroundScheduler`, `adServiceProvider` → `NoAdsService`, and the in-memory `FakeAccountAuth` and fake Drive store.
    - Move the fakes out of `integration_test/account_backup_flow_test.dart`. Their stored backups and `calls` survive a sign-out and a relaunch, because `HarnessWorld` holds them across `launch` calls.
  - **`Future<void> restart(WidgetTester tester, HarnessWorld w)`**: pumps an empty widget, then `launch` again with the same fakes.

  Every journey calls `freshInstall()` in `setUp` (spec FR-010).
  - *Implementation note: the device ID file is kept (the erase keeps it too). The harness also binds `NoAdsService` and an online `FakeNetworkStateSource`, and adds `startAsGuest`.*

- [X] T015 [P] [US2] Fix `integration_test/app_smoke_test.dart` to use the harness. Rename the stale test to `'SYS-02 Skip on a fresh install opens AUTH-01 Login'` and assert that `LoginScreen` is shown, not Home (feature 011 changed this). Keep the language-survives-restart test, starting it through AUTH-01 "Continue as guest".

- [X] T016 [P] [US2] Move `integration_test/expense_flow_test.dart` to the harness. Before adding the expense, each test taps `auth01_guest` ("Continue as guest") from a fresh install. Keep all four journeys, and make sure "add an expense → EXP-01 → Home → Reports" asserts the Reports total (spec FR-006).
  - *Implementation note: kept the file's own launcher (its recording notifications are asserted); each journey now taps `auth01_guest` after Skip.*

- [X] T017 [P] [US2] Move `integration_test/backup_restore_test.dart` to the harness. Start as a guest through AUTH-01. Keep the "backup → erase → restore gives identical rows" assertion (spec FR-006).
  - *Implementation note: after feature 011, Erase all data keeps onboarding and lands on Home, so the stale "restarts at onboarding" step now expects Home.*

- [X] T018 [P] [US2] Create `integration_test/habit_flow_test.dart`, test `'HAB-02 create → HAB-01 check in → streak 1 on HAB-01 and HAB-03'` (spec FR-006, US2 scenario 2). From a fresh install:
  1. Go to AUTH-01, tap guest, then open the Habits tab.
  2. Tap the FAB to open HAB-02. Name the habit "Read", make it daily yes/no, and save.
  3. On HAB-01, tap the check on "Read". Its streak text shows 1.
  4. Open HAB-03. The current streak is 1.

  Use the existing widget keys from `test/features/habit/`.

- [X] T019 [P] [US2] Create `integration_test/guest_flow_test.dart` (spec FR-007, US2 scenario 4). Fresh install, then:
  1. Intro (SYS-02), going through the steps with the existing keys, then AUTH-01 "Continue as guest".
  2. Home, then the + menu, then "Add expense". Enter 250 and save. The expense shows on Home.
  3. More, scroll to `set01_logOutGuest`, tap it, then `acc04_confirm`.
  4. `LoginScreen` is shown, and the transactions table has 0 non-deleted rows.
  5. `restart`. `LoginScreen` is shown again, not Intro or SYS-03.
  6. `world.auth.calls` and `world.drive.calls` are both empty.

- [X] T020 [P] [US2] Create `integration_test/google_flow_test.dart` and delete `integration_test/account_backup_flow_test.dart` (spec FR-008, US2 scenario 5; research R8). Fresh install, then:
  1. Intro, then AUTH-01 "Continue with Google". The fake account chooser returns "me@example.com". The fake has no backup, so the app lands on Home, possibly after the "Finish setting up" sheet; dismiss it if shown.
  2. Add two expenses and one habit check-in.
  3. SET-02 "Back up now". The fake Drive store holds 1 backup.
  4. More → account card → ACC-01 → Sign out → ACC-03 "Remove data from this phone" (backup is up to date). The app is on `LoginScreen` with 0 rows.
  5. "Continue with Google" again. The phone has no data, so ACC-02 is **not** shown (docs/spec.md §16 ACC-02 "No data on this phone"): the restoring view (`auth01_restoring`) shows, then the "Finish setting up" sheet (app lock is off). Dismiss it. The rows are equal to step 2: same ids, amounts and dates.
  6. A second test in the same file covers the ACC-02 path. Sign in, add one expense, back up, then sign out through ACC-03 **keeping** the data on the phone. Sign in again: the phone has data, so ACC-02 is shown. Choose "Restore", and the rows equal the backup.

  Keep the 010 auto backup step from the old test only if it still fits this flow.

- [X] T021 [P] [US2] Create `integration_test/app_lock_flow_test.dart` (spec FR-009, US2 scenario 6). Fresh install, then:
  1. AUTH-01 guest → More → SET-05. Turn on app lock and set PIN `1234` twice through SYS-04.
  2. `restart`. SYS-03 `UnlockScreen` is shown.
  3. Enter `0000`. It's refused with the wrong-PIN text, and the screen stays locked.
  4. Enter `1234`. Home is shown.
  5. Move the injected clock past the lock timeout and send `AppLifecycleState.paused`, then `resumed`, through `tester.binding.handleAppLifecycleStateChanged`. SYS-03 is shown again.

  Use the clock override the lock session already uses (`lib/core/security/lock_session.dart`). If it reads `clock`, wrap with `withClock`.

- [ ] T022 [US2] Run all of `integration_test/` on an Android emulator with Wi-Fi and mobile data off:

  ```text
  flutter test integration_test --flavor dev --dart-define-from-file=config/dart_defines.json -d <emulator>
  ```

  Fix failures until it's green, and write the result in `compliance.md` (T060).

**Checkpoint**: All seven journeys pass offline on an emulator.

---

## Phase 5: User Story 3 - Signed release builds come from a tag (Priority: P1)

**Goal**: The prod store bundle is signed from `android/key.properties` (or secrets), shrunk with R8, versioned from `pubspec.yaml`, and carries the production ad IDs. A version tag builds it in CI, checks it, and attaches it with `mapping.txt` to a GitHub release.

**Independent Test**: Locally, quickstart §5 gives a signed `.aab` that passes `check_bundle.sh … prod`. In CI, pushing `vX.Y.Z` (quickstart §7) produces a GitHub release with the `.aab` and `mapping.txt`. A missing secret or a version mismatch fails in `verify` (spec US3).

### Implementation for User Story 3

- [X] T023 [US3] Add release signing to `android/app/build.gradle.kts` (contracts/build.md, research R1):
  - **Load the file**: above `android {}`, load `rootProject.file("key.properties")` into a `Properties` when it exists.
  - **Create the config**: in `android { signingConfigs { … } }`, create `release` only when the file exists. Use `storeFile = rootProject.file(props["storeFile"])` (absolute paths are left as they are), plus `storePassword`, `keyAlias` and `keyPassword`.
  - **`buildTypes.release`**: `signingConfig = signingConfigs.findByName("release") ?: signingConfigs.getByName("debug")`.
  - **Remove** the `TODO` comment and the "Signing with the debug keys for now" comment.
  - **New `checkReleaseSigning` task**, hooked to `preProdReleaseBuild` next to `checkAdmobAppId`. When `isStoreBuild`, it fails with these exact messages and never prints a password:
    - `Release signing missing: create android/key.properties (see config/README.md)`
    - `Release signing: key.properties is missing <key>`
    - `Release signing: keystore not found at <resolved path>`
  - **Not a store build and no file**: log a warning ("Release build signed with the debug key").

- [X] T024 [US3] Turn on R8 in `android/app/build.gradle.kts` `buildTypes.release` (research R2): `isMinifyEnabled = true`, `isShrinkResources = true`, and `proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")`.

  Create `android/app/proguard-rules.pro` with commented sections:
  - **flutter_local_notifications (Gson)**: `-keep class com.google.gson.reflect.TypeToken { *; }`, `-keep class * extends com.google.gson.reflect.TypeToken`, and `-keepattributes Signature, *Annotation*`.
  - **Flutter embedding (deferred components not used)**: `-dontwarn com.google.android.play.core.**`.

  Build once with `flutter build appbundle --release --flavor prod`. Add each line from `build/app/outputs/mapping/prodRelease/missing_rules.txt`, with a comment naming the plugin it comes from.
  - *Done: the first shrunk build produced no `missing_rules.txt`, so no extra rules. The release build also needed `tools:ignore="FullBackupContent"` on the secure storage excludes in both backup rule files (release lint rejects an exclude outside the include list); the excludes stay as the tested guarantee.*

- [X] T025 [US3] Read the App ID from `config/prod.env.json` in `android/app/build.gradle.kts` (research R4, contracts/build.md):
  - Parse `rootProject.file("../config/prod.env.json")` with `groovy.json.JsonSlurper` when it exists.
  - The order is: `ADMOB_APP_ID` from the file, then `localProperties["admob.appId"]`, then `System.getenv("ADMOB_APP_ID")`. Blank values are skipped.
  - Update the `checkAdmobAppId` message to `AdMob App ID missing: set ADMOB_APP_ID in config/prod.env.json, admob.appId in android/local.properties, or the ADMOB_APP_ID environment variable`.
  - Update the header comment to list the three sources.

- [X] T026 [US3] Version from pubspec (research R3, spec FR-022). Leave `versionCode = flutter.versionCode` and `versionName = flutter.versionName`. Replace the template comment above them with one line: "From pubspec.yaml `version: name+code`; never pass --build-name or --build-number". Then grep `.github/workflows/` and `tool/` for `--build-name` and `--build-number`; none may remain.
  - *Gradle part done, plus `targetSdk = maxOf(36, flutter.targetSdkVersion)` (research R13). `.github/workflows/distribute.yml` passed `--build-number=${{ github.run_number }}` (tester builds reached version code 9 while pubspec said 1). The user chose pubspec only: the flag is removed and `pubspec.yaml` is now `1.0.0+10`.*

- [ ] T027 [P] [US3] Create `tool/release/check_bundle.sh <aab> <prod|dev>` (bash, `set -euo pipefail`, contracts/build.md "check_bundle.sh"):
  - **Setup**: download `bundletool-all-<pinned>.jar` from its GitHub release URL into `build/tools/`, check its SHA-256, and use the cached jar if the hash matches. Unzip the `.aab` into a temp folder.
  - **Manifest**: read it with `java -jar bundletool dump manifest --bundle <aab>`.
  - **prod checks**:
    - no `3940256099942544` in `strings base/lib/*/libapp.so` or in the manifest;
    - the manifest `com.google.android.gms.ads.APPLICATION_ID` matches `^ca-app-pub-\d{16}~\d{10}$` and isn't the test publisher.
  - **dev checks**: no `ca-app-pub-` ID other than the test publisher in `libapp.so` or the manifest.
  - **Both**:
    - `versionName` and `versionCode` equal `pubspec.yaml`, parsed with `sed`;
    - `minSdkVersion` is 24;
    - `targetSdkVersion` is at least `PLAY_MIN_TARGET_SDK`, a variable at the top of the script set to 36. Play requires API 36 for new apps and updates from 31 Aug 2026 (research R13, confirmed 2026-10-28). The comment above it links developer.android.com/google/play/requirements/target-sdk and says to raise it each year;
    - if `flutter.targetSdkVersion` in Flutter 3.47 is below 36, set `targetSdk = 36` in `android/app/build.gradle.kts` `defaultConfig`, with the same comment;
    - no `android.permission.USE_EXACT_ALARM`.
  - **prod signing**: `jarsigner -verify -certs`, and the certificate subject isn't `CN=Android Debug`.
  - **Output**: one `::error::<reason>` line per failure, exit 1 if any failed. Never echo ID values. Print only "prod App ID: set".

- [X] T028 [P] [US3] Create `tool/release/apk_sizes.sh` (research R10, spec FR-016):
  - Run `flutter build apk --release --flavor prod --split-per-abi --dart-define-from-file=config/dart_defines.json`, plus `--dart-define-from-file=config/prod.env.json` when that file exists.
  - For each `build/app/outputs/flutter-apk/app-*-prod-release.apk`, print the ABI and its size in MB to 2 decimals.
  - Exit 1 with an `::error::` line if any is ≥ 26,214,400 bytes. This check blocks the release (clarification Q4).

- [ ] T029 [US3] Create `.github/workflows/release.yml` (contracts/workflows.md "release.yml", research R12):
  - **Trigger**: `on: push: tags: ['v[0-9]+.[0-9]+.[0-9]+']`. `permissions: contents: write`, and `concurrency: group: release-${{ github.ref }}` with `cancel-in-progress: false`.
  - **Job `verify`**:
    - Each of `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD` and `PROD_ENV_JSON` is non-empty. Name each missing one in an `::error::` and exit 1.
    - `PROD_ENV_JSON` parses with `jq` and has all five keys, and no value contains `3940256099942544`.
    - The tag equals `v` + the version name from `pubspec.yaml` (the part before `+`). Otherwise print both and fail.
  - **Job `checks`** (needs `verify`): the same setup steps as `ci.yml`, then build_runner, `flutter analyze`, `dart format --set-exit-if-changed .`, and `flutter test --coverage`.
  - **Job `integration`** (needs `verify`): added in T030.
  - **Job `build`** (needs `checks` and `integration`):
    1. Decode the keystore with `echo "$ANDROID_KEYSTORE_BASE64" | base64 -d > "$RUNNER_TEMP/upload.jks"`.
    2. Write `android/key.properties` with `storeFile=$RUNNER_TEMP/upload.jks` and the three secrets.
    3. Run `::add-mask::` for every value in `PROD_ENV_JSON` (`jq -r '.[]'`), then write it to `config/prod.env.json`.
    4. Build with `DAILYTRACK_STORE_BUILD=true flutter build appbundle --release --flavor prod --dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json`.
    5. Run `tool/release/check_bundle.sh build/app/outputs/bundle/prodRelease/app-prod-release.aab prod`, then `tool/release/apk_sizes.sh`.
    6. Upload the artifact `dailytrack-${{ github.ref_name }}`: the `.aab` and `build/app/outputs/mapping/prodRelease/mapping.txt`, with `retention-days: 90`.
    7. Run `gh release create "$GITHUB_REF_NAME" --verify-tag --title "$GITHUB_REF_NAME" --generate-notes <aab> <mapping>`. If the release already exists (a re-run), use `gh release upload "$GITHUB_REF_NAME" <files> --clobber`. Set `GH_TOKEN: ${{ github.token }}`.
    8. An `if: always()` step runs `rm -f "$RUNNER_TEMP/upload.jks" android/key.properties config/prod.env.json`.
  - No Play upload (clarification Q1).
  - A header comment lists the secrets and points to `config/README.md`.

- [ ] T030 [US3] Add the `integration` job to `.github/workflows/release.yml` (research R9, clarification Q3):
  - **Runner**: `runs-on: ubuntu-latest` with `timeout-minutes: 60`.
  - **KVM**: enable it with the udev rule step `echo 'KERNEL=="kvm", GROUP="kvm", MODE="0666", OPTIONS+="static_node=kvm"' | sudo tee /etc/udev/rules.d/99-kvm4all.rules`, then `sudo udevadm control --reload-rules && sudo udevadm trigger --name-match=kvm`.
  - **Setup**: Java 17, Flutter 3.47.x, `flutter pub get`, build_runner.
  - **AVD cache**: `actions/cache@v4` on `~/.android/avd/*` and `~/.android/adb*`, keyed `avd-34`.
  - **Emulator**: `reactivecircus/android-emulator-runner@v2` with `api-level: 34`, `target: google_apis`, `arch: x86_64`, `disable-animations: true`, `emulator-options: -no-window -gpu swiftshader_indirect -noaudio -no-boot-anim`.
  - **Script**: `flutter test integration_test --flavor dev --dart-define-from-file=config/dart_defines.json`.

  `build` has `needs: [checks, integration]`, so no bundle is built if a journey fails. Add a comment that "Re-run failed jobs" on the same tag is the recovery for an emulator flake.

- [ ] T031 [P] [US3] Change `.github/workflows/ci.yml` (contracts/workflows.md "ci.yml"):
  - Remove the `if: github.ref == 'refs/heads/main'` conditions from "Build prod App Bundle" and "Upload App Bundle", so every pull request and push builds the bundle with the debug key and no secrets (constitution "Development Workflow").
  - Pass `--dart-define-from-file=config/dart_defines.json`.
  - Replace the comment "Release signing uses the debug key until T5.2 (plan Open item 5)" with "Store-signed bundles come only from release.yml".

- [ ] T032 [P] [US3] Change `.github/workflows/distribute.yml` (contracts/workflows.md "distribute.yml"). Add an optional `PROD_ENV_JSON` secret:
  - When it's non-empty and `flavor == prod`, mask its values, write `config/prod.env.json`, and add `--dart-define-from-file=config/prod.env.json` to the build command.
  - Delete the file in an `if: always()` step.
  - List the secret in the header comment.

- [ ] T033 [US3] Local signed-build check (quickstart §5, spec US3 scenarios 1–4, 7):
  1. With a real or throwaway `android/key.properties` and `config/prod.env.json`, build the store bundle. `check_bundle.sh … prod` passes.
  2. Rename `key.properties` and build with `-PstoreBuild=true`. The build fails with "Release signing missing…".
  3. Blank `ADMOB_APP_ID`. A store build fails with "AdMob App ID missing…".
  4. Check that neither Gradle output contains a password or an ID value.
  5. Build `flutter build appbundle --flavor dev --release` and run `check_bundle.sh … dev`. It passes.

  Write the results in `compliance.md` (T060). Restore the files afterwards, and leave nothing tracked.

- [ ] T034 [US3] Tag dry run (quickstart §7, spec US3 scenarios 5 and 6, SC-005). Use a **fork** of the repo with its own throwaway keystore and test-shaped secrets. Never edit the trigger pattern in `release.yml`. **Ask the user before pushing any tag**, even to the fork, because it creates a GitHub release there.
  1. In the fork, with every secret set and `pubspec.yaml` at `1.0.0+1`, push `v1.0.0`. `verify`, `checks`, `integration` and `build` are green, and the run artifact and the GitHub release hold the `.aab` and `mapping.txt`.
  2. Remove one secret and use "Re-run all jobs". `verify` fails and names it.
  3. Push `v1.0.1` without changing `pubspec.yaml`. `verify` fails and prints both versions.

  Delete the fork's test releases and tags afterwards. Write the results in `compliance.md` (T060).

**Checkpoint**: Signed, shrunk, correctly versioned prod bundles with real ad IDs come only from a tag. Every check fails loudly and leaks nothing.

---

## Phase 6: User Story 4 - The app meets the §13 performance targets with heavy data (Priority: P2)

**Goal**: A dev-only "Seed 10,000 transactions" action in SET-01 Developer, and device measurements of cold start, EXP-01 scrolling, writes and APK size, recorded with the blocking rule from clarification Q4.

**Independent Test**: In a dev profile build, seed 10,000 transactions, then run quickstart §4. `performance-report.md` lists every §13 target with its measured value and Pass/Open/Fail (spec US4).

### Tests for User Story 4

- [X] T035 [P] [US4] Create `test/features/expense/data/large_data_seeder_test.dart` over a real in-memory database (`makeRealContainer`), following contracts/dev-seed.md "Seeder". The seeded data:
  - **Count**: exactly 10,000 new `transactions` rows.
  - **Type mix**: expense 80% ± 2%, income 15% ± 2%, transfer 5% ± 2%.
  - **Amounts**: every amount is an `int` with `1000 <= amount <= 5000000`.
  - **Dates**: every `occurredAt` is UTC ms within `[now − 365 days, now]` (fixed clock).
  - **Transfers**: two distinct non-archived accounts.
  - **Accounts and categories**: only non-hidden categories of the matching type.
  - **Notes**: every 4th row has a note, and none has a receipt.
  - **Deletion and determinism**: `deletedAt` is null, and the same seed gives the same rows.

  Its side effects:
  - **Change counter**: `dataChangeCounter` goes up. The database triggers raise it for every inserted row (implementation note: not "exactly 1"; the seeder never writes it).
  - **No alerts or notifications**: the recording budget alert notifier and notification service get 0 calls.
  - **Repeat runs**: a second run brings the total to 20,000.
  - **Backup**: a backup round trip (`BackupService` export, then restore, over the same real database) keeps all 10,000 seeded rows with equal ids and amounts (spec FR-014).
  - **Export**: the expense module's transactions `ExportDataset` from `exportDatasets()` returns 10,000 more rows after seeding (spec FR-014).
  - **Erase**: `DriftAppResetService.eraseAll()` leaves 0.
  - **Busy**: while another `BackupCoordinator.run` holds the lease (start one with a gated body, or write a future `backupLeaseUntil` row), it returns `DevActionBusy` and adds 0 rows. After seeding, the lease is released (`backupLeaseUntil` is gone or in the past).
  - **Progress**: the callback receives 20 increasing values ending at 1.0.

- [X] T036 [P] [US4] Create `test/features/settings/developer_section_test.dart` (`pumpTestApp`, fakes, contracts/dev-seed.md "SET-01 Developer section"). Bind a fake module whose `devActions(read)` returns one `DevAction` with a gated `run`.
  - **Dev builds**: with `debugToolsAvailable = true`, the `developer_section` shows the row `dev_expense.seed10k`, titled "Seed 10,000 transactions".
  - **Confirm**: tapping it opens `dev_confirm`, and Cancel (`dev_confirm_cancel`) doesn't call `run`.
  - **Running**: OK (`dev_confirm_ok`) shows `dev_progress`, and the row is disabled while `run` is pending.
  - **Done**: completing with `DevActionDone(10000)` shows the snackbar `dev_done` with "Added 10,000 transactions".
  - **Busy**: `DevActionBusy` shows `dev_busy`.
  - **Prod**: with `debugToolsAvailable = false`, neither `developer_section` nor `dev_expense.seed10k` exists anywhere in the scrolled list (spec FR-013).
  - **Real module in prod**: add a unit test that `ExpenseModule().devActions(read)` returns empty when `debugToolsAvailableProvider` is overridden to false, and returns the `expense.seed10k` action when it is true.

- [X] T037 [P] [US4] Create `test/features/dashboard/startup_reporter_test.dart` (`pumpTestApp`). DSH-01 calls `StartupReporter.homeShown()` exactly once, after its first content frame. It isn't called while the screen is loading, and it isn't called again after a rebuild, a tab switch away and back, or a second `pumpTestApp` in the same process with the same container.

### Implementation for User Story 4

- [X] T038 [P] [US4] Create `lib/core/module/dev_action.dart` (contracts/dev-seed.md "Core API"):
  - `DevAction` with `id`, `labelKey`, `confirmKey`, `icon` and `run`.
  - The sealed `DevActionResult`, with `DevActionDone(int count)` and `DevActionBusy()`.

  In `lib/core/module/tracker_module.dart`, add `List<DevAction> devActions(ProviderReader read) => const [];` with a doc comment: "Developer-only actions shown in SET-01 Developer in the dev flavor; return const [] when `debugToolsAvailableProvider` is false. Never shown in prod."

- [X] T039 [P] [US4] Add strings to `tool/l10n/phase0_strings.py` in en, hi and gu:
  - `more_seedTransactions`: "Seed 10,000 transactions"
  - `more_seedConfirm`: "Add 10,000 sample transactions to test performance? They are real entries and stay until you delete them or erase all data."
  - `more_seedDone`: "Added {count} transactions" (`count` is an int, formatted with `NumberFormat.decimalPattern(locale)`)
  - `more_seedBusy`: "A backup or restore is running. Try again when it finishes."

  Run `python tool/l10n/phase0_strings.py` and `flutter gen-l10n`. No string may contain "sync".

- [X] T040 [US4] Create `lib/features/expense/data/dev/large_data_seeder.dart` (data-model §5, research R11), class `LargeDataSeeder`. `Future<DevActionResult> seed({int count = 10000, required void Function(double) onProgress})`:
  - **Busy guard**: run the whole seed inside `BackupCoordinator.run` (`lib/core/backup/data/backup_coordinator.dart`, reached through its provider in `lib/core/backup/backup_providers.dart`). That one lease covers every backup and every restore, in this isolate and in the background one. Catch `BackupBusy` and return `DevActionBusy()` before writing any row. While seeding holds the lease, a backup or restore started at the same time reports busy in the usual way.
  - **Load**: the non-archived accounts, and the non-hidden categories split by type.
  - **Random rows**: `Random(42)`. Type `r < 0.80` is expense, `< 0.95` income, otherwise transfer (two distinct accounts).
  - **Amount**: `(exp(normal(mean: ln(50000), sd: 1.2))).round()` clamped to `[1000, 5000000]`, in paise.
  - **Date**: `occurredAt = now − uniform(0, 365 days)`, in UTC ms.
  - **Note**: every 4th row gets one from a fixed list of 8 short English notes.
  - **Ids and timestamps**: the same uuid scheme and `createdAt`/`updatedAt` as `TransactionRepositoryImpl` does on insert.
  - **Insert**: 20 chunks of 500 with `db.transaction(() => db.batch((b) => b.insertAll(db.transactions, rows)))`, calling `onProgress((i + 1) / 20)` after each.
  - **Change counter**: leave it to the database triggers, which raise `dataChangeCounter` for every inserted row (implementation note: the "once at the end" plan was wrong; a manual bump would double-count).
  - **Never call**: the save use case, budget alert checks, or the interstitial counter (spec FR-015).
  - **Return**: `DevActionDone(count)`.

  It lives in `data/`, so it may use Drift.
  - *Implementation note: with fewer than two accounts, a transfer roll becomes an expense, because a transfer needs two accounts. Ids are random UUIDs; determinism covers type, amount, date, account and category.*

- [X] T041 [US4] In `lib/features/expense/expense_module.dart`, override `devActions(ProviderReader read)`:
  - Return `const []` unless `read(debugToolsAvailableProvider)` is true.
  - Otherwise return one `DevAction(id: 'expense.seed10k', labelKey: 'more_seedTransactions', confirmKey: 'more_seedConfirm', icon: Icons.dataset_outlined, run: (read, onProgress) => read(largeDataSeederProvider).seed(onProgress: onProgress))`.
  - Add `largeDataSeederProvider` in `lib/features/expense/expense_bindings.dart`.

  Run build_runner if a generated provider is used.
  - *Implementation note: no `largeDataSeederProvider`; `run` builds the seeder from `appDatabaseProvider`, `clockProvider` and `backupCoordinatorProvider`.*

- [X] T042 [US4] In `lib/features/settings/presentation/screens/settings_screen.dart`, Developer section (inside `if (data.devTools)`), after `reset_ad_counters`, add one `ListTile` per action from the enabled modules' `devActions(ref.read)`. Read them through the existing module registry provider the screen already uses for Export or SET-06; don't import `features/expense`.
  - **Key and text**: `dev_<id>`, with the title from `l10nLookup(labelKey)`.
  - **On tap**: an `AlertDialog` with key `dev_confirm`, the body from `confirmKey`, and the buttons `dev_confirm_cancel` and `dev_confirm_ok`.
  - **Running**: a `LinearProgressIndicator` with key `dev_progress` under the title. The tile is disabled until `run` finishes.
  - **Result**: a SnackBar, `dev_done` with `more_seedDone(count)` or `dev_busy` with `more_seedBusy`.
  - **State**: kept in `settings_controller.dart` as a `devActionRunning` id and a progress fraction. One Notifier per screen (constitution II).
  - **Styling**: only `AppTokens` and shared widgets.

  T036 must pass.
  - *Implementation note: the running id and progress live in controller fields that `build` reads, because `build` reruns on every settings change while seeding raises `dataChangeCounter`.*

- [X] T043 [P] [US4] Startup reporter (research R10):
  - **Port**: create `lib/core/startup/startup_reporter.dart`, pure Dart: `abstract interface class StartupReporter { void homeShown(); }`. Add `startupReporterProvider`, defaulting to a no-op, in `lib/core/startup/startup_providers.dart`.
  - **Channel**: create `lib/app/startup/channel_startup_reporter.dart`. It uses `MethodChannel('dailytrack/startup')` and calls `invokeMethod('reportFullyDrawn')` at most once per process (a static bool), ignoring `MissingPluginException`.
  - **Bind it**: in `lib/app/production_overrides.dart`.
  - **Native side**: in `android/app/src/main/kotlin/com/midexcode/daily/track/dailytrack/MainActivity.kt`, register the channel in `configureFlutterEngine` and call `reportFullyDrawn()` on `"reportFullyDrawn"`. Keep the existing code in that file.
  - **DSH-01**: in `lib/features/dashboard/presentation/screens/home_screen.dart`, after the first frame that shows content (not loading), call `ref.read(startupReporterProvider).homeShown()` once through `WidgetsBinding.instance.addPostFrameCallback`.

  T037 must pass.
  - *Implementation note: a keep-alive `reportHomeShownProvider` makes the call once per app run; the channel reporter also guards once per process.*

- [X] T044 [P] [US4] Create `test_driver/perf_driver.dart`. It uses `integrationDriver(responseDataCallback: …)` and writes each `reportData` key to `build/<key>.timeline_summary.json` through `flutter_driver`'s `TimelineSummary`, the standard pattern from the `integration_test` README.

- [X] T045 [US4] Create `integration_test/perf/exp01_scroll_perf_test.dart` (research R10, spec FR-016, FR-017). Use the harness (T014) and a guest start, then seed 10,000 rows with `LargeDataSeeder`, read from the container. Then:
  1. Open the Expenses tab (EXP-01) and wait for it to settle.
  2. Inside `binding.watchPerformance(() async { … }, reportKey: 'exp01_scroll')`, fling `transactions_list` down 15 times with `tester.fling(list, const Offset(0, -1500), 8000)` and `pumpAndSettle` between flings.
  3. Read the summary. The test fails if `missed_frame_build_budget_count + missed_frame_rasterizer_budget_count` is over 1.2% of `frame_count`. It prints Pass at 1% or below, and Open between 1% and 1.2% (clarification Q4).

  Run with `flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart --target integration_test/perf/exp01_scroll_perf_test.dart`.

- [X] T046 [US4] Create `integration_test/perf/write_perf_test.dart` (spec FR-016). Harness, guest start, and 10,000 seeded rows, plus one habit. Then:
  - Time 50 `TransactionRepository` saves of a new expense, each with a `Stopwatch` around the awaited repository call only.
  - Time 50 habit check-in toggles through the habit repository.
  - Report the p50/p95/max of each through `binding.reportData`.
  - Fail if either p95 is 100 ms or more. This always blocks (clarification Q4).

- [X] T047 [P] [US4] Create `tool/perf/cold_start.sh` (research R10):
  - Takes the package `com.midexcode.dailytrack` and a run count (default 10).
  - For each run, it runs `adb shell am force-stop <pkg>` and then `adb shell am start -W -S -n <pkg>/.MainActivity`. It parses `TotalTime`, and reads the `Fully drawn <pkg>/.MainActivity: +<n>ms` line from `adb logcat -d -s ActivityTaskManager` (clear the log with `-c` before each run).
  - It prints the median and p90 of both values.
  - It exits 1 if the median fully-drawn time is over 1800 ms. It prints Pass at 1500 ms or below, Open between 1501 and 1800 ms, and Fail above that (clarification Q4).
  - The activity component name comes from the manifest, because the namespace differs from the application ID.

- [ ] T048 [US4] Run the performance pass on the reference device, a mid-range phone with about 4 GB RAM on Android 13 or later (quickstart §4):
  1. Install a dev profile build, then seed through the Developer section (spec US4 scenario 1).
  2. Run T045, T046 and T047, and run `tool/release/apk_sizes.sh`.
  3. Write `specs/012-release-readiness/performance-report.md` with one row per target, in the data-model §6 format: target, limit, device, build and commit, data, runs, measured value, result, and whether it blocks.

  Fix any blocking failure (writes, APK size), and any cold start or fps miss over 20%, before continuing. Record misses within 20% as open items for the next version.

- [X] T049 [US4] Tag the DSH-01 300 ms widget timing in `test/features/dashboard/home_perf_test.dart` with `perf` (`@Tags(['perf'])` or a per-test `tags: ['perf']`). Add a comment that the §13 cold start target is measured by `tool/perf/cold_start.sh` on a device (research R10). Keep the test.
  - *Done: the file was already tagged `perf`; added the comment.*

**Checkpoint**: 10,000 transactions can be seeded in dev only, and `performance-report.md` records every §13 target. The blocking targets pass.

---

## Phase 7: User Story 5 - The installed app looks finished (Priority: P2)

**Goal**: The launcher icon (adaptive and monochrome) and the splash (pre-12 and 12+, light and dark) are generated from `assets/branding/` and checked in CI. The privacy and terms links point to the final site.

**Independent Test**: A CI drift check passes, and `splash_colors_test` passes. On Android 7 and 13+ devices, the icon, themed icon and splash look right with no flash, and both links open (spec US5, quickstart §6).

### Tests for User Story 5

- [X] T050 [P] [US5] Create `test/core/theme/splash_colors_test.dart` (research R6). Read `pubspec.yaml` as text, and parse the `flutter_native_splash:` block's `color` and `color_dark` values (and the same under `android_12:`) with a regex. They must equal the default theme's light and dark surface colors in `lib/core/theme/app_colors.dart` (compare hex `#RRGGBB`). `icon_background_color` must equal the seed or brand constant used for the launcher background.

- [X] T051 [P] [US5] Create `test/core/config/app_links_test.dart` (spec FR-028, clarification Q2). With no defines:
  - `AppLinks.privacyPolicyUrl == 'https://daily-track-c5736.web.app/privacy'`;
  - `AppLinks.termsUrl == 'https://daily-track-c5736.web.app/terms'`;
  - both parse with `Uri.parse` to `scheme == 'https'` and `host == 'daily-track-c5736.web.app'`.

  The SET-01 link tests (find them with `grep -rn privacyPolicyUrl test/`) still pass.

### Implementation for User Story 5

- [X] T052 [US5] In `pubspec.yaml` `flutter_launcher_icons:`, set `min_sdk_android: 24` (research R6). Then run `dart run flutter_launcher_icons` and `dart run flutter_native_splash:create`, and commit any changed files under `android/app/src/main/res/`.

  Check that `res/mipmap-anydpi-v26/ic_launcher.xml` (and `ic_launcher_round.xml` if present) still has `<monochrome>`, and that `values-v31/styles.xml` and `values-night-v31/styles.xml` set the Android 12 splash icon background. If T050 fails, change the splash colors in `pubspec.yaml` to the token values, never the reverse, and regenerate.
  - *Done: regenerating gave byte-identical files, so the committed icons and splash already match `assets/branding/`.*

- [X] T053 [US5] In `lib/core/config/app_links.dart`, update the doc comment to "Final site (feature 012 clarification Q2); override per build with --dart-define". The defaults stay unchanged. Delete the phrase "the defaults are placeholders until the site is live".

- [X] T054 [US5] Add a "Branding is up to date" step to `.github/workflows/ci.yml`, after Code generation (research R6, contracts/workflows.md). It runs `dart run flutter_launcher_icons`, then `dart run flutter_native_splash:create`, then `git diff --exit-code -- android/app/src/main/res ios/Runner/Assets.xcassets`. On failure it prints "Run flutter_launcher_icons and flutter_native_splash:create and commit the result".

**Checkpoint**: Icons and splash can't drift from `assets/branding/`, and the links are final.

---

## Phase 8: User Story 6 - A final audit proves release readiness (Priority: P2)

**Goal**: Each item is checked by an automated test or by a reviewed document:
- every `docs/spec.md` acceptance criterion maps to a test;
- there are no leftover markers, and no "sync" in strings;
- there are no test ad IDs in prod;
- the code-controlled Play items pass, and the console items are listed as manual steps.

**Independent Test**: `flutter test test/audit test/android test/core/l10n` passes. Adding `// TODO x` to `lib/main.dart` makes `markers_test` fail, and removing a row from `criteria-coverage.md` makes `criteria_coverage_test` fail (spec US6, quickstart §1).

### Tests for User Story 6

- [ ] T055 [P] [US6] Create `test/audit/markers_test.dart` (spec FR-034, contracts/audit.md).
  - **Folders scanned**: `lib/`, `test/`, `integration_test/`, `tool/`, `test_driver/`, `.github/workflows/`, `android/app/build.gradle.kts`, and `android/app/src/main/**/*.{kt,xml}`.
  - **Skipped**: `*.g.dart`, `*.freezed.dart`, `lib/core/l10n/gen/`, binary files, and this test file. Its own pattern list is built from split strings, so it doesn't match itself.
  - **Patterns** (case-insensitive): `\bTODO\b`, `\bFIXME\b`, `Replaced in`, `\bInterim\b`.
  - **On failure**: print `path:line: text` for each hit.

  Fix every hit it finds: remove the marker, or do the work it points to. The `TODO` in `android/app/build.gradle.kts` goes away in T023.

- [ ] T056 [P] [US6] Create `test/audit/google_scopes_test.dart` (§13, research R13). `GoogleAuth.scopes` (`lib/core/backup/data/google_auth.dart`) plus the sign-in's default scopes must be exactly `{email, profile, https://www.googleapis.com/auth/drive.appdata}`. If the default scopes aren't readable in code, assert `GoogleAuth.scopes == [drive.DriveApi.driveAppdataScope]` and grep `lib/` for other `googleapis.com/auth/` strings, expecting none.

- [ ] T057 [P] [US6] Extend `test/android/manifest_test.dart` (§13 exact alarms, research R13):
  - Assert that `android.permission.USE_EXACT_ALARM` isn't declared.
  - Assert that the declared permissions are exactly this allow-list: `POST_NOTIFICATIONS`, `USE_BIOMETRIC`, `RECEIVE_BOOT_COMPLETED`, `SCHEDULE_EXACT_ALARM`, `INTERNET`, `ACCESS_NETWORK_STATE`, plus whatever else the current manifest declares. Read the file first and list them all in the test.
  - Add a comment that `SCHEDULE_EXACT_ALARM` is justified in `specs/012-release-readiness/compliance.md`.

- [ ] T058 [US6] Create `test/audit/criteria_coverage_test.dart` (spec FR-033, data-model §7, research R13).
  - **Parse `docs/spec.md`**: find each heading whose text contains "Acceptance criteria" (as `**Acceptance criteria:**` or a heading), and collect the `- [ ]` and `- [x]` items until the next heading. Section IDs come from the nearest `###` Screen ID (for example `EXP-02`), or the `##` section number (for example `§11`), or a `§16-<subheading slug>` form. Each item's ID is `<section>#<1-based index>`.
  - **Parse the table** in `specs/012-release-readiness/criteria-coverage.md`, with the columns `ID | Criterion | Test`.
  - **Fail** when:
    - a spec item has no row, or a row has no spec item;
    - the `Criterion` cell isn't the first 60 characters of the spec text (whitespace normalized);
    - a `Test` cell `path :: "name"` names a file that doesn't exist, or one that doesn't contain the quoted name;
    - a `device:` or `manual:` cell doesn't name a quickstart section or `compliance.md`.
  - **Print** every problem, not just the first.

### Implementation for User Story 6

- [ ] T059 [US6] Write `specs/012-release-readiness/criteria-coverage.md` (data-model §7). Generate the ID and Criterion columns with a throwaway script in the scratchpad, using T058's parser rules. Then fill the Test column by hand:
  - Use the Screen ID test naming convention: grep the `test/` names for the Screen ID and the criterion's key words.
  - Use `device: quickstart §N` only for criteria that can't run in `flutter test` (icons on a launcher, a real notification firing, Android Auto Backup on a device).
  - Use `manual: compliance.md` only for console items.
  - Leave the Test cell as `GAP` for every criterion with no test. Don't write tests in this task.

  At the end of the file, add a "Gaps" section: the count, then one line per `GAP` row with its ID, its owner ("011 Tnnn" for a feature 011 open task, or "012 T067"), and the test file it belongs in. Report the count to the user before starting T067. T058 is expected to fail while gaps remain.

- [ ] T067 [US6] Close the gaps listed in `criteria-coverage.md`. It runs right after T059, out of numeric order on purpose: it was added later, and T060–T066 keep their IDs because other tasks refer to them.
  - For each gap owned by feature 011 (its open tasks 011 T030, 011 T042, 011 T043, 011 T050, 011 T052, 011 T058, 011 T065 and 011 T067), do that 011 task under 011 and mark it `[X]` in `specs/011-login-guest-mode/tasks.md`.
  - For every other gap, write the test in the right feature test file, named `<Screen ID> <criterion>`, and fix the code if the test shows a real defect (spec first if the spec is unclear, constitution I).
  - Replace each `GAP` cell with the new test. Work in batches by Screen ID, and run each batch's tests before moving on.
  - Done when the "Gaps" count is 0 and T058 passes. If the count is large, report progress per batch, and stop to ask the user if a gap needs a spec decision.

- [ ] T060 [US6] Write `specs/012-release-readiness/compliance.md` (contracts/audit.md, spec FR-037). It has three tables.

  **Code-controlled §13 items**, each with its check and result:
  - backup rules: `test/android/backup_rules_test.dart`;
  - privacy policy linked in SET-01: the SET-01 link test, plus T051;
  - no ads on lock, forms, onboarding, login, account dialogs or PRM: the 009 placement tests and 011's AUTH-01/ACC-04 ad tests, by file;
  - an 8 dp gap between ads and controls: the 009 test;
  - the frequency cap: `test/core/ads/…`;
  - `SCHEDULE_EXACT_ALARM` justified (user-set habit reminders and the daily summary at user-chosen times, with an inexact fallback when denied) and `USE_EXACT_ALARM` absent: T057;
  - purchase acknowledged and "Restore purchase" present: the 009 tests;
  - no financial or habit data sent to the ad SDK: the 009 test;
  - `tagForChildDirectedTreatment` unspecified: find the feature 009 test that asserts it (`grep -rn tagForChildDirectedTreatment test/`); if there is none, add one to `test/core/ads/` that checks the request configuration leaves it unspecified;
  - Google scopes: T056;
  - min and target SDK, and no test ad IDs in prod: `check_bundle.sh` (T033).

  **Console-only items**, as manual steps with what the code provides:
  - the data safety form: the data types list from §13;
  - OAuth consent verification: the scopes;
  - the 18+ target audience: no Families APIs;
  - `app-ads.txt`: the publisher ID lives in `prod.env.json`;
  - the internal testing track upload: the `.aab` from the GitHub release (clarification Q1).

  **Open items**: Java and Kotlin crash stacks in Crashlytics stay obfuscated, because `mapping.txt` is attached to each GitHub release but not uploaded to Crashlytics (research R2). Record it here as an open item for a later release.

  **Release smoke results**: the R14 / quickstart §6 checklist, with columns for Android 7.0 and the latest Android. Also record the T022, T033 and T034 run results.

- [ ] T061 [US6] Release smoke check on two devices (quickstart §6, research R14, spec SC-010):
  1. Install the store-signed bundle through `bundletool build-apks --connected-device` on an Android 7.0 (API 24) emulator and on the reference device with the latest Android.
  2. Go through every item in the quickstart §6 list, and fill the smoke table in `compliance.md`.
  3. Any crash or broken plugin feature is a blocker. Fix it, usually with a keep rule in `android/app/proguard-rules.pro` (T024), and re-test.

- [ ] T062 [US6] Update the specs when T058 passes (after T067), T061 has no blockers, and `performance-report.md` has no blocking failures (spec FR-038, contracts/audit.md "Spec updates"):
  - **`docs/spec.md` §14**: change `- [ ] T5.1` to `- [x] T5.1`. T5.2 stays `- [ ]`.
  - **`docs/spec.md` §13 Play Store checklist**: tick only the items `compliance.md` marks as code-controlled and passing (at least the Android Auto Backup rules item). Leave the console items unticked.
  - **`docs/CLAUDE.md`**:
    - Add a "Release" section with the store bundle command, `tool/release/check_bundle.sh`, `tool/release/apk_sizes.sh`, the tag routine (bump `pubspec.yaml`, then `git tag vX.Y.Z`), and the rule that `android/key.properties`, `*.jks` and `config/prod.env.json` are never committed.
    - Add to the goldens bullet: "Regenerate baselines with the manual 'Regenerate goldens' workflow, review, and commit".

**Checkpoint**: The criteria coverage, markers, wording, ad ID, permission, scope and backup rule checks pass. `compliance.md` and `performance-report.md` are complete, and §14 T5.1 is checked.

---

## Phase 9: Polish & Cross-Cutting Concerns

- [ ] T063 Run the quality gates (constitution "Development Workflow"):
  - `dart run build_runner build --delete-conflicting-outputs`;
  - `flutter analyze` with zero issues;
  - `dart format --set-exit-if-changed .`;
  - `flutter test --exclude-tags golden` on Windows. The machine has run out of memory on the full run before, so it may run folder by folder: `test/core`, `test/features`, `test/app`, `test/a11y`, `test/audit`, `test/android`, then the rest.
  - The goldens in Linux CI.

  Report exact pass and fail counts, and list any test that was skipped or not run.

- [ ] T064 [P] Run the §15.10 design review checklist on the SET-01 Developer section rows and dialog, and record the result in `compliance.md`:
  - tokens only;
  - 48 dp targets;
  - the confirm dialog at 200% font scale on 360 dp, with no overflow (add a case to `test/a11y/` if needed);
  - strings from ARB files.

- [ ] T065 [P] Secrets audit before handing back:
  - `git status --porcelain` and `git ls-files` list no `key.properties`, `*.jks`, `*.keystore` or `config/prod.env.json`.
  - `git grep -nE 'ca-app-pub-[0-9]{16}' -- ':!*3940256099942544*'` finds no real publisher ID outside `config/prod.env.example.json` placeholders.
  - `git grep -niE 'storePassword=|keyPassword='` finds only the documented placeholders in `config/README.md` and `quickstart.md`.

- [ ] T066 Mark completed tasks `[X]` in this file, with short notes for any decision made while implementing (for example the confirmed Play target SDK, or keep rules added from `missing_rules.txt`). Then summarize the files changed, tests added, checklist results and open items. Nothing is committed unless the user asks.

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: none. T001 comes first, before any file with secrets could exist.
- **Foundational (Phase 2)**: after Setup. It blocks US2 (journeys use the same ad resolution), US3, and US6's ad ID check.
- **US1 (Phase 3)**: needs only Setup. It can start right away, alongside Phase 2.
- **US2 (Phase 4)**: after Phase 2. T014 comes before T015–T021.
- **US3 (Phase 5)**: after Phase 2. T023–T026 edit `build.gradle.kts` in order. T027–T028 can run in parallel with them. T029 → T030 (same file). T033 needs T023–T028. T034 needs T029–T030 and US2's journeys (T022).
- **US4 (Phase 6)**: T038 → T040 → T041 → T042. T043 is independent. T045 and T046 need T014 (harness) and T040. T048 needs T045–T047 and T028.
- **US5 (Phase 7)**: independent of the others. T054 edits `ci.yml`, so do it after T013 and T031.
- **US6 (Phase 8)**: T055–T057 can start any time. T059 needs most other stories' tests in place, then T067 closes its gaps. T061 needs T033. T062 is last.
- **T062 (checking §14 T5.1) also needs feature 011's open tasks closed**, because `criteria_coverage_test` (T058) fails until 011's criteria have tests. T067 does those tasks under 011.
- **Polish (Phase 9)**: after everything.

### User Story Dependencies

- **US1 Goldens**: independent.
- **US2 Journeys**: needs Phase 2. US3's T034 and US4's perf tests reuse its harness.
- **US3 Release build**: needs Phase 2. Its tag workflow runs US2's suite.
- **US4 Performance**: needs US2's harness (T014) for the device perf tests, and US3's T028 for the APK size.
- **US5 Branding**: independent.
- **US6 Audit**: last. It checks the other five.

### Within Each User Story

- Tests come before implementation, and must fail first where they are unit or widget tests.
- Core types come before module code, then the screen, then the device runs.
- Several tasks edit the same file (`build.gradle.kts`, `release.yml`, `ci.yml`): run those one after another.

### Parallel Opportunities

- **Setup**: T002 and T003.
- **US1**: T007, T008 and T011.
- **US2**: T015–T021 after T014 (different files).
- **US3**: T027, T028, T031 and T032 alongside the Gradle edits.
- **US4**: T035, T036 and T037 (tests); T038, T039, T043, T044 and T047 (implementation).
- **US5**: T050 and T051.
- **US6**: T055, T056 and T057.
- **Across stories**: US1 and US5 can run alongside everything else.

---

## Parallel Example: User Story 2

```text
# After T014 (harness) is in place, write the journeys together:
Task: "T018 [US2] integration_test/habit_flow_test.dart"
Task: "T019 [US2] integration_test/guest_flow_test.dart"
Task: "T020 [US2] integration_test/google_flow_test.dart (delete account_backup_flow_test.dart)"
Task: "T021 [US2] integration_test/app_lock_flow_test.dart"
```

## Parallel Example: User Story 4

```text
Task: "T035 [US4] test/features/expense/data/large_data_seeder_test.dart"
Task: "T036 [US4] test/features/settings/developer_section_test.dart"
Task: "T037 [US4] test/features/dashboard/startup_reporter_test.dart"
Task: "T038 [US4] lib/core/module/dev_action.dart + TrackerModule.devActions(read)"
Task: "T039 [US4] strings in tool/l10n/phase0_strings.py"
```

---

## Implementation Strategy

### MVP first

1. Phase 1 Setup and Phase 2 Foundational: secrets can't be committed, and the real ad IDs are wired.
2. **US3** (signed build from a tag) is the true release blocker, and **US1** (goldens) is the first P1 that needs nothing else. Do US1 first if CI Actions access is still being set up; otherwise do US3 first.
3. **Stop and validate**: quickstart §5 (local signed bundle) and §2 (goldens).

### Incremental delivery

1. Setup and Foundational, then US1 goldens: CI catches visual regressions.
2. US2 journeys: core flows proven on a device.
3. US3 release build and tag workflow: shippable bundles. The tag run includes US2.
4. US5 branding check: quick and independent.
5. US4 seed and performance pass: numbers recorded.
6. US6 audit: proof of readiness, then T5.1 is checked.

### Notes

- Nothing here touches the Drift schema, the backup format, or any prod screen except DSH-01's single `homeShown()` call.
- Feature 011's open tasks T044, T060, T062 and T066 are covered here by T007, T019, T020 and T063. Mark them `[X]` in `specs/011-login-guest-mode/tasks.md` with a note "done in 012 Tnnn" when these pass.
- Commit only when the user asks.
