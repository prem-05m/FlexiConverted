import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/pdf_task_model.dart';

abstract class PdfRepository {
  /// Executes a PDF task generically based on the tool type.
  Future<Either<Failure, PdfResult>> executeTask({
    required PdfToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });
}
