package app.ritmia.ritmia

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.provider.CalendarContract
import android.content.ActivityNotFoundException
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var widgetChannel: MethodChannel? = null
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        intent.getStringExtra(RenewalWidgetProvider.EXTRA_ID)?.let {
            widgetChannel?.invokeMethod("openSubscription", it)
            intent.removeExtra(RenewalWidgetProvider.EXTRA_ID)
        }
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        widgetChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ritmia/widget")
        widgetChannel!!.setMethodCallHandler { call, result ->
            when (call.method) {
                "getLaunchSubscription" -> {
                    result.success(intent.getStringExtra(RenewalWidgetProvider.EXTRA_ID))
                    intent.removeExtra(RenewalWidgetProvider.EXTRA_ID)
                }
                "sync" -> {
                    val snapshot = call.arguments as? String
                    if (snapshot == null) result.error("invalid_snapshot", "Missing snapshot", null)
                    else {
                        getSharedPreferences(RenewalWidgetProvider.STORE, MODE_PRIVATE).edit().putString("snapshot", snapshot).apply()
                        RenewalWidgetProvider.updateAll(this)
                        result.success(null)
                    }
                }
                "requestPin" -> {
                    val compact = (call.arguments as? Map<*, *>)?.get("compact") == true || call.arguments == "row"
                    val provider = if (compact) RenewalRowWidgetProvider::class.java else RenewalWidgetProvider::class.java
                    val manager = AppWidgetManager.getInstance(this)
                    result.success(Build.VERSION.SDK_INT >= Build.VERSION_CODES.O && manager.isRequestPinAppWidgetSupported &&
                        manager.requestPinAppWidget(ComponentName(this, provider), null, null))
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ritmia/calendar").setMethodCallHandler { call, result ->
            if (call.method != "insertEvent") result.notImplemented()
            else {
                val args = call.arguments as? Map<*, *>
                val begin = (args?.get("begin") as? Number)?.toLong()
                val end = (args?.get("end") as? Number)?.toLong()
                val title = args?.get("title") as? String
                if (begin == null || end == null || title == null || end <= begin) result.error("invalid_event", "Invalid calendar event", null)
                else try {
                    startActivity(Intent(Intent.ACTION_INSERT).setData(CalendarContract.Events.CONTENT_URI)
                        .putExtra(CalendarContract.Events.TITLE, title)
                        .putExtra(CalendarContract.Events.DESCRIPTION, args?.get("description") as? String ?: "")
                        .putExtra(CalendarContract.EXTRA_EVENT_ALL_DAY, true)
                        .putExtra(CalendarContract.EXTRA_EVENT_BEGIN_TIME, begin)
                        .putExtra(CalendarContract.EXTRA_EVENT_END_TIME, end))
                    result.success(true)
                } catch (_: ActivityNotFoundException) { result.success(false) }
            }
        }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.ritmia/settings").setMethodCallHandler { call, result ->
            when (call.method) {
                "getTimeZone" -> result.success(java.util.TimeZone.getDefault().id)
                // Opens Ritmia's own notification page; falls back to the app details page.
                "openNotificationSettings" -> {
                    val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    } else {
                        Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
                    }
                    try {
                        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)); result.success(true)
                    } catch (e: Exception) {
                        try {
                            startActivity(Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.fromParts("package", packageName, null))
                                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)); result.success(true)
                        } catch (e2: Exception) { result.success(false) }
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
}
