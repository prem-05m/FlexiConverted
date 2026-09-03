import 'dart:async';
import 'database_service.dart';
import 'models/favorite_model.dart';
import 'models/history_model.dart';
import 'models/pinned_tool_model.dart';
import 'models/recent_file_model.dart';
import 'models/settings_model.dart';
import 'models/user_profile_model.dart';

/// In-memory database implementation for web.
/// Data persists during the browser session but resets on page reload.
class WebDatabaseService implements DatabaseService {
  // In-memory stores
  final List<FavoriteItem> _favorites = [];
  final List<HistoryItem> _history = [];
  final List<RecentFile> _recentFiles = [];
  final List<PinnedTool> _pinnedTools = [];
  final Map<int, AppSettings> _settings = {};
  final Map<int, UserProfileModel> _profiles = {};

  // Auto-increment counters
  int _favId = 1;
  int _histId = 1;
  int _recentId = 1;
  int _pinnedId = 1;

  // Stream controllers for reactive updates
  final _favoritesController = StreamController<List<FavoriteItem>>.broadcast();
  final _historyController = StreamController<List<HistoryItem>>.broadcast();
  final _successHistoryController = StreamController<List<HistoryItem>>.broadcast();
  final _recentFilesController = StreamController<List<RecentFile>>.broadcast();
  final _pinnedToolsController = StreamController<List<PinnedTool>>.broadcast();
  final Map<int, StreamController<AppSettings?>> _settingsControllers = {};
  final Map<int, StreamController<UserProfileModel?>> _profileControllers = {};

  @override
  Future<void> init() async {
    // Nothing to initialize for in-memory storage
  }

  // ---- Notify helpers ----
  void _notifyFavorites() {
    _favoritesController.add(List.unmodifiable(
      _favorites..sort((a, b) => b.addedDate.compareTo(a.addedDate)),
    ));
  }

  void _notifyHistory() {
    _historyController.add(List.unmodifiable(
      _history..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    ));
    _notifySuccessHistory();
  }

  void _notifySuccessHistory() {
    _successHistoryController.add(List.unmodifiable(
      _history.where((h) => h.status == 'success').toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    ));
  }

  void _notifyRecentFiles() {
    _recentFilesController.add(List.unmodifiable(
      _recentFiles..sort((a, b) => b.lastOpened.compareTo(a.lastOpened)),
    ));
  }

  void _notifyPinnedTools() {
    _pinnedToolsController.add(List.unmodifiable(List.from(_pinnedTools)));
  }

  void _notifySettings(int id) {
    _settingsControllers[id]?.add(_settings[id]);
  }

  void _notifyProfile(int id) {
    _profileControllers[id]?.add(_profiles[id]);
  }

  // ---- Favorites ----
  @override
  Stream<List<FavoriteItem>> watchFavorites() async* {
    yield List.unmodifiable(
      List<FavoriteItem>.from(_favorites)..sort((a, b) => b.addedDate.compareTo(a.addedDate)),
    );
    yield* _favoritesController.stream;
  }

  @override
  Future<void> putFavorite(FavoriteItem item) async {
    // Check for unique filePath (replace if exists)
    _favorites.removeWhere((f) => f.filePath == item.filePath);
    if (item.id == 0) item.id = _favId++;
    _favorites.add(item);
    _notifyFavorites();
  }

  @override
  Future<bool> deleteFavorite(int id) async {
    final len = _favorites.length;
    _favorites.removeWhere((f) => f.id == id);
    _notifyFavorites();
    return _favorites.length < len;
  }

  // ---- History ----
  @override
  Future<void> putHistory(HistoryItem item) async {
    final idx = _history.indexWhere((h) => h.id == item.id && item.id != 0);
    if (idx >= 0) {
      _history[idx] = item;
    } else {
      if (item.id == 0) item.id = _histId++;
      _history.add(item);
    }
    _notifyHistory();
  }

  @override
  Future<bool> deleteHistory(int id) async {
    final len = _history.length;
    _history.removeWhere((h) => h.id == id);
    _notifyHistory();
    return _history.length < len;
  }

