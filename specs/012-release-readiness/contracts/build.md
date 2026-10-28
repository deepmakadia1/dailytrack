# Contract: Android release build (`android/app/build.gradle.kts`)

## Inputs

| Input | Source | Missing means |
|---|---|---|
| Signing | `android/key.properties` → `storeFile`, `storePassword`, `keyAlias`, `keyPassword` | store build: **fail**; other release builds: debug key plus a warning |
| AdMob App ID | `config/prod.env.json` `ADMOB_APP_ID`, then `local.properties admob.appId`, then env `ADMOB_APP_ID` | store build: **fail**; other prod release builds: test App ID, and no ads requested |
| Store build flag | `-PstoreBuild=true`, env `DAILYTRACK_STORE_BUILD=true`, or `android/key.properties` exists | not a store build |
| Version | `flutter.versionName` / `flutter.versionCode` from `pubspec.yaml` | n/a |

## Behavior by variant

| Variant | Signing | Manifest App ID | Dart ad unit IDs | Shrink |
|---|---|---|---|---|
| `devDebug`, `prodDebug` | debug | test | `AdUnitIds.test` | no |
| `devRelease`, `devProfile` | release key if present, else debug | test | `AdUnitIds.test` | yes |
| `prodRelease`, not a store build, no App ID | debug (warning) | test | `AdUnitIds.none` (no requests) | yes |
| `prodRelease`, store build | **release key (required)** | **prod (required)** | from `prod.env.json`; a format with no ID is off | yes |

## Release build type

```kotlin
release {
    signingConfig = releaseSigning ?: signingConfigs.getByName("debug") // store builds fail earlier
    isMinifyEnabled = true
    isShrinkResources = true
    proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
}
```

## Failure messages (exact prefixes, used by tests and docs)

- `Release signing missing: create android/key.properties (see config/README.md)`
- `Release signing: key.properties is missing <key>`
- `Release signing: keystore not found at <resolved path>`
- `AdMob App ID missing: set ADMOB_APP_ID in config/prod.env.json, admob.appId in android/local.properties, or the ADMOB_APP_ID environment variable`

None of these prints a password or an ID value.

## Commands

| Purpose | Command |
|---|---|
| Store bundle (local) | `flutter build appbundle --release --flavor prod --dart-define-from-file=config/dart_defines.json --dart-define-from-file=config/prod.env.json` (with `key.properties` present) |
| Per-ABI size check | `tool/release/apk_sizes.sh` |
| Bundle audit | `tool/release/check_bundle.sh build/app/outputs/bundle/prodRelease/app-prod-release.aab prod` |
| Dev build | `flutter run --flavor dev --dart-define-from-file=config/dart_defines.json` (unchanged) |

## `tool/release/check_bundle.sh <aab> <prod|dev>`

The script exits non-zero and prints one `::error::` line per failure.

| Check | prod | dev |
|---|---|---|
| `strings base/lib/*/libapp.so` and the base manifest contain `3940256099942544` | fail | required (test IDs in use) |
| any `ca-app-pub-` other than the test publisher | required in the manifest | fail |
| manifest `versionName`/`versionCode` = pubspec | required | required |
| `minSdkVersion` = 24, `targetSdkVersion` ≥ Play minimum (36) | required | required |
| `USE_EXACT_ALARM` absent | required | required |
| bundle signed by the upload key (`jarsigner -verify`; certificate ≠ Android debug) | required | n/a |

`bundletool` comes from a pinned release URL and is checked by its SHA-256 before use.
