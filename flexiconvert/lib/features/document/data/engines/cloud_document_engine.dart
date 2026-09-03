import '../../../../core/models/engine_response.dart';
import '../../domain/engines/document_engine.dart';
import '../../domain/models/document_task_model.dart';

class CloudDocumentEngine implements DocumentEngine {
  @override
  Future<EngineResponse<DocumentResult>> convertDocument({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
    required DocumentFormat targetFormat,
  }) async {
    // API Stub: In the future, this will upload the document to a Node.js + LibreOffice backend.
    return EngineResponse.notAvailable('Cloud Document Conversion');
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
