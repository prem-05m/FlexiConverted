import 'dart:io';
import 'package:logger/logger.dart';
import 'package:archive/archive_io.dart';
import '../../features/image/data/engines/local_image_engine.dart';
import '../../features/image/domain/models/image_task_model.dart';
import '../../core/models/engine_response.dart';
import 'media_api_service.dart';

enum MediaType { image, video, audio }

class MediaProcessingService {
  final Logger _logger = Logger();
  final MediaApiService _apiService = MediaApiService();
  final LocalImageEngine _localImageEngine = LocalImageEngine();

  /// Abstracted method to process media
  /// For Images: If supported locally (convert, resize, crop, compress, rotate, flip), processes locally.
  /// For Videos/Audio: Uploads to backend, polls, and downloads.
  Future<String?> processMedia({
    required MediaType mediaType,
    required String toolType, // Stringified enum like 'convertFormat', 'trim', etc.
    required List<String> inputPaths,
    required String outputPath,
    Map<String, dynamic>? params,
    required Function(double) onProgress,
  }) async {
    try {
      // 1. Check if we can process locally
      if (mediaType == MediaType.image) {
        final localResult = await _tryLocalImageProcessing(
          toolType: toolType,
          inputPaths: inputPaths,
          outputPath: outputPath,
          params: params,
        );

        if (localResult != null && localResult.isSuccess) {
          onProgress(1.0);
          return localResult.data?.outputPath;
        }
        _logger.i('Local image processing skipped or failed, falling back to backend');
      }

      // 2. Fallback to Backend (Required for Video/Audio in this architecture)
      return await _processOnBackend(
        toolType: toolType,
        inputPaths: inputPaths,
        outputPath: outputPath,
        params: params,
        onProgress: onProgress,
      );
    } catch (e) {
      _logger.e('MediaProcessingService error: $e');
      throw Exception(e.toString());
    }
  }

  Future<EngineResponse<ImageResult>?> _tryLocalImageProcessing({
    required String toolType,
    required List<String> inputPaths,
    required String outputPath,
    Map<String, dynamic>? params,
  }) async {
    // If only one file, process normally
    if (inputPaths.length == 1) {
      return _processSingleLocalImage(toolType, inputPaths.first, outputPath, params);
    }

    // Batch processing
    try {
      final processedFiles = <File>[];
      for (int i = 0; i < inputPaths.length; i++) {
        final path = inputPaths[i];
        final fileName = path.split(RegExp(r'[/\\]')).last;
        final baseName = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
        
        ImageFormat targetFormat = ImageFormat.jpg;
        if (params?['outputFormat'] != null) {
          final outFmt = params!['outputFormat'].toString().toLowerCase();
          if (outFmt == 'png') {
            targetFormat = ImageFormat.png;
          } else if (outFmt == 'webp') targetFormat = ImageFormat.webp;
          else if (outFmt == 'bmp') targetFormat = ImageFormat.bmp;
          else if (outFmt == 'gif') targetFormat = ImageFormat.gif;
        }

        // Use a temporary path for each intermediate file
        final tempDir = await Directory.systemTemp.createTemp('flexi_batch_');
        final tempOutputPath = '${tempDir.path}/${baseName}_processed.${targetFormat.name}';

        final res = await _processSingleLocalImage(toolType, path, tempOutputPath, params);
        if (res != null && res.isSuccess && res.data != null) {
          processedFiles.add(File(res.data!.outputPath));
        }
      }

      if (processedFiles.isEmpty) return null;

      final bool zipOutput = params?['zipOutput'] ?? true;
      int totalSize = 0;

      if (zipOutput) {
        // Zip the files
        var encoder = ZipFileEncoder();
        encoder.create(outputPath);
        for (var file in processedFiles) {
          encoder.addFile(file);
          totalSize += await file.length();
        }
        encoder.close();
      } else {
        // Save to directory
        final outDir = Directory(outputPath);
        if (!await outDir.exists()) {
          await outDir.create(recursive: true);
        }
        for (var file in processedFiles) {
          final newPath = '${outDir.path}/${file.path.split(RegExp(r'[/\\]')).last}';
          await file.copy(newPath);
          totalSize += await file.length();
        }
      }

      // Cleanup temp files
      for (var file in processedFiles) {
        if (await file.exists()) await file.delete();
      }

      return EngineResponse.success(ImageResult(
        outputPath: outputPath,
        fileSizeBytes: totalSize,
        durationMs: 0,
      ));
    } catch (e) {
      _logger.e('Local batch processing error: $e');
      return null;
    }
  }

