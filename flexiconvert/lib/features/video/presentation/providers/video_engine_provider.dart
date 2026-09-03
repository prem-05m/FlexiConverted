import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_video_engine.dart';
import '../../domain/engines/video_engine.dart';

final videoEngineProvider = Provider<VideoEngine>((ref) {
  return LocalVideoEngine();
});
