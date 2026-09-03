import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_pdf_engine.dart';
import '../../domain/engines/pdf_engine.dart';

/// Provides the active PdfEngine. 
/// Currently defaults to LocalPdfEngine, but can easily be swapped 
/// for a CloudPdfEngine in the future.
final pdfEngineProvider = Provider<PdfEngine>((ref) {
  return LocalPdfEngine();
});
