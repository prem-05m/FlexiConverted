import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_image_engine.dart';
import '../../domain/engines/image_engine.dart';

/// Provides the active ImageEngine. 
/// Defaults to LocalImageEngine.
final imageEngineProvider = Provider<ImageEngine>((ref) {
  return LocalImageEngine();
});
