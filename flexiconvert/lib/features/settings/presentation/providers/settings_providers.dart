import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/models/settings_model.dart';

final settingsProvider = StreamProvider<AppSettings>((ref) async* {
  // Ensure we have a default settings object
  var settings = await db.getSettings(1);
  if (settings == null) {
    settings = AppSettings()
      ..id = 1
      ..themeMode = 'system'
      ..languageCode = 'en'
      ..notificationsEnabled = true
      ..defaultSaveDirectory = 'Ask Every Time'
      ..autoDeleteOriginal = false;
      
    await db.putSettings(settings);
  }

  yield* db.watchSettings(1).map((s) => s ?? settings!);
});

class SettingsNotifier {
  SettingsNotifier();

  Future<void> updateTheme(String theme) async {
    final settings = await db.getSettings(1);
    if (settings != null) {
      settings.themeMode = theme;
      await db.putSettings(settings);
    }
  }
  
  Future<void> updateLanguage(String language) async {
    final settings = await db.getSettings(1);
    if (settings != null) {
      settings.languageCode = language;
      await db.putSettings(settings);
    }
  }

  Future<void> updateNotifications(bool enabled) async {
    final settings = await db.getSettings(1);
    if (settings != null) {
      settings.notificationsEnabled = enabled;
      await db.putSettings(settings);
    }
  }

  Future<void> updateAutoDelete(bool enabled) async {
    final settings = await db.getSettings(1);
    if (settings != null) {
      settings.autoDeleteOriginal = enabled;
      await db.putSettings(settings);
    }
  }

  Future<void> updateSaveDirectory(String directory) async {
    final settings = await db.getSettings(1);
    if (settings != null) {
      settings.defaultSaveDirectory = directory;
      await db.putSettings(settings);
    }
  }
}

final settingsNotifierProvider = Provider<SettingsNotifier>((ref) {
  return SettingsNotifier();
});
