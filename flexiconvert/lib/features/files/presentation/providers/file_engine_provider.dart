import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_file_engine.dart';
import '../../domain/engines/file_engine.dart';

final fileEngineProvider = Provider<FileEngine>((ref) {
  return LocalFileEngine();
});
