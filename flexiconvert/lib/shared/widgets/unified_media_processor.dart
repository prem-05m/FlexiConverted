import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/services/media_processing_service.dart';
import '../../core/services/download_location_service.dart';
import '../../core/services/history_service.dart';
import 'custom_button.dart';
import '../../features/pdf/presentation/widgets/file_picker_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'animated_app_bar.dart';

class UnifiedMediaProcessor extends ConsumerStatefulWidget {
  final String title;
  final String toolTypeEnumString;
  final MediaType mediaType;
  final List<String> allowedExtensions;
  final List<String> outputFormats;

  const UnifiedMediaProcessor({
    super.key,
    required this.title,
    required this.toolTypeEnumString,
    required this.mediaType,
    required this.allowedExtensions,
    required this.outputFormats,
  });

  @override
  ConsumerState<UnifiedMediaProcessor> createState() => _UnifiedMediaProcessorState();
}

class _UnifiedMediaProcessorState extends ConsumerState<UnifiedMediaProcessor> {
  List<String> _selectedFiles = [];
  String? _selectedOutputFormat;
  bool _isProcessing = false;
  double _progress = 0.0;
  String? _error;
  bool _zipOutput = true;
  bool _isGridView = false;

  final MediaProcessingService _processingService = MediaProcessingService();

  @override
  void initState() {
    super.initState();
    if (widget.outputFormats.isNotEmpty) {
      _selectedOutputFormat = widget.outputFormats.first;
    }
  }

  void _onFilesSelected(List<String> paths) {
    setState(() {
      _selectedFiles = paths;
      _error = null;
    });
  }

