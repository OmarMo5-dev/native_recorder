package com.example.native_recorder.recorder.permission

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MicrophonePermissionManager(
    private val context: Context
) {
    companion object {
        const val REQUEST_CODE = 1001
    }

    private var pendingResult: ((Boolean) -> Unit)? = null

    fun isGranted(): Boolean {
        return ContextCompat.checkSelfPermission(
            context,
            Manifest.permission.RECORD_AUDIO
        ) == PackageManager.PERMISSION_GRANTED
    }

    fun request(activity: Activity, callback: (Boolean) -> Unit) {
        if (isGranted()) {
            callback(true)
            return
        }

        pendingResult = callback

        ActivityCompat.requestPermissions(
            activity,
            arrayOf(Manifest.permission.RECORD_AUDIO),
            REQUEST_CODE
        )
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        grantResults: IntArray
    ): Boolean {
        if (requestCode != REQUEST_CODE) return false

        val granted =
            grantResults.isNotEmpty() &&
            grantResults[0] == PackageManager.PERMISSION_GRANTED

        pendingResult?.invoke(granted)
        pendingResult = null

        return true
    }
}
