import 'package:freezed_annotation/freezed_annotation.dart';

part 'video_task_model.freezed.dart';

enum VideoToolType {
  convertFormat,
  compress,
  trim,
  split,
  merge,
  extractAudio,
  mute,
  changeResolution,
  changeFps,
  changeBitrate,
  rotate,
  flip,
  mirror,
  crop,
  resize,
  generateGif,
  generateThumbnail,
  frameExtractor,
}

enum VideoFormat {
  mp4,
  avi,
  mkv,
  mov,
  webm,
  flv,
  wmv,
  mpeg,
  m4v,
  ts,
  gif,
  threeGp,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class VideoTaskState with _$VideoTaskState {
  const factory VideoTaskState({
    @Default('') String id,
    @Default(VideoToolType.convertFormat) VideoToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _VideoTaskState;
}

@freezed
class VideoResult with _$VideoResult {
  const factory VideoResult({
    required String outputPath,
    required int fileSizeBytes,
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) = _VideoResult;
}
