import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/document_task_model.dart';

abstract class DocumentRepository {
  Future<Either<Failure, DocumentResult>> executeTask({
    required DocumentToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });
}
