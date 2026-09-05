import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/animated_app_bar.dart';
import '../../../../shared/widgets/web_constrained_box.dart';
import '../../../../features/pdf/presentation/widgets/file_picker_widget.dart';
import 'full_image_editor_screen.dart';
import 'package:path/path.dart' as path;

class ImageEditorDashboardScreen extends ConsumerStatefulWidget {
  const ImageEditorDashboardScreen({super.key});

  @override
  ConsumerState<ImageEditorDashboardScreen> createState() => _ImageEditorDashboardScreenState();
}

class _ImageEditorDashboardScreenState extends ConsumerState<ImageEditorDashboardScreen> {
  List<String> _selectedFiles = [];

  void _onFilesSelected(List<String> paths) {
    setState(() {
      _selectedFiles.addAll(paths);
      _selectedFiles = _selectedFiles.toSet().toList();
    });
  }

  void _removeFile(int index) {
    setState(() {
      _selectedFiles.removeAt(index);
    });
  }

  Future<void> _pickMoreFiles() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
      allowMultiple: true,
    );
    if (result.isNotEmpty) {
      final validPaths = result.map((e) => e.path).whereType<String>().toList();
      _onFilesSelected(validPaths);
    }
  }

  void _openEditor(int index) async {
    // Open the Pro Image Editor screen
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FullImageEditorScreen(
          imagePath: _selectedFiles[index],
        ),
      ),
    );

    if (result != null && result is String) {
      // It was saved to a new path or same path
      setState(() {
        _selectedFiles[index] = result;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image saved successfully!'), backgroundColor: Colors.green),
      );
    } else if (result != null && result is Map<String, dynamic>) {
       // Handle "Apply All" if that's what was returned
       final editedPath = result['path'] as String;
       final historyBytes = result['history'];

       setState(() {
         _selectedFiles[index] = editedPath;
       });

       // Now we apply to all others
       if (historyBytes != null) {
          _applyToAll(historyBytes, index);
       }
    }
  }

  Future<void> _applyToAll(dynamic historyState, int sourceIndex) async {
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Applying edits to all images...'), backgroundColor: Colors.blue),
    );
    // Background processing logic using pro_image_editor background generation will go here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AnimatedAppBar(
        title: 'Image Edits',
        actions: [
          if (_selectedFiles.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add_to_photos),
              onPressed: _pickMoreFiles,
              tooltip: 'Add more images',
            ),
        ],
      ),
      body: WebConstrainedBox(
        maxWidth: 800,
        child: _selectedFiles.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(AppSpacing.xxl),
                  child: FilePickerWidget(
                    title: 'Select Images to Edit',
                    subtitle: 'Choose images to crop, draw, and filter',
                    icon: Icons.edit_document,
                    allowMultiple: true,
                    allowedExtensions: const ['jpg', 'jpeg', 'png', 'webp', 'bmp', 'gif'],
                    onFilesSelected: _onFilesSelected,
                  ),
                ),
              )
            : ListView.builder(
                padding: EdgeInsets.all(AppSpacing.lg),
                itemCount: _selectedFiles.length,
                itemBuilder: (context, index) {
                  final p = _selectedFiles[index];
                  final name = path.basename(p);
                  final ext = path.extension(p).replaceAll('.', '').toUpperCase();

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Hero(
                        tag: p,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: Image.file(
                            File(p),
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text('Type: $ext'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openEditor(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeFile(index),
                          ),
                        ],
                      ),
                      onTap: () => _openEditor(index),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
