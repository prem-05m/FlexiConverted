import '../../../../core/models/engine_response.dart';
import '../../domain/engines/document_engine.dart';
import '../../domain/models/document_task_model.dart';

class LocalDocumentEngine implements DocumentEngine {
  @override
  Future<EngineResponse<DocumentResult>> convertDocument({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
    required DocumentFormat targetFormat,
  }) async {
    // Flutter cannot natively convert Microsoft Office documents completely offline
    // without heavy native bindings. We return notAvailable, allowing the
    // repository to automatically fallback to CloudDocumentEngine or UI message.
    return EngineResponse.notAvailable('Local Document Conversion (${sourceFormat.name} to ${targetFormat.name})');
  }

  @override
  Future<EngineResponse<DocumentResult>> extractText({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
  }) async {
    return EngineResponse.notAvailable('Local Text Extraction');
  }

  @override
  Future<EngineResponse<DocumentResult>> mergeDocuments({
    required List<String> inputPaths,
    required String outputPath,
    required DocumentFormat format,
  }) async {
    return EngineResponse.notAvailable('Local Document Merge');
  }
}
