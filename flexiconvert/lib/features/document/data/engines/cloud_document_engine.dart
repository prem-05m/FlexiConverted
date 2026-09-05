import 'dart:io';
import '../../../../core/models/engine_response.dart';
import '../../../../core/services/cloud_convert_service.dart';
import '../../domain/engines/document_engine.dart';
import '../../domain/models/document_task_model.dart';

class CloudDocumentEngine implements DocumentEngine {
  String _mapFormatToExtension(DocumentFormat format) {
    switch (format) {
      case DocumentFormat.word: return 'docx';
      case DocumentFormat.excel: return 'xlsx';
      case DocumentFormat.ppt: return 'pptx';
      case DocumentFormat.pdf: return 'pdf';
      case DocumentFormat.txt: return 'txt';
      case DocumentFormat.html: return 'html';
      case DocumentFormat.rtf: return 'rtf';
      case DocumentFormat.csv: return 'csv';
      default: return format.name;
    }
  }

  @override
  Future<EngineResponse<DocumentResult>> convertDocument({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
    required DocumentFormat targetFormat,
    Function(double)? onProgress,
  }) async {
    try {
      final String fromFormat = inputPath.split('.').last.toLowerCase();
      String toFormat = _mapFormatToExtension(targetFormat);

      final resultPath = await cloudConvertService.convertDocument(
        inputPath: inputPath,
        outputPath: outputPath,
        fromFormat: fromFormat,
        toFormat: toFormat,
        onProgress: onProgress,
      );

      final file = File(resultPath);
      final sizeBytes = await file.length();

      return EngineResponse.success(
        DocumentResult(
          outputPath: resultPath,
          fileSizeBytes: sizeBytes,
          durationMs: 0,
        ),
      );
    } catch (e) {
      return EngineResponse.failure(e.toString());
    }
  }

  @override
  Future<EngineResponse<DocumentResult>> extractText({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
  }) async {
    return EngineResponse.notAvailable('Cloud Text Extraction');
  }

  @override
  Future<EngineResponse<DocumentResult>> mergeDocuments({
    required List<String> inputPaths,
    required String outputPath,
    required DocumentFormat format,
  }) async {
    return EngineResponse.notAvailable('Cloud Document Merge');
  }
}
