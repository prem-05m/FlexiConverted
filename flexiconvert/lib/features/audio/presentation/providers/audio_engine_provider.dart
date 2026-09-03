import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_audio_engine.dart';
import '../../domain/engines/audio_engine.dart';

final audioEngineProvider = Provider<AudioEngine>((ref) {
  return LocalAudioEngine();
});
