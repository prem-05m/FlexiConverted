import 'dart:io';
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/file_engine.dart';
import '../../domain/models/file_task_model.dart';
import 'package:path/path.dart' as path;

class LocalFileEngine implements FileEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<FileResult>> executeFileOperation({
    required FileToolType toolType,
    required List<String> inputPaths,
    String? outputPath,
    Map<String, dynamic>? options,
  }) async {
    try {
      switch (toolType) {
        case FileToolType.rename:
          if (inputPaths.isEmpty || outputPath == null) {
            return EngineResponse.failure('Missing input or output path for rename');
          }
          final file = File(inputPaths.first);
          if (await file.exists()) {
            final newPath = path.join(file.parent.path, outputPath);
            await file.rename(newPath);
            return EngineResponse.success(FileResult(outputPath: newPath));
          }
          return EngineResponse.failure('File not found');

        case FileToolType.delete:
          if (inputPaths.isEmpty) return EngineResponse.failure('No files to delete');
          List<String> deleted = [];
          for (final p in inputPaths) {
            final type = await FileSystemEntity.type(p);
            if (type == FileSystemEntityType.file) {
              await File(p).delete();
              deleted.push(p);
            } else if (type == FileSystemEntityType.directory) {
              await Directory(p).delete(recursive: true);
              deleted.push(p);
            }
          }
          return EngineResponse.success(FileResult(deletedPaths: deleted));

        case FileToolType.copy:
        case FileToolType.move:
          if (inputPaths.isEmpty || outputPath == null) {
            return EngineResponse.failure('Missing input or output path for copy/move');
          }
          final isMove = toolType == FileToolType.move;
          for (final p in inputPaths) {
            final file = File(p);
            if (await file.exists()) {
              final newPath = path.join(outputPath, path.basename(p));
              await file.copy(newPath);
              if (isMove) await file.delete();
            }
          }
          return EngineResponse.success(FileResult(outputPath: outputPath));

        default:
          return EngineResponse.notAvailable(toolType.name);
      }
    } catch (e) {
      return EngineResponse.failure('Failed to execute file operation: $e');
    }
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> getFileInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final stat = await file.stat();
        return EngineResponse.success({
          'sizeBytes': stat.size,
          'modified': stat.modified.toIso8601String(),
          'accessed': stat.accessed.toIso8601String(),
          'type': stat.type.toString(),
        });
      }
      return EngineResponse.failure('File does not exist');
    } catch (e) {
      return EngineResponse.failure('Failed to get file info: $e');
    }
  }
}

extension on List<String> {
  void push(String p) {
    add(p);
  }
}
