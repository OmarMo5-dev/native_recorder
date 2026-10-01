import '../repositories/recorder_repository.dart';

class PlayRecording {
  final RecorderRepository repository;

  PlayRecording(this.repository);

  Future<void> call(String path) => repository.playRecording(path);
}
