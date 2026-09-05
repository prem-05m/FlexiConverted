import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import 'third_party_api_service.dart';

class CloudConvertService {
  final Dio _dio = Dio();
  static const String _baseUrl = 'https://api.cloudconvert.com/v2';

  Future<String> convertDocument({
    required String inputPath,
    required String outputPath,
    required String fromFormat,
    required String toFormat,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. Fetch the rotating API key from our backend
      final apiKey = await thirdPartyApiService.getCloudConvertApiKey();
      
      final headers = {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      };

      // 2. Create Job
      final jobResponse = await _dio.post(
        '$_baseUrl/jobs',
        options: Options(headers: headers),
        data: {
          "tasks": {
            "import-1": {
              "operation": "import/upload"
            },
            "convert-1": {
              "operation": "convert",
              "input": ["import-1"],
              "input_format": fromFormat,
              "output_format": toFormat
            },
            "export-1": {
              "operation": "export/url",
              "input": ["convert-1"]
            }
          }
        },
      );

      final jobData = jobResponse.data['data'];
      final jobId = jobData['id'];
      
      final uploadTask = (jobData['tasks'] as List).firstWhere((t) => t['name'] == 'import-1');
      final uploadUrl = uploadTask['result']['form']['url'];
      final uploadParams = uploadTask['result']['form']['parameters'] as Map<String, dynamic>;

      // 3. Upload File
      if (onProgress != null) onProgress(0.1);
      final file = File(inputPath);
      final fileName = path.basename(inputPath);
      
      final formData = FormData.fromMap({
        ...uploadParams,
        'file': await MultipartFile.fromFile(inputPath, filename: fileName),
      });

      await _dio.post(
        uploadUrl,
        data: formData,
        onSendProgress: (count, total) {
          if (onProgress != null && total > 0) {
            onProgress(0.1 + (count / total) * 0.3); // 10% to 40%
          }
        },
      );

      // 4. Wait for job completion
      if (onProgress != null) onProgress(0.5);
      
      final waitResponse = await _dio.get(
        '$_baseUrl/jobs/$jobId/wait',
        options: Options(headers: headers),
      );

      final finalJobData = waitResponse.data['data'];
      final status = finalJobData['status'];

      if (status == 'error') {
        final tasks = finalJobData['tasks'] as List;
        final failedTask = tasks.firstWhere((t) => t['status'] == 'error', orElse: () => <String, dynamic>{});
        final errorMessage = failedTask['message'] ?? failedTask['code'] ?? 'Unknown conversion error';
        throw Exception(errorMessage);
      }

      // 5. Extract Download URL
      final exportTask = (finalJobData['tasks'] as List).firstWhere((t) => t['name'] == 'export-1');
      final files = exportTask['result']['files'] as List;
      final downloadUrl = files[0]['url'];

      // 6. Download File
      if (onProgress != null) onProgress(0.8);
      await _dio.download(
        downloadUrl,
        outputPath,
        onReceiveProgress: (count, total) {
          if (onProgress != null && total > 0) {
            onProgress(0.8 + (count / total) * 0.2); // 80% to 100%
          }
        },
      );

      if (onProgress != null) onProgress(1.0);
      return outputPath;

    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 402) {
          throw Exception('CloudConvert Error: Your free daily conversion limit has been reached.');
        }
        final responseData = e.response?.data;
        final message = (responseData is Map) ? responseData['message'] : null;
        throw Exception('Network Error: ${message ?? e.message}');
      }
      throw Exception('Conversion Error: $e');
    }
  }
}

final cloudConvertService = CloudConvertService();
