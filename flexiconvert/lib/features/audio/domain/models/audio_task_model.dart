import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio_task_model.freezed.dart';

enum AudioToolType {
  convertFormat,
  compress,
  trim,
  split,
  merge,
  extractAudio,
  normalizeVolume,
  increaseVolume,
  reduceNoise,
  fadeIn,
  fadeOut,
  changeBitrate,
  changeSampleRate,
  stereoMono,
  metadataEditor,
  albumArt,
}

enum AudioFormat {
  mp3,
  wav,
  aac,
  flac,
  ogg,
  m4a,
  wma,
  aiff,
  amr,
  opus,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class AudioTaskState with _$AudioTaskState {
  const factory AudioTaskState({
    @Default('') String id,
    @Default(AudioToolType.convertFormat) AudioToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _AudioTaskState;
}

@freezed
class AudioResult with _$AudioResult {
  const factory AudioResult({
    required String outputPath,
    required int fileSizeBytes,
    required int durationMs,
    Map<String, dynamic>? metadata,
  }) = _AudioResult;
}
