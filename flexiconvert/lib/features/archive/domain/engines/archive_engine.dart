import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/archive_task_model.dart';

abstract class ArchiveEngine implements MediaEngine {
  /// Compresses files into an archive
  Future<EngineResponse<ArchiveResult>> compress({
    required List<String> inputPaths,
    required String outputPath,
    required ArchiveFormat format,
    String? password,
  });

  /// Extracts an archive
  Future<EngineResponse<ArchiveResult>> extract({
    required String inputPath,
    required String outputPath,
    String? password,
  });

  /// Reads metadata/contents of an archive locally
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  });
}
