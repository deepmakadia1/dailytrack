package com.midexcode.daily.track.dailytrack.system

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import java.util.Calendar

/**
 * Wakes Dart just after local midnight so the widget and the daily summary
 * move to the new day (feature 008 research R21, SC-010). Exact when the
 * user allows exact alarms, otherwise within a 10-minute window.
 */
object GlanceAlarmScheduler {
    private const val WINDOW_MS = 10 * 60 * 1000L

    fun armMidnight(context: Context) {
        val alarms = context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager ?: return
        val at = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }.timeInMillis
        val intent = PendingIntent.getBroadcast(
            context,
            0,
            Intent(context, MidnightAlarmReceiver::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        val exact = Build.VERSION.SDK_INT < Build.VERSION_CODES.S || alarms.canScheduleExactAlarms()
        try {
            if (exact) {
                alarms.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, at, intent)
            } else {
                alarms.setWindow(AlarmManager.RTC_WAKEUP, at, WINDOW_MS, intent)
            }
        } catch (e: SecurityException) {
            alarms.setWindow(AlarmManager.RTC_WAKEUP, at, WINDOW_MS, intent)
        }
    }

    /** Runs the Dart background entry point with `dailytrack://system/<name>`. */
    fun notifyDart(context: Context, name: String) {
        try {
            HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("dailytrack://system/$name"),
            ).send()
        } catch (e: PendingIntent.CanceledException) {
            // Nothing to do; the next trigger or app open catches up.
        }
    }
}
