package com.midexcode.daily.track.dailytrack.system

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/**
 * Reboot, app update, and time zone change (feature 008 research R21,
 * FR-041): re-arms the midnight alarm and lets Dart reschedule every
 * notification against current data. All three broadcasts are exempt from
 * Android 8+ implicit broadcast limits.
 */
class SystemEventsReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val trigger = when (intent.action) {
            Intent.ACTION_BOOT_COMPLETED, Intent.ACTION_MY_PACKAGE_REPLACED -> "boot"
            Intent.ACTION_TIMEZONE_CHANGED -> "timezone"
            else -> return
        }
        GlanceAlarmScheduler.armMidnight(context)
        GlanceAlarmScheduler.notifyDart(context, trigger)
    }
}
