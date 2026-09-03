import 'dart:io';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

class FileUtils {
  static String getExtension(String filePath) {
    return p.extension(filePath).replaceAll('.', '');
  }

  static String getFileName(String filePath) {
    return p.basename(filePath);
  }

  static String getFileNameWithoutExtension(String filePath) {
    return p.basenameWithoutExtension(filePath);
  }

  static Future<int> getFileSizeInBytes(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      return await file.length();
    }
    return 0;
  }

  static String? getMimeType(String filePath) {
    return lookupMimeType(filePath);
  }
}
