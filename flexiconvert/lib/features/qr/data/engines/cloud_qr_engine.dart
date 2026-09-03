import '../../../../core/models/engine_response.dart';
import '../../domain/engines/qr_engine.dart';
import '../../domain/models/qr_task_model.dart';

class CloudQrEngine implements QrEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<QrResult>> generate({
    required String data,
    required String outputPath,
    Map<String, dynamic>? options,
  }) async {
    return EngineResponse.notAvailable('Cloud QR generation');
  }

  @override
  Future<EngineResponse<QrResult>> decode({
    required String inputPath,
  }) async {
    return EngineResponse.notAvailable('Cloud QR decoding');
  }
}
