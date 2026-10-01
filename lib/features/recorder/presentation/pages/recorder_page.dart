import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/recorder_cubit.dart';
import '../cubit/recorder_state.dart';
import '../widgets/recording_item.dart';

class RecorderPage extends StatelessWidget {
  const RecorderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Recorder'),
      ),
      body: BlocBuilder<RecorderCubit, RecorderState>(
        builder: (context, state) {
          return Column(
            children: [
              const SizedBox(height: 40),
              Text(_statusText(state.status)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (state.status == RecorderStatus.recording) {
                    context.read<RecorderCubit>().stop();
                  } else {
                    context.read<RecorderCubit>().start();
                  }
                },
                child: CircleAvatar(
                  radius: 45,
                  child: Icon(
                    state.status == RecorderStatus.recording
                        ? Icons.stop
                        : Icons.mic,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: ListView.builder(
                  itemCount: state.recordings.length,
                  itemBuilder: (context, index) {
                    final recording = state.recordings[index];

                    return RecordingItem(
                      recording: recording,
                      isPlaying: state.playingPath == recording.path,
                      onPlay: () {
                        if (state.playingPath == recording.path) {
                          context.read<RecorderCubit>().stopPlayback();
                        } else {
                          context.read<RecorderCubit>().play(recording);
                        }
                      },
                      onDelete: () {
                        context.read<RecorderCubit>().delete(recording);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _statusText(RecorderStatus status) {
    switch (status) {
      case RecorderStatus.initial:
      case RecorderStatus.ready:
        return 'Ready';
      case RecorderStatus.requestingPermission:
        return 'Requesting permission...';
      case RecorderStatus.recording:
        return 'Recording...';
      case RecorderStatus.stopping:
        return 'Stopping...';
      case RecorderStatus.error:
        return 'Error';
    }
  }
}
