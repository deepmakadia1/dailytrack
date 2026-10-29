import groovy.json.JsonSlurper
import java.util.Properties

plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Release signing (feature 012 research R1, contracts/build.md). The upload
// key's details live in android/key.properties, which is git-ignored; see
// config/README.md. Without it, release builds fall back to the debug key so
// `flutter run --release` works, and store builds fail (checkReleaseSigning).
val keyProperties = Properties().apply {
    rootProject.file("key.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
val hasReleaseSigning = rootProject.file("key.properties").exists()
val releaseSigningKeys = listOf("storeFile", "storePassword", "keyAlias", "keyPassword")

android {
    namespace = "com.midexcode.daily.track.dailytrack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Required by flutter_local_notifications (see its README).
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        // The store ID, the same for dev and prod (so dev and prod replace
        // each other on a device). The Kotlin namespace above is the code
        // package and stays as it is.
        applicationId = "com.midexcode.dailytrack"
        minSdk = 24
        // Play requires API 36 for new apps and updates from 31 Aug 2026
        // (developer.android.com/google/play/requirements/target-sdk; feature
        // 012 research R13). Raise it each year; never below Flutter's default.
        targetSdk = maxOf(36, flutter.targetSdkVersion)
        // From pubspec.yaml `version: name+code`; never pass --build-name or
        // --build-number (feature 012 FR-022). Split-per-ABI APKs add
        // 1000 * ABI to the code; App Bundles keep it as is.
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildFeatures {
        // AGP 9 disables resValue by default; the flavors use it for app_name.
        resValues = true
    }

    flavorDimensions += "env"
    productFlavors {
        create("dev") {
            dimension = "env"
            resValue("string", "app_name", "DailyTrack Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "DailyTrack")
        }
    }

    signingConfigs {
        if (hasReleaseSigning) {
            create("release") {
                keyProperties.getProperty("storeFile")?.takeIf { it.isNotBlank() }?.let {
                    // Relative to android/, or an absolute path.
                    storeFile = rootProject.file(it)
                }
                storePassword = keyProperties.getProperty("storePassword")
                keyAlias = keyProperties.getProperty("keyAlias")
                keyPassword = keyProperties.getProperty("keyPassword")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
                ?: signingConfigs.getByName("debug")
            // R8 code and resource shrinking (feature 012 research R2), with
            // the keep rules the plugins don't ship in proguard-rules.pro.
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
        }
    }
}

// AdMob App ID (feature 009 research R2, contracts/android.md; feature 012
// research R4). Google's public test App ID is safe to commit; the real one
// never is. Prod release reads it, in order, from config/prod.env.json
// (`ADMOB_APP_ID`, git-ignored, the same file the build passes to Dart with
// --dart-define-from-file), android/local.properties (`admob.appId`,
// git-ignored), or the ADMOB_APP_ID environment variable. Every other variant
// uses the test ID.
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
// Imported above: in this script `java` is the java extension, not the package.
val localProperties = Properties().apply {
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
val prodEnv: Map<*, *> =
    rootProject.file("../config/prod.env.json").takeIf { it.exists() }
        ?.let { JsonSlurper().parse(it) as? Map<*, *> } ?: emptyMap<String, String>()
val prodAdmobAppId: String? =
    (prodEnv["ADMOB_APP_ID"] as? String)?.takeIf { it.isNotBlank() }
        ?: localProperties.getProperty("admob.appId")?.takeIf { it.isNotBlank() }
        ?: System.getenv("ADMOB_APP_ID")?.takeIf { it.isNotBlank() }

// A build meant for Play upload: -PstoreBuild=true, DAILYTRACK_STORE_BUILD=true,
// or the upload-key signing config (android/key.properties) is present.
val isStoreBuild: Boolean =
    (findProperty("storeBuild") as String?) == "true" ||
        System.getenv("DAILYTRACK_STORE_BUILD") == "true" ||
        rootProject.file("key.properties").exists()

androidComponents {
    onVariants { variant ->
        val isProdRelease = variant.flavorName == "prod" && variant.buildType == "release"
        if (isProdRelease && prodAdmobAppId == null && !isStoreBuild) {
            logger.warn("AdMob App ID not set; using the test App ID, no ads will be requested")
        }
        val appId = if (isProdRelease) prodAdmobAppId ?: admobTestAppId else admobTestAppId
        variant.manifestPlaceholders.put("admobAppId", appId)
    }
}

// Only Play-upload builds must have the real App ID (clarification Q2).
val checkAdmobAppId by tasks.registering {
    doLast {
        if (isStoreBuild && prodAdmobAppId == null) {
            throw GradleException(
                "AdMob App ID missing: set ADMOB_APP_ID in config/prod.env.json, " +
                    "admob.appId in android/local.properties, or the ADMOB_APP_ID environment variable",
            )
        }
    }
}
// Store builds must be signed with the upload key (feature 012 FR-020). The
// messages never include a password.
val checkReleaseSigning by tasks.registering {
    doLast {
        if (!isStoreBuild) {
            if (!hasReleaseSigning) {
                logger.warn("Release build signed with the debug key (no android/key.properties)")
            }
            return@doLast
        }
        if (!hasReleaseSigning) {
            throw GradleException(
                "Release signing missing: create android/key.properties (see config/README.md)",
            )
        }
        for (key in releaseSigningKeys) {
            if (keyProperties.getProperty(key).isNullOrBlank()) {
                throw GradleException("Release signing: key.properties is missing $key")
            }
        }
        val store = rootProject.file(keyProperties.getProperty("storeFile"))
        if (!store.exists()) {
            throw GradleException("Release signing: keystore not found at ${store.absolutePath}")
        }
    }
}
tasks.matching { it.name == "preProdReleaseBuild" }.configureEach {
    dependsOn(checkAdmobAppId)
    dependsOn(checkReleaseSigning)
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    // Theme.AppCompat for the local_auth BiometricPrompt (feature 007 R2).
    implementation("androidx.appcompat:appcompat:1.7.1")
}

flutter {
    source = "../.."
}
