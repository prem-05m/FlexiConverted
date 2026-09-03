import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../domain/engines/file_engine.dart';
import '../../domain/models/file_task_model.dart';
import '../../domain/repositories/file_repository.dart';

class FileRepositoryImpl implements FileRepository {
  final FileEngine _engine;

  FileRepositoryImpl(this._engine);

  @override
  Future<Either<Failure, Map<String, dynamic>>> getFileInfo(String path) async {
    try {
      final response = await _engine.getFileInfo(path);
      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to get file info: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, FileResult>> executeTask({
    required FileToolType toolType,
    required List<String> inputPaths,
    String? outputPath,
    Map<String, dynamic>? additionalParams,
  }) async {
    try {
      final response = await _engine.executeFileOperation(
        toolType: toolType,
        inputPaths: inputPaths,
        outputPath: outputPath,
        options: additionalParams,
      );

      if (response.isSuccess) {
        return Right(response.data!);
      } else if (response.isNotAvailable) {
        return Left(ConversionFailure(response.errorMessage!));
      } else {
        return Left(ConversionFailure(response.errorMessage ?? 'Unknown error occurred.'));
      }
    } catch (e) {
      return Left(ConversionFailure('Failed to process file operation: ${e.toString()}'));
    }
  }
}
