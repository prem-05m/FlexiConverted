import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as pathLib;
import '../../../../core/models/engine_response.dart';
import '../../domain/engines/archive_engine.dart';
import '../../domain/models/archive_task_model.dart';

class LocalArchiveEngine implements ArchiveEngine {
  @override
  Future<bool> isReady() async => true;

  @override
  Future<EngineResponse<ArchiveResult>> compress({
    required List<String> inputPaths,
    required String outputPath,
    required ArchiveFormat format,
    String? password,
  }) async {
    try {
      if (format == ArchiveFormat.zip) {
        final encoder = ZipFileEncoder();
        encoder.create(outputPath);
        
        for (final p in inputPaths) {
          final type = await FileSystemEntity.type(p);
          if (type == FileSystemEntityType.directory) {
            encoder.addDirectory(Directory(p));
          } else {
            encoder.addFile(File(p), pathLib.basename(p));
          }
        }
        
        encoder.close();
        
        final size = await File(outputPath).length();
        return EngineResponse.success(ArchiveResult(
          outputPath: outputPath,
          fileSizeBytes: size,
        ));
      } else {
        // Formats like RAR, 7z usually require native bindings or cloud
        return EngineResponse.notAvailable('Compression format ${format.name} not available locally');
      }
    } catch (e) {
      return EngineResponse.failure('Failed to compress archive: $e');
    }
  }

  @override
  Future<EngineResponse<ArchiveResult>> extract({
    required String inputPath,
    required String outputPath,
    String? password,
  }) async {
    try {
      final bytes = await File(inputPath).readAsBytes();
      
      // Determine format from extension roughly
      final ext = inputPath.split('.').last.toLowerCase();
      
      Archive archive;
      if (ext == 'zip') {
        archive = ZipDecoder().decodeBytes(bytes);
      } else if (ext == 'tar') {
        archive = TarDecoder().decodeBytes(bytes);
      } else if (ext == 'gz') {
        archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
      } else {
        return EngineResponse.notAvailable('Extraction format .$ext not available locally');
      }

      for (final file in archive) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          final outFile = File('$outputPath/$filename');
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(data);
        } else {
          await Directory('$outputPath/$filename').create(recursive: true);
        }
      }

      return EngineResponse.success(ArchiveResult(
        outputPath: outputPath,
        fileSizeBytes: 0,
        metadata: {'extractedFilesCount': archive.length},
      ));
    } catch (e) {
      return EngineResponse.failure('Failed to extract archive: $e');
    }
  }

  @override
  Future<EngineResponse<Map<String, dynamic>>> readMetadata({
    required String inputPath,
  }) async {
    try {
      final file = File(inputPath);
      final size = await file.length();
      
      return EngineResponse.success({
        'sizeBytes': size,
        'path': inputPath,
      });
    } catch (e) {
      return EngineResponse.failure('Failed to read archive metadata: $e');
    }
  }
}
