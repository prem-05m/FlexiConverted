import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/qr_engine.dart';
import '../../domain/models/qr_task_model.dart';
import '../../domain/repositories/qr_repository.dart';

class QrRepositoryImpl implements QrRepository {
  final QrEngine _engine;

  QrRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, QrResult>> executeTask({
    required QrToolType toolType,
    String? inputData,
    String? inputPath,
    String? outputPath,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<QrResult> response;

      switch (toolType) {
        case QrToolType.generate:
        case QrToolType.batchGenerate:
          if (inputData == null || outputPath == null) {
            return const Left(ConversionFailure('Missing data or outputPath'));
          }
          response = await _engine.generate(
            data: inputData,
            outputPath: outputPath,
            options: additionalParams,
          );
          break;
        case QrToolType.scan:
          if (inputPath == null) {
            return const Left(ConversionFailure('Missing inputPath'));
          }
          response = await _engine.decode(inputPath: inputPath);
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
      return Left(ConversionFailure('Failed to process QR task: ${e.toString()}'));
    }
  }
}
