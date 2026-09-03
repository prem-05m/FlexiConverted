import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/audio_repository_impl.dart';
import '../../domain/repositories/audio_repository.dart';
import 'audio_engine_provider.dart';

final audioRepositoryProvider = Provider<AudioRepository>((ref) {
  final engine = ref.watch(audioEngineProvider);
  return AudioRepositoryImpl(engine);
});
