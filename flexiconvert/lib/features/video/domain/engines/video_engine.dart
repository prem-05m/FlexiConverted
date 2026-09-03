import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/video_task_model.dart';

abstract class VideoEngine implements MediaEngine {
  /// Converts video format
  Future<EngineResponse<VideoResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required VideoFormat targetFormat,
  });

  /// Compresses video
  Future<EngineResponse<VideoResult>> compressVideo({
    required String inputPath,
    required String outputPath,
    required int quality,
  });

  /// Trims video
  Future<EngineResponse<VideoResult>> trimVideo({
    required String inputPath,
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
  });

  /// Merges multiple videos
  Future<EngineResponse<VideoResult>> mergeVideos({
    required List<String> inputPaths,
    required String outputPath,
  });

  /// Extracts audio from video
  Future<EngineResponse<VideoResult>> extractAudio({
    required String inputPath,
    required String outputPath,
  });

  /// Reads metadata locally
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  });
  
  /// Generates a thumbnail image
  Future<EngineResponse<String>> generateThumbnail({
    required String inputPath,
    required String outputPath,
    required Duration time,
  });
}
