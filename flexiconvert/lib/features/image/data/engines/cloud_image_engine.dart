import '../../../../core/models/engine_response.dart';
import '../../domain/engines/image_engine.dart';
import '../../domain/models/image_task_model.dart';

class CloudImageEngine implements ImageEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<ImageResult>> convertFormat({
    required String inputPath,
    required String outputPath,
    required ImageFormat targetFormat,
    int quality = 100,
  }) async {
    return EngineResponse.notAvailable('Cloud Convert Format');
  }

  @override
  Future<EngineResponse<ImageResult>> resizeImage({
    required String inputPath,
    required String outputPath,
    required int width,
    required int height,
  }) async {
    return EngineResponse.notAvailable('Cloud Resize');
  }

  @override
  Future<EngineResponse<ImageResult>> compressImage({
    required String inputPath,
    required String outputPath,
    required int quality,
  }) async {
    return EngineResponse.notAvailable('Cloud Compress');
  }

  @override
  Future<EngineResponse<ImageResult>> cropImage({
    required String inputPath,
    required String outputPath,
    required int x,
    required int y,
    required int width,
    required int height,
  }) async {
    return EngineResponse.notAvailable('Cloud Crop');
  }

  @override
  Future<EngineResponse<ImageResult>> rotateImage({
    required String inputPath,
    required String outputPath,
    required int angle,
  }) async {
    return EngineResponse.notAvailable('Cloud Rotate');
  }

  @override
  Future<EngineResponse<ImageResult>> flipImage({
    required String inputPath,
    required String outputPath,
    required bool horizontal,
    required bool vertical,
  }) async {
    return EngineResponse.notAvailable('Cloud Flip');
  }
}
