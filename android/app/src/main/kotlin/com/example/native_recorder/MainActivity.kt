package com.example.native_recorder

import com.example.native_recorder.recorder.channel.RecorderEventChannel
import com.example.native_recorder.recorder.channel.RecorderMethodChannel
import com.example.native_recorder.recorder.file.RecordingFileManager
import com.example.native_recorder.recorder.manager.PlaybackManager
import com.example.native_recorder.recorder.manager.RecordingManager
import com.example.native_recorder.recorder.permission.MicrophonePermissionManager

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private lateinit var permissionManager: MicrophonePermissionManager
    private lateinit var recordingManager: RecordingManager
    private lateinit var fileManager: RecordingFileManager
    private lateinit var playbackManager: PlaybackManager

    override fun configureFlutterEngine(
        flutterEngine: FlutterEngine
    ) {
        super.configureFlutterEngine(flutterEngine)

        permissionManager = MicrophonePermissionManager(this)

        recordingManager = RecordingManager(
            context = this,
            permissionManager = permissionManager
        )

        fileManager = RecordingFileManager(this)
        playbackManager = PlaybackManager()

        RecorderMethodChannel(
            flutterEngine = flutterEngine,
            recordingManager = recordingManager,
            fileManager = fileManager,
            playbackManager = playbackManager,
            requestMicrophonePermission = { callback ->
                permissionManager.request(
                    activity = this,
                    callback = callback
                )
            }
        ).register()

        RecorderEventChannel.register(flutterEngine)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        if (permissionManager.onRequestPermissionsResult(
                requestCode,
                grantResults
            )
        ) {
            return
        }

        super.onRequestPermissionsResult(
            requestCode,
            permissions,
            grantResults
        )
    }
}