  @override
  Future<void> clearHistory() async {
    _history.clear();
    _notifyHistory();
  }

  @override
  Future<List<HistoryItem>> findAllHistory({int? limit}) async {
    final sorted = List<HistoryItem>.from(_history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    if (limit != null) return sorted.take(limit).toList();
    return sorted;
  }

  // ---- Recent Files ----
  @override
  Future<void> putRecentFile(RecentFile item) async {
    _recentFiles.removeWhere((f) => f.filePath == item.filePath);
    if (item.id == 0) item.id = _recentId++;
    _recentFiles.add(item);
    _notifyRecentFiles();
  }

  @override
  Future<bool> deleteRecentFile(int id) async {
    final len = _recentFiles.length;
    _recentFiles.removeWhere((f) => f.id == id);
    _notifyRecentFiles();
    return _recentFiles.length < len;
  }

  // ---- Settings ----
  @override
  Future<AppSettings?> getSettings(int id) async => _settings[id];

  @override
  Future<void> putSettings(AppSettings settings) async {
    _settings[settings.id] = settings;
    _notifySettings(settings.id);
  }

  // ---- Pinned Tools ----
  @override
  Future<void> putPinnedTool(PinnedTool item) async {
    _pinnedTools.removeWhere((p) => p.toolId == item.toolId);
    if (item.id == 0) item.id = _pinnedId++;
    _pinnedTools.add(item);
    _notifyPinnedTools();
  }

  @override
  Future<bool> deletePinnedTool(int id) async {
    final len = _pinnedTools.length;
    _pinnedTools.removeWhere((p) => p.id == id);
    _notifyPinnedTools();
    return _pinnedTools.length < len;
  }

  // ---- User Profile ----
  @override
  Future<UserProfileModel?> getUserProfile(int id) async => _profiles[id];

  @override
  Future<void> putUserProfile(UserProfileModel profile) async {
    _profiles[profile.id] = profile;
    _notifyProfile(profile.id);
  }

  // ---- Search ----
  @override
  Future<List<HistoryItem>> searchHistory(String query, {int limit = 10}) async {
    final q = query.toLowerCase();
    return _history
        .where((h) =>
            h.fileName.toLowerCase().contains(q) ||
            h.toolType.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  @override
  Future<List<RecentFile>> searchRecentFiles(String query, {int limit = 10}) async {
    final q = query.toLowerCase();
    return _recentFiles
        .where((r) => r.fileName.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  // ---- Stream implementations with immediate emission ----
  @override
  Stream<List<HistoryItem>> watchHistory() async* {
    yield List.unmodifiable(
      List<HistoryItem>.from(_history)..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
    yield* _historyController.stream;
  }

  @override
  Stream<List<HistoryItem>> watchSuccessfulHistory() async* {
    yield List.unmodifiable(
      _history.where((h) => h.status == 'success').toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)),
    );
    yield* _successHistoryController.stream;
  }

  @override
  Stream<List<RecentFile>> watchRecentFiles({int? limit}) async* {
    var sorted = List<RecentFile>.from(_recentFiles)
      ..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
    if (limit != null) sorted = sorted.take(limit).toList();
    yield List.unmodifiable(sorted);
    yield* _recentFilesController.stream.map((list) {
      if (limit != null) return list.take(limit).toList();
      return list;
    });
  }

  @override
  Stream<AppSettings?> watchSettings(int id) async* {
    _settingsControllers[id] ??= StreamController<AppSettings?>.broadcast();
    yield _settings[id];
    yield* _settingsControllers[id]!.stream;
  }

  @override
  Stream<List<PinnedTool>> watchPinnedTools() async* {
    yield List.unmodifiable(List.from(_pinnedTools));
    yield* _pinnedToolsController.stream;
  }

  @override
  Stream<UserProfileModel?> watchUserProfile(int id) async* {
    _profileControllers[id] ??= StreamController<UserProfileModel?>.broadcast();
    yield _profiles[id];
    yield* _profileControllers[id]!.stream;
  }
}
