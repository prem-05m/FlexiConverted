import 'dart:io';
import 'dart:ui' as ui;
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/qr_engine.dart';
import '../../domain/models/qr_task_model.dart';

class LocalQrEngine implements QrEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<QrResult>> generate({
    required String data,
    required String outputPath,
    Map<String, dynamic>? options,
  }) async {
    try {
      final validationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (validationResult.status == QrValidationStatus.valid) {
        final qrCode = validationResult.qrCode;
        if (qrCode != null) {
          final painter = QrPainter.withQr(
            qr: qrCode,
            color: const ui.Color(0xFF000000),
            emptyColor: const ui.Color(0xFFFFFFFF),
            gapless: true,
          );

          final picData = await painter.toImageData(2048, format: ui.ImageByteFormat.png);
          if (picData != null) {
            final file = File(outputPath);
            await file.create(recursive: true);
            await file.writeAsBytes(picData.buffer.asUint8List());

            return EngineResponse.success(QrResult(
              outputPath: outputPath,
            ));
          }
        }
      }
      return EngineResponse.failure('Failed to generate QR code');
    } catch (e) {
      return EngineResponse.failure('Failed to generate QR code: $e');
    }
  }

  @override
  Future<EngineResponse<QrResult>> decode({
    required String inputPath,
  }) async {
    // Decoding from file is tricky without native ML Kit bindings.
    // Usually mobile_scanner handles the camera stream.
    // For local file decode, we'll stub it for now or rely on a cloud engine.
    return EngineResponse.notAvailable('Local decoding from file not implemented yet.');
  }
}
