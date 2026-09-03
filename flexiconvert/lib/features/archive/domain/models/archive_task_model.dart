import 'package:freezed_annotation/freezed_annotation.dart';

part 'archive_task_model.freezed.dart';

enum ArchiveToolType {
  zip,
  unzip,
  rar,
  sevenZip,
  tar,
  gzip,
  compress,
  extract,
  passwordProtect,
  batchCompress,
  batchExtract,
  previewArchive,
}

enum ArchiveFormat {
  zip,
  rar,
  sevenZip,
  tar,
  gzip,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class ArchiveTaskState with _$ArchiveTaskState {
  const factory ArchiveTaskState({
    @Default('') String id,
    @Default(ArchiveToolType.zip) ArchiveToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _ArchiveTaskState;
}

@freezed
class ArchiveResult with _$ArchiveResult {
  const factory ArchiveResult({
    required String outputPath,
    required int fileSizeBytes,
    Map<String, dynamic>? metadata,
  }) = _ArchiveResult;
}
