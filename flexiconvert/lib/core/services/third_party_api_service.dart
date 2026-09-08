import 'package:dio/dio.dart';
import '../network/api_client.dart';

class ThirdPartyApiService {
  /// Fetches the rotating CloudConvert API key from the Python backend.
  /// The Python server tracks usage in Firestore and rotates across multiple keys.
  Future<String> getCloudConvertApiKey() async {
    try {
      final response = await ApiClient.dio.get('/api/v1/keys/cloudconvert');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['apiKey'] as String;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to fetch API key');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 429) {
        throw Exception('Daily limit reached. Try again tomorrow.');
      }
      throw Exception('Network error while fetching API key: ${e.message}');
    } catch (e) {
      throw Exception('Failed to get CloudConvert API Key: $e');
    }
  }
}

final thirdPartyApiService = ThirdPartyApiService();

