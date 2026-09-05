import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../../pdf/presentation/widgets/file_picker_widget.dart';
import '../../../pdf/presentation/widgets/progress_dialog.dart';
import '../../../../core/services/download_location_service.dart';
import '../../../../core/services/history_service.dart';
import 'package:path/path.dart' as path;
import 'package:pdfx/pdfx.dart' as pdfx;
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';

class PdfToImageScreen extends ConsumerStatefulWidget {
  const PdfToImageScreen({super.key});

  @override
  ConsumerState<PdfToImageScreen> createState() => _PdfToImageScreenState();
}

class _PdfToImageScreenState extends ConsumerState<PdfToImageScreen> {
  final List<String> _pdfPaths = [];
  final TextEditingController _fileNameCtrl = TextEditingController();
  bool _isGridView = false;
  String _imageQuality = 'normal'; // low, normal, high
  String _imageFormat = 'jpg'; // jpg, png, webp
  String _saveFormat = 'zip'; // zip, folder

  @override
  void dispose() {
    _fileNameCtrl.dispose();
    super.dispose();
  }

  void _onFilesSelected(List<String> paths) {
    setState(() {
      _pdfPaths.addAll(paths);
    });
    if (_pdfPaths.isNotEmpty && _fileNameCtrl.text.isEmpty) {
      _fileNameCtrl.text = '${path.basenameWithoutExtension(_pdfPaths.first)}_images';
    }
  }

  void _removeFile(int index) {
    setState(() {
      _pdfPaths.removeAt(index);
    });
  }

