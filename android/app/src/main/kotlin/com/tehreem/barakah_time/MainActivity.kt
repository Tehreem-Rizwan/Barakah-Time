package com.tehreem.barakah_time

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "barakah_time/home_widget",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "update" -> {
                    val json = call.argument<String>("data")
                    if (json == null) {
                        result.error("bad_args", "missing data", null)
                    } else {
                        PrayerWidgetProvider.save(applicationContext, json)
                        result.success(null)
                    }
                }
                "clear" -> {
                    PrayerWidgetProvider.clear(applicationContext)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
