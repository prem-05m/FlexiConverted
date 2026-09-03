import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/archive_repository_impl.dart';
import '../../domain/repositories/archive_repository.dart';
import 'archive_engine_provider.dart';

final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  final engine = ref.watch(archiveEngineProvider);
  return ArchiveRepositoryImpl(engine);
});
