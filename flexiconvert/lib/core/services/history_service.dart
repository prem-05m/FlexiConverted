import 'package:mime/mime.dart';
import '../database/database_provider.dart';
import '../database/models/history_model.dart';
import '../database/models/recent_file_model.dart';

class HistoryService {
  static Future<void> logConversion({
    required String fileName,
    required String toolType,
    required String status,
    required String outputPath,
    required int durationMs,
  }) async {
    final historyItem = HistoryItem()
      ..fileName = fileName
      ..toolType = toolType
      ..timestamp = DateTime.now()
      ..status = status
      ..outputPath = outputPath
      ..durationMs = durationMs
      ..fileSizeBytes = 0;

    await db.putHistory(historyItem);

    if (status == 'success' && outputPath.isNotEmpty) {
      await _addToRecent(outputPath, fileName);
    }
  }

  static Future<void> _addToRecent(String filePath, String fileName) async {
    final mimeType = lookupMimeType(filePath) ?? 'application/octet-stream';

    final recentFile = RecentFile()
      ..filePath = filePath
      ..fileName = fileName
      ..mimeType = mimeType
      ..lastOpened = DateTime.now();

    await db.putRecentFile(recentFile);
  }
}
