import 'package:freezed_annotation/freezed_annotation.dart';

part 'qr_task_model.freezed.dart';

enum QrToolType {
  generate,
  scan,
  batchGenerate,
}

enum TaskStatus { idle, processing, success, failure }

@freezed
class QrTaskState with _$QrTaskState {
  const factory QrTaskState({
    @Default('') String id,
    @Default(QrToolType.generate) QrToolType toolType,
    String? inputData,
    String? scannedData,
    String? outputPath,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _QrTaskState;
}

@freezed
class QrResult with _$QrResult {
  const factory QrResult({
    String? outputPath,
    String? scannedData,
    Map<String, dynamic>? metadata,
  }) = _QrResult;
}
