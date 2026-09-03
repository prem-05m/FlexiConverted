import 'database_service.dart';
import 'isar_service.dart';

/// Native platform: returns IsarDatabaseService.
DatabaseService createPlatformDatabase() {
  return IsarDatabaseService();
}
