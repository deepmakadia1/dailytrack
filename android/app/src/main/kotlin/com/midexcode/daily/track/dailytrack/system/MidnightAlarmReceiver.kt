package com.midexcode.daily.track.dailytrack.system

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

/** The midnight alarm (feature 008 research R21): tells Dart, then re-arms. */
class MidnightAlarmReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        GlanceAlarmScheduler.notifyDart(context, "midnight")
        GlanceAlarmScheduler.armMidnight(context)
    }
}
