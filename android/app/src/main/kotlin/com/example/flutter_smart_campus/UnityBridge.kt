package com.example.flutter_smart_campus

import android.content.Context
import android.content.Intent
import android.util.Log
import com.unity3d.player.UnityPlayerGameActivity

object UnityBridge {
    private const val TAG = "UnityBridge"

    fun isUnityReady(): Boolean {
        return try {
            Class.forName("com.unity3d.player.UnityPlayerGameActivity")
            true
        } catch (e: Exception) {
            Log.e(TAG, "Unity activity not available", e)
            false
        }
    }

    fun launchUnityCampus(
        context: Context,
        focusBuilding: String?,
        focusRoom: String?,
    ): Boolean {
        return try {
            val intent = Intent(context, UnityPlayerGameActivity::class.java).apply {
                putExtra("focusBuilding", focusBuilding)
                putExtra("focusRoom", focusRoom)
                addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
            }
            context.startActivity(intent)
            true
        } catch (e: Exception) {
            Log.e(TAG, "Failed to launch Unity campus", e)
            false
        }
    }
}
