import '../repositories/recorder_repository.dart';

class DeleteRecording {
  final RecorderRepository repository;

  DeleteRecording(this.repository);

  Future<bool> call(String path) => repository.deleteRecording(path);
}
