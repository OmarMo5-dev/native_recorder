import '../../domain/entities/recording.dart';

enum RecorderStatus {
  initial,
  requestingPermission,
  ready,
  recording,
  stopping,
  error,
}

class RecorderState {
  final RecorderStatus status;
  final List<Recording> recordings;
  final String? errorMessage;
  final String? playingPath;

  const RecorderState({
    this.status = RecorderStatus.initial,
    this.recordings = const [],
    this.errorMessage,
    this.playingPath,
  });

  RecorderState copyWith({
    RecorderStatus? status,
    List<Recording>? recordings,
    String? errorMessage,
    String? playingPath,
    bool clearError = false,
    bool clearPlayingPath = false,
  }) {
    return RecorderState(
      status: status ?? this.status,
      recordings: recordings ?? this.recordings,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      playingPath: clearPlayingPath
          ? null
          : playingPath ?? this.playingPath,
    );
  }
}
