import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/models/qr_task_model.dart';
import 'qr_repository_provider.dart';

class QrTaskNotifier extends Notifier<QrTaskState> {
  @override
  QrTaskState build() {
    return const QrTaskState();
  }

  void initializeTask(QrToolType toolType) {
    state = state.copyWith(
      id: const Uuid().v4(),
      toolType: toolType,
      status: TaskStatus.idle,
      errorMessage: null,
      inputData: null,
      scannedData: null,
      outputPath: null,
    );
  }

  Future<void> executeTask({
    String? inputData,
    String? inputPath,
    String? outputPath,
    Map<String, dynamic>? additionalParams,
  }) async {
    state = state.copyWith(status: TaskStatus.processing);

    final repository = ref.read(qrRepositoryProvider);
    final result = await repository.executeTask(
      toolType: state.toolType,
      inputData: inputData,
      inputPath: inputPath,
      outputPath: outputPath,
      additionalParams: additionalParams,
    );

    result.fold(
      (failure) {
        state = state.copyWith(
          status: TaskStatus.failure,
          errorMessage: failure.message,
        );
      },
      (success) {
        state = state.copyWith(
          status: TaskStatus.success,
          outputPath: success.outputPath,
          scannedData: success.scannedData,
        );
      },
    );
  }
  
  void setScannedData(String data) {
    state = state.copyWith(
      scannedData: data,
      status: TaskStatus.success,
    );
  }
  
  void reset() {
    state = const QrTaskState();
  }
}

final qrTaskProvider = NotifierProvider<QrTaskNotifier, QrTaskState>(() {
  return QrTaskNotifier();
});
