package com.example.native_recorder.recorder.manager

import android.content.Context
import android.content.Intent
import androidx.core.content.ContextCompat

import com.example.native_recorder.recorder.permission.MicrophonePermissionManager
import com.example.native_recorder.recorder.service.RecordingService

class RecordingManager(
    private val context: Context,
    private val permissionManager: MicrophonePermissionManager
) {
    fun hasMicrophonePermission(): Boolean {
        return permissionManager.isGranted()
    }

    fun startRecording() {
        if (!permissionManager.isGranted()) {
            throw SecurityException("Microphone permission is not granted")
        }

        val intent = Intent(
            context,
            RecordingService::class.java
        ).apply {
            action = RecordingService.ACTION_START
        }

        ContextCompat.startForegroundService(context, intent)
    }

    fun stopRecording() {
        val intent = Intent(
            context,
            RecordingService::class.java
        ).apply {
            action = RecordingService.ACTION_STOP
        }

        context.startService(intent)
    }
}
