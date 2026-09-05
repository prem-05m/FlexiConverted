import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../domain/models/pdf_task_model.dart';
import 'pdf_repository_provider.dart';

class PdfTaskNotifier extends Notifier<PdfTaskState> {
  @override
  PdfTaskState build() {
    return const PdfTaskState();
  }

  void initializeTask(PdfToolType toolType, List<String> inputPaths) {
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

    final repository = ref.read(pdfRepositoryProvider);
    final result = await repository.executeTask(
      toolType: state.toolType,
      inputPaths: state.inputPaths,
      outputPath: outputPath,
      additionalParams: additionalParams,
      onProgress: (progress) {
        // Safe update avoiding build phase conflicts
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
          outputPaths: success.outputPaths,
          progress: 1.0,
        );

        // Auto-upload to Cloudinary
        try {
          final cloudinary = CloudinaryService.instance;
          final file = File(success.outputPath);
          final fileName = file.uri.pathSegments.last;
          await cloudinary.uploadFile(file, fileName);
        } catch (e) {
          // Fail silently for uploads to not interrupt the user flow
          print('Cloudinary upload failed: $e');
        }
      },
    );
  }

  void reset() {
    state = const PdfTaskState();
  }
}

final pdfTaskProvider = NotifierProvider<PdfTaskNotifier, PdfTaskState>(() {
  return PdfTaskNotifier();
});