  Future<EngineResponse<ImageResult>?> _processSingleLocalImage(
    String toolType, String inputPath, String outputPath, Map<String, dynamic>? params
  ) async {
    ImageFormat targetFormat = ImageFormat.jpg;
    if (params?['outputFormat'] != null) {
      final outFmt = params!['outputFormat'].toString().toLowerCase();
      if (outFmt == 'png') {
        targetFormat = ImageFormat.png;
      } else if (outFmt == 'webp') targetFormat = ImageFormat.webp;
      else if (outFmt == 'bmp') targetFormat = ImageFormat.bmp;
      else if (outFmt == 'gif') targetFormat = ImageFormat.gif;
    }

    switch (toolType) {
      case 'convertFormat':
      case 'convertImage':
      case 'batchConvert':
        return _localImageEngine.convertFormat(
          inputPath: inputPath,
          outputPath: outputPath,
          targetFormat: targetFormat,
          quality: params?['quality'] ?? 100,
        );
      case 'resize':
      case 'batchResize':
        return _localImageEngine.resizeImage(
          inputPath: inputPath,
          outputPath: outputPath,
          width: params?['width'] ?? 800,
          height: params?['height'] ?? 800,
        );
      case 'compress':
      case 'batchCompress':
        return _localImageEngine.compressImage(
          inputPath: inputPath,
          outputPath: outputPath,
          quality: params?['quality'] ?? 80,
        );
      case 'crop':
        return _localImageEngine.cropImage(
          inputPath: inputPath,
          outputPath: outputPath,
          x: params?['x'] ?? 0,
          y: params?['y'] ?? 0,
          width: params?['width'] ?? 100,
          height: params?['height'] ?? 100,
        );
      case 'rotate':
        return _localImageEngine.rotateImage(
          inputPath: inputPath,
          outputPath: outputPath,
          angle: params?['angle'] ?? 90,
        );
      case 'flip':
        return _localImageEngine.flipImage(
          inputPath: inputPath,
          outputPath: outputPath,
          horizontal: params?['horizontal'] ?? true,
          vertical: params?['vertical'] ?? false,
        );
      case 'removeMetadata':
        return _localImageEngine.removeMetadata(
          inputPath: inputPath,
          outputPath: outputPath,
        );
      case 'colorMode':
        return _localImageEngine.colorMode(
          inputPath: inputPath,
          outputPath: outputPath,
          mode: params?['mode'] ?? 'grayscale',
        );
      case 'dpiResolution':
        return _localImageEngine.dpiResolution(
          inputPath: inputPath,
          outputPath: outputPath,
          dpi: params?['dpi'] ?? 300,
        );
    }
    return null;
  }

  Future<String?> _processOnBackend({
    required String toolType,
    required List<String> inputPaths,
    required String outputPath,
    Map<String, dynamic>? params,
    required Function(double) onProgress,
  }) async {
    // 1. Upload
    onProgress(0.1);
    final jobId = await _apiService.uploadAndCreateJob(
      filePaths: inputPaths,
      toolType: toolType,
      params: params,
    );

    if (jobId == null) throw Exception('Failed to create job on server');

    // 2. Poll
    bool completed = false;
    String? error;
    
    while (!completed) {
      await Future.delayed(const Duration(seconds: 2));
      final statusData = await _apiService.getJobStatus(jobId);
      
      if (statusData == null) continue;

      final status = statusData['status'];
      final progress = (statusData['progress'] ?? 0.0) / 100.0;
      
      // Keep progress between 10% (upload done) and 90% (downloading)
      onProgress(0.1 + (progress * 0.8)); 

      if (status == 'completed') {
        completed = true;
      } else if (status == 'failed' || status == 'cancelled') {
        error = statusData['error'] ?? 'Job failed on server';
        completed = true;
      }
    }

    if (error != null) throw Exception(error);

    // 3. Download
    onProgress(0.9);
    final downloadSuccess = await _apiService.downloadJobOutput(jobId, outputPath);
    
    if (!downloadSuccess) throw Exception('Failed to download processed file');

    // 4. Cleanup on server (optional but good practice)
    await _apiService.deleteJob(jobId);

    onProgress(1.0);
    return outputPath;
  }
}