  Future<void> _pickMoreFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    if (result.isNotEmpty) {
      final paths = result.map((e) => e.path).whereType<String>().toList();
      _onFilesSelected(paths);
    }
  }

  Future<void> _generateImages() async {
    if (_pdfPaths.isEmpty) return;

    String baseName = _fileNameCtrl.text.trim();
    if (baseName.isEmpty) {
      if (_pdfPaths.length == 1) {
        baseName = path.basenameWithoutExtension(_pdfPaths.first);
      } else {
        baseName = 'FlexiConverted_PDF-IMG';
      }
    }
    
    final fileName = _saveFormat == 'zip' ? '$baseName.zip' : baseName;
    final outputPath = await DownloadLocationService.getOutputPath(context, ref, fileName);
    if (outputPath == null) return;

    if (mounted) ProgressDialog.show(context, message: 'Converting PDF to Images...');

    try {
      final archive = Archive();
      
      // Determine quality settings
      int renderScale = 1;
      int saveQuality = 80;
      if (_imageQuality == 'low') {
        renderScale = 1;
        saveQuality = 50;
      } else if (_imageQuality == 'high') {
        renderScale = 2; // Render at 2x resolution
        saveQuality = 100;
      }

      pdfx.PdfPageImageFormat format = pdfx.PdfPageImageFormat.jpeg;
      if (_imageFormat == 'png') format = pdfx.PdfPageImageFormat.png;
      if (_imageFormat == 'webp') format = pdfx.PdfPageImageFormat.webp;

      for (final pdfPath in _pdfPaths) {
        final pdfName = path.basenameWithoutExtension(pdfPath);
        final bytes = await File(pdfPath).readAsBytes();
        final doc = await pdfx.PdfDocument.openData(bytes);
        
        for (int i = 1; i <= doc.pagesCount; i++) {
          final page = await doc.getPage(i);
          final img = await page.render(
            width: page.width * renderScale,
            height: page.height * renderScale,
            format: format,
          );
          
          if (img != null) {
            String entryName = '';
            if (_pdfPaths.length == 1) {
              entryName = 'page_$i.$_imageFormat';
            } else {
              entryName = '$pdfName/page_$i.$_imageFormat';
            }

            if (_saveFormat == 'zip') {
              archive.addFile(ArchiveFile(entryName, img.bytes.length, img.bytes));
            } else {
              // Save to folder directly
              final dir = Directory(outputPath);
              if (!await dir.exists()) await dir.create(recursive: true);
              
              if (_pdfPaths.length > 1) {
                final subDir = Directory(path.join(outputPath, pdfName));
                if (!await subDir.exists()) await subDir.create(recursive: true);
                final file = File(path.join(subDir.path, 'page_$i.$_imageFormat'));
                await file.writeAsBytes(img.bytes);
              } else {
                final file = File(path.join(outputPath, entryName));
                await file.writeAsBytes(img.bytes);
              }
            }
          }
          await page.close();
        }
        await doc.close();
      }

      if (_saveFormat == 'zip') {
        final zipEncoder = ZipEncoder();
        final zipData = zipEncoder.encode(archive);
        final file = File(outputPath);
        await file.writeAsBytes(zipData);
      }

      if (mounted) {
        ProgressDialog.hide(context);
        await HistoryService.logConversion(
          fileName: fileName,
          toolType: 'pdfToJpg',
          status: 'success',
          outputPath: outputPath,
          durationMs: 0,
        );
        final toolPath = '/home/document/pdfToJpg';
        context.go('${RouteConstants.completed}?from=${Uri.encodeComponent(toolPath)}');
      }
    } on PlatformException {
      if (mounted) {
        ProgressDialog.hide(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open PDF. The file may be password-protected, corrupted, or unsupported.'),
            backgroundColor: Colors.red,
          ),
        );
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
        title: 'PDF to Image',
        actions: [
          if (_pdfPaths.isNotEmpty)
            IconButton(
              icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => _isGridView = !_isGridView),
            ),
          if (_pdfPaths.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_to_photos),
              onPressed: _pickMoreFiles,
            ),
        ],
      ),
      body: WebConstrainedBox(
        maxWidth: 1200,
        child: _pdfPaths.isEmpty ? _buildUploadState() : _buildWorkspace(context),
      ),
    );
  }

  Widget _buildUploadState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxl),
        child: FilePickerWidget(
          title: 'Select PDF files',
          subtitle: 'Choose one or more PDFs to convert',
          icon: Icons.picture_as_pdf,
          allowMultiple: true,
          allowedExtensions: const ['pdf'],
          onFilesSelected: _onFilesSelected,
        ),
      ),
    );
  }

  Widget _buildWorkspace(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    
    final content = Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: _isGridView
                ? GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: isDesktop ? 4 : 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, // Standard paper aspect ratio
                    ),
                    itemCount: _pdfPaths.length,
                    itemBuilder: (context, index) {
                      return _PdfThumbnailCard(
                        key: ValueKey(_pdfPaths[index]),
                        pdfPath: _pdfPaths[index],
                        onRemove: () => _removeFile(index),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: _pdfPaths.length,
                    itemBuilder: (context, index) {
                      final p = _pdfPaths[index];
                      final name = path.basename(p);
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                          title: Text(name),
                          trailing: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeFile(index),
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
          Text('PDF to Image options', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: AppSpacing.xl),
          
          Text('Image quality', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildSelectBox('low', 'Low', Icons.compress, _imageQuality, (v) => setState(() => _imageQuality = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('normal', 'Normal', Icons.check_circle_outline, _imageQuality, (v) => setState(() => _imageQuality = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('high', 'High', Icons.high_quality, _imageQuality, (v) => setState(() => _imageQuality = v))),
            ],
          ),
          SizedBox(height: AppSpacing.xl),

          Text('Image format', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          DropdownButtonFormField<String>(
            initialValue: _imageFormat,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: const [
              DropdownMenuItem(value: 'jpg', child: Text('JPG')),
              DropdownMenuItem(value: 'png', child: Text('PNG')),
              DropdownMenuItem(value: 'webp', child: Text('WEBP')),
            ],
            onChanged: (v) => setState(() => _imageFormat = v!),
          ),
          SizedBox(height: AppSpacing.xl),

          Text('Output format', style: Theme.of(context).textTheme.titleSmall),
          SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: _buildSelectBox('zip', 'ZIP file', Icons.folder_zip, _saveFormat, (v) => setState(() => _saveFormat = v))),
              SizedBox(width: AppSpacing.sm),
              Expanded(child: _buildSelectBox('folder', 'Folder', Icons.folder, _saveFormat, (v) => setState(() => _saveFormat = v))),
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
            text: 'Convert to Image',
            icon: Icons.arrow_circle_right_outlined,
            onPressed: _generateImages,
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

class _PdfThumbnailCard extends StatefulWidget {
  final String pdfPath;
  final VoidCallback onRemove;

  const _PdfThumbnailCard({super.key, required this.pdfPath, required this.onRemove});

  @override
  _PdfThumbnailCardState createState() => _PdfThumbnailCardState();
}

class _PdfThumbnailCardState extends State<_PdfThumbnailCard> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    try {
      final bytes = await File(widget.pdfPath).readAsBytes();
      final doc = await pdfx.PdfDocument.openData(bytes);
      final page = await doc.getPage(1);
      final img = await page.render(width: page.width, height: page.height, format: pdfx.PdfPageImageFormat.jpeg);
      if (img != null) {
        if (mounted) setState(() { _thumbnailBytes = img.bytes; _isLoading = false; });
      } else {
        if (mounted) setState(() { _hasError = true; _isLoading = false; });
      }
      await page.close();
      await doc.close();
    } catch (e) {
      if (mounted) setState(() { _hasError = true; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_hasError || _thumbnailBytes == null)
            const Center(child: Icon(Icons.error, color: Colors.red, size: 40))
          else
            Image.memory(_thumbnailBytes!, fit: BoxFit.cover),
          Positioned(
            top: 4,
            right: 4,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black54,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.close, size: 16, color: Colors.white),
                onPressed: widget.onRemove,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                path.basename(widget.pdfPath),
                style: const TextStyle(color: Colors.white, fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

