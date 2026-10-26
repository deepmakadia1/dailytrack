plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

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
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.midexcode.daily.track.dailytrack"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = 24
        targetSdk = flutter.targetSdkVersion
        // Uses the version code from pubspec.yaml. When using split APKs, 1000 * ABI_VERSION
        // is added automatically by Flutter. (https://developer.android.com/studio/build/configure-apk-splits#configure-APK-versions)
        // You can force using the value of versionCode by specifying the `-P force-version-code-ignoring-abi=true`
        // flag during build.
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
            applicationIdSuffix = ".dev"
            resValue("string", "app_name", "DailyTrack Dev")
        }
        create("prod") {
            dimension = "env"
            resValue("string", "app_name", "DailyTrack")
        }
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

// AdMob App ID (feature 009 research R2, contracts/android.md). Google's
// public test App ID is safe to commit; the real one never is. Prod release
// reads it from android/local.properties (`admob.appId`, git-ignored) or the
// ADMOB_APP_ID environment variable. Every other variant uses the test ID.
val admobTestAppId = "ca-app-pub-3940256099942544~3347511713"
val localProperties = java.util.Properties().apply {
    rootProject.file("local.properties").takeIf { it.exists() }?.inputStream()?.use { load(it) }
}
val prodAdmobAppId: String? =
    localProperties.getProperty("admob.appId")?.takeIf { it.isNotBlank() }
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
                "AdMob App ID missing: set admob.appId in android/local.properties or ADMOB_APP_ID",
            )
        }
    }
}
tasks.matching { it.name == "preProdReleaseBuild" }.configureEach {
    dependsOn(checkAdmobAppId)
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
