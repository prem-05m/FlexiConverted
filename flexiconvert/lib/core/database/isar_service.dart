import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'database_service.dart';
import 'models/favorite_model.dart';
import 'models/history_model.dart';
import 'models/pinned_tool_model.dart';
import 'models/recent_file_model.dart';
import 'models/settings_model.dart';
import 'models/user_profile_model.dart';

/// Isar-backed implementation of [DatabaseService] for Android/iOS/Desktop.
class IsarDatabaseService implements DatabaseService {
  late Isar _isar;

  /// Exposed for legacy code that still references IsarService.isar directly.
  Isar get isar => _isar;

  @override
  Future<void> init() async {
    String dirPath = '';
    if (!kIsWeb) {
      final dir = await getApplicationDocumentsDirectory();
      dirPath = dir.path;
    }

    try {
      if (Isar.getInstance() != null) {
        _isar = Isar.getInstance()!;
        return;
      }

      _isar = await Isar.open(
        [
          HistoryItemSchema,
          FavoriteItemSchema,
          RecentFileSchema,
          AppSettingsSchema,
          PinnedToolSchema,
          UserProfileModelSchema,
        ],
        directory: dirPath,
      );
    } catch (e) {
      debugPrint("First Isar.open failed: $e");
      // If an error occurs (like schema mismatch), Isar might leave a broken instance in memory.
      // We must close it before trying to open again.
      await Isar.getInstance()?.close(deleteFromDisk: true);

      if (!kIsWeb) {
        final dbFile = File('$dirPath/default.isar');
        final lockFile = File('$dirPath/default.isar.lock');
        bool deleted = false;

        if (dbFile.existsSync()) {
          try {
            dbFile.deleteSync();
            deleted = true;
          } catch (err) {
            debugPrint("Failed to delete corrupted Isar db: $err");
          }
        } else {
          deleted = true; // Nothing to delete
        }
        
        if (lockFile.existsSync()) {
          try {
            lockFile.deleteSync();
          } catch (_) {}
        }
        
        String dbName = 'default';
        if (!deleted && dbFile.existsSync()) {
          // Fallback: If we couldn't delete the corrupted file, bypass it entirely
          // by creating a fresh database with a unique name.
          dbName = 'default_${DateTime.now().millisecondsSinceEpoch}';
          debugPrint("Using fallback database name: $dbName");
        }

        _isar = await Isar.open(
          [
            HistoryItemSchema,
            FavoriteItemSchema,
            RecentFileSchema,
            AppSettingsSchema,
            PinnedToolSchema,
            UserProfileModelSchema,
          ],
          directory: dirPath,
          name: dbName,
        );
      } else {
        rethrow;
      }
    }
  }

  // ---- Favorites ----
  @override
  Stream<List<FavoriteItem>> watchFavorites() {
    return _isar.favoriteItems
        .where()
        .sortByAddedDateDesc()
        .watch(fireImmediately: true);
  }

  @override
  Future<void> putFavorite(FavoriteItem item) async {
    await _isar.writeTxn(() async {
      await _isar.favoriteItems.put(item);
    });
  }

  @override
  Future<bool> deleteFavorite(int id) async {
    return await _isar.writeTxn(() => _isar.favoriteItems.delete(id));
  }

  // ---- History ----
  @override
  Stream<List<HistoryItem>> watchHistory() {
    return _isar.historyItems
        .where()
        .sortByTimestampDesc()
        .watch(fireImmediately: true);
  }

  @override
  Stream<List<HistoryItem>> watchSuccessfulHistory() {
    return _isar.historyItems
        .filter()
        .statusEqualTo('success')
        .watch(fireImmediately: true);
  }

  @override
  Future<List<HistoryItem>> findAllHistory({int? limit}) async {
    var query = _isar.historyItems.where().sortByTimestampDesc();
    if (limit != null) return await query.limit(limit).findAll();
    return await query.findAll();
  }

  @override
  Future<void> putHistory(HistoryItem item) async {
    await _isar.writeTxn(() async {
      await _isar.historyItems.put(item);
    });
  }

  @override
  Future<bool> deleteHistory(int id) async {
    return await _isar.writeTxn(() => _isar.historyItems.delete(id));
  }

  @override
  Future<void> clearHistory() async {
    await _isar.writeTxn(() => _isar.historyItems.clear());
  }

  // ---- Recent Files ----
  @override
  Stream<List<RecentFile>> watchRecentFiles({int? limit}) {
    var query = _isar.recentFiles.where().sortByLastOpenedDesc();
    if (limit != null) return query.limit(limit).watch(fireImmediately: true);
    return query.watch(fireImmediately: true);
  }

  @override
  Future<void> putRecentFile(RecentFile item) async {
    await _isar.writeTxn(() async {
      await _isar.recentFiles.put(item);
    });
  }

  @override
  Future<bool> deleteRecentFile(int id) async {
    return await _isar.writeTxn(() => _isar.recentFiles.delete(id));
  }

  // ---- Settings ----
  @override
  Future<AppSettings?> getSettings(int id) async {
    return await _isar.appSettings.get(id);
  }

  @override
  Stream<AppSettings?> watchSettings(int id) {
    return _isar.appSettings.watchObject(id, fireImmediately: true);
  }

  @override
  Future<void> putSettings(AppSettings settings) async {
    await _isar.writeTxn(() async {
      await _isar.appSettings.put(settings);
    });
  }

  // ---- Pinned Tools ----
  @override
  Stream<List<PinnedTool>> watchPinnedTools() {
    return _isar.pinnedTools.where().watch(fireImmediately: true);
  }

  @override
  Future<void> putPinnedTool(PinnedTool item) async {
    await _isar.writeTxn(() async {
      await _isar.pinnedTools.put(item);
    });
  }

  @override
  Future<bool> deletePinnedTool(int id) async {
    return await _isar.writeTxn(() => _isar.pinnedTools.delete(id));
  }

  // ---- User Profile ----
  @override
  Future<UserProfileModel?> getUserProfile(int id) async {
    return await _isar.userProfileModels.get(id);
  }

  @override
  Stream<UserProfileModel?> watchUserProfile(int id) {
    return _isar.userProfileModels.watchObject(id, fireImmediately: true);
  }

  @override
  Future<void> putUserProfile(UserProfileModel profile) async {
    await _isar.writeTxn(() async {
      await _isar.userProfileModels.put(profile);
    });
  }

  // ---- Search ----
  @override
  Future<List<HistoryItem>> searchHistory(String query, {int limit = 10}) async {
    return await _isar.historyItems
        .filter()
        .fileNameContains(query, caseSensitive: false)
        .or()
        .toolTypeContains(query, caseSensitive: false)
        .limit(limit)
        .findAll();
  }

  @override
  Future<List<RecentFile>> searchRecentFiles(String query, {int limit = 10}) async {
    return await _isar.recentFiles
        .filter()
        .fileNameContains(query, caseSensitive: false)
        .limit(limit)
        .findAll();
  }
}

/// Legacy static accessor — keeps backward compat for any code not yet migrated.
class IsarService {
  static late IsarDatabaseService _instance;

  static IsarDatabaseService get instance => _instance;

  /// Legacy accessor
  static Isar get isar => _instance.isar;

  static Future<void> init() async {
    _instance = IsarDatabaseService();
    await _instance.init();
  }
}
