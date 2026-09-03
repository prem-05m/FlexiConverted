import 'package:isar/isar.dart';

part 'recent_file_model.g.dart';

@collection
class RecentFile {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String filePath;

  late String fileName;
  late String mimeType;
  late DateTime lastOpened;
}
