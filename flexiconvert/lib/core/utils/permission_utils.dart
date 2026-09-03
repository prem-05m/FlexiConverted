import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      if (androidInfo.version.sdkInt <= 32) {
        final status = await Permission.storage.request();
        return status.isGranted;
      } else {
        // Android 13+ needs granular media permissions
        Map<Permission, PermissionStatus> statuses = await [
          Permission.photos,
          Permission.videos,
          Permission.audio,
        ].request();
        
        return statuses[Permission.photos]!.isGranted ||
               statuses[Permission.videos]!.isGranted ||
               statuses[Permission.audio]!.isGranted;
      }
    }
    
    // iOS and others
    final status = await Permission.storage.request();
    return status.isGranted;
  }
}
