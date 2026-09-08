import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/models/history_model.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../core/services/snackbar_service.dart';

import 'package:dio/dio.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/database/database_provider.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  final HistoryItem item;

  const HistoryDetailScreen({super.key, required this.item});

  @override
  ConsumerState<HistoryDetailScreen> createState() => _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  bool _isDownloading = false;

  Future<void> _downloadCloudFile(BuildContext context) async {
    final item = widget.item;
    if (item.cloudUrl == null) return;
    try {
      setState(() => _isDownloading = true);
      SnackbarService.showInfo('Starting download...');
      
      final dio = Dio();
      final savePath = await DownloadLocationService.getOutputPath(context, ref, item.fileName);
      
      if (savePath == null) {
        setState(() => _isDownloading = false);
        SnackbarService.showInfo('Download cancelled');
        return;
      }
      
      await dio.download(item.cloudUrl!, savePath);
      
      item.outputPath = savePath;
      await db.putHistory(item);
      
      if (mounted) {
        setState(() => _isDownloading = false);
      }
      SnackbarService.showSuccess('Downloaded to FlexiConverted folder');
    } catch (e) {
      if (mounted) {
        setState(() => _isDownloading = false);
      }
      SnackbarService.showError('Download failed: $e');
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
  
  IconData _getFileIcon(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': case 'docx': return Icons.description;
      case 'xls': case 'xlsx': return Icons.table_chart;
      case 'ppt': case 'pptx': return Icons.slideshow;
      case 'jpg': case 'jpeg': case 'png': case 'gif': return Icons.image;
      case 'mp4': case 'avi': case 'mov': return Icons.video_file;
      case 'mp3': case 'wav': case 'aac': return Icons.audio_file;
      case 'zip': case 'rar': return Icons.folder_zip;
      default: return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasCloud = item.cloudUrl != null && item.cloudUrl!.isNotEmpty;
    final isLocal = item.outputPath.isNotEmpty && File(item.outputPath).existsSync();

    return Scaffold(
      appBar: AnimatedAppBar(title: 'Conversion Details'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(context, isLocal, hasCloud),
            SizedBox(height: AppSpacing.lg),
            _buildDetailsCard(context, hasCloud),
            SizedBox(height: AppSpacing.xl),
            if (!kIsWeb) _buildActionButtons(context, isLocal, hasCloud),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context, bool isLocal, bool hasCloud) {
    final item = widget.item;
    return Card(
      elevation: 0,
      color: context.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: context.colorScheme.primaryContainer,
              child: Icon(
                _getFileIcon(item.fileName),
                size: 40,
                color: context.colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            Text(
              item.fileName,
              style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            if (item.deviceName != null && item.deviceName!.isNotEmpty) ...[
              SizedBox(height: AppSpacing.sm),
              Text(
                'Converted on: ${item.deviceName}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            SizedBox(height: AppSpacing.md),
            Chip(
              label: Text(
                isLocal ? 'Available Locally' : (hasCloud ? 'Available in Cloud' : 'Not on this device'),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              backgroundColor: isLocal 
                ? Colors.green.withValues(alpha: 0.1) 
                : Colors.orange.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                color: isLocal ? Colors.green[700] : Colors.orange[800],
              ),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, bool hasCloud) {
    final item = widget.item;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: context.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(context, Icons.calendar_today, 'Date & Time', _formatDate(item.timestamp)),
            const Divider(),
            _buildDetailRow(context, Icons.build_circle_outlined, 'Conversion Type', item.toolType),
            const Divider(),
            _buildDetailRow(context, Icons.save_outlined, 'File Size', _formatSize(item.fileSizeBytes)),
            const Divider(),
            _buildDetailRow(
              context, 
              Icons.cloud_done_outlined, 
              'Cloud Backup', 
              hasCloud ? 'Uploaded' : 'Not Uploaded',
              valueColor: hasCloud ? Colors.green : Colors.grey,
            ),
            if (item.status == 'failed') ...[
              const Divider(),
              _buildDetailRow(
                context, 
                Icons.error_outline, 
                'Status', 
                'Failed',
                valueColor: Colors.red,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.colorScheme.onSurfaceVariant),
          SizedBox(width: AppSpacing.md),
          Text(
            title,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLocal, bool hasCloud) {
    if (_isDownloading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!isLocal && hasCloud) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => _downloadCloudFile(context),
          icon: const Icon(Icons.cloud_download),
          label: const Text('Download from Cloud'),
          style: FilledButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      );
    } else if (!isLocal) {
      return const SizedBox.shrink(); // Cannot open, share, or download
    }

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () async {
              try {
                await OpenFilex.open(widget.item.outputPath);
              } catch (e) {
                SnackbarService.showError('Could not open file');
              }
            },
            icon: const Icon(Icons.open_in_new),
            label: const Text('Open File'),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () async {
              try {
                await Share.shareXFiles([XFile(widget.item.outputPath)]);
              } catch (e) {
                SnackbarService.showError('Could not share file');
              }
            },
            icon: const Icon(Icons.share),
            label: const Text('Share File'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }
}
