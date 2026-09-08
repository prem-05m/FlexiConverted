import 'dart:io';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../network/api_client.dart';
import 'history_service.dart';

/// Service for communicating with the Python FastAPI backend for media jobs.
/// Base URL is controlled by EnvironmentConfig → api_client.dart.
class MediaApiService {
  final Logger _logger = Logger();

  /// Max file size for online (Free tier) users: 100 MB.
  static const int kOnlineMaxBytes = 100 * 1024 * 1024;

  /// Uploads files and creates a job on the Python backend.
  /// Returns the job ID on success, or throws.
  Future<String?> uploadAndCreateJob({
    required List<String> filePaths,
    required String toolType,
    Map<String, dynamic>? params,
  }) async {
    try {
      // ── 100 MB online limit check ───────────────────────────────────────
      for (final path in filePaths) {
        final size = await File(path).length();
        if (size > kOnlineMaxBytes) {
          throw Exception(
            'File too large for online conversion (max 100 MB).\n'
            'Upgrade to Premium for unlimited offline conversions.',
          );
        }
      }

      final deviceName = await HistoryService.getDeviceName();
      final formData = FormData.fromMap({
        'tool_type': toolType,
        'device_name': deviceName,
        if (params != null) 'params': params,
      });

      for (var path in filePaths) {
        formData.files.add(MapEntry(
          'files',
          await MultipartFile.fromFile(
            path,
            filename: path.split(RegExp(r'[/\\]')).last,
          ),
        ));
      }

      // Add Firebase auth token if user is signed in
      final user = FirebaseAuth.instance.currentUser;
      final token = user != null ? await user.getIdToken() : null;

      final response = await ApiClient.dio.post(
        '/api/v1/jobs/upload',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['job']['id'] as String;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to upload and create job: $e');
      rethrow; // re-throw so UI can show the real error message
    }
  }

  /// Polls the job status from the Python backend.
  Future<Map<String, dynamic>?> getJobStatus(String jobId) async {
    try {
      final response = await ApiClient.dio.get('/api/v1/jobs/$jobId/status');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['job'] as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get job status: $e');
      throw Exception('Failed to check job status: $e');
    }
  }

  /// Downloads the finished job output to [outputPath].
  Future<bool> downloadJobOutput(String jobId, String outputPath) async {
    try {
      final response = await ApiClient.dio.download(
        '/api/v1/jobs/$jobId/download',
        outputPath,
        onReceiveProgress: (received, total) {
          // Optional: handle progress
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to download job output: $e');
      throw Exception('Failed to download result: $e');
    }
  }

  /// Deletes the job and cleans up files on the Python server.
  Future<bool> deleteJob(String jobId) async {
    try {
      final response = await ApiClient.dio.delete('/api/v1/jobs/$jobId');
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Failed to delete job: $e');
      return false;
    }
  }
}

