import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/models/audio_task_model.dart';
import '../providers/audio_task_provider.dart';
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';

class BaseAudioToolScreen extends ConsumerStatefulWidget {
  final AudioToolType toolType;

  const BaseAudioToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseAudioToolScreen> createState() => _BaseAudioToolScreenState();
}

class _BaseAudioToolScreenState extends ConsumerState<BaseAudioToolScreen> {
  List<String> selectedFiles = [];
  AudioPlayer? _audioPlayer;
  Map<String, dynamic>? _metadata;
  final TextEditingController _fileNameCtrl = TextEditingController();

  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
  }

  @override
  void dispose() {
    _audioPlayer?.dispose();
    _fileNameCtrl.dispose();
    super.dispose();
  }

  Future<void> _onFilesSelected(List<String> paths) async {
    setState(() {
      selectedFiles = paths;
      _metadata = null;
    });
    if (paths.isNotEmpty) {
      _fileNameCtrl.text = 'FlexiConvert_Audio.mp3';
      await _initializePlayer(paths.first);
    }
  }

  Future<void> _initializePlayer(String path) async {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();
    
    final duration = await _audioPlayer!.setFilePath(path);
    
    setState(() {
      if (duration != null) {
        _metadata = {
          'Duration': duration.toString().split('.').first,
        };
      }
    });
  }

  Future<void> _processFiles() async {
    if (selectedFiles.isEmpty) return;

    String rawName = _fileNameCtrl.text.trim();
    if (rawName.isEmpty) rawName = 'FlexiConvert_Audio.mp3';
    final fileName = rawName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    ref.read(audioTaskProvider.notifier).initializeTask(widget.toolType, selectedFiles);
    
    if (mounted) ProgressDialog.show(context, message: 'Processing audio...');

    final startTime = DateTime.now();

    await ref.read(audioTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {}
    );

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      ProgressDialog.hide(context);
      
      final state = ref.read(audioTaskProvider);

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
        final toolPath = '/home/audio/${widget.toolType.name}';
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
              title: 'Upload your audio',
              subtitle: 'Select audio files to process',
              icon: Icons.audio_file,
              allowMultiple: false,
              onFilesSelected: _onFilesSelected,
            ),
            if (selectedFiles.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),
              
              if (_audioPlayer != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            StreamBuilder<PlayerState>(
                              stream: _audioPlayer!.playerStateStream,
                              builder: (context, snapshot) {
                                final playerState = snapshot.data;
                                final processingState = playerState?.processingState;
                                final playing = playerState?.playing;
                                if (processingState == ProcessingState.loading ||
                                    processingState == ProcessingState.buffering) {
                                  return Container(
                                    margin: const EdgeInsets.all(8.0),
                                    width: 32.0,
                                    height: 32.0,
                                    child: const CircularProgressIndicator(),
                                  );
                                } else if (playing != true) {
                                  return IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    iconSize: 48.0,
                                    onPressed: _audioPlayer!.play,
                                  );
                                } else if (processingState != ProcessingState.completed) {
                                  return IconButton(
                                    icon: const Icon(Icons.pause),
                                    iconSize: 48.0,
                                    onPressed: _audioPlayer!.pause,
                                  );
                                } else {
                                  return IconButton(
                                    icon: const Icon(Icons.replay),
                                    iconSize: 48.0,
                                    onPressed: () => _audioPlayer!.seek(Duration.zero),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        StreamBuilder<Duration>(
                          stream: _audioPlayer!.positionStream,
                          builder: (context, snapshot) {
                            final position = snapshot.data ?? Duration.zero;
                            final duration = _audioPlayer!.duration ?? Duration.zero;
                            return ProgressBar(
                              progress: position,
                              total: duration,
                              onSeek: (duration) {
                                _audioPlayer!.seek(duration);
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
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
                text: 'Process Audio',
                onPressed: _processFiles,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
