import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import 'image_editor_screen.dart';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class ImageToPdfScreen extends ConsumerStatefulWidget {
  const ImageToPdfScreen({super.key});

  @override
  ConsumerState<ImageToPdfScreen> createState() => _ImageToPdfScreenState();
}

class _ImageToPdfScreenState extends ConsumerState<ImageToPdfScreen> {
  final List<String> _imagePaths = [];
  final TextEditingController _fileNameCtrl = TextEditingController();
  String _orientation = 'portrait';
  String _pageSize = 'a4';
  String _margin = 'none';

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    super.dispose();
  }

  void _onFilesSelected(List<String> paths) {
    setState(() {
      _imagePaths.addAll(paths);
    });
    if (_imagePaths.isNotEmpty && _fileNameCtrl.text.isEmpty) {
      _fileNameCtrl.text = '${path.basenameWithoutExtension(_imagePaths.first)}.pdf';
    }
  }

  Future<void> _pickMoreFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
    );
    if (result.isNotEmpty) {
      final paths = result.map((e) => e.path).whereType<String>().toList();
      _onFilesSelected(paths);
    }
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  Future<void> _generatePdf() async {
    if (_imagePaths.isEmpty) return;

    String rawName = _fileNameCtrl.text.trim();
    if (rawName.isEmpty) rawName = 'FlexiConverted_Img-PDF.pdf';
    if (!rawName.toLowerCase().endsWith('.pdf')) rawName += '.pdf';
    final fileName = rawName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    if (mounted) ProgressDialog.show(context, message: 'Generating PDF...');

    try {
      final pdf = pw.Document();
      
      PdfPageFormat format;
      switch (_pageSize) {
        case 'letter': format = PdfPageFormat.letter; break;
        case 'fit': format = PdfPageFormat.undefined; break; // Handled dynamically
        case 'a4':
        default: format = PdfPageFormat.a4; break;
      }

      if (_pageSize != 'fit' && _orientation == 'landscape') {
        format = format.landscape;
      }

      double marginValue = 0.0;
      if (_margin == 'small') marginValue = 15.0;
      if (_margin == 'big') marginValue = 30.0;

      for (final path in _imagePaths) {
        final imageBytes = await File(path).readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        
        final decodedImage = img.decodeImage(imageBytes);
        final imgWidth = decodedImage?.width.toDouble() ?? 400;
        final imgHeight = decodedImage?.height.toDouble() ?? 400;

        PdfPageFormat pageFormat = format;
        if (_pageSize == 'fit') {
          pageFormat = PdfPageFormat(imgWidth, imgHeight, marginAll: marginValue);
        }

        pdf.addPage(
          pw.Page(
            pageFormat: pageFormat,
            margin: pw.EdgeInsets.all(marginValue),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(image),
              );
            },
          ),
        );
      }

      final file = File(outputPath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        ProgressDialog.hide(context);
        await HistoryService.logConversion(
          fileName: fileName,
          toolType: 'imageToPdf',
          status: 'success',
          outputPath: outputPath,
          durationMs: 0,
        );
        final toolPath = '/home/document/jpgToPdf';
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
      }
    } catch (e) {
      if (mounted) {
        ProgressDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar(
        title: 'Image to PDF',
        actions: [
          if (_imagePaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_photo_alternate),
              onPressed: _pickMoreFiles,
            ),
        ],
      ),
      body: WebConstrainedBox(
        maxWidth: 1200,
        child: _imagePaths.isEmpty ? _buildUploadState() : _buildWorkspace(context),
      ),
    );
  }

  Widget _buildUploadState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: FilePickerWidget(
          title: 'Select Images',
          subtitle: 'JPG, PNG, WEBP files allowed',
          icon: Icons.image,
          allowMultiple: true,
          allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp'],
          onFilesSelected: _onFilesSelected,
        ),
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    double gridRatio = 0.8;
    if (_pageSize != 'fit') {
      gridRatio = _orientation == 'portrait' ? 0.707 : 1.414;
    } else {
      gridRatio = 1.0;
    }

    final content = Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: ReorderableGridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isDesktop ? 3 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: gridRatio,
              ),
              itemCount: _imagePaths.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  final element = _imagePaths.removeAt(oldIndex);
                  _imagePaths.insert(newIndex, element);
                });
              },
              itemBuilder: (context, index) {
                final path = _imagePaths[index];
                return GestureDetector(
                  key: ValueKey(path),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageEditorScreen(imageFile: File(path)),
                      ),
                    );
                    if (result != null && result is File) {
                      setState(() {
                        _imagePaths[index] = result.path;
                      });
                    }
                  },
                  child: Card(
                    elevation: 4,
                    clipBehavior: Clip.antiAlias,
                    color: Colors.grey.shade200,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            double marginVal = 0.0;
                            if (_margin == 'small') marginVal = constraints.maxWidth * 0.05;
                            if (_margin == 'big') marginVal = constraints.maxWidth * 0.10;
                            return Container(
                              color: Colors.white, // Paper background
                              padding: EdgeInsets.all(marginVal),
                              child: kIsWeb
                                  ? Image.network(path, fit: BoxFit.contain)
                                  : Image.file(File(path), fit: BoxFit.contain),
                            );
                          },
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.close, size: 16, color: Colors.white),
                              onPressed: () => _removeImage(index),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          left: 4,
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 12, color: Colors.white)),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.black54,
                            child: const Icon(Icons.edit, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );

    final optionsPanel = Container(
      width: isDesktop ? 320 : double.infinity,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      padding: EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min, // For mobile
        children: [
          Text('Image to PDF options', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: AppSpacing.xl),
          
          Text('Page orientation', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildSelectBox('portrait', 'Portrait', Icons.portrait, _orientation, (v) => setState(() => _orientation = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('landscape', 'Landscape', Icons.landscape, _orientation, (v) => setState(() => _orientation = v))),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          Text('Page size', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _pageSize,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'a4', child: Text('A4 (297x210 mm)')),
              DropdownMenuItem(value: 'letter', child: Text('US Letter (279x215 mm)')),
              DropdownMenuItem(value: 'fit', child: Text('Fit (same as image size)')),
            ],
            onChanged: (v) => setState(() => _pageSize = v!),
          ),
          SizedBox(height: AppSpacing.xl),

          Text('Margin', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildSelectBox('none', 'No margin', Icons.crop_square, _margin, (v) => setState(() => _margin = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('small', 'Small', Icons.padding, _margin, (v) => setState(() => _margin = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('big', 'Big', Icons.margin, _margin, (v) => setState(() => _margin = v))),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          Text('Output File Name', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _fileNameCtrl,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.edit_document),
            ),
          ),
          
          if (isDesktop) const Spacer() else SizedBox(height: AppSpacing.xxl),
          CustomButton(
            text: 'Convert to PDF',
            icon: Icons.arrow_circle_right_outlined,
            onPressed: _generatePdf,
          ),
        ],
      ),
    );

    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 3, child: content),
          optionsPanel,
        ],
      );
    } else {
      return Column(
        children: [
          Expanded(child: content),
          optionsPanel,
        ],
      );
    }
  }

  Widget _buildSelectBox(String value, String label, IconData icon, String groupValue, Function(String) onChanged) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: 2),
          borderRadius: BorderRadius.circular(8),
          color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1) : Colors.transparent,
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
