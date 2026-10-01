package com.example.native_recorder.recorder.channel

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import com.example.native_recorder.recorder.file.RecordingFileManager
import com.example.native_recorder.recorder.manager.PlaybackManager
import com.example.native_recorder.recorder.manager.RecordingManager

class RecorderMethodChannel(
    private val flutterEngine: FlutterEngine,
    private val recordingManager: RecordingManager,
    private val fileManager: RecordingFileManager,
    private val playbackManager: PlaybackManager,
    private val requestMicrophonePermission:
        ((Boolean) -> Unit) -> Unit
) {
    companion object {
        private const val CHANNEL_NAME = "native_recorder/methods"
    }

    fun register() {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "requestMicrophonePermission" -> {
                    requestMicrophonePermission { granted ->
                        result.success(granted)
                    }
                }

                "hasMicrophonePermission" -> {
                    result.success(
                        recordingManager.hasMicrophonePermission()
                    )
                }

                "startRecording" -> {
                    try {
                        recordingManager.startRecording()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "RECORDING_START_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                "stopRecording" -> {
                    try {
                        recordingManager.stopRecording()
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "RECORDING_STOP_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                "getRecordings" -> {
                    try {
                        val recordings = fileManager
                            .getRecordings()
                            .map { file ->
                                mapOf(
                                    "path" to file.absolutePath,
                                    "name" to file.name,
                                    "createdAt" to file.lastModified(),
                                    "size" to file.length()
                                )
                            }

                        result.success(recordings)
                    } catch (e: Exception) {
                        result.error(
                            "GET_RECORDINGS_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                "playRecording" -> {
                    val path = call.argument<String>("path")

                    if (path == null) {
                        result.error(
                            "INVALID_PATH",
                            "Recording path is required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        playbackManager.play(path)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(
                            "PLAYBACK_FAILED",
                            e.message,
                            null
                        )
                    }
                }

                "stopPlayback" -> {
                    playbackManager.stop()
                    result.success(true)
                }

                "deleteRecording" -> {
                    val path = call.argument<String>("path")

                    if (path == null) {
                        result.error(
                            "INVALID_PATH",
                            "Recording path is required",
                            null
                        )
                        return@setMethodCallHandler
                    }

                    result.success(
                        fileManager.deleteRecording(path)
                    )
                }

                else -> result.notImplemented()
            }
        }
    }
}
