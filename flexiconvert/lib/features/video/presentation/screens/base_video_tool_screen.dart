import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/models/video_task_model.dart';
import '../providers/video_task_provider.dart';
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';

class BaseVideoToolScreen extends ConsumerStatefulWidget {
  final VideoToolType toolType;

  const BaseVideoToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseVideoToolScreen> createState() => _BaseVideoToolScreenState();
}

class _BaseVideoToolScreenState extends ConsumerState<BaseVideoToolScreen> {
  List<String> selectedFiles = [];
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  Map<String, dynamic>? _metadata;
  final TextEditingController _fileNameCtrl = TextEditingController();

  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _fileNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFilesSelected(List<String> paths) async {
    setState(() {
      selectedFiles = paths;
      _metadata = null;
    });
    if (paths.isNotEmpty) {
      _fileNameCtrl.text = 'FlexiConvert_Video.mp4';
      await _initializePlayer(paths.first);
    }
  }

  Future<void> _initializePlayer(String path) async {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();

    _videoPlayerController = VideoPlayerController.file(File(path));
    await _videoPlayerController!.initialize();

    final size = await File(path).length();

    setState(() {
      _metadata = {
        'Duration': _videoPlayerController!.value.duration.toString().split('.').first,
        'Resolution': '${_videoPlayerController!.value.size.width.toInt()}x${_videoPlayerController!.value.size.height.toInt()}',
        'File Size': '${(size / (1024 * 1024)).toStringAsFixed(2)} MB',
      };

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
      );
    });
  }

  Future<void> _processFiles() async {
    if (selectedFiles.isEmpty) return;

    String rawName = _fileNameCtrl.text.trim();
    if (rawName.isEmpty) rawName = 'FlexiConvert_Video.mp4';
    final fileName = rawName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    ref.read(videoTaskProvider.notifier).initializeTask(widget.toolType, selectedFiles);
    
    if (mounted) ProgressDialog.show(context, message: 'Processing video...');

    final startTime = DateTime.now();

    await ref.read(videoTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {}
    );

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      ProgressDialog.hide(context);
      
      final state = ref.read(videoTaskProvider);

      await HistoryService.logConversion(
        fileName: fileName,
        toolType: widget.toolType.name,
        status: state.status == TaskStatus.success ? 'success' : 'failed',
        outputPath: outputPath,
        durationMs: duration,
      );

      if (state.status == TaskStatus.failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage ?? 'An error occurred'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      } else if (state.status == TaskStatus.success) {
        final toolPath = '/home/video/${widget.toolType.name}';
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar(title: _title),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilePickerWidget(
              title: 'Upload your video',
              subtitle: 'Select video files to process',
              icon: Icons.video_file,
              allowMultiple: false, // For simplicity in preview
              allowedExtensions: const ['mp4', 'mkv', 'avi', 'mov', 'flv'],
              onFilesSelected: _onFilesSelected,
            ),
            if (selectedFiles.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),
              
              if (_chewieController != null) ...[
                AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: Chewie(controller: _chewieController!),
                ),
                SizedBox(height: AppSpacing.lg),
              ],

              if (_metadata != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _metadata!.entries.map((e) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(e.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(e.value.toString()),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                SizedBox(height: AppSpacing.xl),
              ],

              CustomButton(
                text: 'Process Video',
                onPressed: _processFiles,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