  Future<void> _startProcessing() async {
    if (_selectedFiles.isEmpty) return;

    setState(() {
      _isProcessing = true;
      _progress = 0.0;
      _error = null;
    });

    try {
      final inputPath = _selectedFiles.first;
      final fileName = inputPath.split(RegExp(r'[/\\]')).last;
      final baseName = fileName.contains('.') ? fileName.substring(0, fileName.lastIndexOf('.')) : fileName;
      
      String defaultOutName = '${baseName}_processed.${_selectedOutputFormat ?? widget.allowedExtensions.first}';

      if (_selectedFiles.length > 1 && widget.mediaType == MediaType.image) {
        if (_zipOutput) {
          defaultOutName = 'FlexiConverted_Converted_imgs.zip';
        } else {
          defaultOutName = 'FlexiConverted_Converted_imgs'; 
        }
      }

      final outputPath = await DownloadLocationService.getOutputPath(context, ref, defaultOutName);
      if (outputPath == null) {
        setState(() => _isProcessing = false);
        return;
      }

      final startTime = DateTime.now();

      final resultPath = await _processingService.processMedia(
        mediaType: widget.mediaType,
        toolType: widget.toolTypeEnumString,
        inputPaths: _selectedFiles,
        outputPath: outputPath,
        params: {
          if (_selectedOutputFormat != null) 'outputFormat': _selectedOutputFormat,
          if (widget.toolTypeEnumString.toLowerCase().contains('compress')) 'compress': true,
          if (_selectedFiles.length > 1) 'zipOutput': _zipOutput,
        },
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );

      if (resultPath != null) {
        final duration = DateTime.now().difference(startTime).inMilliseconds;
        
        await HistoryService.logConversion(
          fileName: defaultOutName,
          toolType: widget.toolTypeEnumString,
          status: 'success',
          outputPath: resultPath,
          durationMs: duration,
        );

        if (mounted) {
          final category = widget.mediaType == MediaType.image ? RouteConstants.image 
                         : widget.mediaType == MediaType.video ? RouteConstants.video 
                         : RouteConstants.audio;
          final toolPath = '/home/$category/${widget.toolTypeEnumString}';
          context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
        }
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isProcessing = false;
      });
      await HistoryService.logConversion(
        fileName: _selectedFiles.first.split(RegExp(r'[/\\]')).last,
        toolType: widget.toolTypeEnumString,
        status: 'failed',
        outputPath: '',
        durationMs: 0,
      );
    }
  }

  String get _qualityText {
    if (widget.toolTypeEnumString.toLowerCase().contains('compress')) {
      return "Compression enabled";
    }
    if (widget.mediaType == MediaType.video || widget.mediaType == MediaType.audio) {
      if (widget.toolTypeEnumString.contains('convertFormat')) {
        return "Processing: Stream Copy (If compatible) / High Quality Re-encode";
      }
      return "Processing: High Quality Re-encode";
    }
    return "Quality: Original / Preserved";
  }

  void _showFullScreenImage(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              child: Image.file(File(path), fit: BoxFit.contain),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar(
        title: widget.title,
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
              tooltip: 'Toggle View',
            ),
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_to_photos),
              onPressed: () async {
                final result = await FilePicker.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: widget.allowedExtensions,
                  allowMultiple: widget.toolTypeEnumString.toLowerCase().contains('batch') || widget.toolTypeEnumString.toLowerCase().contains('merge'),
                );
                if (result.isNotEmpty) {
                  final validPaths = result.map((e) => e.path).whereType<String>().toList();
                  setState(() {
                    _selectedFiles.addAll(validPaths);
                    _selectedFiles = _selectedFiles.toSet().toList();
                  });
                }
              },
              tooltip: 'Add more files',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
        if (!_isProcessing) ...[
          if (_selectedFiles.isEmpty)
            FilePickerWidget(
              title: 'Upload your file',
              subtitle: 'Drag and drop or browse to choose files',
              icon: widget.mediaType == MediaType.image ? Icons.image
                  : widget.mediaType == MediaType.video ? Icons.video_file
                  : Icons.audio_file,
              allowMultiple: widget.toolTypeEnumString.toLowerCase().contains('batch') || widget.toolTypeEnumString.toLowerCase().contains('merge'),
              allowedExtensions: widget.allowedExtensions,
              onFilesSelected: _onFilesSelected,
            )
          else ...[
            // Image Preview
            if (widget.mediaType == MediaType.image) ...[
              Text('Preview:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: AppSpacing.sm),
              if (_isGridView)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _selectedFiles.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showFullScreenImage(_selectedFiles[index]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(_selectedFiles[index]),
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.grey, child: const Icon(Icons.broken_image)),
                        ),
                      ),
                    );
                  },
                )
              else
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedFiles.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(right: AppSpacing.md),
                        child: GestureDetector(
                          onTap: () => _showFullScreenImage(_selectedFiles[index]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedFiles[index]),
                              height: 120,
                              width: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, s) => Container(height: 120, width: 120, color: Colors.grey, child: const Icon(Icons.broken_image)),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: AppSpacing.lg),
              
              if (_selectedFiles.length > 1) ...[
                Text('Output Mode:', style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('ZIP Archive'),
                        value: true,
                        groupValue: _zipOutput,
                        onChanged: (val) => setState(() => _zipOutput = val!),
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<bool>(
                        title: const Text('Folder Output'),
                        value: false,
                        groupValue: _zipOutput,
                        onChanged: (val) => setState(() => _zipOutput = val!),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.lg),
              ],
            ],

            // Output format selector (if applicable)
            if (widget.outputFormats.isNotEmpty && widget.toolTypeEnumString.contains('convertFormat')) ...[
              Text('Output Format:', style: Theme.of(context).textTheme.titleMedium),
              SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<String>(
                initialValue: _selectedOutputFormat,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                items: widget.outputFormats.map((f) => DropdownMenuItem(value: f, child: Text(f.toUpperCase()))).toList(),
                onChanged: (val) => setState(() => _selectedOutputFormat = val),
              ),
              SizedBox(height: AppSpacing.lg),
            ],

            Container(
              padding: EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(_qualityText, style: TextStyle(color: Theme.of(context).colorScheme.primary))),
                ],
              ),
            ),
            
            SizedBox(height: AppSpacing.xxl),
            if (_error != null) ...[
              Text(_error!, style: const TextStyle(color: Colors.red)),
              SizedBox(height: AppSpacing.md),
            ],
            CustomButton(
              text: 'Process File',
              onPressed: _startProcessing,
            ),
          ]
        ] else ...[
          // Processing UI
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                SizedBox(height: AppSpacing.xl),
                Text(
                  'Processing... ${(_progress * 100).toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: AppSpacing.lg),
                LinearProgressIndicator(value: _progress),
              ],
            ),
          )
          ]
        ],
      ),
    ),
  );
}
}
