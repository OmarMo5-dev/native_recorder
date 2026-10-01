import '../repositories/recorder_repository.dart';

class StopPlayback {
  final RecorderRepository repository;

  StopPlayback(this.repository);

  Future<void> call() => repository.stopPlayback();
}
