import 'package:flutter/material.dart';
import '../../domain/entities/recording.dart';

class RecordingItem extends StatelessWidget {
  final Recording recording;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final bool isPlaying;

  const RecordingItem({
    super.key,
    required this.recording,
    required this.onPlay,
    required this.onDelete,
    required this.isPlaying,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          isPlaying ? Icons.volume_up : Icons.audio_file,
        ),
        title: Text(recording.name),
        subtitle: Text(
          '${(recording.size / 1024).toStringAsFixed(1)} KB',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: onPlay,
              icon: Icon(
                isPlaying ? Icons.stop : Icons.play_arrow,
              ),
            ),
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete),
            ),
          ],
        ),
      ),
    );
  }
}
