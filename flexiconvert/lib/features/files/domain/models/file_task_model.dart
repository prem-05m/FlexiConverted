import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_task_model.freezed.dart';

enum FileToolType {
  rename,
  move,
  copy,
  delete,
  duplicate,
  info,
  storageAnalyzer,
  largeFileFinder,
  emptyFolderCleaner,
  tempFileCleaner,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class FileTaskState with _$FileTaskState {
  const factory FileTaskState({
    @Default('') String id,
    @Default(FileToolType.rename) FileToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _FileTaskState;
}

@freezed
class FileResult with _$FileResult {
  const factory FileResult({
    String? outputPath,
    Map<String, dynamic>? metadata,
    @Default([]) List<String> deletedPaths,
  }) = _FileResult;
}
