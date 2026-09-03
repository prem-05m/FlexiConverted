import 'database_service.dart';
import 'database_stub.dart'
    if (dart.library.io) 'database_native.dart'
    if (dart.library.js_interop) 'database_web.dart';

/// Global database instance. Initialized in main().
late final DatabaseService db;

/// Initialize the correct database for the current platform.
/// Uses conditional imports to avoid loading dart:ffi/Isar on web.
Future<void> initDatabase() async {
  db = createPlatformDatabase();
  await db.init();
}
