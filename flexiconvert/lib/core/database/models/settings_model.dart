import 'package:isar/isar.dart';

part 'settings_model.g.dart';

@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  late String themeMode; // light, dark, system
  late String languageCode;
  late bool notificationsEnabled;
  late String defaultSaveDirectory;
  late bool autoDeleteOriginal;
}
