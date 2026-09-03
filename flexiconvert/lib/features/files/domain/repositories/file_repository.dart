import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/file_task_model.dart';

abstract class FileRepository {
  Future<Either<Failure, FileResult>> executeTask({
    required FileToolType toolType,
    required List<String> inputPaths,
    String? outputPath,
    Map<String, dynamic>? additionalParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> getFileInfo(String path);
}
