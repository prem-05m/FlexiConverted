import 'dart:io';
import 'package:video_player/video_player.dart' hide VideoFormat;
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/video_engine.dart';
import '../../domain/models/video_task_model.dart';

class LocalVideoEngine implements VideoEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<VideoResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required VideoFormat targetFormat,
  }) async {
    return EngineResponse.notAvailable('Local Video Conversion');
  }

  @override
  Future<EngineResponse<VideoResult>> compressVideo({
    required String inputPath,
    required String outputPath,
    required int quality,
  }) async {
    return EngineResponse.notAvailable('Local Video Compression');
  }

  @override
  Future<EngineResponse<VideoResult>> trimVideo({
    required String inputPath,
    required String outputPath,
    required Duration startTime,
    required Duration endTime,
  }) async {
    return EngineResponse.notAvailable('Local Video Trim');
  }

  @override
  Future<EngineResponse<VideoResult>> mergeVideos({
    required List<String> inputPaths,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Local Video Merge');
  }

  @override
  Future<EngineResponse<VideoResult>> extractAudio({
    required String inputPath,
    required String outputPath,
  }) async {
    return EngineResponse.notAvailable('Local Audio Extraction');
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  }) async {
    try {
      final file = File(inputPath);
      final size = await file.length();
      
      // We can use VideoPlayerController to extract basic metadata
      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      
      final metadata = {
        'durationMs': controller.value.duration.inMilliseconds,
        'width': controller.value.size.width,
        'height': controller.value.size.height,
        'aspectRatio': controller.value.aspectRatio,
        'fileSize': size,
      };
      
      await controller.dispose();
      return EngineResponse.success(metadata);
    } catch (e) {
      return EngineResponse.failure('Failed to read metadata: $e');
    }
  }

  @override
  Future<EngineResponse<String>> generateThumbnail({
    required String inputPath,
    required String outputPath,
    required Duration time,
  }) async {
    // True thumbnail generation to a file requires FFmpeg or a specific native package.
    // We return notAvailable to cleanly fallback or notify the user.
    return EngineResponse.notAvailable('Local Thumbnail Generation');
  }
}
