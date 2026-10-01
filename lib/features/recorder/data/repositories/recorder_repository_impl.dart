import '../../domain/entities/recording.dart';
import '../../domain/repositories/recorder_repository.dart';
import '../datasources/native_recorder_data_source.dart';
import '../models/recording_model.dart';

class RecorderRepositoryImpl implements RecorderRepository {
  final NativeRecorderDataSource dataSource;

  RecorderRepositoryImpl(this.dataSource);

  @override
  Future<bool> requestMicrophonePermission() =>
      dataSource.requestMicrophonePermission();

  @override
  Future<bool> hasMicrophonePermission() =>
      dataSource.hasMicrophonePermission();

  @override
  Future<void> startRecording() => dataSource.startRecording();

  @override
  Future<void> stopRecording() => dataSource.stopRecording();

  @override
  Future<List<Recording>> getRecordings() async {
    final data = await dataSource.getRecordings();
    return data.map((item) => RecordingModel.fromMap(item)).toList();
  }

  @override
  Future<void> playRecording(String path) =>
      dataSource.playRecording(path);

  @override
  Future<void> stopPlayback() => dataSource.stopPlayback();

  @override
  Future<bool> deleteRecording(String path) =>
      dataSource.deleteRecording(path);

  @override
  Stream<Map<dynamic, dynamic>> get recordingEvents =>
      dataSource.recordingEvents;
}
