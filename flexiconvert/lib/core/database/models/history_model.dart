import 'package:isar/isar.dart';

part 'history_model.g.dart';

@collection
class HistoryItem {
  Id id = Isar.autoIncrement;

  late String fileName;
  late String toolType;
  late DateTime timestamp;
  late String status; // success, failed, processing
  late String outputPath;
  late int durationMs;
  late int fileSizeBytes;
  String? deviceName; // Add this
  String? cloudUrl;   // Add this
}
