import '../../../../core/models/engine_response.dart';
import '../../domain/engines/file_engine.dart';
import '../../domain/models/file_task_model.dart';

class CloudFileEngine implements FileEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<FileResult>> executeFileOperation({
    required FileToolType toolType,
    required List<String> inputPaths,
    String? outputPath,
    Map<String, dynamic>? options,
  }) async {
    return EngineResponse.notAvailable('Cloud File Operations');
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> getFileInfo(String path) async {
    return EngineResponse.notAvailable('Cloud File Info');
  }
}
