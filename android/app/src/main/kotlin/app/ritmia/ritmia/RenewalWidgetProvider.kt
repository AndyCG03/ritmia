package app.ritmia.ritmia

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.res.Configuration
import android.graphics.Color
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import org.json.JSONObject
import java.time.LocalDate
import java.time.format.DateTimeFormatter
import java.util.Locale

/** A private recurrence snapshot survives process death; dates advance without opening Flutter. */
open class RenewalWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) = updateAll(context)
    override fun onAppWidgetOptionsChanged(context: Context, manager: AppWidgetManager, appWidgetId: Int, newOptions: Bundle) = updateAll(context)
    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action in listOf(Intent.ACTION_DATE_CHANGED, Intent.ACTION_TIME_CHANGED, Intent.ACTION_TIMEZONE_CHANGED, Intent.ACTION_LOCALE_CHANGED, Intent.ACTION_MY_PACKAGE_REPLACED)) updateAll(context)
    }
    companion object {
        const val STORE = "ritmia_widget"
        const val EXTRA_ID = "ritmia_subscription_id"
        private data class Entry(val id: String, val name: String, val amount: String, val date: LocalDate, val stops: Boolean)

        private fun nullableString(j: JSONObject, key: String): String? = if (j.isNull(key)) null else j.optString(key).takeIf { it.isNotEmpty() }

        /** Anchor arithmetic intentionally mirrors domain/subscription.dart (no accumulated month drift). */
        private fun nextDate(j: JSONObject, today: LocalDate): LocalDate? {
            return RenewalDates.nextDate(j.getString("anchorDate"), nullableString(j, "purchasedOn"),
                nullableString(j, "endsOn"), j.getString("cycle"), today)
        }

        private fun launch(context: Context, id: String?): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
                data = Uri.Builder().scheme("ritmia").authority("widget").appendPath(id ?: "home").build()
                if (id != null) putExtra(EXTRA_ID, id)
            }
            return PendingIntent.getActivity(context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE)
        }

        fun updateAll(context: Context) {
            val manager = AppWidgetManager.getInstance(context)
            val fullIds = manager.getAppWidgetIds(ComponentName(context, RenewalWidgetProvider::class.java))
            val rowIds = manager.getAppWidgetIds(ComponentName(context, RenewalRowWidgetProvider::class.java))
            if (fullIds.isEmpty() && rowIds.isEmpty()) return

            val snapshot = try { JSONObject(context.getSharedPreferences(STORE, Context.MODE_PRIVATE).getString("snapshot", "{}") ?: "{}") } catch (_: Exception) { JSONObject() }
            val tag = snapshot.optString("locale").ifEmpty { context.resources.configuration.locales[0].language }
            val locale = Locale.forLanguageTag(if (tag in listOf("es","en","pt","fr")) tag else "en")
            val config = Configuration(context.resources.configuration).apply { setLocale(locale) }
            val strings = context.createConfigurationContext(config).resources
            val theme = snapshot.optString("theme", "system")
            val dark = theme == "dark" || (theme == "system" && context.resources.configuration.uiMode and Configuration.UI_MODE_NIGHT_MASK == Configuration.UI_MODE_NIGHT_YES)

            val ink = Color.parseColor(if (dark) "#F2EEF7" else "#282338")
            val secondary = Color.parseColor(if (dark) "#AAA5B5" else "#6B6577")
            val alert = Color.parseColor(if (dark) "#F47D68" else "#C62F28")
            val accentText = Color.parseColor(if (dark) "#B9A3F5" else "#7251AF")

            val today = LocalDate.now()
            val entries = mutableListOf<Entry>()
            val items = snapshot.optJSONArray("items")
            if (items != null) for (i in 0 until items.length()) {
                try {
                    val j = items.getJSONObject(i)
                    val date = nextDate(j, today) ?: continue
                    entries.add(Entry(j.getString("id"), j.getString("name"), (if (j.optBoolean("free", false)) strings.getString(R.string.widget_free) else j.optString("amount")), date, nullableString(j, "endsOn") != null))
                } catch (_: Exception) { /* A malformed legacy record cannot blank the other rows. */ }
            }
            val top = entries.sortedWith(compareBy<Entry> { if(it.stops) 0 else 1 }.thenBy { it.date }.thenBy { it.name.lowercase(Locale.ROOT) }.thenBy { it.id }).take(3)
            val rows = intArrayOf(R.id.widget_row_1, R.id.widget_row_2, R.id.widget_row_3)
            val accents = intArrayOf(R.id.widget_accent_1, R.id.widget_accent_2, R.id.widget_accent_3)
            val names = intArrayOf(R.id.widget_name_1, R.id.widget_name_2, R.id.widget_name_3)
            val metas = intArrayOf(R.id.widget_meta_1, R.id.widget_meta_2, R.id.widget_meta_3)
            val amounts = intArrayOf(R.id.widget_amount_1, R.id.widget_amount_2, R.id.widget_amount_3)

            fun bindWidget(id: Int, compactRow: Boolean) {
                val view = RemoteViews(context.packageName, if (compactRow) R.layout.ritmia_widget_row else R.layout.ritmia_widget)
                view.setInt(R.id.widget_root, "setBackgroundResource", if (dark) R.drawable.widget_background_dark else R.drawable.widget_background_light)
                view.setTextViewText(R.id.widget_heading, strings.getString(R.string.widget_heading))
                view.setTextColor(R.id.widget_heading, ink)
                view.setTextViewText(R.id.widget_empty, strings.getString(R.string.widget_empty))
                view.setTextColor(R.id.widget_empty, secondary)
                view.setViewVisibility(R.id.widget_empty, if (top.isEmpty()) View.VISIBLE else View.GONE)
                view.setOnClickPendingIntent(R.id.widget_header, launch(context, null))
                view.setOnClickPendingIntent(R.id.widget_empty, launch(context, null))

                val minWidth = manager.getAppWidgetOptions(id).getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
                val maxVisible = if (compactRow && minWidth in 1..205) 2 else 3

                for (i in 0..2) {
                    val entry = if (i < maxVisible) top.getOrNull(i) else null
                    view.setViewVisibility(rows[i], if (entry == null) View.GONE else View.VISIBLE)
                    if (entry == null) continue
                    view.setInt(rows[i], "setBackgroundResource", if (dark) R.drawable.widget_card_dark else R.drawable.widget_card_light)
                    view.setInt(accents[i], "setBackgroundResource", if (entry.stops) R.drawable.widget_accent_coral else R.drawable.widget_accent_lavender)
                    if (!compactRow) {
                        view.setInt(amounts[i], "setBackgroundResource", if (dark) R.drawable.widget_pill_dark else R.drawable.widget_pill_light)
                    }
                    val date = entry.date.format(DateTimeFormatter.ofPattern("d MMM", locale))
                    val prefix = strings.getString(if (entry.stops) R.string.widget_stops else R.string.widget_renews)
                    val fullMeta = if (entry.stops && entry.date.isBefore(today)) "${strings.getString(R.string.widget_check)} · $date" else "$prefix · $date"
                    val displayMeta = if (compactRow) date else fullMeta
                    view.setTextViewText(names[i], entry.name)
                    view.setTextViewText(metas[i], displayMeta)
                    view.setTextViewText(amounts[i], entry.amount)
                    view.setTextColor(names[i], ink)
                    view.setTextColor(metas[i], if (entry.stops) alert else secondary)
                    view.setTextColor(amounts[i], if (compactRow) accentText else ink)
                    view.setContentDescription(rows[i], "${entry.name}, $fullMeta, ${entry.amount}")
                    view.setOnClickPendingIntent(rows[i], launch(context, entry.id))
                }
                manager.updateAppWidget(id, view)
            }

            for (id in fullIds) bindWidget(id, compactRow = false)
            for (id in rowIds) bindWidget(id, compactRow = true)
        }
    }
}

/** 1-row, 3-to-4-column horizontal widget alternative. */
class RenewalRowWidgetProvider : RenewalWidgetProvider()
