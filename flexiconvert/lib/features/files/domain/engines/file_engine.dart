import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/file_task_model.dart';

abstract class FileEngine implements MediaEngine {
  Future<EngineResponse<FileResult>> executeFileOperation({
    required FileToolType toolType,
    required List<String> inputPaths,
    String? outputPath,
    Map<String, dynamic>? options,
  });

  Future<EngineResponse<Map<String, dynamic>>> getFileInfo(String path);
}
