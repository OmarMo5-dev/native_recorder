import '../repositories/recorder_repository.dart';

class StartRecording {
  final RecorderRepository repository;

  StartRecording(this.repository);

  Future<void> call() => repository.startRecording();
}
