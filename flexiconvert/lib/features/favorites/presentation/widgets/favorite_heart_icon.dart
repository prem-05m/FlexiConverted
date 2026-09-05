import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favorite_tools_provider.dart';
import '../../domain/models/favorite_tool_model.dart';

class FavoriteHeartIcon extends ConsumerWidget {
  final FavoriteToolItem tool;
  
  const FavoriteHeartIcon({super.key, required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoriteToolsProvider);
    final isFavorite = favorites.any((item) => item.toolId == tool.toolId);

    return Material(
      color: Colors.transparent,
      child: IconButton(
        icon: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.red : Colors.grey.shade400,
        ),
        onPressed: () {
          ref.read(favoriteToolsProvider.notifier).toggleFavorite(tool);
        },
      ),
    );
  }
}
