import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../../features/settings/presentation/providers/settings_providers.dart';

class DownloadLocationService {
  static Future<String?> getOutputPath(
      BuildContext context, WidgetRef ref, String fileName) async {
    final settings = await ref.read(settingsProvider.future);
    final downloadPref = settings.defaultSaveDirectory;

    String? targetDirectory;

    if (downloadPref == 'Ask Every Time') {
      final selectedDir = await FilePicker.getDirectoryPath(
        dialogTitle: 'Select where to save $fileName',
      );
      if (selectedDir == null) return null; // User canceled
      targetDirectory = selectedDir;
    } else if (downloadPref == 'Default Downloads') {
      if (Platform.isAndroid) {
        // As requested by user, use /storage/emulated/0/FlexiConverted
        targetDirectory = '/storage/emulated/0/FlexiConverted';
        final dir = Directory(targetDirectory);
        if (!dir.existsSync()) {
          try {
            dir.createSync(recursive: true);
          } catch (e) {
            // Fallback if permission denied
            targetDirectory = '/storage/emulated/0/Download/FlexiConverted';
            final fallbackDir = Directory(targetDirectory);
            if (!fallbackDir.existsSync()) {
              fallbackDir.createSync(recursive: true);
            }
          }
        }
      } else {
        final dir = await getDownloadsDirectory();
        if (dir != null) {
          targetDirectory = path.join(dir.path, 'FlexiConverted');
          final targetDir = Directory(targetDirectory);
          if (!targetDir.existsSync()) {
            targetDir.createSync(recursive: true);
          }
        }
      }
      targetDirectory ??= (await getApplicationDocumentsDirectory()).path;
    } else {
      // Custom directory
      targetDirectory = downloadPref;
      // Check if directory exists
      if (!Directory(targetDirectory).existsSync()) {
        targetDirectory = (await getApplicationDocumentsDirectory()).path;
      }
    }

    // Ensure unique filename
    return _getUniqueFilePath(targetDirectory, fileName);
  }

  static String _getUniqueFilePath(String dir, String fileName) {
    var file = File(path.join(dir, fileName));
    if (!file.existsSync()) {
      return file.path;
    }

    final ext = path.extension(fileName);
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    int counter = 1;

    while (file.existsSync()) {
      file = File(path.join(dir, '${nameWithoutExt}_$counter$ext'));
      counter++;
    }

    return file.path;
  }
}
