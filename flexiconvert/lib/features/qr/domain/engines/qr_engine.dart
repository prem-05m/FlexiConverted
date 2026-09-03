import '../../../../core/interfaces/media_engine.dart';
import '../../../../core/models/engine_response.dart';
import '../models/qr_task_model.dart';

abstract class QrEngine implements MediaEngine {
  /// Generates a QR Code image
  Future<EngineResponse<QrResult>> generate({
    required String data,
    required String outputPath,
    Map<String, dynamic>? options,
  });

  /// Decodes a QR Code image from a file path
  Future<EngineResponse<QrResult>> decode({
    required String inputPath,
  });
}
