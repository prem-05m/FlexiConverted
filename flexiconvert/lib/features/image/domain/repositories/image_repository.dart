import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/image_task_model.dart';

abstract class ImageRepository {
  Future<Either<Failure, ImageResult>> executeTask({
    required ImageToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });
}
