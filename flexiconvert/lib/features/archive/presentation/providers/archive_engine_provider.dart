import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_archive_engine.dart';
import '../../domain/engines/archive_engine.dart';

final archiveEngineProvider = Provider<ArchiveEngine>((ref) {
  return LocalArchiveEngine();
});
