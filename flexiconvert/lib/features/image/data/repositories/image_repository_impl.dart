import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/image_engine.dart';
import '../../domain/models/image_task_model.dart';
import '../../domain/repositories/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageEngine _engine;

  ImageRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, ImageResult>> executeTask({
    required ImageToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<ImageResult> response;

      switch (toolType) {
        case ImageToolType.convertFormat:
          response = await _engine.convertFormat(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            targetFormat: additionalParams?['targetFormat'] ?? ImageFormat.jpg,
            quality: additionalParams?['quality'] ?? 100,
          );
          break;
        case ImageToolType.resize:
          response = await _engine.resizeImage(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            width: additionalParams?['width'] ?? 800,
            height: additionalParams?['height'] ?? 800,
          );
          break;
        case ImageToolType.compress:
          response = await _engine.compressImage(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            quality: additionalParams?['quality'] ?? 80,
          );
          break;
        case ImageToolType.crop:
          response = await _engine.cropImage(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            x: additionalParams?['x'] ?? 0,
            y: additionalParams?['y'] ?? 0,
            width: additionalParams?['width'] ?? 100,
            height: additionalParams?['height'] ?? 100,
          );
          break;
        case ImageToolType.rotate:
          response = await _engine.rotateImage(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            angle: additionalParams?['angle'] ?? 90,
          );
          break;
        case ImageToolType.flip:
          response = await _engine.flipImage(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            horizontal: additionalParams?['horizontal'] ?? true,
            vertical: additionalParams?['vertical'] ?? false,
          );
          break;
      }

      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to process image: ${e.toString()}'));
    }
  }
}
