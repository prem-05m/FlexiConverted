import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/models/document_task_model.dart';
import 'document_repository_provider.dart';

class DocumentTaskNotifier extends Notifier<DocumentTaskState> {
  @override
  DocumentTaskState build() {
    return const DocumentTaskState();
  }

  void initializeTask(DocumentToolType toolType, List<String> inputPaths) {
    state = state.copyWith(
      id: const Uuid().v4(),
      toolType: toolType,
      inputPaths: inputPaths,
      status: TaskStatus.idle,
      errorMessage: null,
      progress: 0.0,
    );
  }

  Future<void> executeTask({
    required String outputPath,
    Map<String, dynamic>? additionalParams,
  }) async {
    state = state.copyWith(status: TaskStatus.processing, progress: 0.0);

    final repository = ref.read(documentRepositoryProvider);
    final result = await repository.executeTask(
      toolType: state.toolType,
      inputPaths: state.inputPaths,
      outputPath: outputPath,
      additionalParams: additionalParams,
      onProgress: (progress) {
        Future.microtask(() {
          state = state.copyWith(progress: progress);
        });
      },
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        );
      },
      (success) async {
        state = state.copyWith(
          status: TaskStatus.success,
          outputPath: success.outputPath,
          progress: 1.0,
        );
        
        try {
          if (!success.outputPath.toLowerCase().endsWith('.zip') &&
              !success.outputPath.toLowerCase().endsWith('.mp4')) {
            final cloudinary = CloudinaryService.instance;
            final file = File(success.outputPath);
            final fileName = file.uri.pathSegments.last;
            final url = await cloudinary.uploadFile(file, fileName);
            if (url != null) {
              state = state.copyWith(cloudUrl: url);
            }
          }
        } catch (e) {
          print('Cloudinary upload failed: $e');
        }
      },
    );
  }
  
  void reset() {
    state = const DocumentTaskState();
  }
}

final documentTaskProvider = NotifierProvider<DocumentTaskNotifier, DocumentTaskState>(() {
  return DocumentTaskNotifier();
});
