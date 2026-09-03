import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/video_task_model.dart';

abstract class VideoRepository {
  Future<Either<Failure, VideoResult>> executeTask({
    required VideoToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> readMetadata(String inputPath);
}
