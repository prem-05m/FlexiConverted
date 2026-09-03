import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/archive_engine.dart';
import '../../domain/models/archive_task_model.dart';
import '../../domain/repositories/archive_repository.dart';

class ArchiveRepositoryImpl implements ArchiveRepository {
  final ArchiveEngine _engine;

  ArchiveRepositoryImpl(this._engine);

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
  Future<Either<Failure, ArchiveResult>> executeTask({
    required ArchiveToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      EngineResponse<ArchiveResult> response;

      switch (toolType) {
        case ArchiveToolType.compress:
        case ArchiveToolType.zip:
        case ArchiveToolType.tar:
        case ArchiveToolType.gzip:
          response = await _engine.compress(
            inputPaths: inputPaths,
            outputPath: outputPath,
            format: additionalParams?['format'] ?? ArchiveFormat.zip,
            password: additionalParams?['password'],
          );
          break;
        case ArchiveToolType.extract:
        case ArchiveToolType.unzip:
          response = await _engine.extract(
            inputPath: inputPaths.first,
            outputPath: outputPath,
            password: additionalParams?['password'],
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
      return Left(ConversionFailure('Failed to process archive: ${e.toString()}'));
    }
  }
}
