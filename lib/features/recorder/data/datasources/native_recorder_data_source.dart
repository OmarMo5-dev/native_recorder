import 'package:flutter/services.dart';

class NativeRecorderDataSource {
  static const MethodChannel _methodChannel =
      MethodChannel('native_recorder/methods');

  static const EventChannel _eventChannel =
      EventChannel('native_recorder/events');

  Future<bool> requestMicrophonePermission() async {
    final result = await _methodChannel.invokeMethod<bool>(
      'requestMicrophonePermission',
    );
    return result ?? false;
  }

  Future<bool> hasMicrophonePermission() async {
    final result = await _methodChannel.invokeMethod<bool>(
      'hasMicrophonePermission',
    );
    return result ?? false;
  }

  Future<void> startRecording() async {
    await _methodChannel.invokeMethod('startRecording');
  }

  Future<void> stopRecording() async {
    await _methodChannel.invokeMethod('stopRecording');
  }

  Future<List<dynamic>> getRecordings() async {
    final result = await _methodChannel.invokeMethod<List<dynamic>>(
      'getRecordings',
    );
    return result ?? [];
  }

  Future<void> playRecording(String path) async {
    await _methodChannel.invokeMethod(
      'playRecording',
      {'path': path},
    );
  }

  Future<void> stopPlayback() async {
    await _methodChannel.invokeMethod('stopPlayback');
  }

  Future<bool> deleteRecording(String path) async {
    final result = await _methodChannel.invokeMethod<bool>(
      'deleteRecording',
      {'path': path},
    );
    return result ?? false;
  }

  Stream<Map<dynamic, dynamic>> get recordingEvents {
    return _eventChannel
        .receiveBroadcastStream()
        .map((event) => Map<dynamic, dynamic>.from(event));
  }
}
