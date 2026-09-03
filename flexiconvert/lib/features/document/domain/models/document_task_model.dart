import 'package:freezed_annotation/freezed_annotation.dart';

part 'document_task_model.freezed.dart';

enum DocumentToolType {
  wordToPdf,
  pdfToWord,
  excelToPdf,
  pdfToExcel,
  pptToPdf,
  pdfToPpt,
  txtToPdf,
  htmlToPdf,
  csvToExcel,
  jpgToPdf,
  pdfToJpg,
  pdfToPdfA,
}

enum DocumentFormat {
  word,
  excel,
  ppt,
  txt,
  rtf,
  html,
  csv,
  pdf,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class DocumentTaskState with _$DocumentTaskState {
  const factory DocumentTaskState({
    @Default('') String id,
    @Default(DocumentToolType.wordToPdf) DocumentToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _DocumentTaskState;
}

@freezed
class DocumentResult with _$DocumentResult {
  const factory DocumentResult({
    required String outputPath,
    required int fileSizeBytes,
    required int durationMs,
  }) = _DocumentResult;
}
