import 'dart:async';
import 'models/favorite_model.dart';
import 'models/history_model.dart';
import 'models/pinned_tool_model.dart';
import 'models/recent_file_model.dart';
import 'models/settings_model.dart';
import 'models/user_profile_model.dart';

/// Platform-agnostic database interface.
/// Isar implements this on Android/iOS/Desktop.
/// WebDatabaseService implements this with in-memory storage for web.
abstract class DatabaseService {
  // --- Initialization ---
  Future<void> init();

  // --- Favorites ---
  Stream<List<FavoriteItem>> watchFavorites();
  Future<void> putFavorite(FavoriteItem item);
  Future<bool> deleteFavorite(int id);

  // --- History ---
  Stream<List<HistoryItem>> watchHistory();
  Stream<List<HistoryItem>> watchSuccessfulHistory();
  Future<List<HistoryItem>> findAllHistory({int? limit});
  Future<void> putHistory(HistoryItem item);
  Future<bool> deleteHistory(int id);
  Future<void> clearHistory();

  // --- Recent Files ---
  Stream<List<RecentFile>> watchRecentFiles({int? limit});
  Future<void> putRecentFile(RecentFile item);
  Future<bool> deleteRecentFile(int id);

  // --- Settings ---
  Future<AppSettings?> getSettings(int id);
  Stream<AppSettings?> watchSettings(int id);
  Future<void> putSettings(AppSettings settings);

  // --- Pinned Tools ---
  Stream<List<PinnedTool>> watchPinnedTools();
  Future<void> putPinnedTool(PinnedTool item);
  Future<bool> deletePinnedTool(int id);

  // --- User Profile ---
  Future<UserProfileModel?> getUserProfile(int id);
  Stream<UserProfileModel?> watchUserProfile(int id);
  Future<void> putUserProfile(UserProfileModel profile);

  // --- Search ---
  Future<List<HistoryItem>> searchHistory(String query, {int limit = 10});
  Future<List<RecentFile>> searchRecentFiles(String query, {int limit = 10});
}
