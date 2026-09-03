import 'package:freezed_annotation/freezed_annotation.dart';

part 'pdf_task_model.freezed.dart';

enum PdfToolType {
  imageToPdf,
  pdfToImage,
  mergePdf,
  splitPdf,
  compressPdf,
  rotatePdf,
  reorderPages,
  deletePages,
  extractPages,
  watermarkPdf,
  addSignature,
  encryptPdf,
  unlockPdf,
  renamePdf,
  duplicatePdf,
  previewPdf,
  sharePdf,
  printPdf,
  scanToPdf,
  repairPdf,
  ocrPdf,
  addPageNumbers,
  cropPdf,
  editPdf,
  pdfForms,
  pdfToMarkdown,
  redactPdf,
  comparePdf,
  aiSummarizer,
  translatePdf,
}

enum TaskStatus { idle, picking, processing, success, failure }

@freezed
class PdfTaskState with _$PdfTaskState {
  const factory PdfTaskState({
    @Default('') String id,
    @Default(PdfToolType.imageToPdf) PdfToolType toolType,
    @Default([]) List<String> inputPaths,
    String? outputPath,
    List<String>? outputPaths,
    @Default(0.0) double progress,
    @Default(TaskStatus.idle) TaskStatus status,
    String? errorMessage,
  }) = _PdfTaskState;
}

@freezed
class PdfResult with _$PdfResult {
  const factory PdfResult({
    required String outputPath,
    List<String>? outputPaths,
    required int pageCount,
    required int fileSizeBytes,
    required int durationMs,
  }) = _PdfResult;
}
