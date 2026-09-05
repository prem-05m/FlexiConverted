import 'dart:io';
import 'package:mime/mime.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../database/database_provider.dart';
import '../database/models/history_model.dart';
import '../database/models/recent_file_model.dart';
import 'firestore_history_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryService {
  static Future<String> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine;
    }
    return 'Unknown Device';
  }

  static Future<void> logConversion({
    required String fileName,
    required String toolType,
    required String status,
    required String outputPath,
    required int durationMs,
    String? cloudUrl,
  }) async {
    final deviceName = await getDeviceName();
    
    final historyItem = HistoryItem()
      ..fileName = fileName
      ..toolType = toolType
      ..timestamp = DateTime.now()
      ..status = status
      ..outputPath = outputPath
      ..durationMs = durationMs
      ..fileSizeBytes = 0
      ..deviceName = deviceName
      ..cloudUrl = cloudUrl;

    await db.putHistory(historyItem);

    // Sync to Firestore if logged in
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final firestoreService = FirestoreHistoryService(uid: uid);
      await firestoreService.putHistory(historyItem);
    }

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
