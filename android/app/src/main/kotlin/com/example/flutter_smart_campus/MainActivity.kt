package com.example.flutter_smart_campus

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "smart_campus/unity_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "isUnityReady" -> {
                        val isReady = UnityBridge.isUnityReady()
                        result.success(isReady)
                    }
                    "launchUnityCampus" -> {
                        val focusBuilding = call.argument<String>("focusBuilding")
                        val focusRoom = call.argument<String>("focusRoom")
                        val launched = UnityBridge.launchUnityCampus(this, focusBuilding, focusRoom)
                        result.success(launched)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            } catch (e: Exception) {
                android.util.Log.e("MainActivity", "Error in method channel: ${call.method}", e)
                result.error("CHANNEL_ERROR", e.message, null)
            }
        }
    }
}
