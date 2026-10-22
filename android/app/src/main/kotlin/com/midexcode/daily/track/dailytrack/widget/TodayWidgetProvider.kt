package com.midexcode.daily.track.dailytrack.widget

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.midexcode.daily.track.dailytrack.MainActivity
import com.midexcode.daily.track.dailytrack.R
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import org.json.JSONObject

/**
 * The 4×2 "today" widget (feature 008 research R20, contracts/android.md).
 *
 * Dart writes every string already localized and formatted into the
 * `glance.v1` JSON (data-model §6); this class only displays it. It picks the
 * `today` or `next` block whose date matches the device's local date, so the
 * widget is right just after midnight even before Dart runs. With no
 * matching block, or in hidden mode, it shows only "Open DailyTrack".
 */
class TodayWidgetProvider : HomeWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val payload = parse(widgetData.getString(PAYLOAD_KEY, null))
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, render(context, payload))
        }
    }

    private fun parse(json: String?): JSONObject? = try {
        json?.let { JSONObject(it) }
    } catch (e: Exception) {
        null
    }

    private fun render(context: Context, payload: JSONObject?): RemoteViews {
        val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
        val day = if (payload?.optString("mode") == "data") {
            listOf("today", "next")
                .mapNotNull { payload.optJSONObject(it) }
                .firstOrNull { it.optString("dateKey") == today }
        } else {
            null
        }
        val open = HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse("dailytrack://widget/open"),
        )
        if (day == null) {
            return RemoteViews(context.packageName, R.layout.widget_hidden).apply {
                payload?.optString("openLabel")?.takeIf { it.isNotEmpty() }?.let {
                    setTextViewText(R.id.widget_open_label, it)
                }
                setOnClickPendingIntent(R.id.widget_root, open)
            }
        }
        return RemoteViews(context.packageName, R.layout.widget_today).apply {
            setOnClickPendingIntent(R.id.widget_root, open)
            bindSpend(day)
            bindBudget(day)
            bindHabits(context, day)
        }
    }

    private fun RemoteViews.bindSpend(day: JSONObject) {
        val spend = day.optJSONObject("spend")
        if (spend == null) {
            setViewVisibility(R.id.widget_spend_row, View.GONE)
            return
        }
        setViewVisibility(R.id.widget_spend_row, View.VISIBLE)
        setTextViewText(R.id.widget_spend_label, spend.optString("label"))
        setTextViewText(R.id.widget_spend_amount, spend.optString("amount"))
        setContentDescription(R.id.widget_spend_row, spend.optString("a11y"))
    }

    private fun RemoteViews.bindBudget(day: JSONObject) {
        val budget = day.optJSONObject("budget")
        val bars = mapOf(
            "under" to R.id.widget_budget_bar_under,
            "warning" to R.id.widget_budget_bar_warning,
            "over" to R.id.widget_budget_bar_over,
        )
        bars.values.forEach { setViewVisibility(it, View.GONE) }
        if (budget == null) {
            setViewVisibility(R.id.widget_budget, View.GONE)
            return
        }
        setViewVisibility(R.id.widget_budget, View.VISIBLE)
        if (budget.has("none")) {
            setTextViewText(R.id.widget_budget_label, budget.optString("none"))
            setTextViewText(R.id.widget_budget_text, "")
            return
        }
        setTextViewText(R.id.widget_budget_label, budget.optString("label"))
        // The text always states the percent, so the bar color is never the
        // only signal (FR-050).
        setTextViewText(R.id.widget_budget_text, budget.optString("text"))
        val bar = bars[budget.optString("level")] ?: R.id.widget_budget_bar_under
        setViewVisibility(bar, View.VISIBLE)
        setProgressBar(bar, 100, budget.optInt("percent").coerceIn(0, 100), false)
    }

    private fun RemoteViews.bindHabits(context: Context, day: JSONObject) {
        val habits = day.optJSONArray("habits")
        val count = habits?.length() ?: 0
        setViewVisibility(R.id.widget_habits, if (count == 0) View.GONE else View.VISIBLE)
        for (i in SLOTS.indices) {
            val slot = SLOTS[i]
            val habit = if (i < count) habits?.optJSONObject(i) else null
            if (habit == null) {
                setViewVisibility(slot.root, View.INVISIBLE)
                continue
            }
            setViewVisibility(slot.root, View.VISIBLE)
            val done = habit.optBoolean("done")
            val isCount = habit.optString("kind") == "count"
            setImageViewResource(
                slot.icon,
                when {
                    done -> R.drawable.ic_widget_check_done
                    isCount -> R.drawable.ic_widget_plus
                    else -> R.drawable.ic_widget_check
                },
            )
            setTextViewText(slot.name, habit.optString("name"))
            val progress = habit.optString("progress").takeUnless { habit.isNull("progress") }
            setTextViewText(slot.progress, progress ?: "")
            setViewVisibility(slot.progress, if (progress == null) View.GONE else View.VISIBLE)
            setContentDescription(slot.root, habit.optString("a11y"))
            val check = Uri.parse("dailytrack://widget/check").buildUpon()
                .appendQueryParameter("habit", habit.optString("id"))
                .appendQueryParameter("day", day.optString("dateKey"))
                .build()
            setOnClickPendingIntent(
                slot.root,
                HomeWidgetBackgroundIntent.getBroadcast(context, check),
            )
        }
    }

    private data class Slot(val root: Int, val icon: Int, val name: Int, val progress: Int)

    companion object {
        /** The `home_widget` key Dart writes (`widgetPayloadKey`). */
        const val PAYLOAD_KEY = "glance.v1"

        private val SLOTS = listOf(
            Slot(R.id.habit_slot_0, R.id.habit_icon_0, R.id.habit_name_0, R.id.habit_progress_0),
            Slot(R.id.habit_slot_1, R.id.habit_icon_1, R.id.habit_name_1, R.id.habit_progress_1),
            Slot(R.id.habit_slot_2, R.id.habit_icon_2, R.id.habit_name_2, R.id.habit_progress_2),
            Slot(R.id.habit_slot_3, R.id.habit_icon_3, R.id.habit_name_3, R.id.habit_progress_3),
        )
    }
}
