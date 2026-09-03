import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/audio_engine.dart';
import '../../domain/models/audio_task_model.dart';
import '../../domain/repositories/audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioEngine _engine;

  AudioRepositoryImpl(this._engine);

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
  Future<Either<Failure, AudioResult>> executeTask({
    required AudioToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<AudioResult> response;

      switch (toolType) {
        case AudioToolType.convertFormat:
          response = await _engine.convertFormat(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            targetFormat: additionalParams?['targetFormat'] ?? AudioFormat.mp3,
          );
          break;
        case AudioToolType.compress:
          response = await _engine.compressAudio(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            quality: additionalParams?['quality'] ?? 80,
          );
          break;
        case AudioToolType.trim:
          response = await _engine.trimAudio(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            startTime: additionalParams?['startTime'] ?? Duration.zero,
            endTime: additionalParams?['endTime'] ?? const Duration(seconds: 10),
          );
          break;
        case AudioToolType.merge:
          response = await _engine.mergeAudios(
            inputPaths: inputPaths,
            outputPath: outputPath,
          );
          break;
        case AudioToolType.normalizeVolume:
          response = await _engine.normalizeVolume(
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
      return Left(ConversionFailure('Failed to process audio: ${e.toString()}'));
    }
  }
}
