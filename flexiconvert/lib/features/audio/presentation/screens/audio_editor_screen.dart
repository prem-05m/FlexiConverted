import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:just_audio/just_audio.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../features/pdf/presentation/widgets/file_picker_widget.dart';
import '../../../../core/services/media_processing_service.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/constants/route_constants.dart';
import '../../domain/models/audio_task_model.dart';

class AudioEditorScreen extends ConsumerStatefulWidget {
  final AudioToolType toolType;

  const AudioEditorScreen({super.key, required this.toolType});

  @override
  ConsumerState<AudioEditorScreen> createState() => _AudioEditorScreenState();
}

class _AudioEditorScreenState extends ConsumerState<AudioEditorScreen> {
  String? _selectedFilePath;
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  // Editor states
  double _startValue = 0.0;
  double _endValue = 1.0;
  double _splitValue1 = 0.5;
  double _splitValue2 = 0.75;
  
  bool _isProcessing = false;
  double _progress = 0.0;

  final MediaProcessingService _processingService = MediaProcessingService();

  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
  }

  @override
  void initState() {
    super.initState();
    _player.positionStream.listen((p) => setState(() => _position = p));
    _player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });
    _player.playerStateStream.listen((state) {
      setState(() => _isPlaying = state.playing);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'wav', 'aac', 'm4a', 'flac'],
    );
    if (result.isNotEmpty && result.single.path != null) {
      setState(() {
        _selectedFilePath = result.single.path;
        _startValue = 0.0;
        _endValue = 1.0;
      });
      await _player.setFilePath(_selectedFilePath!);
    }
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<void> _processAudio() async {
    if (_selectedFilePath == null) return;
    
    setState(() {
      _isProcessing = true;
      _progress = 0.0;
    });

    try {
      final fileName = _selectedFilePath!.split(RegExp(r'[/\\]')).last;
      final baseName = fileName.substring(0, fileName.lastIndexOf('.'));
      final ext = fileName.substring(fileName.lastIndexOf('.'));
      
      String defaultOutName = '${baseName}_edited$ext';
      if (widget.toolType == AudioToolType.split || widget.toolType == AudioToolType.cut) {
        defaultOutName = 'Audio Converted.zip';
      }

      final outputPath = await DownloadLocationService.getOutputPath(context, ref, defaultOutName);
      if (outputPath == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final Map<String, dynamic> params = {};
      
      // Calculate times
      final totalSeconds = _duration.inMilliseconds / 1000.0;
      
      if (widget.toolType == AudioToolType.trim) {
        final startTime = _startValue * totalSeconds;
        final duration = (_endValue - _startValue) * totalSeconds;
        // Format to HH:MM:SS
        params['startTime'] = _formatDurationForFfmpeg(startTime);
        params['duration'] = _formatDurationForFfmpeg(duration);
      } else if (widget.toolType == AudioToolType.split) {
        params['splitTime'] = _formatDurationForFfmpeg(_splitValue1 * totalSeconds);
        params['zipOutput'] = true;
      } else if (widget.toolType == AudioToolType.cut) {
        params['cutStart'] = _formatDurationForFfmpeg(_splitValue1 * totalSeconds);
        params['cutEnd'] = _formatDurationForFfmpeg(_splitValue2 * totalSeconds);
        params['zipOutput'] = true;
      }

      final resultPath = await _processingService.processMedia(
        mediaType: MediaType.audio,
        toolType: widget.toolType == AudioToolType.trim ? 'trim' : 
                  widget.toolType == AudioToolType.split ? 'split' : 'cut',
        inputPaths: [_selectedFilePath!],
        outputPath: outputPath,
        params: params,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );

      if (resultPath != null && mounted) {
        context.go('${RouteConstants.completed}?from=/home/${RouteConstants.audio}/${widget.toolType.name}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  String _formatDurationForFfmpeg(double seconds) {
    final duration = Duration(milliseconds: (seconds * 1000).toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hrs = twoDigits(duration.inHours);
    final mins = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$hrs:$mins:$secs';
  }

  Widget _buildEditorControls() {
    if (widget.toolType == AudioToolType.trim) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trim Range:', style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values: RangeValues(_startValue, _endValue),
            onChanged: (v) => setState(() {
              _startValue = v.start;
              _endValue = v.end;
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(Duration(milliseconds: (_startValue * _duration.inMilliseconds).toInt()))),
              Text(_formatDuration(Duration(milliseconds: (_endValue * _duration.inMilliseconds).toInt()))),
            ],
          )
        ],
      );
    } else if (widget.toolType == AudioToolType.split) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Split Point:', style: Theme.of(context).textTheme.titleMedium),
          Slider(
            value: _splitValue1,
            onChanged: (v) => setState(() => _splitValue1 = v),
          ),
          Center(
            child: Text('Split at: ${_formatDuration(Duration(milliseconds: (_splitValue1 * _duration.inMilliseconds).toInt()))}'),
          )
        ],
      );
    } else {
      // Cut
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cut Points (3 parts):', style: Theme.of(context).textTheme.titleMedium),
          RangeSlider(
            values: RangeValues(_splitValue1, _splitValue2),
            onChanged: (v) => setState(() {
              _splitValue1 = v.start;
              _splitValue2 = v.end;
            }),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(Duration(milliseconds: (_splitValue1 * _duration.inMilliseconds).toInt()))),
              Text(_formatDuration(Duration(milliseconds: (_splitValue2 * _duration.inMilliseconds).toInt()))),
            ],
          )
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar(
        title: _title,
        actions: [
          if (_selectedFilePath != null)
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: 'Download Processed Audio',
              onPressed: _isProcessing ? null : _processAudio,
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: _selectedFilePath == null
            ? FilePickerWidget(
                title: 'Upload Audio',
                subtitle: 'Choose a file to ${_title.toLowerCase()}',
                icon: Icons.audio_file,
                allowedExtensions: const ['mp3', 'wav', 'aac', 'm4a', 'flac'],
                onFilesSelected: (paths) {
                  if (paths.isNotEmpty) {
                    setState(() {
                      _selectedFilePath = paths.first;
                    });
                    _player.setFilePath(_selectedFilePath!);
                  }
                },
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Icon(Icons.audiotrack, size: 64, color: Theme.of(context).colorScheme.primary),
                          SizedBox(height: AppSpacing.md),
                          Text(_selectedFilePath!.split(RegExp(r'[/\\]')).last, style: Theme.of(context).textTheme.titleMedium),
                          
                          SizedBox(height: AppSpacing.xl),
                          
                          // Player controls
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                iconSize: 48,
                                icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                                color: Theme.of(context).colorScheme.primary,
                                onPressed: () {
                                  _isPlaying ? _player.pause() : _player.play();
                                },
                              ),
                            ],
                          ),
                          Slider(
                            value: _position.inMilliseconds.toDouble(),
                            max: _duration.inMilliseconds.toDouble() > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                            onChanged: (v) {
                              _player.seek(Duration(milliseconds: v.toInt()));
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(_position)),
                              Text(_formatDuration(_duration)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.xl),
                  
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: _buildEditorControls(),
                    ),
                  ),

                  SizedBox(height: AppSpacing.xl),

                  if (_isProcessing) ...[
                    const Center(child: CircularProgressIndicator()),
                    SizedBox(height: AppSpacing.md),
                    Center(child: Text('Processing... ${(_progress * 100).toStringAsFixed(1)}%')),
                  ] else
                    CustomButton(
                      text: 'Process & Download',
                      onPressed: _processAudio,
                      icon: Icons.download,
                    ),
                ],
              ),
      ),
    );
  }
}
