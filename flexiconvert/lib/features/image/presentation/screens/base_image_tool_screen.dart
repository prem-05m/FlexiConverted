import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/models/image_task_model.dart';
import '../providers/image_task_provider.dart';
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';

class BaseImageToolScreen extends ConsumerStatefulWidget {
  final ImageToolType toolType;

  const BaseImageToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseImageToolScreen> createState() => _BaseImageToolScreenState();
}

class _BaseImageToolScreenState extends ConsumerState<BaseImageToolScreen> {
  List<String> selectedFiles = [];
  final TextEditingController _fileNameCtrl = TextEditingController();

  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
  }

  String get _defaultFileName {
    final ext = widget.toolType.name.contains('jpg') || widget.toolType.name.contains('Jpg') ? 'jpg'
        : widget.toolType.name.contains('png') || widget.toolType.name.contains('Png') ? 'png'
        : widget.toolType.name.contains('webp') || widget.toolType.name.contains('Webp') ? 'webp'
        : 'jpg';
    return 'FlexiConvert_Image.$ext';
  }

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    super.dispose();
  }

  void _onFilesSelected(List<String> paths) {
    setState(() {
      selectedFiles = paths;
    });
    if (paths.isNotEmpty) {
      _fileNameCtrl.text = _defaultFileName;
    }
  }

  Future<void> _processFiles() async {
    if (selectedFiles.isEmpty) return;

    String rawName = _fileNameCtrl.text.trim();
    if (rawName.isEmpty) rawName = _defaultFileName;
    final fileName = rawName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    ref.read(imageTaskProvider.notifier).initializeTask(widget.toolType, selectedFiles);
    
    if (mounted) ProgressDialog.show(context, message: 'Processing image...');

    final startTime = DateTime.now();

    await ref.read(imageTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {
        'targetFormat': ImageFormat.jpg,
        'quality': 80,
      }
    );

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      ProgressDialog.hide(context);
      
      final state = ref.read(imageTaskProvider);

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
        final toolPath = '/home/image/${widget.toolType.name}';
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
          children: [
            FilePickerWidget(
              title: 'Upload your image',
              subtitle: 'Drag and drop or browse to choose files',
              icon: Icons.add_photo_alternate_outlined,
              allowMultiple: false,
              allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
              onFilesSelected: _onFilesSelected,
            ),
            if (selectedFiles.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xl),
              // Custom filename field
              TextField(
                controller: _fileNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Output File Name',
                  hintText: 'e.g. MyImage.jpg',
                  prefixIcon: Icon(Icons.drive_file_rename_outline),
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final path = selectedFiles[index];
                  final fileName = path.split('/').last;
                  return ListTile(
                    leading: const Icon(Icons.image, color: Colors.blue),
                    title: Text(fileName),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          selectedFiles.removeAt(index);
                        });
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpacing.xxl),
              CustomButton(
                text: 'Process Image',
                onPressed: _processFiles,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
