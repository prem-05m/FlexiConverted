import 'database_service.dart';
import 'web_database_service.dart';

/// Web platform: returns WebDatabaseService.
DatabaseService createPlatformDatabase() {
  return WebDatabaseService();
}
