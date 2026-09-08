import 'dart:io';
import 'dart:async';
import '../../../../core/models/engine_response.dart';
import '../../../../core/services/media_api_service.dart';
import '../../domain/engines/document_engine.dart';
import '../../domain/models/document_task_model.dart';

class CloudDocumentEngine implements DocumentEngine {
  final MediaApiService _mediaApiService = MediaApiService();

  String _getToolType(DocumentFormat source, DocumentFormat target) {
    if (source == DocumentFormat.pdf && target == DocumentFormat.word) return 'pdf_to_docx';
    if (source == DocumentFormat.pdf && target == DocumentFormat.excel) return 'pdf_to_xlsx';
    if (source == DocumentFormat.pdf && target == DocumentFormat.ppt) return 'pdf_to_pptx';
    if (source == DocumentFormat.word && target == DocumentFormat.pdf) return 'docx_to_pdf';
    if (source == DocumentFormat.excel && target == DocumentFormat.pdf) return 'xlsx_to_pdf';
    if (source == DocumentFormat.ppt && target == DocumentFormat.pdf) return 'pptx_to_pdf';
    throw Exception('Unsupported conversion: ${source.name} to ${target.name}');
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
      final toolType = _getToolType(sourceFormat, targetFormat);

      // 1. Upload and create job
      onProgress?.call(0.1);
      final jobId = await _mediaApiService.uploadAndCreateJob(
        filePaths: [inputPath],
        toolType: toolType,
      );

      if (jobId == null) {
        return EngineResponse.failure('Failed to create conversion job on the server.');
      }

      // 2. Poll for status
      bool isCompleted = false;
      while (!isCompleted) {
        await Future.delayed(const Duration(seconds: 2));
        final status = await _mediaApiService.getJobStatus(jobId);
        
        if (status != null) {
          final state = status['status'] as String;
          if (state == 'failed') {
            return EngineResponse.failure(status['error'] ?? 'Server conversion failed');
          } else if (state == 'completed') {
            isCompleted = true;
            onProgress?.call(0.9);
          } else {
            // Processing or pending
            final progress = (status['progress'] as num?)?.toDouble() ?? 0.0;
            onProgress?.call(0.1 + (progress * 0.8)); // map 0-1 to 0.1-0.9
          }
        }
      }

      // 3. Download result
      final downloadSuccess = await _mediaApiService.downloadJobOutput(jobId, outputPath);
      if (!downloadSuccess) {
        return EngineResponse.failure('Failed to download the converted file.');
      }

      // 4. Cleanup job on server
      await _mediaApiService.deleteJob(jobId);
      
      onProgress?.call(1.0);

      final file = File(outputPath);
      final sizeBytes = await file.length();

      return EngineResponse.success(
        DocumentResult(
          outputPath: outputPath,
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
