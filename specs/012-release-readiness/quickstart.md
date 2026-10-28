# Quickstart: validating Release Readiness (feature 012)

Every command runs from the repo root. Windows users run the shell scripts in Git Bash.

## 0. Prerequisites

- Flutter 3.47.x, JDK 17, Android SDK with `platform-tools`, and `jq`.
- Copy `config/prod.env.example.json` to `config/prod.env.json` and fill in the real AdMob IDs.
  The file is git-ignored.
- For a signed build, create an upload key, then `android/key.properties` (git-ignored):
  ```text
  keytool -genkeypair -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
  ```
  ```properties
  storeFile=upload-keystore.jks
  storePassword=…
  keyAlias=upload
  keyPassword=…
  ```
- Confirm nothing secret is tracked:
  `git check-ignore android/key.properties android/upload-keystore.jks config/prod.env.json`
  must print all three.

## 1. Quality gates and the audit (any OS)

```text
dart run build_runner build --delete-conflicting-outputs
flutter analyze
dart format --set-exit-if-changed .
flutter test --exclude-tags golden          # Windows/macOS
```

The audit tests run as part of `flutter test` (`test/audit/`, `test/android/`, `test/core/l10n/`).

**Expected**: all green. Adding `// TODO x` to any file in `lib/` makes `markers_test` fail.
Removing a row from `criteria-coverage.md` makes `criteria_coverage_test` fail. ([contracts/audit.md](contracts/audit.md))

## 2. Goldens (Linux only)

1. In GitHub, go to Actions → **Regenerate goldens** → Run workflow, then download `golden-baselines`.
2. Unzip it into `test/goldens/` (next to the test files), review every PNG, and commit.
3. In WSL or CI: `flutter test --tags golden`.

**Expected**: 28 required images (see [data-model.md](data-model.md) §8) and the existing extra
states, all passing. Changing a token in `app_colors.dart` fails the affected images and writes
`failures/`.

## 3. Integration journeys (emulator)

```text
flutter test integration_test --flavor dev -d <emulator-id>
```

**Expected**: the expense, habit, backup, guest, Google, app lock, and smoke journeys pass with Wi-Fi
off. In the guest journey, the fake Google `calls` list stays empty.

## 4. Seed and performance pass (reference device, about 4 GB RAM)

1. Install a dev profile build:
   `flutter run --profile --flavor dev --dart-define-from-file=config/dart_defines.json`.
2. Go to More → Developer → **Seed 10,000 transactions** → Confirm. A progress bar shows, then
   "Added 10,000 transactions".
3. Scroll and writes:
   ```text
   flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart --target integration_test/perf/exp01_scroll_perf_test.dart
   flutter drive --profile --flavor dev --driver test_driver/perf_driver.dart --target integration_test/perf/write_perf_test.dart
   ```
   **Expected**: the scroll summary shows at most 1% missed frames (an open item is allowed up to
   1.2%), and the write p95 is under 100 ms.
4. Cold start: `tool/perf/cold_start.sh` (10 runs).
   **Expected**: the median "Fully drawn" time is under 1.5 s (an open item is allowed up to 1.8 s).
5. APK size: `tool/release/apk_sizes.sh`. **Expected**: every ABI is under 25 MB. This one blocks.
6. Record everything in `performance-report.md`.

## 5. Signed store bundle (local)

```text
flutter build appbundle --release --flavor prod --dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json
tool/release/check_bundle.sh build/app/outputs/bundle/prodRelease/app-prod-release.aab prod
```

**Expected**: the check passes. It confirms the upload-key signature, the version equal to pubspec,
the prod App ID, no test IDs, min SDK 24, and target SDK ≥ 36.

Negative checks:
- Rename `key.properties`, then run with `-PstoreBuild=true`. The build fails with
  "Release signing missing…".
- Empty `ADMOB_APP_ID` in a store build. It fails with "AdMob App ID missing…".

([contracts/build.md](contracts/build.md))

## 6. Release smoke check (Android 7.0 emulator and the latest Android)

```text
bundletool build-apks --bundle=app-prod-release.aab --output=app.apks --connected-device --ks=… --ks-key-alias=upload
bundletool install-apks --apks=app.apks
```

Tick each item in `compliance.md`:
- Google sign-in, Drive backup and restore;
- a notification and its action button;
- a WorkManager auto backup;
- the home widget;
- banner, native, interstitial, and rewarded ads, and UMP consent;
- Pro purchase and Restore (license tester);
- the PIN surviving a restart, and biometric unlock;
- CSV share and PDF export;
- the launcher icon (adaptive and themed on 13+), and the splash in light and dark with no flash;
- Privacy and Terms opening `https://dailytrack.midexcode.com/privacy` and `/terms`.

## 7. Tag release (CI)

1. Set the repository secrets `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`,
   `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`, and `PROD_ENV_JSON`.
2. Bump `version:` in `pubspec.yaml` (for example `1.0.0+1`), commit, then
   `git tag v1.0.0 && git push origin v1.0.0`.

**Expected**:
- `verify`, then `checks` and `integration`, then `build` all pass.
- The run has the artifact `dailytrack-v1.0.0`, and a GitHub release `v1.0.0` holds the `.aab` and
  `mapping.txt`.
- Pushing `v1.0.1` without bumping the pubspec fails in `verify`.
- Deleting one secret fails in `verify` and names it.

([contracts/workflows.md](contracts/workflows.md))

## 8. Manual steps (out of scope, listed in `compliance.md`)

These are done by hand:
- the Play Console app, the internal testing track upload, and the data safety form;
- the 18+ target audience;
- OAuth consent verification;
- the AdMob app and its units;
- hosting `/privacy`, `/terms`, and `app-ads.txt`.
