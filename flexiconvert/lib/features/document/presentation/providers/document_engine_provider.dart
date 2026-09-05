import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/engines/cloud_document_engine.dart';
import '../../domain/engines/document_engine.dart';

/// Provides the active DocumentEngine. 
/// Defaults to CloudDocumentEngine to use the CloudConvert API.
final documentEngineProvider = Provider<DocumentEngine>((ref) {
  return CloudDocumentEngine();
});
