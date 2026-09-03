import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/database/models/history_model.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/services/firestore_history_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/bottom_nav_bar.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Provides the active FirestoreHistoryService when user is logged in.
final firestoreHistoryServiceProvider = Provider<FirestoreHistoryService?>((ref) {
  final authState = ref.watch(authStateProvider);
  final uid = authState.value?.uid;
  if (uid == null) return null;
  return FirestoreHistoryService(uid: uid);
});

/// Streams history from Firestore when logged in, local DB otherwise.
final historyProvider = StreamProvider<List<HistoryItem>>((ref) {
  final firestoreService = ref.watch(firestoreHistoryServiceProvider);
  if (firestoreService != null) {
    return firestoreService.watchHistory();
  }
  return db.watchHistory();
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AnimatedAppBar(
        title: 'History',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear all history',
            onPressed: () => _confirmClearAll(context, ref),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (items) {
          if (items.isEmpty) {
            return EmptyStateWidget(
              title: 'No History Yet',
              subtitle: 'Your conversion history will appear here.',
              icon: Icons.history_rounded,
            ).animate().fadeIn().slideY(begin: 0.1, end: 0);
          }
          return ListView.separated(
            padding: EdgeInsets.all(AppSpacing.lg),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = items[index];
              return _HistoryTile(item: item, index: index, ref: ref);
            },
          );
        },
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Remove all conversion history? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final firestoreService = ref.read(firestoreHistoryServiceProvider);
              if (firestoreService != null) {
                await firestoreService.clearHistory();
              } else {
                await db.clearHistory();
              }
            },
            child: const Text('Clear All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final HistoryItem item;
  final int index;
  final WidgetRef ref;
  const _HistoryTile({required this.item, required this.index, required this.ref});

  Color _statusColor(BuildContext context, String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'failed':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'success':
        return Icons.check_circle_outline;
      case 'failed':
        return Icons.error_outline;
      default:
        return Icons.hourglass_bottom;
    }
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _deleteItem() async {
    final firestoreService = ref.read(firestoreHistoryServiceProvider);
    if (firestoreService != null) {
      await firestoreService.deleteHistory(item.id);
    } else {
      await db.deleteHistory(item.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(context, item.status);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: context.colorScheme.primaryContainer,
        child: Icon(Icons.transform, color: context.colorScheme.primary),
      ),
      title: Text(item.fileName, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.toolType, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(
            '${_formatDate(item.timestamp)} • ${_formatSize(item.fileSizeBytes)}',
            style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_statusIcon(item.status), color: statusColor, size: 18),
          PopupMenuButton<String>(
            onSelected: (val) async {
              if (val == 'open' && !kIsWeb) await OpenFilex.open(item.outputPath);
              if (val == 'share' && !kIsWeb) {
                await Share.shareXFiles([XFile(item.outputPath)]);
              }
              if (val == 'rename' && !kIsWeb) {
                _showRenameDialog(context, item);
              }
              if (val == 'delete') {
                await _deleteItem();
              }
            },
            itemBuilder: (_) => [
              if (!kIsWeb) ...[
                const PopupMenuItem(value: 'open', child: Text('Open')),
                const PopupMenuItem(value: 'share', child: Text('Share')),
                const PopupMenuItem(value: 'rename', child: Text('Rename')),
              ],
              const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms).slideX(begin: 0.05, end: 0);
  }

  void _showRenameDialog(BuildContext context, HistoryItem item) {
    if (kIsWeb) return;
    final controller = TextEditingController(text: item.fileName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename File'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'New File Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != item.fileName) {
                try {
                  final extension = item.fileName.contains('.')
                      ? item.fileName.substring(item.fileName.lastIndexOf('.'))
                      : '';
                  final newFileNameWithExt = newName.endsWith(extension) ? newName : '$newName$extension';
                  item.fileName = newFileNameWithExt;
                  await db.putHistory(item);
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    SnackbarService.showSuccess('Renamed successfully');
                  }
                } catch (e) {
                  if (context.mounted) {
                    Navigator.pop(ctx);
                    SnackbarService.showError('Failed to rename: $e');
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
