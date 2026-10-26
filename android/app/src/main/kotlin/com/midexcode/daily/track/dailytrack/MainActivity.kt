package com.midexcode.daily.track.dailytrack

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import com.midexcode.daily.track.dailytrack.system.GlanceAlarmScheduler
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

// A FragmentActivity because local_auth shows BiometricPrompt as a fragment
// (feature 007 research R2).
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The device's IANA zone for habit reminders (feature 005 research R1).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dailytrack/timezone")
            .setMethodCallHandler { call, result ->
                if (call.method == "getTimeZone") {
                    result.success(TimeZone.getDefault().id)
                } else {
                    result.notImplemented()
                }
            }
        // The home screen widget's midnight alarm (feature 008 research R21).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dailytrack/glance")
            .setMethodCallHandler { call, result ->
                if (call.method == "armMidnight") {
                    GlanceAlarmScheduler.armMidnight(applicationContext)
                    result.success(null)
                } else {
                    result.notImplemented()
                }
            }
        // Window and support calls (feature 007 research R9, R14, R17).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "dailytrack/window")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // FLAG_SECURE blocks screenshots and blanks the recents
                    // preview (SYS-03, "Hide app content in recents").
                    "setSecure" -> {
                        val on = call.arguments as? Boolean ?: false
                        runOnUiThread {
                            if (on) {
                                window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            } else {
                                window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                            }
                            result.success(null)
                        }
                    }
                    // Device facts for the feedback email; no identifiers.
                    "getDeviceInfo" -> result.success(
                        mapOf(
                            "manufacturer" to Build.MANUFACTURER,
                            "model" to Build.MODEL,
                            "release" to Build.VERSION.RELEASE,
                            "sdkInt" to Build.VERSION.SDK_INT,
                        ),
                    )
                    // Android's no-backup folder for the device ID file, which
                    // is never backed up or transferred (feature 010 R4).
                    "getNoBackupDir" -> result.success(noBackupFilesDir.absolutePath)
                    // The system notification settings for this app.
                    "openNotificationSettings" -> {
                        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                                .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                        } else {
                            Intent(
                                Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                                Uri.fromParts("package", packageName, null),
                            )
                        }
                        result.success(
                            try {
                                startActivity(intent)
                                true
                            } catch (e: Exception) {
                                false
                            },
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
