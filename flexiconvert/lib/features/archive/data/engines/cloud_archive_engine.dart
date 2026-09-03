import '../../../../core/models/engine_response.dart';
import '../../domain/engines/archive_engine.dart';
import '../../domain/models/archive_task_model.dart';

class CloudArchiveEngine implements ArchiveEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<ArchiveResult>> compress({
    required List<String> inputPaths,
    required String outputPath,
    required ArchiveFormat format,
    String? password,
  }) async {
    return EngineResponse.notAvailable('Cloud Archive Compression');
  }

  @override
  Future<EngineResponse<ArchiveResult>> extract({
    required String inputPath,
    required String outputPath,
    String? password,
  }) async {
    return EngineResponse.notAvailable('Cloud Archive Extraction');
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Archive Metadata');
  }
}
