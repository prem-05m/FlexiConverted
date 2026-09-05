import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'history_service.dart';

class MediaApiService {
  final Logger _logger = Logger();
  
  // Create a dedicated Dio instance without interceptors that might retry FormDatas
  final Dio _dio = Dio();
  
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for desktop/web/iOS simulator
  static String get _baseUrl {
    if (Platform.isAndroid) return 'http://10.0.2.2:3000/api/v1/jobs';
    return 'http://127.0.0.1:3000/api/v1/jobs';
  }

  /// Uploads files and creates a job, returning the Job ID.
  Future<String?> uploadAndCreateJob({
    required List<String> filePaths,
    required String toolType,
    Map<String, dynamic>? params,
  }) async {
    try {
      final deviceName = await HistoryService.getDeviceName();
      
      final formData = FormData.fromMap({
        'toolType': toolType,
        'deviceName': deviceName,
        if (params != null) 'params': params, // Send as JSON string or object depending on backend
      });

      for (var path in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(path, filename: path.split(RegExp(r'[/\\]')).last),
        ));
      }

      final response = await _dio.post(
        '$_baseUrl/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        return response.data['job']['_id'] as String;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to upload and create job: $e');
      throw Exception('Failed to communicate with media server: $e');
    }
  }

  /// Polls the job status
  Future<Map<String, dynamic>?> getJobStatus(String jobId) async {
    try {
      final response = await _dio.get('$_baseUrl/$jobId/status');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['job'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get job status: $e');
      throw Exception('Failed to check job status: $e');
    }
  }

  /// Downloads the finished job to a specified path
  Future<bool> downloadJobOutput(String jobId, String outputPath) async {
    try {
      final response = await _dio.download(
        '$_baseUrl/$jobId/download',
        outputPath,
        onReceiveProgress: (received, total) {
          // Optional: handle download progress
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to download job output: $e');
      throw Exception('Failed to download result: $e');
    }
  }

  /// Deletes the job and cleans up files
  Future<bool> deleteJob(String jobId) async {
    try {
      final response = await _dio.delete('$_baseUrl/$jobId');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to delete job: $e');
      return false;
    }
  }
}
