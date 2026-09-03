import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../models/audio_task_model.dart';

abstract class AudioRepository {
  Future<Either<Failure, AudioResult>> executeTask({
    required AudioToolType toolType,
    required List<String> inputPaths,
    required String outputPath,
    void Function(double)? onProgress,
    Map<String, dynamic>? additionalParams,
  });

  Future<Either<Failure, Map<String, dynamic>>> readMetadata(String inputPath);
}
