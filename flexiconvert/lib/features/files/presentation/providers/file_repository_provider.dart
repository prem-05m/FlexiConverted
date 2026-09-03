import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/file_repository_impl.dart';
import '../../domain/repositories/file_repository.dart';
import 'file_engine_provider.dart';

final fileRepositoryProvider = Provider<FileRepository>((ref) {
  final engine = ref.watch(fileEngineProvider);
  return FileRepositoryImpl(engine);
});
