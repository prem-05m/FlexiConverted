import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/image_task_model.dart';

abstract class ImageEngine implements MediaEngine {
  /// Converts an image to a different format
  Future<EngineResponse<ImageResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required ImageFormat targetFormat,
    int quality = 100,
  });

  /// Resizes an image
  Future<EngineResponse<ImageResult>> resizeImage({
    required String inputPath,
    required String outputPath,
    required int width,
    required int height,
  });

  /// Compresses an image
  Future<EngineResponse<ImageResult>> compressImage({
    required String inputPath,
    required String outputPath,
    required int quality,
  });

  /// Crops an image
  Future<EngineResponse<ImageResult>> cropImage({
    required String inputPath,
    required String outputPath,
    required int x,
    required int y,
    required int width,
    required int height,
  });

  /// Rotates an image
  Future<EngineResponse<ImageResult>> rotateImage({
    required String inputPath,
    required String outputPath,
    required int angle,
  });

  /// Flips an image horizontally or vertically
  Future<EngineResponse<ImageResult>> flipImage({
    required String inputPath,
    required String outputPath,
    required bool horizontal,
    required bool vertical,
  });

  Future<EngineResponse<ImageResult>> removeMetadata({
    required String inputPath,
    required String outputPath,
  });

  Future<EngineResponse<ImageResult>> colorMode({
    required String inputPath,
    required String outputPath,
    required String mode, // grayscale, cmyk
  });

  Future<EngineResponse<ImageResult>> dpiResolution({
    required String inputPath,
    required String outputPath,
    required int dpi,
  });
}
