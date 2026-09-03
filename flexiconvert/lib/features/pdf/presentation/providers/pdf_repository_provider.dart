import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/pdf_repository_impl.dart';
import '../../domain/repositories/pdf_repository.dart';
import 'pdf_engine_provider.dart';

final pdfRepositoryProvider = Provider<PdfRepository>((ref) {
  final engine = ref.watch(pdfEngineProvider);
  return PdfRepositoryImpl(engine);
});
