import 'dart:io';
import 'package:logger/logger.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_new/return_code.dart';

class LocalFfmpegEngine {
  final Logger _logger = Logger();

  /// Gets the media duration in milliseconds using FFprobe
  Future<int> getMediaDurationMs(String path) async {
    final session = await FFprobeKit.getMediaInformation(path);
    final info = session.getMediaInformation();
    if (info != null) {
      final durationStr = info.getDuration();
      if (durationStr != null) {
        final durationSecs = double.tryParse(durationStr) ?? 0.0;
        return (durationSecs * 1000).toInt();
      }
    }
    return 0;
  }

  /// Executes an FFmpeg command and reports progress
  Future<String?> executeCommand({
    required String command,
    required String outputPath,
    required Function(double) onProgress,
    int? totalDurationMs,
  }) async {
    _logger.i('Executing FFmpeg command: $command');
    
    // Set up progress callback
    FFmpegKitConfig.enableStatisticsCallback((statistics) {
      if (totalDurationMs != null && totalDurationMs > 0) {
        final timeInMs = statistics.getTime();
        double progress = timeInMs / totalDurationMs;
        if (progress > 1.0) progress = 1.0;
        if (progress < 0.0) progress = 0.0;
        onProgress(progress);
      }
    });

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    
    // Clear callback after execution
    FFmpegKitConfig.enableStatisticsCallback(null);

    if (ReturnCode.isSuccess(returnCode)) {
      _logger.i('FFmpeg command successful');
      onProgress(1.0);
      return outputPath;
    } else {
      final logs = await session.getLogsAsString();
      _logger.e('FFmpeg command failed with return code $returnCode. Logs: $logs');
      throw Exception('Media processing failed. Logs: $logs');
    }
  }

  /// Convert format for Audio or Video
  Future<String?> convertFormat({
    required String inputPath,
    required String outputPath,
    Map<String, dynamic>? params,
    required Function(double) onProgress,
  }) async {
    final durationMs = await getMediaDurationMs(inputPath);
    
    // Check if remux is possible
    bool useRemux = params?['useRemux'] ?? false;
    
    if (useRemux) {
      try {
        final command = '-y -i "$inputPath" -c copy "$outputPath"';
        _logger.i('Attempting Remux (stream copy)...');
        return await executeCommand(
          command: command,
          outputPath: outputPath,
          onProgress: onProgress,
          totalDurationMs: durationMs,
        );
      } catch (e) {
        _logger.w('Remux failed, falling back to re-encoding. Error: $e');
        // Delete potentially corrupted output file from failed remux
        if (await File(outputPath).exists()) {
          await File(outputPath).delete();
        }
      }
    }

    // Basic auto conversion based on file extension (Re-encoding)
    _logger.i('Starting Re-encoding...');
    final command = '-y -i "$inputPath" "$outputPath"';
    return executeCommand(
      command: command,
      outputPath: outputPath,
      onProgress: onProgress,
      totalDurationMs: durationMs,
    );
  }

  /// Trim Audio or Video
  Future<String?> trim({
    required String inputPath,
    required String outputPath,
    required double startTimeMs,
    required double endTimeMs,
    required Function(double) onProgress,
  }) async {
    final startSec = startTimeMs / 1000.0;
    final endSec = endTimeMs / 1000.0;
    final durationSec = endSec - startSec;
    
    // -ss specifies start time, -t specifies duration
    final command = '-y -ss $startSec -i "$inputPath" -t $durationSec -c copy "$outputPath"';
    
    return executeCommand(
      command: command,
      outputPath: outputPath,
      onProgress: onProgress,
      totalDurationMs: (durationSec * 1000).toInt(),
    );
  }

  /// Split Media into parts
  Future<String?> split({
    required String inputPath,
    required String outputDir,
    required int parts,
    required Function(double) onProgress,
  }) async {
    final totalDurationMs = await getMediaDurationMs(inputPath);
    if (totalDurationMs == 0) throw Exception("Could not determine media duration for splitting");
    
    final partDurationSec = (totalDurationMs / 1000.0) / parts;
    
    final baseName = inputPath.split(RegExp(r'[/\\]')).last;
    final nameWithoutExt = baseName.contains('.') ? baseName.substring(0, baseName.lastIndexOf('.')) : baseName;
    final ext = baseName.contains('.') ? baseName.substring(baseName.lastIndexOf('.')) : '';
    
    // We can use the segment muxer in FFmpeg
    final outputPath = '$outputDir/${nameWithoutExt}_part%03d$ext';
    
    final command = '-y -i "$inputPath" -f segment -segment_time $partDurationSec -c copy "$outputPath"';
    
    // Since output is a directory/pattern, we return the directory
    await executeCommand(
      command: command,
      outputPath: outputDir, 
      onProgress: onProgress,
      totalDurationMs: totalDurationMs,
    );
    
    return outputDir;
  }

  /// Cut/Remove a segment from Media
  Future<String?> cut({
    required String inputPath,
    required String outputPath,
    required double removeStartTimeMs,
    required double removeEndTimeMs,
    required Function(double) onProgress,
  }) async {
    final startSec = removeStartTimeMs / 1000.0;
    final endSec = removeEndTimeMs / 1000.0;
    
    // Complex filter to remove middle segment
    // Since dealing with AV sync in filter_complex is tricky and format specific,
    // a simpler approach is to split into two temporary files and concat them.
    
    final tempDir = await Directory.systemTemp.createTemp('flexi_cut_');
    final ext = inputPath.contains('.') ? inputPath.substring(inputPath.lastIndexOf('.')) : '.mp4';
    final part1 = '${tempDir.path}/part1$ext';
    final part2 = '${tempDir.path}/part2$ext';
    final listFile = File('${tempDir.path}/files.txt');
    
    try {
      // 1. Extract Part 1 (from 0 to startSec)
      await FFmpegKit.execute('-y -i "$inputPath" -t $startSec -c copy "$part1"');
      onProgress(0.4);
      
      // 2. Extract Part 2 (from endSec to end)
      await FFmpegKit.execute('-y -ss $endSec -i "$inputPath" -c copy "$part2"');
      onProgress(0.8);
      
      // 3. Concat
      await listFile.writeAsString("file 'part1$ext'\nfile 'part2$ext'\n");
      final concatCommand = '-y -f concat -safe 0 -i "${listFile.path}" -c copy "$outputPath"';
      await FFmpegKit.execute(concatCommand);
      
      onProgress(1.0);
      return outputPath;
    } finally {
      // Cleanup
      if (await File(part1).exists()) await File(part1).delete();
      if (await File(part2).exists()) await File(part2).delete();
      if (await listFile.exists()) await listFile.delete();
    }
  }
}
