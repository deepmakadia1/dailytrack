# Android and Build Contracts

## `android/app/build.gradle.kts`

```kotlin
// Google's public test App ID (safe to commit).
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"

val localProps = java.util.Properties().apply {
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
val prodAdmobAppId: String? =
    localProps.getProperty("admob.appId")?.takeIf { it.isNotBlank() }
        ?: System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() }
val isStoreBuild: Boolean =
    (findProperty("storeBuild") as String?) == "true" ||
        System.getenv("DAILYTRACK_STORE_BUILD") == "true" ||
        rootProject.file("key.properties").exists()

androidComponents {
    onVariants { variant ->
        val isProdRelease = variant.flavorName == "prod" && variant.buildType == "release"
        val appId = if (isProdRelease) prodAdmobAppId ?: admobTestAppId else admobTestAppId
        variant.manifestPlaceholders.put("admobAppId", appId)
    }
}

// Only Play-upload builds must have the real App ID (clarification of /speckit-clarify Q2).
val checkAdmobAppId by tasks.registering {
    doLast {
        if (isStoreBuild && prodAdmobAppId == null) {
            throw GradleException(
                "AdMob App ID missing: set admob.appId in android/local.properties or ADMOB_APP_ID",
            )
        }
    }
}
tasks.matching { it.name == "preProdReleaseBuild" }.configureEach { dependsOn(checkAdmobAppId) }
```

A prod release built without a store flag and without the ID prints
`logger.warn("AdMob App ID not set; using the test App ID, no ads will be requested")`.

## `android/app/src/main/AndroidManifest.xml` (inside `<application>`)

```xml
<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" android:value="${admobAppId}"/>
<meta-data android:name="com.google.android.gms.ads.flag.OPTIMIZE_INITIALIZATION" android:value="true"/>
<meta-data android:name="com.google.android.gms.ads.flag.OPTIMIZE_AD_LOADING" android:value="true"/>
```

Merged automatically (not added by hand): `com.google.android.gms.permission.AD_ID`,
`com.android.vending.BILLING`, and the AdMob `AdActivity`.

## `MainActivity.kt`, `dailytrack/window` channel

- New method `getAdmobAppId`. It returns the `APPLICATION_ID` meta-data string, or null.
- Dart: `AdmobManifestSource` in `lib/core/ads/data/`. In a prod release, a value equal to the test
  App ID makes `AdUnitIds.resolve` return `AdUnitIds.none`.

## Dart defines

| Define | Used when | Purpose |
| --- | --- | --- |
| `ADMOB_BANNER_ID`, `ADMOB_NATIVE_ID`, `ADMOB_INTERSTITIAL_ID`, `ADMOB_REWARDED_ID` | prod release only | Real ad unit IDs (CI secrets) |
| `UMP_DEBUG_GEOGRAPHY` (`eea`, `notEea`) | dev only | Force the consent geography |
| `UMP_TEST_DEVICE_ID` | dev only | Hashed device ID for UMP debug and AdMob test devices |

## Build commands

| Purpose | Command |
| --- | --- |
| Dev (test IDs) | `flutter run --flavor dev` |
| Dev, consent form test | `flutter run --flavor dev --dart-define=UMP_DEBUG_GEOGRAPHY=eea --dart-define=UMP_TEST_DEVICE_ID=<id>` |
| CI pull request (no secrets) | `flutter build appbundle --flavor prod --release` → test App ID, warning, no ads |
| Play upload | `flutter build appbundle --flavor prod --release -PstoreBuild=true --dart-define=ADMOB_BANNER_ID=… (4 IDs)` with `admob.appId` in `local.properties` or `ADMOB_APP_ID` set |

**Repository rule (SC-010)**: no `ca-app-pub-` string other than publisher `3940256099942544` is
ever committed. `test/android/manifest_test.dart` scans `android/` and `lib/` for this.
