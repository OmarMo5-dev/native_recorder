package com.example.native_recorder.recorder.channel

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

object RecorderEventChannel {
    private const val CHANNEL_NAME = "native_recorder/events"

    private var eventSink: EventChannel.EventSink? = null

    fun register(flutterEngine: FlutterEngine) {
        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_NAME
        ).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(
                    arguments: Any?,
                    events: EventChannel.EventSink?
                ) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    fun send(event: Map<String, Any?>) {
        eventSink?.success(event)
    }
}
