import 'package:isar/isar.dart';

part 'favorite_model.g.dart';

@collection
class FavoriteItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String filePath;

  late String fileName;
  late String fileType;
  late DateTime addedDate;
}
