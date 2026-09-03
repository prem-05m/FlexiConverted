import 'dart:io';
import 'package:dio/dio.dart';

class CloudinaryConfig {
  final String cloudName;
  final String uploadPreset;

  const CloudinaryConfig({
    required this.cloudName,
    required this.uploadPreset,
  });
}

class CloudinaryService {
  final Dio _dio = Dio();
  
  // The two accounts provided by the user
  final List<CloudinaryConfig> _accounts = const [
    CloudinaryConfig(
      cloudName: 'brxgal7f',
      uploadPreset: 'qxydm8ec', // Eatoo account
    ),
    CloudinaryConfig(
      cloudName: 'dzt0qada5',
      uploadPreset: 'yedsrha2', // Krishna account
    ),
  ];

  static final CloudinaryService instance = CloudinaryService._internal();

  CloudinaryService._internal();

  Future<String?> uploadFile(File file, String fileName) async {
    for (int i = 0; i < _accounts.length; i++) {
      final account = _accounts[i];
      try {
        // We use /auto/upload so it handles both images and raw documents (PDFs)
        final url = 'https://api.cloudinary.com/v1_1/${account.cloudName}/auto/upload';
        
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(file.path, filename: fileName),
          'upload_preset': account.uploadPreset,
          // Put the file into a FlexiConvert folder
          'public_id': 'FlexiConvert/${DateTime.now().millisecondsSinceEpoch}_$fileName',
        });

        final response = await _dio.post(url, data: formData);

        if (response.statusCode == 200) {
          final data = response.data;
          print('Successfully uploaded to Cloudinary (Account ${i + 1}): ${data['secure_url']}');
          return data['secure_url']; // Returns the public URL of the uploaded file
        }
      } catch (e) {
        print('Upload to Cloudinary account ${i + 1} failed: $e');
        // If it's the last account, we have completely failed.
        if (i == _accounts.length - 1) {
          print('All Cloudinary accounts failed! Storage might be full on both.');
          return null;
        }
        // Otherwise, the loop continues and tries the next account automatically!
        print('Automatically switching to the next Cloudinary account...');
      }
    }
    return null;
  }
}
