import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/models/favorite_model.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

final favoritesProvider = StreamProvider<List<FavoriteItem>>((ref) {
  return db.watchFavorites();
});

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: const AnimatedAppBar(title: 'Favorites'),
      body: favAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              title: 'No Favorites Yet',
              subtitle: 'Mark your frequently converted files as favorites to see them here.',
              icon: Icons.favorite_border_rounded,
            ).animate().fadeIn().slideY(begin: 0.1, end: 0);
          }
          return ListView.builder(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _FavoriteTile(item: item, index: index)
                  .animate()
                  .fadeIn(delay: (50 * index).ms)
                  .slideX(begin: 0.05, end: 0);
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final FavoriteItem item;
  final int index;
  const _FavoriteTile({required this.item, required this.index});

  IconData _iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'image': return Icons.image;
      case 'video': return Icons.video_file;
      case 'audio': return Icons.audio_file;
      case 'document': return Icons.description;
      case 'archive': return Icons.folder_zip;
      default: return Icons.insert_drive_file;
    }
  }

  Color _colorForType(String type) {
    switch (type.toLowerCase()) {
      case 'pdf': return Colors.red;
      case 'image': return Colors.green;
      case 'video': return Colors.blue;
      case 'audio': return Colors.orange;
      case 'document': return Colors.indigo;
      case 'archive': return Colors.brown;
      default: return Colors.grey;
    }
  }

  Future<void> _removeFavorite() async {
    await db.deleteFavorite(item.id);
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForType(item.fileType);
    final icon = _iconForType(item.fileType);

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(item.fileType.toUpperCase()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              tooltip: 'Remove from favorites',
              onPressed: _removeFavorite,
            ),
            PopupMenuButton<String>(
              onSelected: (val) async {
                if (val == 'open' && !kIsWeb) await OpenFilex.open(item.filePath);
                if (val == 'share' && !kIsWeb) {
                  await Share.shareXFiles([XFile(item.filePath)]);
                }
                if (val == 'delete') {
                  await db.deleteFavorite(item.id);
                }
              },
              itemBuilder: (_) => [
                if (!kIsWeb) ...[
                  const PopupMenuItem(value: 'open', child: Text('Open')),
                  const PopupMenuItem(value: 'share', child: Text('Share')),
                ],
                const PopupMenuItem(value: 'delete', child: Text('Delete File', style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
        onTap: () async {
          if (!kIsWeb) {
            await OpenFilex.open(item.filePath);
          } else {
            SnackbarService.showError('File operations not supported on web');
          }
        },
      ),
    );
  }
}
