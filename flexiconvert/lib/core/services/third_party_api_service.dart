import 'package:dio/dio.dart';

class ThirdPartyApiService {
  // Use 10.140.7.111 for physical Android device on the same Wi-Fi
  // Or your production Vercel URL
  static const String _baseUrl = 'http://10.140.7.111:3000/api/v1';
  final Dio _dio = Dio();

  /// Fetches the CloudConvert API key.
  /// To bypass network issues, simply paste your CloudConvert API key below.
  Future<String> getCloudConvertApiKey() async {
    // -------------------------------------------------------------
    // TEMPORARY FIX: Paste your CloudConvert API key here for testing
    // Get a free key at: https://cloudconvert.com/dashboard/api/v2/keys
    // -------------------------------------------------------------
    const String hardcodedKey =
        'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiNTNjZmY1MjcyNTUzNjgyYjUyNGRiYWM2Mjk5Y2RhZDgzN2RiZGVhYjgwMzM0Y2NhYzJmMmI3Y2FkNzY2NGY5MDY4OGQ5M2E3ZTM4YjI4ZTgiLCJpYXQiOjE3ODg0NTUyNjQuOTY4NjMyLCJuYmYiOjE3ODg0NTUyNjQuOTY4NjMzLCJleHAiOjQ5NDQxMjg4NjQuOTU3MTIsInN1YiI6Ijc2ODQxOTc1Iiwic2NvcGVzIjpbInVzZXIucmVhZCIsInRhc2sucmVhZCIsInRhc2sud3JpdGUiXX0.CQ17TdNs70pviAoS_kDhHdwCRezI1WUAk0Icpsq372U-ljstWqiieFk_SbP44G8VTNtmXCYlCa-SsKFBIqgCvT9DGVsJzXy5kDy2AB2GqN63S32gnm39iZKlIFca2xgcSGcZERxjDfxY49bM3G9D6R56Aw2z7Y7rbwpFLRIAT1IvmbUj3H5lJXihOp1t-FCdn_gzXgt50o9wMTNbGpRvr6Ko70iJVNQ2HAjqfELGe_DhRW3nMcEpq-ASjBEoAVbNzZYP16dgRlmyhj62d0SIpvb61dHF6YUiwjQuL52mgjqWsALdKqGUiKY1PzThfizdzXGNHkqetfxg15Qh40w8ZZ2EioOIuJrvg85UKYuXCJZ3V8AZY2IFHz8gjl_Y2OF3EGZd8iatl46sdVs2P_O1VYLhAtQKtOaP5hqz9JaA0jd_FKRgIJ7Bzw4grW2JTAuCvjfuM8FVOzKIRPGTlaxF8Rjqoe2M7o8KzohX6AL983mfm0rVthFeuaz1hLfwBCqF_9v2aEbIDPpwLwX3pYGBRkJWTApTpySghyajpMA1FjZ1EoOOqpjDkEUhsgVNP-j8kanjpf3gY-Hzx2ESfBRU96kwHdN3fpbByrgIqX-mC1OE2YGzY8FrR5A7a3lxZxCrlV_43GLx09EIEFy5-wiKbwaiqx5aESrQdXgorTfqZuU'; // <-- PASTE KEY HERE

    if (hardcodedKey.isNotEmpty) {
      return hardcodedKey;
    }

    try {
      final response = await _dio.get('$_baseUrl/keys/cloudconvert');
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
