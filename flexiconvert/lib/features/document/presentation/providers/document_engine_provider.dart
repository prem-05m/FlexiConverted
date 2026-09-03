import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/local_document_engine.dart';
import '../../domain/engines/document_engine.dart';

/// Provides the active DocumentEngine. 
/// Defaults to LocalDocumentEngine.
final documentEngineProvider = Provider<DocumentEngine>((ref) {
  return LocalDocumentEngine();
});
