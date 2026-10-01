import '../repositories/recorder_repository.dart';

class RequestMicrophonePermission {
  final RecorderRepository repository;

  RequestMicrophonePermission(this.repository);

  Future<bool> call() => repository.requestMicrophonePermission();
}
