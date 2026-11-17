package com.tehreem.barakah_time

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.SystemClock
import android.text.format.DateFormat
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.util.Date

/**
 * Home-screen widget: next prayer, a live countdown and the five prayer
 * times of that day.
 *
 * The Flutter app computes the times (7 days ahead) and sends them over the
 * `barakah_time/home_widget` channel (see MainActivity); they are kept in
 * SharedPreferences so the widget works while the app is closed. An alarm
 * refreshes the widget when each prayer time passes.
 */
class PrayerWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        render(context, appWidgetManager, appWidgetIds)
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        when (intent.action) {
            ACTION_TICK,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_TIMEZONE_CHANGED -> updateAll(context)
        }
    }

    override fun onDisabled(context: Context) {
        alarmManager(context)?.cancel(tickIntent(context))
    }

    companion object {
        private const val PREFS = "barakah_home_widget"
        private const val KEY_DATA = "data"
        private const val ACTION_TICK = "com.tehreem.barakah_time.WIDGET_TICK"
        private val PRAYERS = arrayOf("fajr", "dhuhr", "asr", "maghrib", "isha")
        private val NAME_IDS = intArrayOf(
            R.id.p0_name, R.id.p1_name, R.id.p2_name, R.id.p3_name, R.id.p4_name,
        )
        private val TIME_IDS = intArrayOf(
            R.id.p0_time, R.id.p1_time, R.id.p2_time, R.id.p3_time, R.id.p4_time,
        )
        private val GOLD = Color.parseColor("#F2D79B")
        private val TEXT = Color.parseColor("#FFFDF6")
        private val MUTED = Color.parseColor("#B9D0CF")

        /** Stores new data from the app and redraws every widget. */
        fun save(context: Context, json: String) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit().putString(KEY_DATA, json).apply()
            updateAll(context)
        }

        /** Clears the data (e.g. location unavailable) and redraws. */
        fun clear(context: Context) {
            context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .edit().remove(KEY_DATA).apply()
            updateAll(context)
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                ComponentName(context, PrayerWidgetProvider::class.java),
            )
            if (ids.isNotEmpty()) render(context, manager, ids)
        }

        private fun render(context: Context, manager: AppWidgetManager, ids: IntArray) {
            val views = buildViews(context)
            for (id in ids) manager.updateAppWidget(id, views)
        }

        private fun buildViews(context: Context): RemoteViews {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget)
            views.setOnClickPendingIntent(R.id.widget_root, openAppIntent(context))

            val raw = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
                .getString(KEY_DATA, null)
            val data = try {
                raw?.let { JSONObject(it) }
            } catch (_: Exception) {
                null
            }
            val labels = data?.optJSONObject("labels")
            val emptyText = labels?.optString("empty")?.takeIf { it.isNotEmpty() }
                ?: context.getString(R.string.widget_empty)

            val now = System.currentTimeMillis()
            val days = data?.optJSONArray("days")
            var dayIndex = -1
            var nextIndex = -1
            var nextTime = 0L
            if (days != null) {
                loop@ for (d in 0 until days.length()) {
                    val day = days.optJSONArray(d) ?: continue
                    for (p in 0 until minOf(day.length(), PRAYERS.size)) {
                        val t = day.optLong(p)
                        if (t > now) {
                            dayIndex = d
                            nextIndex = p
                            nextTime = t
                            break@loop
                        }
                    }
                }
            }

            if (dayIndex < 0 || days == null) {
                views.setViewVisibility(R.id.widget_content, View.GONE)
                views.setViewVisibility(R.id.widget_empty, View.VISIBLE)
                views.setTextViewText(R.id.widget_empty, emptyText)
                alarmManager(context)?.cancel(tickIntent(context))
                return views
            }
            views.setViewVisibility(R.id.widget_content, View.VISIBLE)
            views.setViewVisibility(R.id.widget_empty, View.GONE)

            val timeFormat = DateFormat.getTimeFormat(context)
            fun label(key: String) = labels?.optString(key)?.takeIf { it.isNotEmpty() }
                ?: key.replaceFirstChar { it.uppercase() }

            views.setTextViewText(R.id.next_label, label("next"))
            views.setTextViewText(R.id.next_name, label(PRAYERS[nextIndex]))
            views.setTextViewText(R.id.next_time, timeFormat.format(Date(nextTime)))

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                val base = SystemClock.elapsedRealtime() + (nextTime - now)
                views.setChronometer(R.id.next_countdown, base, null, true)
                views.setChronometerCountDown(R.id.next_countdown, true)
                views.setViewVisibility(R.id.next_countdown, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.next_countdown, View.GONE)
            }

            val day = days.getJSONArray(dayIndex)
            for (p in PRAYERS.indices) {
                val highlight = p == nextIndex
                views.setTextViewText(NAME_IDS[p], label(PRAYERS[p]))
                views.setTextViewText(
                    TIME_IDS[p],
                    if (p < day.length()) timeFormat.format(Date(day.optLong(p))) else "",
                )
                views.setTextColor(NAME_IDS[p], if (highlight) GOLD else MUTED)
                views.setTextColor(TIME_IDS[p], if (highlight) GOLD else TEXT)
            }

            scheduleTick(context, nextTime + 1000)
            return views
        }

        private fun openAppIntent(context: Context): PendingIntent {
            val intent = Intent(context, MainActivity::class.java)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP)
            return PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun tickIntent(context: Context): PendingIntent {
            val intent = Intent(context, PrayerWidgetProvider::class.java)
                .setAction(ACTION_TICK)
            return PendingIntent.getBroadcast(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
            )
        }

        private fun alarmManager(context: Context) =
            context.getSystemService(Context.ALARM_SERVICE) as? AlarmManager

        /** Redraws the widget right after the next prayer time passes. */
        private fun scheduleTick(context: Context, at: Long) {
            val am = alarmManager(context) ?: return
            val pi = tickIntent(context)
            try {
                val exactAllowed = Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                    am.canScheduleExactAlarms()
                if (exactAllowed && Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    am.setExactAndAllowWhileIdle(AlarmManager.RTC, at, pi)
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    // No exact-alarm permission: a short window keeps the
                    // refresh within a minute instead of "whenever".
                    am.setWindow(AlarmManager.RTC, at, 60_000L, pi)
                } else {
                    am.set(AlarmManager.RTC, at, pi)
                }
            } catch (_: SecurityException) {
                am.set(AlarmManager.RTC, at, pi)
            }
        }
    }
}
