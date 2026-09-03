import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/archive_task_model.dart';

abstract class ArchiveRepository {
  Future<Either<Failure, ArchiveResult>> executeTask({
    required ArchiveToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> readMetadata(String inputPath);
}
