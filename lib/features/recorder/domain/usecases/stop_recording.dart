import '../repositories/recorder_repository.dart';

class StopRecording {
  final RecorderRepository repository;

  StopRecording(this.repository);

  Future<void> call() => repository.stopRecording();
}
