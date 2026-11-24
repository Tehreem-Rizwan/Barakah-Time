package com.tehreem.barakah_time

import android.hardware.GeomagneticField
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
        // Magnetic declination for the Qibla compass: Android's rotation
        // vector points to magnetic north, the Qibla bearing is from true north.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "barakah_time/geomagnetic",
        ).setMethodCallHandler { call, result ->
            if (call.method != "declination") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val lat = call.argument<Double>("latitude")
            val lng = call.argument<Double>("longitude")
            if (lat == null || lng == null) {
                result.error("bad_args", "missing coordinates", null)
            } else {
                val field = GeomagneticField(
                    lat.toFloat(),
                    lng.toFloat(),
                    0f,
                    System.currentTimeMillis(),
                )
                result.success(field.declination.toDouble())
            }
        }
    }
}
