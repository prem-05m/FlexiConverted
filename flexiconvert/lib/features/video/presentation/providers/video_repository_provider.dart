import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/video_repository_impl.dart';
import '../../domain/repositories/video_repository.dart';
import 'video_engine_provider.dart';

final videoRepositoryProvider = Provider<VideoRepository>((ref) {
  final engine = ref.watch(videoEngineProvider);
  return VideoRepositoryImpl(engine);
});
