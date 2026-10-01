import '../../domain/entities/recording.dart';

class RecordingModel extends Recording {
  const RecordingModel({
    required super.path,
    required super.name,
    required super.createdAt,
    required super.size,
  });

  factory RecordingModel.fromMap(Map<dynamic, dynamic> map) {
    return RecordingModel(
      path: map['path'] as String,
      name: map['name'] as String,
      createdAt: map['createdAt'] as int,
      size: map['size'] as int,
    );
  }
}
