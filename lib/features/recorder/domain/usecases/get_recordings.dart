import '../entities/recording.dart';
import '../repositories/recorder_repository.dart';

class GetRecordings {
  final RecorderRepository repository;

  GetRecordings(this.repository);

  Future<List<Recording>> call() => repository.getRecordings();
}
