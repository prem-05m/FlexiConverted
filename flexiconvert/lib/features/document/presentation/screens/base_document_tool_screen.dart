import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../domain/models/document_task_model.dart';
import '../providers/document_task_provider.dart';
// Note: we can reuse the generic file picker and progress dialog from PDF feature or shared folder.
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';

class BaseDocumentToolScreen extends ConsumerStatefulWidget {
  final DocumentToolType toolType;

  const BaseDocumentToolScreen({super.key, required this.toolType});

  @override
  ConsumerState<BaseDocumentToolScreen> createState() => _BaseDocumentToolScreenState();
}

class _BaseDocumentToolScreenState extends ConsumerState<BaseDocumentToolScreen> {
  List<String> selectedFiles = [];
  final TextEditingController _fileNameCtrl = TextEditingController();

  String get _title {
    return widget.toolType.name
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .replaceFirst(RegExp(r'^[a-z]'), widget.toolType.name[0].toUpperCase());
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
      final inputName = path.basenameWithoutExtension(paths.first);
      String ext = 'pdf';
      switch (widget.toolType) {
        case DocumentToolType.pdfToWord: ext = 'docx'; break;
        case DocumentToolType.pdfToPpt: ext = 'pptx'; break;
        case DocumentToolType.pdfToExcel: ext = 'xlsx'; break;
        case DocumentToolType.csvToExcel: ext = 'xlsx'; break;
        default: ext = 'pdf';
      }
      _fileNameCtrl.text = '$inputName.$ext';
    }
  }

  Future<void> _processFiles() async {
    if (selectedFiles.isEmpty) return;

    String rawName = _fileNameCtrl.text.trim();
    if (rawName.isEmpty) rawName = 'FlexiConvert_Doc.pdf';
    final fileName = rawName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    ref.read(documentTaskProvider.notifier).initializeTask(widget.toolType, selectedFiles);
    
    if (mounted) ProgressDialog.show(context, message: 'Processing document...');

    final startTime = DateTime.now();

    await ref.read(documentTaskProvider.notifier).executeTask(
      outputPath: outputPath,
      additionalParams: {}
    );

    final duration = DateTime.now().difference(startTime).inMilliseconds;

    if (mounted) {
      ProgressDialog.hide(context);
      
      final state = ref.read(documentTaskProvider);

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
        final toolPath = '/home/document/${widget.toolType.name}';
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
      }
    }
  }
  List<String> get _allowedExtensions {
    switch (widget.toolType) {
      case DocumentToolType.wordToPdf:
        return ['doc', 'docx'];
      case DocumentToolType.pptToPdf:
        return ['ppt', 'pptx'];
      case DocumentToolType.excelToPdf:
        return ['xls', 'xlsx'];
      case DocumentToolType.pdfToWord:
      case DocumentToolType.pdfToPpt:
      case DocumentToolType.pdfToExcel:
      default:
        return ['pdf'];
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
              title: 'Upload your document',
              subtitle: 'Drag and drop or browse to choose files',
              icon: Icons.upload_file,
              allowMultiple: false,
              allowedExtensions: _allowedExtensions,
              onFilesSelected: _onFilesSelected,
            ),
            if (selectedFiles.isNotEmpty) ...[
              SizedBox(height: AppSpacing.xxl),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: selectedFiles.length,
                itemBuilder: (context, index) {
                  final path = selectedFiles[index];
                  final fileName = path.split('/').last;
                  return ListTile(
                    leading: const Icon(Icons.description, color: Colors.blue),
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
              SizedBox(height: AppSpacing.lg),
              TextField(
                controller: _fileNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Output File Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_document),
                ),
              ),
              SizedBox(height: AppSpacing.xxl),
              CustomButton(
                text: 'Process Document',
                onPressed: _processFiles,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
