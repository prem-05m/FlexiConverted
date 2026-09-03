import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/video_engine.dart';
import '../../domain/models/video_task_model.dart';
import '../../domain/repositories/video_repository.dart';

class VideoRepositoryImpl implements VideoRepository {
  final VideoEngine _engine;

  VideoRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, Map<String, dynamic>>> readMetadata(String inputPath) async {
    try {
      final response = await _engine.readMetadata(inputPath: inputPath);
      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to read metadata: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, VideoResult>> executeTask({
    required VideoToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<VideoResult> response;

      switch (toolType) {
        case VideoToolType.convertFormat:
          response = await _engine.convertFormat(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            targetFormat: additionalParams?['targetFormat'] ?? VideoFormat.mp4,
          );
          break;
        case VideoToolType.compress:
          response = await _engine.compressVideo(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            quality: additionalParams?['quality'] ?? 80,
          );
          break;
        case VideoToolType.trim:
          response = await _engine.trimVideo(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            startTime: additionalParams?['startTime'] ?? Duration.zero,
            endTime: additionalParams?['endTime'] ?? const Duration(seconds: 10),
          );
          break;
        case VideoToolType.merge:
          response = await _engine.mergeVideos(
            inputPaths: inputPaths,
            outputPath: outputPath,
          );
          break;
        case VideoToolType.extractAudio:
          response = await _engine.extractAudio(
            inputPath: inputPaths.first,
            outputPath: outputPath,
          );
          break;
        default:
          response = EngineResponse.notAvailable(toolType.name);
      }

      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to process video: ${e.toString()}'));
    }
  }
}
