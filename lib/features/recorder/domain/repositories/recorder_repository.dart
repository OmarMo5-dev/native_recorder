import '../entities/recording.dart';

abstract class RecorderRepository {
  Future<bool> requestMicrophonePermission();
  Future<bool> hasMicrophonePermission();
  Future<void> startRecording();
  Future<void> stopRecording();
  Future<List<Recording>> getRecordings();
  Future<void> playRecording(String path);
  Future<void> stopPlayback();
  Future<bool> deleteRecording(String path);
  Stream<Map<dynamic, dynamic>> get recordingEvents;
}
