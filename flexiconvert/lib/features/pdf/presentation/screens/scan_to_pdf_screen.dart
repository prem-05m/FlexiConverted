import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';
import 'package:pdf/pdf.dart' as pw_core;
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../domain/models/pdf_task_model.dart';
import '../widgets/progress_dialog.dart';
import 'image_editor_screen.dart';

class ScanToPdfScreen extends ConsumerStatefulWidget {
  const ScanToPdfScreen({super.key});

  @override
  ConsumerState<ScanToPdfScreen> createState() => _ScanToPdfScreenState();
}

class _ScanToPdfScreenState extends ConsumerState<ScanToPdfScreen> {
  final List<File> _scannedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool get _isAndroid => !kIsWeb && Platform.isAndroid;

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 90);
    if (picked == null) return;

    // Open the editor
    final editedFile = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => ImageEditorScreen(imageFile: File(picked.path)),
      ),
    );

    if (editedFile != null && mounted) {
      setState(() => _scannedImages.add(editedFile));
    }
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Select Source', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF1A73E8),
                  child: Icon(Icons.photo_library, color: Colors.white),
                ),
                title: const Text('Gallery'),
                subtitle: const Text('Choose from your photos'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF34A853),
                  child: Icon(Icons.camera_alt, color: Colors.white),
                ),
                title: const Text('Camera'),
                subtitle: const Text('Take a new photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPdf() async {
    if (_scannedImages.isEmpty) return;

    const fileName = 'FlexiConvert_Scan.pdf';
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    if (mounted) ProgressDialog.show(context, message: 'Creating PDF...');

    try {
      final pdf = pw.Document();

      for (final imgFile in _scannedImages) {
        final bytes = await imgFile.readAsBytes();
        final img = pw.MemoryImage(bytes);
        pdf.addPage(
          pw.Page(
            pageFormat: pw_core.PdfPageFormat(img.width!.toDouble(), img.height!.toDouble()),
            build: (pw.Context ctx) => pw.Center(child: pw.Image(img)),
          ),
        );
      }

      final pdfBytes = await pdf.save();
      await File(outputPath).writeAsBytes(pdfBytes);

      await HistoryService.logConversion(
        fileName: fileName,
        toolType: PdfToolType.scanToPdf.name,
        status: 'success',
        outputPath: outputPath,
        durationMs: 0,
      );

      if (mounted) {
        ProgressDialog.hide(context);
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent('/home/pdf/scanToPdf')}');
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
    // Show "better on Android" for web/Windows
    if (!_isAndroid) {
      return Scaffold(
        appBar: const AnimatedAppBar(title: 'Scan to PDF'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 24),
                Text(
                  'Available on Android',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Scan to PDF is optimized for Android devices.\nFor the best experience, use the FlexiConvert app on your Android phone.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AnimatedAppBar(
        title: 'Scan to PDF',
        actions: _scannedImages.isNotEmpty
            ? [
                TextButton.icon(
                  onPressed: _showSourcePicker,
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.white),
                  label: const Text('Add', style: TextStyle(color: Colors.white)),
                ),
              ]
            : null,
      ),
      body: _scannedImages.isEmpty
          ? _buildEmptyState()
          : _buildImageGrid(),
      bottomNavigationBar: _scannedImages.isNotEmpty
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CustomButton(
                  text: 'Create PDF (${_scannedImages.length} page${_scannedImages.length > 1 ? 's' : ''})',
                  onPressed: _createPdf,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.document_scanner, size: 80, color: Colors.teal.shade300),
            const SizedBox(height: 24),
            Text(
              'Scan Documents to PDF',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Take photos or select images from your gallery, edit them, and combine into a PDF.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _showSourcePicker,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Add First Page'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageGrid() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Drag to reorder pages',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          ReorderableGridView.builder(
            dragWidgetBuilder: _dragWidgetBuilder,
            onDragStart: (_) => HapticFeedback.lightImpact(),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: _scannedImages.length,
            onReorder: (oldIdx, newIdx) {
              setState(() {
                final item = _scannedImages.removeAt(oldIdx);
                _scannedImages.insert(newIdx, item);
              });
            },
            itemBuilder: (ctx, index) {
              final img = _scannedImages[index];
              return Card(
                key: ValueKey(img.path),
                clipBehavior: Clip.antiAlias,
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(img, fit: BoxFit.cover),
                    // Page number badge
                    Positioned(
                      bottom: 0, left: 0, right: 0,
                      child: Container(
                        color: Colors.black54,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          'Page ${index + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    // Remove button
                    Positioned(
                      top: 6, right: 6,
                      child: GestureDetector(
                        onTap: () => setState(() => _scannedImages.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.close, color: Colors.white, size: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dragWidgetBuilder(int index, Widget child) {
    return Transform.scale(
      scale: 0.9,
      child: Opacity(
        opacity: 0.6,
        child: Material(
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}
