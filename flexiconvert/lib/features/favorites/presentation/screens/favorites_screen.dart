import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../providers/favorite_tools_provider.dart';
import '../../domain/models/favorite_tool_model.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteTools = ref.watch(favoriteToolsProvider);

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Favorite Tools'),
      body: favoriteTools.isEmpty
          ? EmptyStateWidget(
              title: 'No Favorite Tools Yet',
              subtitle: 'Click the heart icon on any tool card to add it to your favorites!',
              icon: Icons.favorite_border_rounded,
            ).animate().fadeIn().slideY(begin: 0.1, end: 0)
          : ListView.builder(
              padding: EdgeInsets.all(AppSpacing.lg),
              itemCount: favoriteTools.length,
              itemBuilder: (context, index) {
                final tool = favoriteTools[index];
                return _FavoriteToolTile(tool: tool, index: index)
                    .animate()
                    .fadeIn(delay: (50 * index).ms)
                    .slideX(begin: 0.05, end: 0);
              },
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _FavoriteToolTile extends ConsumerWidget {
  final FavoriteToolItem tool;
  final int index;
  
  const _FavoriteToolTile({required this.tool, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(tool.colorValue).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            IconData(tool.iconCodePoint, fontFamily: 'MaterialIcons'),
            color: Color(tool.colorValue),
          ),
        ),
        title: Text(
          tool.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          tool.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.favorite, color: Colors.red),
          tooltip: 'Remove from favorites',
          onPressed: () {
            ref.read(favoriteToolsProvider.notifier).toggleFavorite(tool);
          },
        ),
        onTap: () {
          context.push(tool.route);
        },
      ),
    );
  }
}
