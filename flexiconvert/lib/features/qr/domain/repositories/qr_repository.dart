import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/qr_task_model.dart';

abstract class QrRepository {
  Future<Either<Failure, QrResult>> executeTask({
    required QrToolType toolType,
    String? inputData,
    String? inputPath,
    String? outputPath,
    Map<String, dynamic>? additionalParams,
  });
}
