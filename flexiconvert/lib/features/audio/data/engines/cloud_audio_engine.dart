import '../../../../core/models/engine_response.dart';
import '../../domain/engines/audio_engine.dart';
import '../../domain/models/audio_task_model.dart';

class CloudAudioEngine implements AudioEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<AudioResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required AudioFormat targetFormat,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Conversion');
  }

  @override
  Future<EngineResponse<AudioResult>> compressAudio({
    required String inputPath,
    required String outputPath,
    required int quality,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Compression');
  }

  @override
  Future<EngineResponse<AudioResult>> trimAudio({
    required String inputPath,
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Trim');
  }

  @override
  Future<EngineResponse<AudioResult>> mergeAudios({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Merge');
  }

  @override
  Future<EngineResponse<AudioResult>> normalizeVolume({
    required String inputPath,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Audio Normalize');
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud Metadata Reading');
  }
}
