package com.example.native_recorder.recorder.service

import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.media.MediaRecorder
import android.os.Build
import android.os.IBinder

import com.example.native_recorder.recorder.channel.RecorderEventChannel
import com.example.native_recorder.recorder.file.RecordingFileManager
import com.example.native_recorder.recorder.notification.RecordingNotificationManager

class RecordingService : Service() {
    companion object {
        const val ACTION_START = "native_recorder.action.START"
        const val ACTION_STOP = "native_recorder.action.STOP"
    }

    private lateinit var fileManager: RecordingFileManager
    private lateinit var notificationManager: RecordingNotificationManager
    private var mediaRecorder: MediaRecorder? = null
    private var currentRecordingFile: java.io.File? = null

    override fun onCreate() {
        super.onCreate()

        fileManager = RecordingFileManager(this)
        notificationManager = RecordingNotificationManager(this)
        notificationManager.createChannel()
    }

    override fun onStartCommand(
        intent: Intent?,
        flags: Int,
        startId: Int
    ): Int {
        when (intent?.action) {
            ACTION_START -> startRecording()
            ACTION_STOP -> stopRecording()
        }

        return START_NOT_STICKY
    }

    private fun startRecording() {
        if (mediaRecorder != null) return

        try {
            val notification =
                notificationManager.createRecordingNotification()

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    RecordingNotificationManager.NOTIFICATION_ID,
                    notification,
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_MICROPHONE
                )
            } else {
                startForeground(
                    RecordingNotificationManager.NOTIFICATION_ID,
                    notification
                )
            }

            val outputFile = fileManager.createRecordingFile()
            currentRecordingFile = outputFile

            mediaRecorder =
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                    MediaRecorder(this)
                } else {
                    @Suppress("DEPRECATION")
                    MediaRecorder()
                }

            mediaRecorder?.apply {
                setAudioSource(MediaRecorder.AudioSource.MIC)
                setOutputFormat(MediaRecorder.OutputFormat.MPEG_4)
                setAudioEncoder(MediaRecorder.AudioEncoder.AAC)
                setOutputFile(outputFile.absolutePath)
                prepare()
                start()
            }

            RecorderEventChannel.send(
                mapOf(
                    "type" to "RECORDING_STARTED",
                    "path" to outputFile.absolutePath,
                    "name" to outputFile.name,
                    "createdAt" to outputFile.lastModified()
                )
            )
        } catch (e: Exception) {
            mediaRecorder?.release()
            mediaRecorder = null

            currentRecordingFile?.delete()
            currentRecordingFile = null

            RecorderEventChannel.send(
                mapOf(
                    "type" to "RECORDING_ERROR",
                    "message" to (e.message ?: "Unknown recording error")
                )
            )

            stopForeground(STOP_FOREGROUND_REMOVE)
            stopSelf()
        }
    }

    private fun stopRecording() {
        val recorder = mediaRecorder ?: return
        val file = currentRecordingFile

        try {
            recorder.stop()
            recorder.release()

            mediaRecorder = null
            currentRecordingFile = null

            RecorderEventChannel.send(
                mapOf(
                    "type" to "RECORDING_STOPPED",
                    "path" to file?.absolutePath,
                    "name" to file?.name
                )
            )
        } catch (e: RuntimeException) {
            recorder.release()
            mediaRecorder = null

            file?.delete()
            currentRecordingFile = null

            RecorderEventChannel.send(
                mapOf(
                    "type" to "RECORDING_ERROR",
                    "message" to (e.message ?: "Failed to stop recording")
                )
            )
        }

        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
    }

    override fun onDestroy() {
        mediaRecorder?.let {
            try {
                it.stop()
            } catch (_: Exception) {
            }

            it.release()
        }

        mediaRecorder = null
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}
