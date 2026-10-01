import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/recording.dart';
import '../../domain/usecases/delete_recording.dart';
import '../../domain/usecases/get_recordings.dart';
import '../../domain/usecases/play_recording.dart';
import '../../domain/usecases/request_microphone_permission.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_playback.dart';
import '../../domain/usecases/stop_recording.dart';
import 'recorder_state.dart';

class RecorderCubit extends Cubit<RecorderState> {
  final RequestMicrophonePermission requestPermission;
  final StartRecording startRecordingUseCase;
  final StopRecording stopRecordingUseCase;
  final GetRecordings getRecordingsUseCase;
  final PlayRecording playRecordingUseCase;
  final StopPlayback stopPlaybackUseCase;
  final DeleteRecording deleteRecordingUseCase;
  final Stream<Map<dynamic, dynamic>> recordingEvents;

  StreamSubscription? _eventSubscription;

  RecorderCubit({
    required this.requestPermission,
    required this.startRecordingUseCase,
    required this.stopRecordingUseCase,
    required this.getRecordingsUseCase,
    required this.playRecordingUseCase,
    required this.stopPlaybackUseCase,
    required this.deleteRecordingUseCase,
    required this.recordingEvents,
  }) : super(const RecorderState()) {
    _listenToNativeEvents();
    loadRecordings();
  }

  void _listenToNativeEvents() {
    _eventSubscription = recordingEvents.listen((event) {
      switch (event['type']) {
        case 'RECORDING_STARTED':
          emit(state.copyWith(
            status: RecorderStatus.recording,
            clearError: true,
          ));
          break;

        case 'RECORDING_STOPPED':
          emit(state.copyWith(status: RecorderStatus.ready));
          loadRecordings();
          break;

        case 'RECORDING_ERROR':
          emit(state.copyWith(
            status: RecorderStatus.error,
            errorMessage: event['message']?.toString(),
          ));
          break;
      }
    });
  }

  Future<void> loadRecordings() async {
    try {
      final recordings = await getRecordingsUseCase();
      emit(state.copyWith(
        recordings: recordings,
        status: state.status == RecorderStatus.initial
            ? RecorderStatus.ready
            : state.status,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecorderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> start() async {
    try {
      emit(state.copyWith(
        status: RecorderStatus.requestingPermission,
        clearError: true,
      ));

      final granted = await requestPermission();

      if (!granted) {
        emit(state.copyWith(
          status: RecorderStatus.error,
          errorMessage: 'Microphone permission denied',
        ));
        return;
      }

      await startRecordingUseCase();
    } catch (e) {
      emit(state.copyWith(
        status: RecorderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> stop() async {
    try {
      emit(state.copyWith(status: RecorderStatus.stopping));
      await stopRecordingUseCase();
    } catch (e) {
      emit(state.copyWith(
        status: RecorderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> play(Recording recording) async {
    try {
      await playRecordingUseCase(recording.path);
      emit(state.copyWith(
        playingPath: recording.path,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: RecorderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> stopPlayback() async {
    await stopPlaybackUseCase();
    emit(state.copyWith(clearPlayingPath: true));
  }

  Future<void> delete(Recording recording) async {
    try {
      final deleted = await deleteRecordingUseCase(recording.path);
      if (deleted) {
        await loadRecordings();
      }
    } catch (e) {
      emit(state.copyWith(
        status: RecorderStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _eventSubscription?.cancel();
    return super.close();
  }
}
