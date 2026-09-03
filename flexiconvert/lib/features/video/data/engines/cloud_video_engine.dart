import '../../../../core/models/engine_response.dart';
import '../../domain/engines/video_engine.dart';
import '../../domain/models/video_task_model.dart';

class CloudVideoEngine implements VideoEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<VideoResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required VideoFormat targetFormat,
  }) async {
    return EngineResponse.notAvailable('Cloud Video Conversion');
  }

  @override
  Future<EngineResponse<VideoResult>> compressVideo({
    required String inputPath,
    required String outputPath,
    required int quality,
  }) async {
    return EngineResponse.notAvailable('Cloud Video Compression');
  }

  @override
  Future<EngineResponse<VideoResult>> trimVideo({
    required String inputPath,
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
  }) async {
    return EngineResponse.notAvailable('Cloud Video Trim');
  }

  @override
  Future<EngineResponse<VideoResult>> mergeVideos({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Video Merge');
  }

  @override
  Future<EngineResponse<VideoResult>> extractAudio({
    required String inputPath,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Extraction');
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Metadata Reading');
  }

  @override
  Future<EngineResponse<String>> generateThumbnail({
    required String inputPath,
    required String outputPath,
    required Duration time,
  }) async {
    return EngineResponse.notAvailable('Cloud Thumbnail Generation');
  }
}
