import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/document_repository_impl.dart';
import '../../domain/repositories/document_repository.dart';
import 'document_engine_provider.dart';

final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  final engine = ref.watch(documentEngineProvider);
  return DocumentRepositoryImpl(engine);
});
