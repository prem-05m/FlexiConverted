import '../../../../core/models/engine_response.dart';
import '../models/document_task_model.dart';

abstract class DocumentEngine {
  /// Converts a document from one format to another (e.g., Word to PDF)
  Future<EngineResponse<DocumentResult>> convertDocument({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
    required DocumentFormat targetFormat,
  });

  /// Extracts text from a document
  Future<EngineResponse<DocumentResult>> extractText({
    required String inputPath,
    required String outputPath,
    required DocumentFormat sourceFormat,
  });

  /// Merges multiple documents of the same type (if supported)
  Future<EngineResponse<DocumentResult>> mergeDocuments({
    required List<String> inputPaths,
    required String outputPath,
    required DocumentFormat format,
  });
}
