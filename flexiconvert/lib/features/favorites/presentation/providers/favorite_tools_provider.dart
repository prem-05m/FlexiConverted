import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/favorite_tool_model.dart';

class FavoriteToolsNotifier extends StateNotifier<List<FavoriteToolItem>> {
  FavoriteToolsNotifier() : super([]) {
    _loadFavorites();
  }

  static const _key = 'favorite_tools_list';

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStringList = prefs.getStringList(_key) ?? [];
    
    final items = jsonStringList.map((str) {
      try {
        return FavoriteToolItem.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (e) {
        return null;
      }
    }).whereType<FavoriteToolItem>().toList();
    
    state = items;
  }

  Future<void> toggleFavorite(FavoriteToolItem tool) async {
    final prefs = await SharedPreferences.getInstance();
    final current = List<FavoriteToolItem>.from(state);
    
    final index = current.indexWhere((item) => item.toolId == tool.toolId);
    
    if (index >= 0) {
      current.removeAt(index);
    } else {
      current.add(tool);
    }
    
    final jsonStringList = current.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_key, jsonStringList);
    
    state = current;
  }
}

final favoriteToolsProvider = StateNotifierProvider<FavoriteToolsNotifier, List<FavoriteToolItem>>((ref) {
  return FavoriteToolsNotifier();
});
