import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_task_model.freezed.dart';

enum ImageToolType {
  convertFormat,
  resize,
  compress,
  crop,
  rotate,
  flip,
}

enum ImageFormat {
  jpg,
  png,
  webp,
  bmp,
  heic,
  gif,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class ImageTaskState with _$ImageTaskState {
  const factory ImageTaskState({
    @Default('') String id,
    @Default(ImageToolType.convertFormat) ImageToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _ImageTaskState;
}

@freezed
class ImageResult with _$ImageResult {
  const factory ImageResult({
    required String outputPath,
    required int fileSizeBytes,
    required int durationMs,
  }) = _ImageResult;
}
