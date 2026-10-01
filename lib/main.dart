import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'features/recorder/data/datasources/native_recorder_data_source.dart';
import 'features/recorder/data/repositories/recorder_repository_impl.dart';
import 'features/recorder/domain/repositories/recorder_repository.dart';
import 'features/recorder/domain/usecases/delete_recording.dart';
import 'features/recorder/domain/usecases/get_recordings.dart';
import 'features/recorder/domain/usecases/play_recording.dart';
import 'features/recorder/domain/usecases/request_microphone_permission.dart';
import 'features/recorder/domain/usecases/start_recording.dart';
import 'features/recorder/domain/usecases/stop_playback.dart';
import 'features/recorder/domain/usecases/stop_recording.dart';
import 'features/recorder/presentation/cubit/recorder_cubit.dart';
import 'features/recorder/presentation/pages/recorder_page.dart';

void main() {
  final dataSource = NativeRecorderDataSource();
  final RecorderRepository repository = RecorderRepositoryImpl(dataSource);

  runApp(
    BlocProvider(
      create: (_) => RecorderCubit(
        requestPermission: RequestMicrophonePermission(repository),
        startRecordingUseCase: StartRecording(repository),
        stopRecordingUseCase: StopRecording(repository),
        getRecordingsUseCase: GetRecordings(repository),
        playRecordingUseCase: PlayRecording(repository),
        stopPlaybackUseCase: StopPlayback(repository),
        deleteRecordingUseCase: DeleteRecording(repository),
        recordingEvents: repository.recordingEvents,
      ),
      child: const NativeRecorderApp(),
    ),
  );
}

class NativeRecorderApp extends StatelessWidget {
  const NativeRecorderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const RecorderPage(),
    );
  }
}
