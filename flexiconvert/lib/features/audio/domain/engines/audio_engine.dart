import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/audio_task_model.dart';

abstract class AudioEngine implements MediaEngine {
  /// Converts audio format
  Future<EngineResponse<AudioResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required AudioFormat targetFormat,
  });

  /// Compresses audio
  Future<EngineResponse<AudioResult>> compressAudio({
    required String inputPath,
    required String outputPath,
    required int quality,
  });

  /// Trims audio
  Future<EngineResponse<AudioResult>> trimAudio({
    required String inputPath,
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
  });

  /// Merges multiple audios
  Future<EngineResponse<AudioResult>> mergeAudios({
    required List<String> inputPaths,
    required String outputPath,
  });

  /// Normalizes volume
  Future<EngineResponse<AudioResult>> normalizeVolume({
    required String inputPath,
    required String outputPath,
  });

  /// Reads metadata locally
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  });
}
