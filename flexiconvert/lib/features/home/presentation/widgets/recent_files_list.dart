import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/models/recent_file_model.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

import 'dart:io';
import 'package:mime/mime.dart';

import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../../core/utils/permission_utils.dart';
import '../../../history/presentation/screens/history_screen.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/database/models/history_model.dart';
import '../../../../core/database/database_provider.dart';

final recentFilesProvider = StreamProvider<List<RecentFile>>((ref) async* {
  await PermissionUtils.requestStoragePermission();
  
  // Watch local Isar DB history (this gets wiped on uninstall, so it only has post-install conversions)
  final localHistoryStream = db.watchHistory();
  
  await for (final historyItems in localHistoryStream) {
    final settings = await ref.read(settingsProvider.future);
    final customPref = settings.defaultSaveDirectory;
    
    final List<Directory> dirsToCheck = [];
    
    if (customPref != 'Ask Every Time' && customPref != 'Default Downloads') {
      dirsToCheck.add(Directory(customPref));
    }
    
    if (Platform.isAndroid) {
      dirsToCheck.add(Directory('/storage/emulated/0/FlexiConverted'));
      dirsToCheck.add(Directory('/storage/emulated/0/Download/FlexiConverted'));
    }
    
    final List<File> allFiles = [];
    
    // 1. Scan default/custom directories
    for (final dir in dirsToCheck) {
      if (dir.existsSync()) {
        allFiles.addAll(dir.listSync().whereType<File>());
      }
    }
    
    // 2. Add files from local history (conversions saved in other locations)
    for (final item in historyItems) {
      if (item.status == 'success' && item.outputPath != null) {
        final file = File(item.outputPath!);
        if (file.existsSync()) {
          allFiles.add(file);
        }
      }
    }
    
    // 3. Remove duplicates
    final uniqueFilesMap = <String, File>{};
    for (final file in allFiles) {
      uniqueFilesMap[file.path] = file;
    }
    final uniqueFiles = uniqueFilesMap.values.toList();
    
    // 4. Sort by modified date descending
    uniqueFiles.sort((a, b) {
      try {
        return b.statSync().modified.compareTo(a.statSync().modified);
      } catch (_) {
        return 0;
      }
    });
    
    // 5. Convert to RecentFile and limit to 15
    final recentFiles = <RecentFile>[];
    for (final file in uniqueFiles) {
      try {
        final stat = file.statSync();
        final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
        recentFiles.add(
          RecentFile()
            ..filePath = file.path
            ..fileName = file.uri.pathSegments.last
            ..mimeType = mime
            ..lastOpened = stat.modified,
        );
      } catch (_) {}
      
      if (recentFiles.length >= 15) break;
    }
    
    yield recentFiles;
  }
});

class RecentFilesList extends ConsumerWidget {
  const RecentFilesList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentFilesProvider);

    return recentAsync.when(
      loading: () =>
          const Center(heightFactor: 2, child: CircularProgressIndicator()),
      error: (e, _) => Text('Error loading files: $e'),
      data: (files) {
        if (files.isEmpty) {
          return const EmptyStateWidget(
            title: 'No Recent Files',
            subtitle: 'Convert a file to see it here.',
            icon: Icons.history_rounded,
          );
        }
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: files.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final file = files[index];
            return _RecentFileTile(file: file, ref: ref);
          },
        );
      },
    );
  }
}

class _RecentFileTile extends StatelessWidget {
  final RecentFile file;
  final WidgetRef ref;
  const _RecentFileTile({required this.file, required this.ref});

  IconData _iconForMime(String mime) {
    if (mime.startsWith('image/')) return Icons.image;
    if (mime.startsWith('video/')) return Icons.video_file;
    if (mime.startsWith('audio/')) return Icons.audio_file;
    if (mime == 'application/pdf') return Icons.picture_as_pdf;
    if (mime.contains('word') || mime.contains('document')) {
      return Icons.description;
    }
    if (mime.contains('zip') || mime.contains('archive')) {
      return Icons.folder_zip;
    }
    return Icons.insert_drive_file;
  }

  Color _colorForMime(String mime) {
    if (mime.startsWith('image/')) return Colors.green;
    if (mime.startsWith('video/')) return Colors.blue;
    if (mime.startsWith('audio/')) return Colors.orange;
    if (mime == 'application/pdf') return Colors.red;
    if (mime.contains('word') || mime.contains('document')) {
      return Colors.indigo;
    }
    if (mime.contains('zip')) return Colors.brown;
    return Colors.grey;
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return 'Today, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  Future<void> _deleteFile(BuildContext context, WidgetRef ref) async {
    try {
      final physicalFile = File(file.filePath);
      if (physicalFile.existsSync()) {
        physicalFile.deleteSync();
      }
      ref.invalidate(recentFilesProvider);
      SnackbarService.showSuccess('File deleted');
    } catch (e) {
      SnackbarService.showError('Failed to delete file: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorForMime(file.mimeType);
    final icon = _iconForMime(file.mimeType);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        file.fileName,
        style: const TextStyle(fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _formatDate(file.lastOpened),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) async {
          switch (value) {
            case 'open':
              if (!kIsWeb) {
                await OpenFilex.open(file.filePath);
              } else {
                SnackbarService.showError(
                    'File operations not supported on web');
              }
              break;
            case 'share':
              if (!kIsWeb) {
                await Share.shareXFiles([XFile(file.filePath)]);
              } else {
                SnackbarService.showError('File sharing not supported on web');
              }
              break;
            case 'delete':
              await _deleteFile(context, ref);
              break;
          }
        },
        itemBuilder: (_) => [
          if (!kIsWeb) ...[
            const PopupMenuItem(value: 'open', child: Text('Open')),
            const PopupMenuItem(value: 'share', child: Text('Share')),
          ],
          const PopupMenuItem(
              value: 'delete',
              child: Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
      onTap: () async {
        if (!kIsWeb) {
          await OpenFilex.open(file.filePath);
        } else {
          SnackbarService.showError('File operations not supported on web');
        }
      },
    );
  }
}
